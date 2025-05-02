<?php

use Infolot\Utilities;

class ResultsController extends ControllerBase
{
    public function initialize()
    {
        if (method_exists(parent::class, 'initialize')) {
            parent::initialize();
        }
    }

    public function genericResultadosAction()
    {
        $id_game = $this->dispatcher->getParam('id_game');
        $fecha   = $this->request->getQuery('fecha');

        $games   = (object)$this->getDI()->getShared('getgames');
        if (isset($games->{$id_game})) {
            $game = $games->{$id_game};
            $this->view->game_rules = $game;
        }
        $this->set_max_numbers($game);

        $this->view->header_title = 'Resultados '.$game->name;
        $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();

        // Valores personalizados
        if ($game->is_custom_values_per_number) {
            $tmp = json_decode($game->custom_values_per_number);
            if (strpos($tmp[0], '-') !== false) {
                $uniqueCustomValues = [];
                foreach (json_decode($game->custom_values_per_number) as $value) {
                    $uniqueCustomValues = array_merge($uniqueCustomValues, explode('-', $value));
                }
                $uniqueCustomValues = array_values(array_unique($uniqueCustomValues));
                sort($uniqueCustomValues);

                $this->view->unique_custom_values = $uniqueCustomValues;
            }
        }

        // Resultados anteriores y Jackpots
        $resultados_anteriores = json_decode(json_encode(Utilities::getResults($id_game)), true);
        if (isset($resultados_anteriores[0])) {
            $ultimo_sorteo = $resultados_anteriores[0];
            $available_dates = [];
            //Buscar resultado concreto
            if (!empty($fecha)) {
                $ultimo_sorteo = false;
                foreach ($resultados_anteriores as $r) {
                    $available_dates[] = $r['date'];
                    if ($r['date'] == $fecha) {
                        $ultimo_sorteo = $r;
                    }
                }
            } else {
                foreach ($resultados_anteriores as $r) {
                    $available_dates[] = $r['date'];
                }
            }

            $dt = new \DateTime($resultados_anteriores[0]['date']);
            $this->view->setVars([
                'sorteos'         => $resultados_anteriores,
                'sorteo'          => $ultimo_sorteo,
                'available_dates' => json_encode($available_dates),
                'fechaLarga'      => $dt->format('d-m-Y'),
                'fechaMobil'      => $dt->format('Y-m-d')
            ]);

            $response_object = json_decode(json_encode($this->getDI()->getShared('infonextjackpots')), true);
            if (!empty($response_object)) {
                $jackpots = [];
                foreach ($response_object as $r) {
                    $jackpots[$r['id_game']] = (object)$r;
                    if ($r['id_game'] == intval($id_game)) {
                        $this->view->next_jackpot = $r;
                    }
                }
            }

            $this->view->jackpots = $jackpots;
        }

        $this->select_view($game);
    }

    /**
     * Se encarga de seleccionar la vista de forma automática, en función
     * del juego
     *
     * @param     object    $game    Información del juego
     */
    private function select_view($game)
    {
        // Plantilla del juego (por id o tipo de juego)
        $template = Utilities::template_exists('results/'.$game->id) ? 'results/'.$game->id : 'results/type-'.$game->id_type;

        // Módulo de resultados (soporta distintas plantillas (ID, tipo y por defecto)
        if (Utilities::template_exists('layouts/boxs/box_results_'.$game->id)) {
            $box_results = 'layouts/boxs/box_results_'.$game->id;
        } elseif (Utilities::template_exists('layouts/boxs/box_results_type-'.$game->id_type)) {
            $box_results = 'layouts/boxs/box_results_type-'.$game->id_type;
        } else {
            $box_results = 'layouts/boxs/box_results';
        }

        $this->view->setVars([
            'css_subsection' => 'game-type-'.$game->id_type/*.' game-id-'.$game->id*/,
            'box_results'    => $box_results
        ]);

        $this->view->pick($template);
    }

    /**
     * Devuelve el número máximo de apuestas por número en una apuesta,
     * teniendo en cuenta si el juego soporta múltiples
     *
     * @param     object    $game    Objeto con la información del juego
     *
     * @return    int                Nº máximo de números por apuesta
     */
    private function set_max_numbers($game)
    {
        if ($game->is_multiple && !empty($game->multiples)) {
            $multiples  = json_decode($game->multiples);
            $max_number = 0;
            $max_extra  = 0;
            foreach ($multiples as $tmp) {
                $max_number = max($max_number, $tmp->number);
                $max_extra  = max($max_extra, $tmp->extra);
            }
        } else {
            $max_number = $game->num_number_per_bet;
            $max_extra = $game->num_extra_per_bet;
        }

        $this->view->default_max_number_per_bet = $max_number;
        if (!empty($game->num_extra_per_bet)) {
            $this->view->default_max_extra_per_bet = $max_extra;
        }
    }
}
