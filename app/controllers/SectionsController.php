<?php

use Infolot\Utilities;
use \Phalcon\Mvc\View;

class SectionsController extends ControllerBase
{
    public function initialize()
    {
        parent::initialize();

        $actual_link = "http://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";
        $parsed_link = explode('/', $actual_link);
        $server_name = $_SERVER['SERVER_NAME'];
        try {
            $server_name = idn_to_ascii($server_name);
        } catch (\Error $e) {
        }
        if (!is_string($_SERVER['REQUEST_URI']) || strlen($_SERVER['REQUEST_URI']) < 2) {
            $community_exists = false;
        } else {
            $community_exists = file_exists($community_path = $this->config->get('application')->admonsDir . $server_name . '/communities' . $_SERVER['REQUEST_URI'] . '.ini');
        }

        if ($parsed_link[3] != "venta-participaciones" && $parsed_link[3] != "carrito-comunidad" && !$community_exists && isset($this->config->datosAdmon->media) && isset($this->config->datosAdmon->media->header)) {
            $this->view->setVar('is_admon_header', true);
        }
    }

    public function botesAction()
    {
        //$response_object = $this->getRestful('proximos-botes', 'POST');
        $response_object = json_decode(json_encode($this->getDI()->getShared('infonextjackpots')), true);
        $jackpots = [];
        foreach ($response_object as $r) {
            $myDateTime = DateTime::createFromFormat('Y-m-d', $r['date']);
            if ($myDateTime) {
                $r['date_formatted'] = $myDateTime->format('d-m-Y');
            }

            $jackpots[$r['id_game']] = (object)$r;
        }

        /* TODO por quitar pre-webhooks */
        //$this->view->response_object = $response_object->body->data;
        $this->view->games = $this->getDI()->getShared('getgames');
        $this->view->jackpots = $jackpots;

        $this->view->header_title = "Botes";
        $this->view->active_menu = "botes";
        $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
    }

    public function ventaParticipacionesWithKeywordAction()
    {
        $di = \Phalcon\Di\Di::getDefault();
        $keyword = $di->get("router")->getMatchedRoute()->getName();
        $server_name = $_SERVER['SERVER_NAME'];
        $this->view->showMenu = false;
        $this->view->class_css_main = 'container-fluid';

        // $path = $this->config->get('application')->admonsDir . $server_name . '/communities/' . $keyword . '.ini';

        $active_community = false;
        $active_play = false;
        $selected_community_index = -1;

        $communityCacheKey = $this->config->cache->base_config_key . Utilities::getServerName() . '_communities_' . $keyword;
        
        if ($this->cache->has($communityCacheKey)) {
            $community_info = $this->cache->get($communityCacheKey);
            // $community_info = file_get_contents($path);

            // $community_info = json_decode($community_info, true);

            if ($community_info) {
                $active_community = $community_info['data']['is_active'];
                $community_uuid = ((object)$community_info["data"])->uuid;
                $response_object = Utilities::getNewRestful('get-community-plays', 'POST', array('uuid' => $community_uuid))->body->data;
                $community_plays = $response_object;
                if ($community_plays) {
                    foreach ($community_plays as $i => $community_play) {
                        if ($community_play->is_active /* && $community_play->date_end > date("Y-m-d H:i:s")*/) {
                            $active_play = true;
                            if ($community_play->date_end > date("Y-m-d H:i:s") && $selected_community_index == -1) {
                                $selected_community_index = $i;
                            }
                        }
                        $community_play->products = json_decode(json_encode($community_play->products), true);
                    }
                }
            }
        } else {
            $community_info = false;
        }

        // si la entidad no esta activa o no hay campañas
        $is_active = $active_community && $active_play;

        if ($selected_community_index == -1) {
            $selected_community_index = 0;
        }

        $this->view->header_title = "Venta Participaciones";
        $this->view->is_active = $is_active;
        $this->view->ahora = date("Y-m-d H:i:s");
        $this->view->community_info = $community_info ? (object)$community_info["data"] : false;
        $this->view->community_plays = $community_plays ? $community_plays : false;
        $this->view->selected_community_index = $selected_community_index;

        foreach ($community_plays as $play) {
            // se sacan los decimos disponibles de LN
            if ($play->products[$this->idLn]) {
                $countProducts = 0;
                foreach ($play->products[$this->idLn]['numbers'] as $drawNumbers) {
                    $countProducts += count($drawNumbers);
                }

                foreach (array_keys($play->products[$this->idLn]['draw']) as $drawId) {
                    // ahora se reciben sorteos pasados
                    if (!is_null($play->products[$this->idLn]['draw'][$drawId])) {
                        $drawInfo = $play->products[$this->idLn]['draw'][$drawId];
                        $precio[$drawId] = $drawInfo['price_ticket'];
                        $drawName[$drawId] = $drawInfo['name'];
                        $date_sorteo = DateTime::createFromFormat('Y-m-d H:i:s', $drawInfo["date_draw"]);
                        $drawDateFromated[$drawId] = $date_sorteo->format('Y-m-d H:i:s');
                        $drawDate[$drawId] = date("d/m/Y", $date_sorteo->getTimestamp());

                        foreach (array_keys($play->products[$this->idLn]['numbers'][$drawId]) as $number) {
                            $buyed = 0;
                            if ($play->buyed->numbers) {
                                // total vendido de ese numero
                                $buyed = json_decode(json_encode($play->buyed->numbers), true)[$drawId][$number]['total'];
                            } else {
                                // total vendido de la jugada
                                $buyed = $play->buyed->total;
                                if ($play->is_individual) {
                                    // si solo está el total de la jugada pero se puede elegir el décimo, el precio se reparte
                                    $buyed = $buyed / $countProducts;
                                } else {
                                    $quantityNotIndividual = floor(($play->total_price_play - $buyed) / $play->price_play);
                                }
                            }

                            // nº de participaciones (precio_producto - vendido) / precio_jugada
                            // este precio solo se usa si is_individual == 1
                            if (!is_null($quantityNotIndividual)) {
                                $quantity = $quantityNotIndividual;
                                unset($quantityNotIndividual);
                            } else {
                                $quantity = floor(($play->products[$this->idLn]['numbers'][$drawId][$number] - $buyed) / ($play->price_play ? $play->price_play : $precio[$drawId]));
                            }
                            $participaciones_individuales[] = array(
                                "number" => $number,
                                "quantity" => $quantity,
                                "id_sorteo" => $drawId,
                                "uuid" => $play->uuid,
                                "draw_name" => $drawName[$drawId],
                                "draw_date" => $drawDate[$drawId],
                                "draw_date_formated" => $drawDateFromated[$drawId],
                            );
                        }
                    }
                }
            }
        }

        // si hay varios sorteos en la misma jugada se muestra el sorteo que es debajo del numero
        if ($participaciones_individuales) {
            $selected_participaciones_individuales = array_filter($participaciones_individuales, function ($v) use ($community_plays, $selected_community_index) {
                return $v['uuid'] == $community_plays[$selected_community_index]->uuid;
            });
            $this->view->selected_participaciones_individuales = $selected_participaciones_individuales;

            $drawsOnPlay = [];
            foreach ($participaciones_individuales as $value) {
                $drawsOnPlay[$value['uuid']][] = $value['id_sorteo'];
            }
            $this->view->drawsOnPlay = $drawsOnPlay;

            $this->view->participaciones_individuales = $participaciones_individuales;
        }

        $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
    }

    public function getHeaderAction()
    {
        // return file_get_contents($this->config->application->viewsDir . 'partial/header.phtml');
        $this->view->setRenderLevel(View::LEVEL_ACTION_VIEW);
        // $this->view->render($this->config->application->viewsDir . 'sections/getHeader.phtml');
        // $input = $this->getInput();
        // return Utilities::updateCommunity($input);
    }

    public function getFooterAction()
    {
        return file_get_contents($this->config->application->viewsDir . 'partial/header.phtml');
        // $input = $this->getInput();
        // return Utilities::updateCommunity($input);
    }
}
