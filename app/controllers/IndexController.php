<?php

use Infolot\Utilities;

class IndexController extends ControllerBase
{
    public function indexAction()
    {
        $this->view->active_menu = "inicio";
        $datosAdmon = $this->config->get('datosadmon')->data;

        if ($datosAdmon->pages->portada->text) {
            $this->view->disable();
            echo $datosAdmon->pages->portada->text;
            exit();
        }

        $games = [];
        foreach ($datosAdmon->games->all as $game) {
            $code = $this->getDI()->getShared('getgames')->{$game->id}->lae->code;
            if ($code == 'LNAC') {
                continue;
            }
            $logo = $this->getDI()->getShared('getgames')->{$game->id}->logo;
            $games[$game->id] = [
                "active" => in_array($code, $datosAdmon->games->active),
                "code"   => $code,
                "name"   => $game->name,
                "logo"   => $logo,
                "id"     => $game->id,
            ];
        }

        if (BENCHMARK_ENABLED) {
            \Infolot\Benchmark::set_time('time_'.__CLASS__.'_'.__FUNCTION__.'::games', 1);
        }

        //posible redirección a domain especificado por usuario
        if ($datosAdmon && $datosAdmon->url && $datosAdmon->url->redirect) {
            return $this->response->redirect($datosAdmon->url->redirect, true, 302);
        }

        $response_object = json_decode(json_encode($this->getDI()->getShared('infonextjackpots')), true);
        $jackpots = [];

        foreach ($response_object as $r) {
            $jackpots[$r['id_game']] = $r;
        }

        $this->view->jackpots = $jackpots;
        if (BENCHMARK_ENABLED) {
            \Infolot\Benchmark::set_time('time_'.__CLASS__.'_'.__FUNCTION__.'::jackpots', 1);
        }

        $this->view->close_dates = Utilities::getCloseDateNextDraw();
        $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
        // $this->view->selae_url_with_game = 'https://juegos.loteriasyapuestas.es/CF/loginFromRetailer.do?retailerId=' . RECEPTOR_ID . '&gameId=%s';
        $this->view->games = $games;
        $this->view->lot_nac_enabled = $datosAdmon->mods->featured_ln->enabled;
        $this->view->id_featured = -1;
        // modulo de comprar loteria en el index
        if ($datosAdmon->mods->featured_ln->enabled) {
            $id_type = $datosAdmon->mods->featured_ln->id_type;
            $this->view->id_featured = $id_type;

            $proximos_sorteos_general = null;
            if ($id_type == 4) {
                $proximos_sorteos = Utilities::removeOldResults($this->getDI()->getShared('infonextdrawsnavidad'));
            } elseif ($id_type == 5) {
                $proximos_sorteos = Utilities::removeOldResults($this->getDI()->getShared('infonextdrawsnino'));
            } else {
                $proximos_sorteos = Utilities::removeOldResults($this->getDI()->getShared('infonextdrawsgeneral'));
                $proximos_sorteos_general = $proximos_sorteos;

                if ($id_type != null) {
                    $typeFilteredDraws = [];
                    foreach ($proximos_sorteos as $prox_sorteo) {
                        if ($prox_sorteo["id_type"] == $id_type) {
                            $typeFilteredDraws[] = $prox_sorteo;
                        }
                    }
                    $proximos_sorteos = $typeFilteredDraws;
                }
            }

            if (BENCHMARK_ENABLED) {
                \Infolot\Benchmark::set_time('time_'.__CLASS__.'_'.__FUNCTION__.'::proximos_sorteos', 1);
            }
            //FIX por si no hay próximos del tipo seleccionado
            /*if(!$proximos_sorteos)
            {
                $proximos_sorteos = $this->getDI()->getShared('infonextdrawsgeneral');
                $proximos_sorteos = Utilities::removeOldResults($proximos_sorteos);
                $this->view->id_featured = -1;
            }*/

            if (empty($proximos_sorteos)) {
                $this->view->info_sorteo = null;
            } else {
                if (is_null($proximos_sorteos_general)) {
                    $proximos_sorteos_general = Utilities::removeOldResults($this->getDI()->getShared('infonextdrawsgeneral'));

                    if (BENCHMARK_ENABLED) {
                        \Infolot\Benchmark::set_time('time_'.__CLASS__.'_'.__FUNCTION__.'::proximos_sorteos_general', 1);
                    }
                }

                $proximo_sorteo = $proximos_sorteos[0];

                $this->view->sorteo_id = $proximo_sorteo['id_draw'];
                $this->view->info_sorteo = $proximo_sorteo;

                if (BENCHMARK_ENABLED) {
                    \Infolot\Benchmark::set_time('time_'.__CLASS__.'_'.__FUNCTION__.'::pv-draw-numbers antes', 1);
                }

                if ($proximo_sorteo['id_draw']) {
                    $this->view->numeros_sorteo = Utilities::getRandomNumbers($proximo_sorteo['id_draw']);
                    //Utilities::getNewRestful('pv-draw-numbers', 'POST', array('id_draw' => $proximo_sorteo['id_draw'], 'limit' => 6, 'order' => 'random'))->body->data;
                }

                if (BENCHMARK_ENABLED) {
                    \Infolot\Benchmark::set_time('time_'.__CLASS__.'_'.__FUNCTION__.'::pv-draw-numbers despues', 1);
                }

                $priorityDraws = [];
                $otherDraws = [];
        
                foreach ($proximos_sorteos_general as $sorteo) {
                    //Navidad y niño primero
                    if ($sorteo['draw_type'] == "N" || $sorteo['draw_type'] == "I") {
                        $priorityDraws[] = $sorteo;
                    } else {
                        $otherDraws[] = $sorteo;
                    }
                }
        
                $proximos_sorteos_general = array_merge($priorityDraws, $otherDraws);
        
                $this->view->proximos_sorteos_5 = $proximos_sorteos_general;
            }

            if (!is_null($this->view->drawsByNameSeo)) {
                $hasFeaturedSearcher = (count(array_filter($this->view->drawsByNameSeo, function ($d) {
                    return ($d["id"] == $this->view->info_sorteo['id']);
                })) > 0);
            }
            $this->view->hasFeaturedSearcher = $hasFeaturedSearcher;
            $this->view->featuredSearcherUrl = Utilities::getSearchUrlFromIdDraw($this->view->info_sorteo["id"]);

            if (BENCHMARK_ENABLED) {
                \Infolot\Benchmark::set_time('time_'.__CLASS__.'_'.__FUNCTION__.'::mod_ln_featured_end', 1);
            }
        }
    }
}
