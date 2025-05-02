<?php

use Infolot\Utilities;

class CarritoController extends ControllerBase
{
    public function initialize()
    {
        parent::initialize();

        setlocale(LC_NUMERIC, 'en_US');
    }

    public function carritoAction()
    {
        $this->view->header_title = "Carrito";
        $this->view->active_menu = "carrito";
        $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
        $user = $this->session->get('user');

        if (array_key_exists('delete', $_GET) && $_GET['delete'] != '') {

            // $cookie_cart = json_decode($this->cookies->get('cart_ws')->getValue(), true);
            $cookie_cart = $this->session->get('cart_ws');

            $index = $_GET['delete'];

            if ($index == "all") {
                $cookie_cart = [];
            } else {
                unset($cookie_cart[$index]);
                $cookie_cart = array_values($cookie_cart);
            }

            if (!$cookie_cart && $this->session->has('user')) {
                if ($this->session->has("cartws_id")) {
                    $arCarrito = array(
                        "id_user" => $user["id"],
                        "id_cart" => $this->session->get('cartws_id'),
                    );
                    $response = Utilities::getNewRestful('delete-user-cart', 'POST', $arCarrito)->body->data;

                    $this->session->remove("cartws_id");
                } else {
                    $arCarrito = array(
                        "id_user" => $user["id"],
                        "cart" => array((object)[])
                    );

                    $response = Utilities::getNewRestful('save-user-cart', 'POST', $arCarrito)->body->data;

                    if (!is_null($response)) {
                        $this->session->set("cartws_id", $response);
                    }
                }
            } elseif ($this->session->has('user')) {
                if ($this->session->has("cartws_id")) {
                    $arCarrito = array(
                        "id_user" => $user["id"],
                        "cart" => $cookie_cart,
                        "id_cart" => $this->session->get("cartws_id")
                    );

                    $response = Utilities::getNewRestful('save-user-cart', 'POST', $arCarrito)->body->data;
                } else {
                    $arCarrito = array(
                        "id_user" => $user["id"],
                        "cart" => $cookie_cart
                    );

                    $response = Utilities::getNewRestful('save-user-cart', 'POST', $arCarrito)->body->data;

                    if (!is_null($response)) {
                        $this->session->set("cartws_id", $response);
                    }
                }
            }

            $this->session->set('cart_ws', json_decode(json_encode($cookie_cart), true));

            // $this->cookies->set(
            //     'cart_ws',
            //     json_encode($cookie_cart),
            //     time() + 15 * 86400
            // );

            // $this->cookies->send();

            if (!is_array($cookie_cart) || !$cookie_cart[0] || sizeof($cookie_cart) == 0) {
                //Vaciar carrito
                // $coo = $this->cookies->get('cart_ws');
                // $coo->delete();
                $this->session->remove('cart_ws');
            }

            $this->view->carrito_ws = $cookie_cart;
        }

        $datosAdmon = $this->config->get('datosadmon');

        $pvinfo_games = $datosAdmon->data->games;

        $games = $this->getDI()->getShared('getgames');

        $hoursToFirstGame = 9999;

        $hoursToFirstShippable = 9999;

        $hoursToFirstNotShippable = 9999;

        $gameIds = [];
        $total = 0;

        if (is_array($this->view->carrito_ws) && $this->view->carrito_ws[0]) {
            $newCart = array();
            $isNewCartNeeded = 0;
            foreach ($this->view->carrito_ws as $cart_line) {
                if (array_search($cart_line["id_game"], $gameIds) === false) {
                    array_push($gameIds, $cart_line["id_game"]);
                }
                //Convert the date string into a unix timestamp.
                $unixDate = strtotime($cart_line["date_draw_ini"]);

                //Get the day of the week using PHP's date function.
                $dayOfWeek = date("N", $unixDate);

                //Para loteria nacional ignorar las horas de cierre y usar la del sorteo
                if ($cart_line["id_game"] == $this->idLn) {
                    $total += intval($cart_line['quantity']) * floatval($cart_line['price_ticket']);
                    $closeDate = null;
                    foreach ($this->getDI()->getShared('infonextdrawsgeneral') as $draw) {
                        if ($draw['id_draw'] == $cart_line["id_draw"]) {
                            $closeDate = $draw['date_draw'];
                        }
                    }

                    if (is_null($closeDate)) {
                        foreach ($this->getDI()->getShared('infonextdrawsnavidad') as $draw) {
                            if ($draw['id_draw'] == $cart_line["id_draw"]) {
                                $closeDate = $draw['date_draw'];
                            }
                        }
                    }

                    if (is_null($closeDate)) {
                        foreach ($this->getDI()->getShared('infonextdrawsnino') as $draw) {
                            if ($draw['id_draw'] == $cart_line["id_draw"]) {
                                $closeDate = $draw['date_draw'];
                            }
                        }
                    }

                    if (is_null($closeDate)) {
                        $closeDate = $cart_line["date_draw_ini"];
                    } else {
                        // 30 mins antes del sorteo
                        $closeDate = date('Y-m-d H:i:s', strtotime('-30 mins', strtotime($closeDate)));
                    }
                } elseif (property_exists($pvinfo_games->close_dates, $cart_line["id_game"]) && $pvinfo_games->close_dates->{$cart_line["id_game"]} && property_exists($pvinfo_games->close_dates->{$cart_line["id_game"]}, $dayOfWeek) && $pvinfo_games->close_dates->{$cart_line["id_game"]}->{$dayOfWeek}) {
                    $closeDate = Utilities::getCloseDateByDayNumber($pvinfo_games->close_dates->{$cart_line["id_game"]}->{$dayOfWeek}->close_id_day, $cart_line["date_draw_ini"]) . ' ' . $pvinfo_games->close_dates->{$cart_line["id_game"]}->{$dayOfWeek}->close_hour;
                } else {
                    $closeDate = $cart_line["date_draw_ini"];
                }

                if ($cart_line["id_game"] != $this->idLn) {
                    $total += $cart_line["total"];
                }

                $closeDateTime = new DateTime($closeDate);

                $now = new DateTime();

                $interval = $closeDateTime->diff($now);

                if ($interval->invert) {
                    $hours = ($interval->days * 24) + $interval->h;
                    $newCart[] = $cart_line;
                } else {
                    $isNewCartNeeded = 1;
                    //$hours = -1;
                }

                $cart_line["hours"] = $hours;

                if ($games->{$cart_line["id_game"]}) {
                    $shippable = $games->{$cart_line["id_game"]}->is_shippable;
                }

                if ($shippable == 1) {
                    if ($hours < $hoursToFirstShippable) {
                        $hoursToFirstShippable = $hours;
                    }
                } else {
                    if ($hours < $hoursToFirstNotShippable) {
                        $hoursToFirstNotShippable = $hours;
                    }
                }

                if ($hours < $hoursToFirstGame) {
                    $hoursToFirstGame = $hours;
                }
            }
        }

        if ($isNewCartNeeded) {
            $this->session->set('cart_ws', json_decode(json_encode($newCart), true));
            // $this->cookies->set(
            //     'cart_ws',
            //     json_encode($newCart),
            //     time() + 15 * 86400
            // );

            // $this->cookies->send();

            if (!is_array($newCart) || !$newCart[0] || sizeof($newCart) == 0) {
                //Vaciar carrito
                // $coo = $this->cookies->get('cart_ws');
                // $coo->delete();
                $this->session->remove('cart_ws');

                if ($this->session->has('user') && $this->session->get('cartws_id')) {
                    $arCarrito = array(
                        "id_user" => $user["id"],
                        "id_cart" => $this->session->get('cartws_id'),
                    );
                    //borrar el carrito si todos los items han expirado
                    Utilities::getNewRestful('delete-user-cart', 'POST', $arCarrito);
                }
            }

            if ($this->session->has('user')) {
                if ($this->session->has("cartws_id")) {
                    $arCarrito = array(
                        "id_user" => $user["id"],
                        "cart" => $newCart,
                        "id_cart" => $this->session->get("cartws_id")
                    );

                    $response = Utilities::getNewRestful('save-user-cart', 'POST', $arCarrito)->body->data;
                } else {
                    $arCarrito = array(
                        "id_user" => $user["id"],
                        "cart" => $newCart
                    );

                    $response = Utilities::getNewRestful('save-user-cart', 'POST', $arCarrito)->body->data;

                    if (!is_null($response)) {
                        $this->session->set("cartws_id", $response);
                    }
                }
            }

            $this->view->carrito_ws = $newCart;
        }

        $this->view->newCartNeeded = $isNewCartNeeded;
        $this->view->hoursToFirstGame = $hoursToFirstGame;
        $this->view->hoursToFirstShippable = $hoursToFirstShippable;
        $this->view->hoursToFirstNotShippable = $hoursToFirstNotShippable;

        if (is_array($user) && isset($user['id'])) {
            $userAddresses = Utilities::getNewRestful('get-user-addresses', 'POST', array('id_user' => $user['id']))->body->data;
            $userBalance = Utilities::getNewRestful('get-user-balance', 'POST', array('id_user' => $user['id']))->body->data;
        } else {
            $userAddresses = [];
            //userBalance ya está controlado en e codigo js del carrito
        }


        //$paymentMethods = $datosAdmon->data->payments;
        $shippingMethods = $datosAdmon->data->shippings;

        $gamesInfo = [];

        foreach ($games as $game) {
            // $ar = array(
            //     "id" => $game->id,
            //     "name" => $game->name,
            //     "logo" => $game->logo,
            //     "is_shippable" => $game->is_shippable,
            //     "id_type" => $game->id_type,
            // );
            $gamesInfo[$game->id] = json_decode(json_encode($game), true);
        }

        //$countries = Utilities::getNewRestful('get-countries', 'GET')->body->data;
        //$provinces = Utilities::getNewRestful('get-provinces', 'GET')->body->data;
        //$cities = Utilities::getNewRestful('get-cities', 'GET')->body->data;
        $arLocationInfo = array(
            "countries" => $this->getDI()->getShared('infocountries'),
            "provinces" => $this->getDI()->getShared('infoprovinces'),
            "cities" => $this->getDI()->getShared('infocities')
        );

        $this->view->locationInfo     = $arLocationInfo;
        $this->view->domain           = $this->config->get('baseconfig')->media_domain;
        $this->view->user             = $user;
        $this->view->user_addresses   = $userAddresses;
        $this->view->user_balance     = $userBalance;
        $this->view->shipping_methods = $shippingMethods;
        $this->view->games_info       = $gamesInfo;
        $this->view->gameIds          = $gameIds;
        $this->view->total            = $total;
    }

    public function carritoComunidadAction()
    {
        $this->view->header_title = "Carrito";
        $this->view->active_menu = "carrito";
        $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
        $this->view->showMenu = false;

        $games = $this->getDI()->getShared('getgames');

        $id_user = $this->session->get('user');

        if (isset($id_user)) {
            $userAddresses = Utilities::getNewRestful('get-user-addresses', 'POST', array('id_user' => $id_user['id']))->body->data;

            $userBalance = Utilities::getNewRestful('get-user-balance', 'POST', array('id_user' => $id_user['id']))->body->data;
        } else {
            $userAddresses = [];
            //userBalance ya está controlado en e codigo js del carrito
        }

        $gamesInfo = [];

        foreach ($games as $game) {
            $ar = array(
                "id" => $game->id,
                "name" => $game->name,
                "logo" => $game->logo,
                "is_shippable" => $game->is_shippable
            );
            $gamesInfo[] = $ar;
        }

        //$countries = Utilities::getNewRestful('get-countries', 'GET')->body->data;
        //$provinces = Utilities::getNewRestful('get-provinces', 'GET')->body->data;
        //$cities = Utilities::getNewRestful('get-cities', 'GET')->body->data;

        /* El json encode es para que llegue con el formato al que luego se cambia en el js, de esta forma
        no se gestiona desde js y ya llega parseado*/
        $arLocationInfo = array(
            "countries" => $this->getDI()->getShared('infocountries'),
            "provinces" => $this->getDI()->getShared('infoprovinces'),
            "cities" => $this->getDI()->getShared('infocities')
        );

        $cookie_cart = json_decode($this->cookies->get('cart_community')->getValue(), true);

        if ($cookie_cart == null || !is_array($cookie_cart)) {
            $cart = array();
        } else {
            $cart = $cookie_cart;
        }

        $gameIds = [];
        if (!empty($cart)) {
            // formas de envío de la campaña/play
            $communityPlays = Utilities::getNewRestful('get-community-plays', 'POST', array('uuid' => $cart['community_uuid']))->body->data;
            foreach ($communityPlays as $play) {
                if ($play->uuid == $cart['uuid']) {
                    $shippingMethods = $play->shippings;
                    $selectedPlay = $play;
                }
            }

            // de momento solo hay 1 juego diferente por jugada
            $idGame                 = array_keys(json_decode(json_encode($selectedPlay->products), true))[0];
            $donation               = $selectedPlay->price_donation ? $selectedPlay->price_donation : 0;
            $total = 0;

            if ($selectedPlay->is_individual) {
                foreach ($cart["lines"] as $item) {
                    $total += $item["quantity"] * ($selectedPlay->price_play + $donation);
                }
            } else {
                $total = $cart["lines"]["quantity"] * ($selectedPlay->price_play + $donation);
            }

            $cart["idGame"]         = $idGame;
            $cart["isShippable"]    = $selectedPlay->is_shippable;
            $cart["total"]          = $total;
            $cart["draw_info"]      = json_decode(json_encode($selectedPlay->products->{$idGame}->draw), true);
            $cart["is_fractional"]  = $selectedPlay->is_fractional;
            $cart["extraData"]      = json_decode(json_encode($selectedPlay->products->{$idGame}->numbers), true);
            $cart["play_price"]     = $selectedPlay->price_play;
            $cart["is_individual"]  = $selectedPlay->is_individual;
            $cart["play_donation"]  = $donation;

            //suponemos de momento juego loteria_nacional, habrá que hacer filtro con id game, cuando se reciba en el carrito
            //siguiente versión debería ser, para todos los id_game encontrados en carrito, poner la sección correspondiente para selección de método de envío
            if (!empty(intval($idGame))) {
                array_push($gameIds, intval($idGame));
            }
        }

        //si llega un 0 será un juego sin producto definido, pero de LN
        if (empty($gameIds)) {
            array_push($gameIds, $this->idLn);
        }

        $this->view->carrito_comunidad = $cart;
        $this->view->gameIds = $gameIds;




        $closeDateTime = new DateTime($selectedPlay->date_end);

        $now = new DateTime();

        $interval = $closeDateTime->diff($now);

        if ($interval->invert) {
            $hoursToDraw = ($interval->days * 24) + $interval->h;
            $newCart[] = $cart_line;
        }

        $this->view->hoursToDraw = $hoursToDraw;
        $this->view->locationInfo = $arLocationInfo;
        $this->view->domain = $this->config->get('baseconfig')->media_domain;
        $this->view->user_addresses = $userAddresses;
        $this->view->user_balance = $userBalance;
        $this->view->shipping_methods = $shippingMethods;
        $this->view->games_info = $gamesInfo;
    }
}
