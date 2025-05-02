<?php

use Phalcon\Http\Request;
use Infolot\Utilities;

class AjaxController extends ControllerBase
{
    public function initialize()
    {
        $this->view->disable();
        ini_set('display_errors', 1);
        error_reporting(E_ERROR);
    }

    public function paginateBoletosAction()
    {
        $cantidadBoletosPorPagina = 10;
        $items_pagina_actual = [];

        $request = new Request();
        //$orden = "random";
        $pagina = $request->getPost('pagina');
        $id_sorteo = $request->getPost('idsorteo');
        //Numero a buscar
        $numero = $request->getPost("numero");
        $numeros_sorteo = null;
        /**
         * Si el no se introduce número a buscar mediante GET (Ver javascript var numTerminacion de loteriaNacional ) Numero será -1
         * Si no, Numero podrá ser N, *N, N*, o *N*. Según la documentación de pv_draw_numbers
         */
        if ($numero != -1) {
            $numero = '*' . $request->getPost('numero');
            $body = Utilities::getNewRestful('pv_draw_numbers', 'POST', array('id_draw' => $id_sorteo, 'number' => $numero))->body;
        } else {
            $body = Utilities::getNewRestful('pv_draw_numbers', 'POST', array('id_draw' => $id_sorteo))->body;
        }

        if (property_exists($body, 'data')) {
            $numeros_sorteo = $body->data;

            for ($i = $cantidadBoletosPorPagina * $pagina; $i < $cantidadBoletosPorPagina * $pagina + 10; $i++) {
                array_push($items_pagina_actual, $numeros_sorteo[$i]);
            }
        }

        $this->view->numeros_sorteo = $items_pagina_actual;
        $this->view->paginas = (is_null($numeros_sorteo)) ? 0 : ((int)(sizeof($numeros_sorteo) % 10));

        //Principio Paginador
        /**
         * Creación del paginador 1 · ... · 5 · 6 · 7 · ... · 90.
         */
        $output = '';
        $output .= '<a><i class="fa fa-chevron-circle-left" id="paginador-pagina-anterior"></i></a>';
        $numSiguientePagina = $pagina;
        $cantidadTotal = (is_null($numeros_sorteo)) ? 0 : (intval(ceil(sizeof($numeros_sorteo) / 10)));
        if ($numSiguientePagina > 2) {
            $checkpoint = 0;
            $output .= '<a onclick="pageLoad(' . $checkpoint . ', ' . $cantidadTotal . ')" class="page_links" id="num_pagina_' . $checkpoint . '">' . ($checkpoint + 1) . '</a> · ... · ';
        }
        for ($i = $numSiguientePagina - 1; $i < $cantidadTotal && $i < $numSiguientePagina + 3; $i++) {
            if ($i < 0) {
                continue;
            }
            if ($i == 1) {
                $output .= ' <a onclick="pageLoad(' . ($i) . ', ' . $cantidadTotal . ')" class="page_links pagina_activa" id="num_pagina_' . $i . '">' . ($i + 1) . '</a>';
            } else {
                $output .= ' <a onclick="pageLoad(' . ($i) . ', ' . $cantidadTotal . ')" class="page_links" id="num_pagina_' . $i . '">' . ($i + 1) . '</a>';
            }
            if ($i < $cantidadTotal - 1) {
                $output .= " · ";
            }
        }
        if ($cantidadTotal > $numSiguientePagina + 4) {
            $output .= ' ... · <a onclick="pageLoad(' . ($cantidadTotal - 1) . ',' . $cantidadTotal . ')" class="page_links" id="num_pagina_' . $cantidadTotal . '">' . ($cantidadTotal) . '</a>';
        }
        $output .= '<a><i class="fa fa-chevron-circle-right" id="paginador-pagina-siguiente"></i></a>';
        //Fin paginador

        $result["items_pagina_actual"] = $items_pagina_actual;
        $result['output'] = $output;
        $json = json_encode($result);


        $this->response->setHeader('Content-Type', 'application/json');
        $this->response->setStatusCode(200, "Pagination success");
        $this->response->setContent($json);
        $this->response->send();
        return;
    }

    /**
     * Devuelve los resultados de un sorteo en base a los parámetros id_game y date
     *
     * @param   int         $id_game        ID del juego
     * @param   date        $date           Fecha del sorteo
     * @param   id_draw     $id_draw        ID del sorteo
     *
     * @see     /get-draw-results?id_game=7&date=23-3-2023
     */
    public function getDrawResultsAction()
    {
        $id_game = (int)$this->request->getPost('id_game');
        $date    = date('Y-m-d', strtotime($this->request->getPost('date')));

        $draw    = null;
        $result  = [];

        //Buscar resultado concreto
        if (!empty($date)) {
            $v = array(
                'id_game' => $id_game,
                'limit'   => 30
            );

            //$res = $this->getRestful('resultados-juego', 'POST', $v )->body;
            $res = Utilities::getNewRestful('last-game-results', 'POST', $v)->body;
            if (property_exists($res, 'data')) {
                $draw = false;
                foreach ($res->data as $r) {
                    if ($r->date == $date) {
                        $draw = $r;
                        break;
                    }
                }
            }
        }

        if ($draw) {
            $game              = $this->getDI()->getShared('getgames')[$id_game];
            $result['game']    = $game;
            $result['id_draw'] = $draw->id_draw;
            $result['bet']     = $draw->bet;
            if ($game->num_extra_per_bet > 0) {
                $result['extra']         = $draw->extra;
            }
            if ($game->is_code_a) {
                $result['code_a']        = $draw->other->code_a;
            }
            if ($game->is_code_b) {
                $result['code_b']        = $draw->other->code_b;
            }
            if ($game->is_num_complementary) {
                $result['complementary'] = $draw->other->complementary;
            }
            if (isset($draw->other->num_refund)) {
                $result['num_refund']    = $draw->other->num_refund;
            }
            if (isset($draw->other->refund)) {
                $result['refund']        = $draw->other->refund;
            }
            if ($game->is_num_serie) {
                $result['num_serie']     = $draw->other->num_serie;
            }
            if ($game->is_num_fraction) {
                $result['num_fraction']  = $draw->other->num_fraction;
            }
        }

        $this->response->setContentType('application/json', 'UTF-8');
        $this->response->setStatusCode(200, 'OK');
        $this->response->setJsonContent($result);

        return $this->response->send();
    }

    public function checkResultsAction()
    {
        $id_game    = $this->request->getPost('id_game');
        $number     = $this->request->getPost('number');
        $numbers    = $this->request->getPost('numbers');
        $extras     = $this->request->getPost('extras');
        $serie      = $this->request->getPost('serie');
        $fraction   = $this->request->getPost('fraction');
        $num_refund = $this->request->getPost('num_refund');
        $amount     = $this->request->getPost('amount');
        $id_draw    = $this->request->getPost('id_draw');
        $date       = $this->request->getPost('date');

        $result     = [
            'total'      => null,
            'other_info' => null,
        ];

        // Montamos parametros
        $v = [
            'id_game'  => $id_game,
            'date'     => date('Y-m-d', strtotime($date)),
        ];

        $draw = null;
        $game = $this->getDI()->getShared('getgames')->{$id_game};
        if ($game->id_type == T_GAME_RIFA) {
            $v['id_draw']  = $id_draw;
            $v['number']   = $number;
            $v['serie']    = $serie;
            $v['fraction'] = $fraction;

            // Sorteo
            if ($game->is_link_draw && !empty($id_draw)) {
                $res = Utilities::getNewRestful('last-draws', 'POST', $v)->body;
                if (property_exists($res, 'data')) {
                    foreach ($res->data as $r) {
                        if ($r->id_draw == $id_draw) {
                            $draw = $r;
                            break;
                        }
                    }
                }
            }
        } else {
            $v['numbers']    = [$numbers];
            $v['extras']     = [$extras];
            $v['num_refund'] = $num_refund;
            $v['code_a']     = $code_a;
            $v['code_b']     = $code_b;
        }

        $res = Utilities::getNewRestful('get-prizes', 'POST', $v)->body;
        if (!empty($res) && property_exists($res, 'data')) {
            if (!empty($amount) && !empty($draw)) {
                $result['total'] = number_format($amount / $draw->price_ticket * $res->data->total, 2, ',', '.');
            } else {
                $result['total'] = number_format($res->data->total, 2, ',', '.');
            }
            $result['other_info'] = $res->data;
        }/* else {
            //puede devolver ['error'] pero no esta controlado
            $res = null;
        }*/

        //$this->response->setHeader('Content-Type', 'application/json');
        //$this->response->setContent($json);
        $this->response->setContentType('application/json', 'UTF-8');
        $this->response->setStatusCode(200, 'OK');
        $this->response->setJsonContent($result);

        return $this->response->send();
    }

    /**
     * 1) Hace carrito y posteriormente se loguea (se hace get-last-user-cart)
     * 1.1) SI tenía carrito previo: se elimina (delete-user-cart) y se queda con el carrito nuevo (save-user-cart)
     * 1.2) NO tenía carrito previo: se hace save-user-cart recogiendo id_cart
     * 2) No hace carrito y se loguea (se hace get-last-user-cart)
     * 2.1) SI tenía carrito previo: se guarda en memoria local + id_cart
     * 2.2) No tenía carrito previo: no se hace nada
     */
    public function setSessionUserAction()
    {
        ini_set('display_errors', 0);

        $request   = new Request();
        $user_data = $request->getPost('data');
        $id_user   = $user_data['id'];
        
        $this->session->set('user', $user_data);
        
        $cookie_cart = $this->session->get('cart_ws');
        $saved_cart  = json_decode(json_encode(Utilities::getNewRestful('get-last-user-cart', 'POST', array('id_user' => $id_user))->body), true);

        if (empty($cookie_cart)) {
            if (!empty($saved_cart["data"]) && is_null($saved_cart["error"])) {
                $this->session->set("cartws_id", $saved_cart["data"]["id_cart"]);
                $this->session->set('cart_ws', $saved_cart["data"]["cart"]);
            } else {
                $this->session->remove("cartws_id");
                $this->session->remove("cart_ws");
            }
        } else {
            if (!empty($saved_cart["data"])) {
                // se borra el ultimo carrito del ws para meter el nuevo
                $cartToDelete = array(
                    "id_user" => $id_user,
                    "id_cart" => $saved_cart["data"]["id_cart"]
                );
                Utilities::getNewRestful('delete-user-cart', 'POST', $cartToDelete);
            }

            $cartToSave = array(
                "id_user" => $id_user,
                "cart" => $cookie_cart
            );
            $saveResult = Utilities::getNewRestful('save-user-cart', 'POST', $cartToSave)->body;

            if (is_null($saveResult->error) && isset($saveResult->data)) {
                $this->session->set("cartws_id", $saveResult->data);
                // el carrito no se vuelve a guardar porque ya está en sesion
            }
        }

        $this->response->setHeader('Content-Type', 'application/json');
        $this->response->setStatusCode(200, "User logged!");
        $this->response->setContent(json_encode(array("success" => true)));
        $this->response->send();
    }

    public function guardarCarritoWsAction()
    {
        ini_set('display_errors', 0);

        $request = new Request();

        $user_id = $request->getPost('user');

        // $cookie_cart = json_decode($this->cookies->get('cart_ws')->getValue(), true);
        $cookie_cart = $this->session->get('cart_ws');

        if ($cookie_cart != null) {
            $arCarrito = array(
                "id_user" => $user_id,
                "cart" => $cookie_cart
            );

            $response = Utilities::getNewRestful('save-user-cart', 'POST', $arCarrito)->body->data;

            if (!is_null($response)) {
                $this->session->set("cartws_id", $response);
            }
        }

        $this->response->setHeader('Content-Type', 'application/json');
        $this->response->setStatusCode(200, "Carrito guardado!");
        $this->response->setContent(json_encode(array("success" => true)));
        $this->response->send();
    }

    public function createOrderWsAction()
    {
        ini_set('display_errors', 0);

        // $cookie_cart = json_decode($this->cookies->get('cart_ws')->getValue(), true);
        $cookie_cart = $this->session->get('cart_ws');

        $request = new Request();
        $ship = $request->getPost('ship');
        $ship = explode('_', $ship);
        $shipping_method_id = $ship[1];

        $not_ship = $request->getPost('not_ship');
        $not_ship = explode('_', $not_ship);
        $not_shipping_method_id = $not_ship[1];

        $address = $request->getPost('address');

        $isVoiceServer = $request->getPost('is_voice_server');

        if (is_null($isVoiceServer) || $isVoiceServer != 1) {
            $cookie_cart = $this->session->get('cart_ws');
            if ($this->session->has("cartws_id")) {
                $id_cart = $this->session->get("cartws_id");
            }
            $cart = $cookie_cart;
        } else {
            $cookie_cart = $this->session->get('cart_voice_server');
            $id_cart = $cookie_cart["id_cart"];
            $cart = $cookie_cart["cart"];
        }

        $res = array();

        if ($cart != null && $this->session->has('user')) {
            $user_id = $this->session->get('user')["id"];

            $arCarrito = [
                "id_user" => $user_id,
                "id_web_shipping_shippable" => $shipping_method_id,
                "id_web_shipping_not_shippable" => $not_shipping_method_id,
                "id_user_address" => $address,
                "cart" => $cart
            ];

            if ($id_cart) {
                $arCarrito["id_cart"] = $id_cart;
            }

            $response = Utilities::getNewRestful('create-order', 'POST', $arCarrito)->body;
            if (isset($response->error) || empty($response)) {
                $res = array(
                    "success" => false,
                    "error" => $response->error ? $response->error : 'No se ha podido tramitar el pedido',
                    "carrito" => json_encode($arCarrito)
                );
            } else {
                // se borra aqui la cache del modulo del index
                foreach ($cart as $item) {
                    if (is_array($item) && array_key_exists('id_draw', $item)) {
                        Utilities::deleteFeaturedCache($item['id_draw']);
                    }
                }

                $res = array(
                    "success" => true,
                    "order" => $response->data,
                    "carrito" => json_encode($arCarrito)
                );

                //borrar carrito
                // no es necesario borrar el carrito, el create-order lo hace si le pasas el id_cart
                // if ($this->session->has('cartws_id')) {
                //     $arCarrito = array(
                //         "id_user" => $this->session->get('user')["id"],
                //         "id_cart" => $this->session->get('cartws_id'),
                //     );
                //     $response = Utilities::getNewRestful('delete-user-cart', 'POST', $arCarrito)->body->data;
                // }

                if (is_null($isVoiceServer) || $isVoiceServer != 1) {
                    $this->session->remove("cartws_id");
                    $this->session->remove("cart_ws");
                } else {
                    $this->session->remove('cart_voice_server');
                }

                // $cookie_cart = null;

                // $coo = $this->cookies->get('cart_ws');
                // $coo->delete();

                $this->view->carrito_ws = null;
            }
        }

        $this->response->setHeader('Content-Type', 'application/json');
        $this->response->setStatusCode(200, "Pedido realizado!");
        $this->response->setContent(json_encode($res));
        $this->response->send();
    }

    public function createCommunityOrderWsAction()
    {
        ini_set('display_errors', 0);

        $cookie_cart = json_decode($this->cookies->get('cart_community')->getValue(), true);

        $request = new Request();
        $ship = $request->getPost('ship');
        $ship = explode('_', $ship);
        $shipping_method_id = $ship[1];

        $not_ship = $request->getPost('not_ship');
        $not_ship = explode('_', $not_ship);
        $not_shipping_method_id = $not_ship[1];

        $address = $request->getPost('address');

        $res = array();

        if ($cookie_cart != null && $this->session->has('user')) {
            $user_id = $this->session->get('user')["id"];

            $arCarrito = array(
                "uuid" => $cookie_cart["uuid"],
                "id_user" => $user_id,
                "id_web_shipping_shippable" => $shipping_method_id,
                "id_web_shipping_not_shippable" => $not_shipping_method_id,
                "id_user_address" => $address,
                "cart" => $cookie_cart["lines"]
            );

            $response = Utilities::getNewRestful('create-community-order', 'POST', $arCarrito)->body;

            if (isset($response->error)) {
                $res = array(
                    "success" => false,
                    "error" => $response->error,
                    "carrito" => json_encode($arCarrito)
                );
            } else {
                $res = array(
                    "success" => true,
                    "order" => $response->data,
                    "carrito" => json_encode($arCarrito)
                );

                $cookie_cart = null;

                $coo = $this->cookies->get('cart_community');
                $coo->delete();

                $this->view->carrito_comunidad = $cookie_cart;
            }
        }

        $this->response->setHeader('Content-Type', 'application/json');
        $this->response->setStatusCode(200, "Pedido realizado!");
        $this->response->setContent(json_encode($res));
        $this->response->send();
    }

    public function saveUserDataWSAction()
    {
        ini_set('display_errors', 0);

        $request = new Request();

        $user_id = $this->session->get('user')["id"];

        $json_data = $request->getPost('jsonData');

        $data = json_decode($json_data, true);

        $data["id_user"] = $user_id;

        $response = Utilities::getNewRestful('set-user-info', 'POST', $data)->body;

        if (isset($response->error)) {
            $res = array(
                "success" => false,
                "error" => $response->error
            );
        } else {
            $res = array(
                "success" => true,
                "address_id" => $response->data
            );
            //save user data in session
            $user_data = $this->session->get('user');

            if ($data["cif"]) {
                $user_data["cif"] = $data["cif"];
            }
            if ($data["phone"]) {
                $user_data["phone"] = $data["phone"];
            }
            if ($data["phone_2"]) {
                $user_data["phone_2"] = $data["phone_2"];
            }
            if ($data["mobile"]) {
                $user_data["mobile"] = $data["mobile"];
            }
            if ($data["mobile_2"]) {
                $user_data["mobile_2"] = $data["mobile_2"];
            }

            $this->session->set('user', $user_data);
        }

        $this->response->setHeader('Content-Type', 'application/json');
        $this->response->setStatusCode(200, "Dirección guardada!");
        $this->response->setContent(json_encode($res));
        $this->response->send();
    }

    public function saveNewAddressWSAction()
    {
        ini_set('display_errors', 0);

        $request = new Request();

        $user_id = $this->session->get('user')["id"];

        $name_contact = $request->getPost('name_contact');
        $address = $request->getPost('address');
        $id_country = $request->getPost('id_country');
        $id_province = $request->getPost('id_province');
        $id_city = $request->getPost('id_city');
        $cp = $request->getPost('cp');
        $phone = $request->getPost('phone');
        $phone_2 = $request->getPost('phone_2');
        $mobile = $request->getPost('mobile');
        $mobile_2 = $request->getPost('mobile_2');

        $arAddress = array(
            "id_user" => $user_id,
            "name_contact" => $name_contact,
            "address" => $address,
            "id_country" => $id_country,
            "id_province" => $id_province,
            "id_city" => $id_city,
            "cp" => $cp,
            "phone" => $phone,
            "phone_2" => $phone_2,
            "mobile" => $mobile,
            "mobile_2" => $mobile_2
        );

        $response = Utilities::getNewRestful('create-user-address', 'POST', $arAddress)->body;

        if (isset($response->error)) {
            $res = array(
                "success" => false,
                "error" => $response->error
            );
        } else {
            $res = array(
                "success" => true,
                "address_id" => $response->data
            );
        }

        $this->response->setHeader('Content-Type', 'application/json');
        $this->response->setStatusCode(200, "Dirección guardada!");
        $this->response->setContent(json_encode($res));
        $this->response->send();
    }

    public function getUserAdressesWSAction()
    {
        ini_set('display_errors', 0);

        $res = array();

        if ($this->session->has('user')) {
            $user_id = $this->session->get('user')["id"];

            $response = Utilities::getNewRestful('get-user-addresses', 'POST', array('id_user' => $user_id))->body;

            if (isset($response->error)) {
                $res = array(
                    "success" => false,
                    "error" => $response->error,
                    "user_id" => $user_id
                );
            } else {
                $res = array(
                    "success" => true,
                    "addresses" => $response->data,
                    "user_id" => $user_id
                );
            }
        }

        $this->response->setHeader('Content-Type', 'application/json');
        $this->response->setStatusCode(200, "Direcciones obtenidas");
        $this->response->setContent(json_encode($res));
        $this->response->send();
    }

    //TODO ambos saveCart son muy parecidos revisar de unirlos
    // euromillon, bonoloto...
    public function saveCartTypeLottoAction()
    {
        ini_set('display_errors', 0);


        $request = new Request();
        $response = new \Phalcon\Http\Response();

        $bloquesSemanales = $request->getPost("bloquesSemanales");

        // Montamos el objeto para enviar al carrito
        // $cookie_cart = json_decode($this->cookies->get('cart_ws')->getValue(), true);
        $cookie_cart = $this->session->get('cart_ws');

        if ($cookie_cart == null || !is_array($cookie_cart)) {
            $cart = [];
        } else {
            $cart = $cookie_cart;
        }

        $game = json_decode(json_encode($this->getDI()->getShared('getgames')->{$bloquesSemanales[0]["id_game"]}), true);
        $multiples = $game["multiples"] ? json_decode($game["multiples"], true) : [];
        $addedPricePerSlip = 0;
        $addedPricePerBet = 0;
        $priceAOnBet = 0;
        $priceBOnBet = 0;

        if ($game["is_code_a_per_slip"]) {
            if (array_key_exists("code_a", $bloquesSemanales[0]["lineasPedido"][0]) || $bloquesSemanales[0]["lineasPedido"][0]["code_a"]) {
                if ($game["is_code_a_selectable"] && is_array($bloquesSemanales[0]["lineasPedido"][0]["code_a"])) {
                    if (count($bloquesSemanales[0]["lineasPedido"][0]["code_a"])) {
                        $addedPricePerSlip += $game["code_a_price"] ? $game["code_a_price"] : 0;
                    }
                } else {
                    $addedPricePerSlip += $game["code_a_price"] ? $game["code_a_price"] : 0;
                }
            }
        } else {
            $priceAOnBet = $game["code_a_price"] ? $game["code_a_price"] : 0;
        }
        
        if ($game["is_code_b_per_slip"]) {
            if (array_key_exists("code_b", $bloquesSemanales[0]["lineasPedido"][0]) || $bloquesSemanales[0]["lineasPedido"][0]["code_b"]) {
                if ($game["is_code_b_selectable"] && is_array($bloquesSemanales[0]["lineasPedido"][0]["code_b"])) {
                    if (count($bloquesSemanales[0]["lineasPedido"][0]["code_b"])) {
                        $addedPricePerSlip += $game["code_b_price"] ? $game["code_b_price"] : 0;
                    }
                } else {
                    $addedPricePerSlip += $game["code_b_price"] ? $game["code_b_price"] : 0;
                }
            }
        } else {
            $priceBOnBet = $game["code_b_price"] ? $game["code_b_price"] : 0;
        }

        foreach ($bloquesSemanales as $bloquesemanal) {
            $lineCart = [
                "id_game"           => $bloquesemanal["id_game"],
                "date_draw_ini"     => $bloquesemanal["date"],
                "numSorteos"        => $bloquesemanal["numSorteos"],
                "date_draw_last"    => $bloquesemanal["lastDate"] ? $bloquesemanal["lastDate"] : $bloquesemanal["date"],
                "is_week"           => intval($bloquesemanal["week"]),
            ];

            if ($this->config->datosadmon->data->is_subscription && $game['is_subscribable']) {
                $lineCart["is_subscription"] = intval($bloquesemanal["is_subscription"]);
                $lineCart["is_random"]       = intval($bloquesemanal["is_random"]);
                $lineCart["is_jackpot"]      = intval($bloquesemanal["is_jackpot"]);
                $lineCart["jackpot_min"]     = $bloquesemanal["jackpot_min"];
            }

            $simples = [];

            // se meten los multiples al carrito y los simples a otro array
            foreach ($bloquesemanal["lineasPedido"] as $lineaPedido) {
                if (!$game['is_custom_values_per_number'] && isset($game['min_value_per_number']) && isset($game['max_value_per_number'])) {
                    sort($lineaPedido["numeros"]);
                }

                if ($lineaPedido["extras"] && !$game['is_custom_values_per_extra'] && isset($game['min_value_per_extra']) && isset($game['max_value_per_extra'])) {
                    sort($lineaPedido["extras"]);
                }

                if (count($lineaPedido["numeros"]) > $game['num_number_per_bet'] || ($lineaPedido["extras"] && count($lineaPedido["extras"]) > $game['num_extra_per_bet'])) {
                    if (array_key_exists("extras", $lineaPedido)) {
                        $selectedMultiple = array_filter($multiples, function ($multiple) use ($lineaPedido) {
                            if ($multiple["number"] == count($lineaPedido["numeros"]) && $multiple["extra"] == count($lineaPedido["extras"])) {
                                return true;
                            }
                        });
                    } else {
                        $selectedMultiple = array_filter($multiples, function ($multiple) use ($lineaPedido) {
                            if ($multiple["number"] == count($lineaPedido["numeros"])) {
                                return true;
                            }
                        });
                    }

                    $lineCart["numbers"][0] = $lineaPedido["numeros"];

                    if ($priceAOnBet && $lineaPedido["code_a"]) {
                        if ($game["is_code_a_selectable"] && is_array($lineaPedido["code_a"])) {
                            if (count($lineaPedido["code_a"])) {
                                $addedPricePerBet += $priceAOnBet;
                            }
                        } else {
                            $addedPricePerBet += $priceAOnBet;
                        }
                    }
                
                    if ($priceBOnBet && $lineaPedido["code_b"]) {
                        if ($game["is_code_b_selectable"] && is_array($lineaPedido["code_b"])) {
                            if (count($lineaPedido["code_b"])) {
                                $addedPricePerBet += $priceBOnBet;
                            }
                        } else {
                            $addedPricePerBet += $priceBOnBet;
                        }
                    }
                    // (numero de apuestas * dias * (precio + precio por apuesta)) + (precio por boleto * dias)
                    $lineCart["total"] = (array_values($selectedMultiple)[0]["combinations"] * $lineCart['numSorteos'] * ($game['price'] + $addedPricePerBet)) + ($addedPricePerSlip * $lineCart['numSorteos']);

                    if (array_key_exists("extras", $lineaPedido)) {
                        // Francis (03/09/2023): Le faltaba un nivel de jerarquía a los extras
                        //$lineCart["extras"] = $lineaPedido["extras"];
                        $lineCart["extras"][0] = $lineaPedido["extras"];
                    }

                    if (array_key_exists("refund", $lineaPedido)) {
                        if ($game["is_num_refund_per_slip"]) {
                            $lineCart["num_refund"] = $lineaPedido["refund"];
                        } else {
                            $lineCart["num_refund"][0] = $lineaPedido["refund"];
                        }
                    }

                    if (array_key_exists("code_a", $lineaPedido)) {
                        if ($game["is_code_a_per_slip"]) {
                            $lineCart["code_a"] = $lineaPedido["code_a"];
                        } else {
                            $lineCart["code_a"][0] = $lineaPedido["code_a"];
                        }
                    }

                    if (array_key_exists("code_b", $lineaPedido)) {
                        if ($game["is_code_b_per_slip"]) {
                            $lineCart["code_b"] = $lineaPedido["code_b"];
                        } else {
                            $lineCart["code_b"][0] = $lineaPedido["code_b"];
                        }
                    }

                    $cart[] = $lineCart;
                    continue;
                }

                $simples[] = $lineaPedido;
                $addedPricePerBet = 0;
            }
            unset($lineaPedido);

            $minNumbersPerSlip = $game['min_import_per_slip'] ? round($game['min_import_per_slip'] / $game['price'], 2, PHP_ROUND_HALF_UP) : $game['num_min_bets_per_slip'];
            $i = count($simples);
            $separatedNumbers = [];
            $separatedExtras = [];
            $separatedRefund = [];
            $separatedCodeA = [];
            $separatedCodeB = [];
            $addedPricePerBet = 0;
            $lineCart["total"] = 0;
            foreach ($simples as $key => $lineaPedido) {
                //cuando solo quedan el minimo de numeros por boleto se comprueba si caben en el actual
                //ej. si el min son 2 y el max son 8 si hay 7 en el boleto actual no caben 2 mas pero tampoco puedes tener 8-1, tiene que ser un boleto de 7 y otro de 2
                //TODO puede que de problema el separar los reintegros si los 2 que quedan tienen reintegros diferentes (al solo haber bonoloto no se va a dar el caso de momento)
                if ($i == $minNumbersPerSlip) {
                    //si cabe con el resto no se hace nada sino se añade a un boleto nuevo y se para el bucle
                    if ((count($separatedNumbers) + $minNumbersPerSlip) > $game['num_max_bets_per_slip']) {
                        $lineCart["numbers"] = $separatedNumbers;

                        if (count($separatedExtras)) {
                            $lineCart["extras"] = $separatedExtras;
                        }

                        if ((is_array($separatedRefund) && count($separatedRefund)) || !is_array($separatedRefund)) {
                            $lineCart["num_refund"] = $separatedRefund;
                        }
        
                        if ((is_array($separatedCodeA) && count($separatedCodeA)) || !is_array($separatedCodeA)) {
                            $lineCart["code_a"] = $separatedCodeA;
                        }
        
                        if ((is_array($separatedCodeB) && count($separatedCodeB)) || !is_array($separatedCodeB)) {
                            $lineCart["code_b"] = $separatedCodeB;
                        }

                        $lineCart["total"] += $addedPricePerSlip * $lineCart['numSorteos'];
                        $cart[] = $lineCart;
                        $separatedNumbers = [];
                        $separatedExtras = [];
                        $separatedRefund = [];
                        $lineCart["total"] = 0;
                        break;
                    }
                }

                $separatedNumbers[] = $lineaPedido["numeros"];

                if (array_key_exists("extras", $lineaPedido)) {
                    if ($game["is_link_num_refund_extra"]) {
                        if ($game["is_num_refund_per_slip"]) {
                            $separatedExtras[0] = $lineaPedido["extras"];
                        } else {
                            $separatedExtras[] = $lineaPedido["extras"];
                        }
                    } else {
                        $separatedExtras[] = $lineaPedido["extras"];    
                    }
                }

                if (array_key_exists("refund", $lineaPedido)) {
                    if ($game["is_num_refund_per_slip"]) {
                        $separatedRefund = $lineaPedido["refund"];
                    } else {
                        $separatedRefund[] = $lineaPedido["refund"];
                    }
                }

                if (array_key_exists("code_a", $lineaPedido)) {
                    if ($game["is_code_a_per_slip"]) {
                        $separatedCodeA = $lineaPedido["code_a"];
                    } else {
                        $separatedCodeA[] = $lineaPedido["code_a"];
                    }
                }

                if (array_key_exists("code_b", $lineaPedido)) {
                    if ($game["is_code_b_per_slip"]) {
                        $separatedCodeB = $lineaPedido["code_b"];
                    } else {
                        $separatedCodeB[] = $lineaPedido["code_b"];
                    }
                }

                if ($priceAOnBet && $lineaPedido["code_a"]) {
                    if ($game["is_code_a_selectable"] && is_array($lineaPedido["code_a"])) {
                        if (count($lineaPedido["code_a"])) {
                            $addedPricePerBet += $priceAOnBet;
                        }
                    } else {
                        $addedPricePerBet += $priceAOnBet;
                    }
                }
            
                if ($priceBOnBet && $lineaPedido["code_b"]) {
                    if ($game["is_code_b_selectable"] && is_array($lineaPedido["code_b"])) {
                        if (count($lineaPedido["code_b"])) {
                            $addedPricePerBet += $priceBOnBet;
                        }
                    } else {
                        $addedPricePerBet += $priceBOnBet;
                    }
                }

                $lineCart["total"] += $lineCart['numSorteos'] * ($game['price'] + $addedPricePerBet);

                
                $separateSlip = false;
                if ($game['is_num_refund'] && $game['is_num_refund_per_slip'] && isset($simples[$key + 1])) {
                    if ($game['is_link_num_refund_extra']) {
                        if (is_array($lineaPedido['extras'])) {
                            $separateSlip = boolval(count(array_diff($lineaPedido['extras'], $simples[$key + 1]['extras'])));
                        } else {
                            $separateSlip = $lineaPedido['extras'] != $simples[$key + 1]['extras'];
                        }
                    } else {
                        $separateSlip = $lineaPedido['refund'] != $simples[$key + 1]['refund'];
                    }
                }

                // cuando se llena un boleto se mete en el carrito o si es la ultima linea por procesar o si el reintegro es por boleto y es diferente al siguiente
                if (count($separatedNumbers) == $game['num_max_bets_per_slip'] || $i == 1 || $separateSlip) {
                    $lineCart["numbers"] = $separatedNumbers;

                    if (count($separatedExtras)) {
                        $lineCart["extras"] = $separatedExtras;
                    }

                    if ((is_array($separatedRefund) && count($separatedRefund)) || !is_array($separatedRefund)) {
                        $lineCart["num_refund"] = $separatedRefund;
                    }
    
                    if ((is_array($separatedCodeA) && count($separatedCodeA)) || !is_array($separatedCodeA)) {
                        $lineCart["code_a"] = $separatedCodeA;
                    }
    
                    if ((is_array($separatedCodeB) && count($separatedCodeB)) || !is_array($separatedCodeB)) {
                        $lineCart["code_b"] = $separatedCodeB;
                    }
                    $lineCart["total"] += $addedPricePerSlip * $lineCart['numSorteos'];
                    $cart[] = $lineCart;
                    $separatedNumbers = [];
                    $separatedExtras = [];
                    $separatedRefund = [];
                    $lineCart["total"] = 0;
                }
                $i--;
                $addedPricePerBet = 0;
            }
        }

        if ($this->session->has('user')) {
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

        // $this->cookies->send();

        $this->view->carrito_ws = $cart;

        $this->response->setHeader('Content-Type', 'application/json');
        $this->response->setStatusCode(200, "Guardado!");
        $this->response->setContent(json_encode(array("success" => true)));
        $this->response->send();
    }

    // quiniela, quinigol...
    public function saveCartTypeApuestasAction()
    {
        ini_set('display_errors', 0);


        $request = new Request();
        $response = new \Phalcon\Http\Response();

        $date              = $request->getPost("date");
        $game_code         = $request->getPost("game_code");
        // $lastDate       = $request->getPost("lastDate");
        $week              = $request->getPost("week");
        $lineasPedido      = $request->getPost("lineasPedido");
        $is_subscription   = intval($request->getPost("is_subscription"));
        $is_random         = intval($request->getPost("is_random"));
        $is_jackpot        = intval($request->getPost("is_jackpot"));
        $jackpot_min       = $request->getPost("jackpot_min");
        $game              = Utilities::getGameByCode($game_code);
        $addedPricePerSlip = 0;
        $addedPricePerBet  = 0;
        $priceAOnBet       = 0;
        $priceBOnBet       = 0;

        if ($game["is_code_a_per_slip"]) {
            if (array_key_exists("code_a", $lineasPedido[0]) && $lineasPedido[0]["code_a"]) {
                if ($game["is_code_a_selectable"] && is_array($lineasPedido[0]["code_a"])) {
                    if (count($lineasPedido[0]["code_a"])) {
                        $addedPricePerSlip += $game["code_a_price"] ? $game["code_a_price"] : 0;
                    }
                } else {
                    $addedPricePerSlip += $game["code_a_price"] ? $game["code_a_price"] : 0;
                }
            }
        } else {
            $priceAOnBet = $game["code_a_price"] ? $game["code_a_price"] : 0;
        }
        
        if ($game["is_code_b_per_slip"]) {
            if (array_key_exists("code_b", $lineasPedido[0]) && $lineasPedido[0]["code_b"]) {
                if ($game["is_code_b_selectable"] && is_array($lineasPedido[0]["code_b"])) {
                    if (count($lineasPedido[0]["code_b"])) {
                        $addedPricePerSlip += $game["code_b_price"] ? $game["code_b_price"] : 0;
                    }
                } else {
                    $addedPricePerSlip += $game["code_b_price"] ? $game["code_b_price"] : 0;
                }
            }
        } else {
            $priceBOnBet = $game["code_b_price"] ? $game["code_b_price"] : 0;
        }

        // Montamos el objeto para enviar al carrito
        // $cookie_cart = json_decode($this->cookies->get('cart_ws')->getValue(), true);
        $cookie_cart = $this->session->get('cart_ws');

        if ($cookie_cart == null || !is_array($cookie_cart)) {
            $cart = [];
        } else {
            $cart = $cookie_cart;
        }

        $simples = [];
        $i = 0;

        foreach ($lineasPedido as $lineaPedido) {
            $lineCart = [
                "id_game" => $game["id"],
                "date_draw_ini" => $date,
                "is_week" => intval($week),
            ];

            if ($this->config->datosadmon->data->is_subscription && $game['is_subscribable']) {
                $lineCart["is_subscription"] = $is_subscription;
                $lineCart["is_random"]       = $is_random;
                $lineCart["is_jackpot"]      = $is_jackpot;
                $lineCart["jackpot_min"]     = $jackpot_min;
            }

            if (!$game["is_custom_values_per_number"] && isset($game["min_value_per_number"]) && isset($game["max_value_per_number"])) {
                sort($lineaPedido["numeros"]);
            }

            if ($lineaPedido["extras"] && !$game["is_custom_values_per_extra"] && isset($game["min_value_per_extra"]) && isset($game["max_value_per_extra"])) {
                sort($lineaPedido["extras"]);
            }

            $bets = 0;

            $bets = Utilities::getNumSportBets($lineaPedido["numeros"]);

            if (array_key_exists("extras", $lineaPedido)) {
                $bets *= pow(2, count($lineaPedido["extras"][0]) - 1);
                $bets *= pow(2, count($lineaPedido["extras"][1]) - 1);
            }

            //multiple
            if ($bets > 1) {
                $lineCart["numbers"][] = $lineaPedido["numeros"];

                if ($priceAOnBet && $lineaPedido["code_a"]) {
                    if ($game["is_code_a_selectable"] && is_array($lineaPedido["code_a"])) {
                        if (count($lineaPedido["code_a"])) {
                            $addedPricePerBet += $priceAOnBet;
                        }
                    } else {
                        $addedPricePerBet += $priceAOnBet;
                    }
                }
            
                if ($priceBOnBet && $lineaPedido["code_b"]) {
                    if ($game["is_code_b_selectable"] && is_array($lineaPedido["code_b"])) {
                        if (count($lineaPedido["code_b"])) {
                            $addedPricePerBet += $priceBOnBet;
                        }
                    } else {
                        $addedPricePerBet += $priceBOnBet;
                    }
                }

                // los multiples van separados en cada boleto no hace falta comprobar num_max_bets_per_slip != num_max_extras_per_slip
                if (array_key_exists("extras", $lineaPedido)) {
                    $lineCart["extras"][] = $lineaPedido["extras"];
                }

                if (array_key_exists("refund", $lineaPedido)) {
                    if ($game["is_num_refund_per_slip"]) {
                        $lineCart["refund"] = $lineaPedido["refund"];
                    } else {
                        $lineCart["refund"][] = $lineaPedido["refund"];
                    }
                }

                if (array_key_exists("code_a", $lineaPedido)) {
                    if ($game["is_code_a_per_slip"] && $game["is_code_a_selectable"]) {
                        $lineCart["code_a"]["code"] = $lineaPedido["code_a"];
                    } elseif ($game["is_code_a_per_slip"] && !$game["is_code_a_selectable"]) {
                        $lineCart["code_a"]["buy"] = true;
                    } elseif (!$game["is_code_a_per_slip"] && $game["is_code_a_selectable"]) {
                        $lineCart["code_a"][] = ["code" => $lineaPedido["code_a"]];
                    } elseif (!$game["is_code_a_per_slip"] && !$game["is_code_a_selectable"]) {
                        $lineCart["code_a"][] = ["buy" => true];
                    }
                }
    
                if (array_key_exists("code_b", $lineaPedido)) {
                    if ($game["is_code_b_per_slip"] && $game["is_code_b_selectable"]) {
                        $lineCart["code_b"]["code"] = $lineaPedido["code_b"];
                    } elseif ($game["is_code_b_per_slip"] && !$game["is_code_b_selectable"]) {
                        $lineCart["code_b"]["buy"] = true;
                    } elseif (!$game["is_code_b_per_slip"] && $game["is_code_b_selectable"]) {
                        $lineCart["code_b"][] = ["code" => $lineaPedido["code_b"]];
                    } elseif (!$game["is_code_b_per_slip"] && !$game["is_code_b_selectable"]) {
                        $lineCart["code_b"][] = ["buy" => true];
                    }
                }

                if ($game["code"] == 'LQ') {
                    $lineCart["total"] = Utilities::getItemPrice($lineaPedido, $game, 1);
                } else {
                    $lineCart["total"] = ($bets * ($game["price"] + $addedPricePerBet)) + $addedPricePerSlip;
                }
                $addedPricePerBet = 0;
                $cart[] = $lineCart;
                $i++;
                continue;
            }

            $simples[] = $lineaPedido;
            $i++;
        }

        $minNumbersPerSlip = $game["min_import_per_slip"] ? round($game["min_import_per_slip"] / $game["price"], 2, PHP_ROUND_HALF_UP) : $game["num_min_bets_per_slip"];

        $i = count($simples);
        $lineCart["total"] = 0;
        $addedPricePerBet = 0;

        $cartIndex = count($cart);
        $blankSlip = [
            'id_game'       => $game["id"],
            'date_draw_ini' => $date,
            'is_week'       => intval($week),
            'total'         => 0.0,
            'numbers'       => [],
            'extras'        => []
        ];

        if ($this->config->datosadmon->data->is_subscription && $game['is_subscribable']) {
            $blankSlip["is_subscription"] = $is_subscription;
            $blankSlip["is_random"]       = $is_random;
            $blankSlip["is_jackpot"]      = $is_jackpot;
            $blankSlip["jackpot_min"]     = $jackpot_min;
        }

        // si hay apuestas simples se prepara un boleto nuevo
        if ($i) {
            $cart[$cartIndex] = $blankSlip;
        }

        $baseBet = null;
        $updateBaseBet = false;
        $forceSlipChange = false;
        //TODO usar este mismo sistema para euromillon, bonoloto...
        foreach ($simples as $lineaPedido) {
            // si quedan el minimo y no caben en el boleto anterior se pasa a uno nuevo (se esta obviando si las apuestas son iguales porque no deberia dejar la vista comprar apuestas sueltas si el minimo son 2)
            if ($i == $minNumbersPerSlip && (count($cart[$cartIndex]["numbers"]) + $minNumbersPerSlip > $game["num_max_bets_per_slip"])) {
                $forceSlipChange = true;
            }

            // si la apuesta no puede estar en el mismo boleto se añade otro
            if ($forceSlipChange || (!Utilities::isBetOnSameSlip($game, $baseBet, $lineaPedido) || count($cart[$cartIndex]["numbers"]) >= $game["num_max_bets_per_slip"])) {
                // como el boleto anterior esta terminado se le añade el precio por boleto
                $cart[$cartIndex]["total"] += $addedPricePerSlip;
                $cart[] = $blankSlip;
                $cartIndex++;
                $updateBaseBet = true;
                $forceSlipChange = false;
            }

            $cart[$cartIndex]["numbers"][] = $lineaPedido["numeros"];

            // pillar solo el primer extra si no van las apuestas con los extras de la mano
            if ($game["num_max_bets_per_slip"] != $game["num_max_extras_per_slip"]) {
                if (empty($cart[$cartIndex]["extras"])) {
                    $cart[$cartIndex]["extras"] = [$lineaPedido["extras"]];
                }
            } else {
                $cart[$cartIndex]["extras"][] = $lineaPedido["extras"];
            }

            if (array_key_exists("refund", $lineaPedido)) {
                if ($game["is_num_refund_per_slip"]) {
                    $cart[$cartIndex]["refund"] = $lineaPedido["refund"];
                } else {
                    $cart[$cartIndex]["refund"][] = $lineaPedido["refund"];
                }
            }

            //TODO pasar el code_a directamente con {"buy": true} o {"code": ["1", "2", "3", "4", "5", "6", "7", "8"]}
            if (array_key_exists("code_a", $lineaPedido)) {
                if ($game["is_code_a_per_slip"] && $game["is_code_a_selectable"]) {
                    $cart[$cartIndex]["code_a"]["code"] = $lineaPedido["code_a"];
                } elseif ($game["is_code_a_per_slip"] && !$game["is_code_a_selectable"]) {
                    $cart[$cartIndex]["code_a"]["buy"] = true;
                } elseif (!$game["is_code_a_per_slip"] && $game["is_code_a_selectable"]) {
                    $cart[$cartIndex]["code_a"][] = ["code" => $lineaPedido["code_a"]];
                } elseif (!$game["is_code_a_per_slip"] && !$game["is_code_a_selectable"]) {
                    $cart[$cartIndex]["code_a"][] = ["buy" => true];
                }
            }

            if (array_key_exists("code_b", $lineaPedido)) {
                if ($game["is_code_b_per_slip"] && $game["is_code_b_selectable"]) {
                    $cart[$cartIndex]["code_b"]["code"] = $lineaPedido["code_b"];
                } elseif ($game["is_code_b_per_slip"] && !$game["is_code_b_selectable"]) {
                    $cart[$cartIndex]["code_b"]["buy"] = true;
                } elseif (!$game["is_code_b_per_slip"] && $game["is_code_b_selectable"]) {
                    $cart[$cartIndex]["code_b"][] = ["code" => $lineaPedido["code_b"]];
                } elseif (!$game["is_code_b_per_slip"] && !$game["is_code_b_selectable"]) {
                    $cart[$cartIndex]["code_b"][] = ["buy" => true];
                }
            }

            if ($priceAOnBet && $lineaPedido["code_a"]) {
                if ($game["is_code_a_selectable"] && is_array($lineaPedido["code_a"])) {
                    if (count($lineaPedido["code_a"])) {
                        $addedPricePerBet += $priceAOnBet;
                    }
                } else {
                    $addedPricePerBet += $priceAOnBet;
                }
            }
        
            if ($priceBOnBet && $lineaPedido["code_b"]) {
                if ($game["is_code_b_selectable"] && is_array($lineaPedido["code_b"])) {
                    if (count($lineaPedido["code_b"])) {
                        $addedPricePerBet += $priceBOnBet;
                    }
                } else {
                    $addedPricePerBet += $priceBOnBet;
                }
            }

            $cart[$cartIndex]["total"] += $game["price"] + $addedPricePerBet;

            // apuesta con la que se comparan las siguientes para añadirlas al mismo boleto
            if ($updateBaseBet || is_null($baseBet)) {
                $baseBet = $lineaPedido;
                $updateBaseBet = false;
            }
            $i--;
            $addedPricePerBet = 0;

            // se añade el precio por boleto al ultimo
            if ($i == 0) {
                $cart[$cartIndex]["total"] += $addedPricePerSlip;
            }
        }

        if ($this->session->has('user')) {
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

        // $this->cookies->send();

        $this->view->carrito_ws = $cart;

        $this->response->setHeader('Content-Type', 'application/json');
        $this->response->setStatusCode(200, "Guardado!");
        $this->response->setContent(json_encode(array("success" => true)));
        $this->response->send();
    }

    public function guardarCarritoLoteriaNacionalAction()
    {
        ini_set('display_errors', 0);

        $request = new Request();

        $date_draw_ini = $request->getPost("date_draw_ini");
        $price_ticket = $request->getPost("price_ticket");
        $id_draw = $request->getPost("id_draw");
        $tickets = $request->getPost("tickets");
        $replace_quantity = $request->getPost("replace_quantity");

        // $cookie_cart = json_decode($this->cookies->get('cart_ws')->getValue(), true);
        $sessionCart = $this->session->get('cart_ws');

        if ($sessionCart == null || !is_array($sessionCart)) {
            $cart = [];
        } else {
            $cart = $sessionCart;
        }

        $cart = array_values($cart);

        foreach ($tickets as $k => $param) {
            if ($replace_quantity || $param > 0) {
                $num_encontrado = false;

                // Revisar si en el carrito actual tenemos el numero que está jugando
                for ($i = 0; $i < sizeof($cart); $i++) {
                    if ($cart[$i]["id_game"] == $this->idLn && $cart[$i]["date_draw_ini"] == $date_draw_ini && $cart[$i]["id_draw"] == $id_draw && $cart[$i]["number"] == $k) {
                        if ($replace_quantity) {
                            if ($param == 0) {
                                unset($cart[$i]);
                            } else {
                                $cart[$i]["quantity"] = $param;
                            }
                        } else {
                            $cart[$i]["quantity"] += $param;
                        }
                        $num_encontrado = true;
                    }
                }

                // Si no ha encontrado el numero, añadimos al carrito
                if (!$num_encontrado && $param > 0) {
                    $cart[] = array(
                        "id_game" => 7,
                        "date_draw_ini" => $date_draw_ini,
                        "is_week" => 0,
                        "is_subscription" => 0,
                        "quantity" => $param,
                        "id_draw" => $id_draw,
                        "number" => $k,
                        "price_ticket" => $price_ticket
                    );
                }
            }
        }

        // reordenar el array para no tener keys vacios
        $cart = array_values($cart);

        if ($this->session->has('user')) {
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

        // var_dump($this->session->get('cart_ws'));
        // exit(0);


        $this->response->setHeader('Content-Type', 'application/json');
        $this->response->setStatusCode(200, "Guardado!");
        $this->response->setContent(json_encode(array("success" => true, "id_draw" => $id_draw)));
        $this->response->send();
    }

    public function guardarCarritoQuinigolAction()
    {
        ini_set('display_errors', 0);


        $request = new Request();
        $response = new \Phalcon\Http\Response();

        $date            = $request->getPost("date");
        $lastDate        = $request->getPost("lastDate");
        $week            = $request->getPost("week");
        $lineasPedido    = $request->getPost("lineasPedido");
        $is_subscription = intval($request->getPost("is_subscription"));
        $is_random       = intval($request->getPost("is_random"));
        $is_jackpot      = intval($request->getPost("is_jackpot"));
        $jackpot_min     = $request->getPost("jackpot_min");
        
        $game = Utilities::getGameByCode('QGOL');
        $addedPricePerSlip = 0;
        $addedPricePerBet = 0;

        if ($game["is_code_a_per_slip"]) {
            $addedPricePerSlip += $game["code_a_price"];
        } else {
            $addedPricePerBet += $game["code_a_price"];
        }

        if ($game["is_code_b_per_slip"]) {
            $addedPricePerSlip += $game["code_b_price"];
        } else {
            $addedPricePerBet += $game["code_b_price"];
        }

        // Montamos el objeto para enviar al carrito
        // $cookie_cart = json_decode($this->cookies->get('cart_ws')->getValue(), true);
        $cookie_cart = $this->session->get('cart_ws');

        if ($cookie_cart == null || !is_array($cookie_cart)) {
            $cart = [];
        } else {
            $cart = $cookie_cart;
        }

        $finalNumbers = [];
        $simples = [];
        $i = 0;
        foreach ($lineasPedido as $lineaPedido) {
            $lineCart = [
                "id_game" => $game["id"],
                "date_draw_ini" => $date,
                "date_draw_last" => $lastDate ? $lastDate : $date,
                "is_week" => intval($week),
                // "is_subscription"   => intval($lineaPedido["subscription"]),
            ];

            if ($this->config->datosadmon->data->is_subscription && $game['is_subscribable']) {
                $lineCart["is_subscription"] = $is_subscription;
                $lineCart["is_random"]       = $is_random;
                $lineCart["is_jackpot"]      = $is_jackpot;
                $lineCart["jackpot_min"]     = $jackpot_min;
            }

            $bets = 0;
            foreach ($lineaPedido as $numbers) {
                $finalNumbers[$i][] = Utilities::arrayCombineValues($numbers[0], $numbers[1]);
            }

            $bets = Utilities::getNumSportBets($finalNumbers[$i]);

            //multiple
            if ($bets > 1) {
                $lineCart["numbers"] = $finalNumbers;
                $lineCart["total"] = ($bets * ($game["price"] + $addedPricePerBet)) + $addedPricePerSlip;

                $cart[] = $lineCart;
                $i++;
                continue;
            }

            $simples[] = $lineaPedido;
            $i++;
        }

        $minNumbersPerSlip = $game["min_import_per_slip"] ? round($game["min_import_per_slip"] / $game["price"], 2, PHP_ROUND_HALF_UP) : $game["num_min_bets_per_slip"];

        $i = count($simples);
        $separatedNumbers = [];
        $lineCart["total"] = 0;
        $finalNumbers = [];

        foreach ($simples as $lineaPedido) {
            //cuando solo quedan el minimo de numeros por boleto se comprueba si caben en el actual
            //ej. si el min son 2 y el max son 8 si hay 7 en el boleto actual no caben 2 mas pero tampoco puedes tener 8-1, tiene que ser un boleto de 7 y otro de 2
            if ($i == $minNumbersPerSlip) {
                //si cabe con el resto no se hace nada sino se añade a un boleto nuevo
                if ((count($separatedNumbers) + $minNumbersPerSlip) > $game["num_max_bets_per_slip"]) {
                    $lineCart["numbers"] = $separatedNumbers;
                    $cart[] = $lineCart;
                    $separatedNumbers = [];
                    $lineCart["total"] = 0;
                }
            }

            foreach ($lineaPedido as $numbers) {
                $finalNumbers[$i][] = Utilities::arrayCombineValues($numbers[0], $numbers[1]);
            }
            $separatedNumbers[] = $finalNumbers[$i];

            // no se sacan las apuestas porque son todas simples
            $lineCart["total"] += ($game["price"] + $addedPricePerBet) + $addedPricePerSlip;
            $bets = 0;

            // cuando se llena un boleto se mete en el carrito o si es la ultima linea por procesar
            if (count($separatedNumbers) == $game["num_max_bets_per_slip"] || $i == 1) {
                $lineCart["numbers"] = $separatedNumbers;

                $cart[] = $lineCart;
                $separatedNumbers = [];
                $lineCart["total"] = 0;
            }
            $i--;
        }

        if ($this->session->has('user')) {
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

        // $this->cookies->send();

        $this->view->carrito_ws = $cart;

        $this->response->setHeader('Content-Type', 'application/json');
        $this->response->setStatusCode(200, "Guardado!");
        $this->response->setContent(json_encode(array("success" => true)));
        $this->response->send();
    }

    public function guardarCarritoParticipacionesAction()
    {
        ini_set('display_errors', 0);

        $request = new Request();

        $post = $request->getPost();

        $cart = array(
            "community_uuid" => $post["community_uuid"],
            "uuid" => $post["uuid"],
            "lines" => $post["lineasPedido"],
            
            // excepto lines se puede sacar todo con el uuid de la jugada, daba error 502 porque habia demasiados datos
            // "play_donation" => $post["play_donation"],
            // "is_individual" => $post["is_individual"],
            // "play_price" => $post["play_price"],
            // "extraData" => $post["extraData"],
            // "is_fractional" => $post["is_fractional"],
            // "draw_info" => $post["draw_info"],
            // "total" => $post["total"],
            // "isShippable" => $post["isShippable"],
            // "idGame" => $post["idGame"],
        );

        $this->cookies->set(
            'cart_community',
            json_encode($cart),
            time() + 15 * 86400
        );

        $this->cookies->send();

        $this->view->carrito_comunidad = $cart;

        $this->response->setHeader('Content-Type', 'application/json');
        $this->response->setStatusCode(200, "Guardado!");
        $this->response->setContent(json_encode(array("success" => true)));
        $this->response->send();
    }
}
