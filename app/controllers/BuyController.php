<?php

use Infolot\Utilities;

class BuyController extends ControllerBase
{
    public function initialize()
    {
        parent::initialize();

        $this->games = $this->config->datosadmon->data->games;
        // ej. ["EMIL" => ["id" => '1', "name" => 'Euromillon']]
        $this->gameIds = json_decode(json_encode($this->games->all), true);
        $this->limit = 30;
        $this->weeksListed = 5;
        $this->view->num_preloaded_bets = 10;
        $this->view->game_code = null;
        $this->view->game_id = null;
        $this->view->close_date = null;
        $this->view->pvCalendar = null;
        $this->view->sorteo_id = null;
        $this->view->sorteo_especial_id = null;
        $this->view->proximos_sorteos_10 = null;
        $this->view->class_css_controller = 'section-buy';

        // Clase que se asignará al container principal que contiene el contenido de la sección
        $this->view->class_css_main = 'container-fluid';
    }
    /*
        public function comprarEuromillonesAction()
        {
            $gameCode = 'EMIL';
            $this->view->game_code = $gameCode;
            $this->view->game_id = $this->gameIds[$gameCode]['id'];
            $this->view->default_max_number_per_bet = 10;
            $this->view->default_max_extra_per_bet = 5;
            if ($this->genericCompra($gameCode)) {
                $this->view->header_title = "Comprar Euromillones";
                $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
                $this->view->close_date = Utilities::getCloseDateNextDraw($this->gameIds[$gameCode]['id']);
            }
        }

        public function comprarPrimitivaAction()
        {
            $gameCode = 'LAPR';
            $this->view->game_code = $gameCode;
            $this->view->game_id = $this->gameIds[$gameCode]['id'];
            $this->view->default_max_number_per_bet = 11;
            if ($this->genericCompra($gameCode)) {
                $this->view->header_title = "Comprar Primitiva";
                $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
                $this->view->close_date = Utilities::getCloseDateNextDraw($this->gameIds[$gameCode]['id']);
            }
        }

        public function comprarGordoAction()
        {
            $gameCode = 'ELGR';
            $this->view->game_code = $gameCode;
            $this->view->game_id = $this->gameIds[$gameCode]['id'];
            $this->view->default_max_number_per_bet = 11;
            if ($this->genericCompra($gameCode)) {
                $this->view->header_title = "Comprar El Gordo";
                $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
                $this->view->close_date = Utilities::getCloseDateNextDraw($this->gameIds[$gameCode]['id']);
            }
        }

        public function comprarLototurfAction()
        {
            $gameCode = 'LOTU';
            $this->view->game_code = $gameCode;
            $this->view->game_id = $this->gameIds[$gameCode]['id'];
            $this->view->default_max_number_per_bet = 10;
            $this->view->default_max_extra_per_bet = 4;
            if ($this->genericCompra($gameCode)) {
                $this->view->header_title = "Comprar Lototurf";
                $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
                $this->view->close_date = Utilities::getCloseDateNextDraw($this->gameIds[$gameCode]['id']);
            }
        }

        public function comprarQuinielaAction()
        {
            $gameCode = 'LAQU';
            $this->view->game_code = $gameCode;
            $this->view->game_id = $this->gameIds[$gameCode]['id'];
            if ($this->genericCompra($gameCode)) {
                $this->view->header_title = "Comprar quiniela";
                $ar = [
                    "id_game" => $this->gameIds[$gameCode]['id'],
                    "limit" => $this->limit
                ];
                $jornadas = Utilities::getNewRestful('get-next-game-matches', 'POST', $ar)->body->data;
                $jornadas = json_decode(json_encode($jornadas), true);
                $holydays = array_keys(json_decode(json_encode($this->config->pvCalendar), true));
                foreach ($jornadas as $date => $jornada) {
                    if (in_array($date, $holydays)) {
                        unset($jornadas[$date]);
                    }
                }
                $this->view->jornadas = $jornadas;
                $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
                $this->view->close_date = Utilities::getCloseDateNextDraw($this->gameIds[$gameCode]['id']);
                $this->view->num_preloaded_bets = 15;
            }
        }

        public function comprarQuinigolAction()
        {
            $gameCode = 'QGOL';
            $this->view->game_code = $gameCode;
            $this->view->game_id = $this->gameIds[$gameCode]['id'];
            if ($this->genericCompra($gameCode)) {
                $this->view->header_title = "Comprar quinigol";
                $ar = [
                    "id_game" => $this->gameIds[$gameCode]['id'],
                    "limit" => $this->limit
                ];
                $jornadas = Utilities::getNewRestful('get-next-game-matches', 'POST', $ar)->body->data;
                $jornadas = json_decode(json_encode($jornadas), true);
                $holydays = array_keys(json_decode(json_encode($this->config->pvCalendar), true));
                foreach ($jornadas as $date => $jornada) {
                    if (in_array($date, $holydays)) {
                        unset($jornadas[$date]);
                    }
                }
                $this->view->jornadas = json_decode(json_encode($jornadas), true);
                $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
                $this->view->close_date = Utilities::getCloseDateNextDraw($this->gameIds[$gameCode]['id']);
                $this->view->num_preloaded_bets = 15;

                $uniqueCustomValues = [];
                foreach (json_decode($this->view->game_rules->custom_values_per_number) as $value) {
                    $uniqueCustomValues = array_merge($uniqueCustomValues, explode('-', $value));
                }
                $uniqueCustomValues = array_values(array_unique($uniqueCustomValues));
                sort($uniqueCustomValues);
                $this->view->unique_custom_values = $uniqueCustomValues;
            }
        }

        public function comprarBonolotoAction()
        {
            $gameCode = 'BONO';
            $this->view->game_code = $gameCode;
            $this->view->game_id = $this->gameIds[$gameCode]['id'];
            $this->view->default_max_number_per_bet = 11;
            if ($this->genericCompra($gameCode)) {
                $this->view->header_title = "Comprar Bonoloto";
                $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
                $this->view->close_date = Utilities::getCloseDateNextDraw($this->gameIds[$gameCode]['id']);
            }
        }
    */

    // de este se sacan los datos para todos los de arriba
    public function genericCompraAction()
    {
        $code    = $this->dispatcher->getParam('code');
        $id_type = $this->dispatcher->getParam('id_type');
        $name    = $this->dispatcher->getParam('name');
        $id_game = $this->gameIds[$code]['id'];

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
        }
        $this->view->game_code = $code;
        $this->view->game_id = $id_game;

        $games   = $this->getDI()->getShared('getgames');
        if (isset($games->{$id_game})) {
            $game = $games->{$id_game};
            // valores por defecto de los numeros y extras
            if (!$game->number_name) {
                $game->number_name = 'números';
            }
            if (!$game->extra_name) {
                $game->extra_name = 'extras';
            }
            if ($game->id_days) {
                $game->id_days = explode(',', $game->id_days);
            }
            
            if ($game->custom_values_per_number) {
                $game->custom_values_per_number = json_decode($game->custom_values_per_number);
            }

            if ($game->custom_values_per_extra) {
                $game->custom_values_per_extra = json_decode($game->custom_values_per_extra);
            }
            $this->view->game_rules = $game;
        }
        $this->set_max_numbers($game);

        if ($this->games->club_amigo_online != 1
            && $this->games->buy_online == 1
            && in_array($code, $this->games->active)
        ) {
            $this->view->header_title   = 'Comprar '.$game->name;
            $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
            $this->view->close_date     = Utilities::getCloseDateNextDraw($id_game);

            // Jackpot
            $response_object            = $this->getDI()->getShared('infonextjackpots');
            $jackpots                   = [];
            foreach ($response_object as $jackpot) {
                $parsedJackpot = (object)$jackpot;
                $jackpots[] = $parsedJackpot;
                if ($parsedJackpot->id_game == $id_game) {
                    $this->view->next_jackpot = $parsedJackpot;
                }
            }
            $this->view->jackpots = $jackpots;

            // Jornadas
            if ($game->id_type == T_GAME_APUESTAS) {
                $ar  = ['id_game' => $id_game, 'limit' => $this->limit];
                $tmp = Utilities::getNewRestful('get-next-game-matches', 'POST', $ar);
                if (!empty($tmp)) {
                    $jornadas = json_decode(json_encode($tmp->body->data), true);
                    $holydays = array_keys(json_decode(json_encode($this->config->pvCalendar), true));
                    foreach ($jornadas as $date => $jornada) {
                        if (in_array($date, $holydays)) {
                            unset($jornadas[$date]);
                        }
                    }
                    $this->view->jornadas = $jornadas;
                    $this->view->num_preloaded_bets = $this->config->games->num_preloaded_bets;
                    $this->view->first_play = (is_array($jornadas) && count($jornadas) > 0) ? $jornadas[array_keys($jornadas)[0]] : null;
                }
            }

            // Valores personalizados
            if ($game->is_custom_values_per_number) {
                if (strpos($game->custom_values_per_number[0], '-') !== false) {
                    $uniqueCustomValues = [];
                    foreach ($game->custom_values_per_number as $value) {
                        $uniqueCustomValues = array_merge($uniqueCustomValues, explode('-', $value));
                    }
                    $uniqueCustomValues = array_values(array_unique($uniqueCustomValues));
                    sort($uniqueCustomValues);

                    $this->view->unique_custom_values = $uniqueCustomValues;
                    $this->view->game_rules->is_unique_custom_values = true;
                    $this->view->game_rules->unique_custom_values = $uniqueCustomValues;
                }
            }

            $this->view->close_dates = json_decode(json_encode($this->config->datosadmon->data->games->close_dates->{$this->gameIds[$code]['id']}), true);
            $this->view->pvCalendar = json_decode(json_encode($this->config->pvCalendar), true);
            $this->view->weeks = self::getWeeks(Utilities::getFirstEnabledDay($this->gameIds[$code]['id']));

            $clean = [];
            $hasPreviousDay = false;
            $holydayText = null;

            foreach ($this->view->dayNames as $i => $day) {
                $clean[$i]["day"] = $day;
                $clean[$i]["normalizedDay"] = Utilities::removeAccents($day);
                $weekDay = strtotime('+' . $i . ' day', $this->view->weeks[0]["monday"]);
                $clean[$i]["timestamp"] = $weekDay;
                if (is_array($this->view->close_dates) && !array_key_exists($i+1, $this->view->close_dates)) {
                    $clean[$i]["holydayText"] = $holydayText;
                    // si el dia esta desactivado en la ficha del PV se miran que hayan sorteos antes y sorteos ese dia para poder jugar toda la semana
                    $clean[$i]["isEnabled"] = ($hasPreviousDay && in_array($i + 1, json_decode(json_encode($game->id_days), true)));
                    $clean[$i]["weekDay"] = date('d', $weekDay);
                    continue;
                }
                $closeTime = Utilities::getCloseDateByDayNumber($this->view->close_dates[$i+1]["close_id_day"], date('Y-m-d H:i:s', $weekDay));
                $isEnabled = false;

                if (!is_null($closeTime)) {
                    $closeTime .=  ' ' . $this->view->close_dates[$i+1]["close_hour"];
                    $closeTime = strtotime('-'.Utilities::getBestHoursNeeded($this->gameIds[$code]['id']).' hours', strtotime($closeTime));
                    $closeTime = date('Y-m-d H:i:s', $closeTime);
                    $isEnabled = (strtotime('now') < strtotime($closeTime));
                }

                $holydayText = null;

                if (isset($this->view->pvCalendar[date('Y-m-d', $weekDay)])) {
                    $holydayText = $this->view->pvCalendar[date('Y-m-d', $weekDay)];

                    // si esta dentro de la hora de cierre se comprueba que no sea un festivo
                    if ($isEnabled) {
                        // si está en el calendario de festivos y tiene un dia anterior habilitado se puede comprar
                        $isEnabled = in_array(date('Y-m-d', $weekDay), array_keys($this->view->pvCalendar)) && $hasPreviousDay;
                    }
                }

                if (!$hasPreviousDay) {
                    /**
                     * para poder habilitar un dia con festivo tiene que haber un dia activo antes para
                     * poder jugar toda la semana, como el primer dia no va a tener otro antes se pone
                     * al final de las comprobaciones mientras $hasPreviousDay sea false
                     * (no hay dias activos anteriores) se va asignando $isEnabled y una vez sea true no cambiara
                     *
                     * esto es por si hay dos festivos una misma semana, segun en dia que sea se podrá
                     * jugar a uno pero al otro no
                     */
                    $hasPreviousDay = $isEnabled;
                }

                $clean[$i]["holydayText"] = $holydayText;
                $clean[$i]["isEnabled"] = $isEnabled;
                $clean[$i]["weekDay"] = date('d', $weekDay);
            }

            $this->view->daysEnabled = $clean;

            $this->select_view($game);

            return true;
        } else {
            $this->response->redirect('');
            return false;
        }
    }
    /*
        public function loteriaNacionalAction()
        {
            $this->view->header_title = "Lotería Nacional";
            $this->getDatosLoteria();

            // FIX temporal en master para tener game_rules en la vista
            $id_game = $this->gameIds['LNAC']['id'];
            foreach ($this->getDI()->getShared('getgames') as $game) {
                if ($game->id == $id_game) {
                    // if ($game->id_days) {
                    //     $game->id_days = explode(',', $game->id_days);
                    // }
                    $this->view->game_rules = $game;
                }
            }
            $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
        }

        public function loteriaNavidadAction()
        {
            $this->view->header_title = "Lotería de Navidad";
            $this->getDatosLoteria(4);

            // FIX temporal en master para tener game_rules en la vista
            $id_game = $this->gameIds['LNAC']['id'];
            foreach ($this->getDI()->getShared('getgames') as $game) {
                if ($game->id == $id_game) {
                    // if ($game->id_days) {
                    //     $game->id_days = explode(',', $game->id_days);
                    // }
                    $this->view->game_rules = $game;
                }
            }
            $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
        }

        public function loteriaNinoAction()
        {
            $this->view->header_title = "Lotería del Niño";
            $this->getDatosLoteria(5);

            // FIX temporal en master para tener game_rules en la vista
            $id_game = $this->gameIds['LNAC']['id'];
            foreach ($this->getDI()->getShared('getgames') as $game) {
                if ($game->id == $id_game) {
                    // if ($game->id_days) {
                    //     $game->id_days = explode(',', $game->id_days);
                    // }
                    $this->view->game_rules = $game;
                }
            }
            $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
        }*/

    // de este se sacan los datos para los 3 de arriba
    // si se llama desde la pantalla principal, en ese modulo cuando le das a comprar te
    // envia aqui y esto mete los datos en el carrito y de deja en la vista del que has
    // comprado, por get no veo que se pase nada y por post se pasa esto
    // 0: {name: "idsorteo", value: "2022012"}
    // 1: {name: "iddraw", value: "1661"}
    // 2: {name: "datedraw", value: "2022-02-14 13:00:00"}
    // 3: {name: "pricedraw", value: "15"}
    // 4: {name: "84230", value: "0"}
    // 5: {name: "52047", value: "0"}
    // 6: {name: "32686", value: "0"}
    // 7: {name: "94365", value: "0"}
    // 8: {name: "61851", value: "0"}
    // 9: {name: "39752", value: "0"}
    // los numeros son los que hay en el modulo ese y el valor es la cantidad que se ha comprado
    public function getDatosLoteriaAction()
    {
        $code      = $this->dispatcher->getParam('code');
        $id_draw_t = $this->dispatcher->getParam('id_draw_t');
        $name      = $this->dispatcher->getParam('name');
        $keyword   = $this->dispatcher->getParam('keyword');

        $this->view->keyword = $keyword;

        $games   = $this->getDI()->getShared('getgames');
        $id_game = $this->gameIds[$code]['id'];
        if (isset($games->{$id_game})) {
            $game                   = $games->{$id_game};
            $this->view->game_rules = $game;
            if (is_null($keyword)) {
                $this->view->keyword = $game->keyword;
            }
        }

        $this->view->header_title = $name;
        $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();

        switch ($id_draw_t) {
            case 4:
                $proximos_sorteos = $this->getDI()->getShared('infonextdrawsnavidad');
                break;
            case 5:
                $proximos_sorteos = $this->getDI()->getShared('infonextdrawsnino');
                break;
            default:
                $proximos_sorteos = $this->getDI()->getShared('infonextdrawsgeneral');
                break;
        }

        $sorteos_filtro = [];

        $id_sorteo = null;

        if (isset($_POST['idsorteo'])) {
            $id_sorteo = $_POST['idsorteo'];
        } elseif (isset($_GET['idsorteo'])) {
            $id_sorteo = $_GET['idsorteo'];
        }

        // hora actual + tiempo de envio/pago tiene que ser menor a la hora del sorteo para mostrarse
        $hoursNeeded = Utilities::getBestHoursNeeded($this->gameIds[$code]['id']);
        foreach ($proximos_sorteos as $prox_sorteo) {
            if (strtotime($prox_sorteo['date_draw']) > strtotime("+$hoursNeeded hours")) {
                $sorteos_filtro[$prox_sorteo['id_draw']] = $prox_sorteo;
            }
        }
        $proximos_sorteos = $sorteos_filtro;

        if (empty($id_sorteo)) {
            $id_sorteo = key($proximos_sorteos);
        }

        $this->view->info_sorteo = null;
        if (isset($proximos_sorteos[$id_sorteo])) {
            $this->view->sorteo_id = $id_sorteo;
            $this->view->info_sorteo = $proximos_sorteos[$id_sorteo];
        } else {
            return $this->select_view($game);
        }

        // if (!$proximos_sorteos) {
        //     $this->view->info_sorteo = null;
        //     $this->view->sorteo_especial_id = 00000;
        //     return;
        // }
        /* Comprobación de que id_type es para coger x .ini */
        $proximo_sorteo = $proximos_sorteos[$id_sorteo];

        $this->view->searcher_url = Utilities::getSearchUrlFromIdDraw($proximo_sorteo["id"]);

        if ($id_draw_t == null) {
            $this->view->proximos_sorteos_10 = $proximos_sorteos;
        } else {
            // $id_sorteo = $proximo_sorteo->id_draw;
            $this->view->sorteo_especial_id = $id_sorteo;
            // $this->view->info_sorteo = $proximo_sorteo;
        }

        $this->view->todos = $_POST['todos'];

        // $iddraw = $_POST['iddraw'];
        // if ($iddraw == null) {
        //     $iddraw = $_GET['iddraw'];
        // }

        if ($id_draw_t == null) {
            $fecha_sorteo = $_POST['datedraw'];
            if ($fecha_sorteo == null) {
                $fecha_sorteo = $_GET['datedraw'];
            }
            $fecha_sorteo = substr($fecha_sorteo, 0, 10);
            $price = $_POST['pricedraw'];
            if ($price == null) {
                $price = $_GET['pricedraw'];
            }
        } else {
            $fecha_sorteo = $proximo_sorteo['date_draw'];
            $fecha_sorteo = substr($fecha_sorteo, 0, 10);
            $price = $proximo_sorteo['price_ticket'];
        }

        $requestBody = [
            'id_draw' => $id_sorteo,
            'order' => 'asc',
        ];


        if ($this->request->getQuery('aleatorio') == 'S' || $this->request->getPost('aleatorio') == 'S') {
            $requestBody['order'] = 'random';
            $requestBody['limit'] = 1;
        }

        $number = null;
        if (!is_null($this->request->getQuery('numero'))) {
            $number = $this->request->getQuery('numero');
        } elseif (!is_null($this->request->getPost('numero'))) {
            $number = $this->request->getPost('numero');
        }

        $this->view->number = $number;
        if (!is_null($number)) {
            if (mb_strlen($number) < 5) {
                $number = '*' . $number;
            }
            $requestBody['number'] = $number;
        }

 

        $this->view->numeros_sorteo = Utilities::getNewRestful('pv_draw_numbers', 'POST', $requestBody)->body->data;

        if (empty($this->view->numeros_sorteo) || !is_array($this->view->numeros_sorteo) || count($this->view->numeros_sorteo) < 10) {
            $this->view->cantidad_total = 0;
        } else {
            $this->view->cantidad_total = intval(ceil(count($this->view->numeros_sorteo) / 10));
        }

        // $cookie_cart = json_decode($this->cookies->get('cart_ws')->getValue(), true);
        $cookie_cart = $this->session->get('cart_ws');

        if ($cookie_cart == null || !is_array($cookie_cart)) {
            $cart = [];
        } else {
            $cart = $cookie_cart;
        }

        $param_found = false;

        // Recorrer los numeros que está jugando
        foreach ($_POST as $k => $param) {
            if (is_numeric($k)) {
                if ($param > 0) {
                    $param_found = true;
                    $num_encontrado = false;

                    // Revisar si en el carrito actual tenemos el numero que está jugando
                    for ($i = 0; $i < sizeof($cart); $i++) {
                        if ($cart[$i]["id_game"] == $this->idLn && $cart[$i]["date_draw_ini"] == $fecha_sorteo && $cart[$i]["id_draw"] == $id_sorteo && $cart[$i]["number"] == $k) {
                            $cart[$i]["quantity"] += $param;
                            $num_encontrado = true;
                        }
                    }

                    // Si no ha encontrado el numero, añadimos al carrito
                    if (!$num_encontrado) {
                        $cart[] = array(
                            "id_game" => 7,
                            "date_draw_ini" => $fecha_sorteo,
                            "is_week" => 0,
                            "is_subscription" => 0,
                            "quantity" => $param,
                            "id_draw" => $id_sorteo,
                            "number" => $k,
                            "price_ticket" => $price
                        );
                    }
                }
            }
        }

        // Recorrer los numeros que está jugando
        foreach ($_GET as $k => $param) {
            if (is_numeric($k)) {
                if ($param > 0) {
                    $param_found = true;
                    $num_encontrado = false;

                    // Revisar si en el carrito actual tenemos el numero que está jugando
                    for ($i = 0; $i < sizeof($cart); $i++) {
                        if ($cart[$i]["id_game"] == $this->idLn && $cart[$i]["date_draw_ini"] == $fecha_sorteo && $cart[$i]["id_draw"] == $id_sorteo && $cart[$i]["number"] == $k) {
                            $cart[$i]["quantity"] += $param;
                            $num_encontrado = true;
                        }
                    }

                    // Si no ha encontrado el numero, añadimos al carrito
                    if (!$num_encontrado) {
                        $cart[] = array(
                            "id_game" => 7,
                            "date_draw_ini" => $fecha_sorteo,
                            "is_week" => 0,
                            "is_subscription" => 0,
                            "quantity" => $param,
                            "id_draw" => $id_sorteo,
                            "number" => $k,
                            "price_ticket" => $price
                        );
                    }
                }
            }
        }

        if ($param_found && $this->session->has('user')) {
            if ($this->session->has("cartws_id")) {
                $arCarrito = array(
                    "id_user" => $this->session->get('user')["id"],
                    "cart" => $cart,
                    "id_cart" => $this->session->get("cartws_id")
                );

                $response = Utilities::getNewRestful('save-user-cart', 'POST', $arCarrito)->body->data;
            } else {
                $arCarrito = array(
                    "id_user" => $this->session->get('user')["id"],
                    "cart" => $cart
                );

                $response = Utilities::getNewRestful('save-user-cart', 'POST', $arCarrito)->body->data;

                if (!is_null($response)) {
                    $this->session->set("cartws_id", $response);
                }
            }
        }

        $this->session->set('cart_ws', json_decode(json_encode($cart), true));

        // $this->cookies->set(
        //     'cart_ws',
        //     json_encode($cart),
        //     time() + 15 * 86400
        // );

        $this->view->carrito_ws = $cart;

        // $this->cookies->send();

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
        $template = 'buy/'.$game->id;
        if (Utilities::template_exists($template)) {
            $this->view->pick($template);
            return;
        }

        $template = 'buy/type-'.$game->id_type;
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
        $this->view->default_max_extra_per_bet = !empty($game->num_extra_per_bet) ? $max_extra : null;
    }

    private function getWeeks($date)
    {
        setlocale(LC_TIME, 'es_ES');
        $startDate = strtotime('monday this week', strtotime($date));
        $nextWeek = $startDate;
        $weeks = [];
        $i = 0;

        for ($addedWeek = 1; $addedWeek <= $this->weeksListed; $addedWeek++) {
            $lastMonday = $nextWeek;
            $nextWeek = strtotime('+' . $addedWeek . ' week', $startDate);
            $lastSunday = strtotime('last sunday', $nextWeek);
            $weeks[$i] = [
                "week_number" => date("W", $lastMonday),
                "monday" => $lastMonday,
            ];
            if (date('m', $lastMonday) == date('m', $lastSunday)) {
                $weeks[$i]["week_text"] = date("d", $lastMonday) . '-' . date("d", $lastSunday) . ' ' . $this->view->shortMonthNames[date('n', $lastMonday) - 1] . ' ' . date('Y', $lastMonday);
            } else {
                //                        primer dia                          primer mes                                                       segundo dia                         segundo mes                                                      año del primer dia
                $weeks[$i]["week_text"] = date("d", $lastMonday) . ' ' . $this->view->shortMonthNames[date('n', $lastMonday) - 1] . '-' . date("d", $lastSunday) . ' ' . $this->view->shortMonthNames[date('n', $lastSunday) - 1] . ' ' . date('Y', $lastMonday);
            }
            $i++;
        }

        return $weeks;
    }
}
