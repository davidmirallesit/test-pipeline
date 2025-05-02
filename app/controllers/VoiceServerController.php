<?php

use Infolot\Utilities;

class VoiceServerController extends ControllerBase
{
    public function cartAction($id_cart)
    {
        $this->view->setVar('js_section', 'js/carrito.js');

        $responseCart = Utilities::getNewRestful('get-voice-server-cart', 'POST', ["id_cart" => $id_cart])->body->data;
        $responseCart = json_decode(json_encode($responseCart), true);
        $this->session->set('cart_voice_server', $responseCart);

        $hasCart = false;
        $total = 0;
        $cart = [];
        $cart_id = null;
        if (array_key_exists("id_cart", $responseCart)) {
            $cart = $responseCart["cart"];
            $cart_id = $responseCart["id_cart"];
            $hasCart = true;
            foreach ($cart as $item) {
                $total += $item["price_ticket"] * $item["quantity"];
            }
        }


        
        $id_user    = $this->session->get('user')['id'];
        $game       = $this->getDI()->getShared('getgames')->{$this->idLn};
        $datosAdmon = $this->config->get('datosadmon')->data;

        if (isset($id_user)) {
            $userAddresses = Utilities::getNewRestful('get-user-addresses', 'POST', array('id_user' => $id_user))->body->data;
            $userBalance = Utilities::getNewRestful('get-user-balance', 'POST', array('id_user' => $id_user))->body->data;
        } else {
            $userAddresses = [];
        }

        /* El json encode es para que llegue con el formato al que luego se cambia en el js, de esta forma
        no se gestiona desde js y ya llega parseado*/
        $arLocationInfo = array(
            "countries" => $this->getDI()->getShared('infocountries'),
            "provinces" => $this->getDI()->getShared('infoprovinces'),
            "cities"    => $this->getDI()->getShared('infocities')
        );

        if ($cart[0]["id_draw"] == 2023102) {
            $proximos_sorteos = $this->getDI()->getShared('infonextdrawsnavidad')[0];
        } elseif ($cart[0]["id_draw"] == 2024002) {
            $proximos_sorteos = $this->getDI()->getShared('infonextdrawsnino')[0];
        }

        $this->view->setVars([
            "header_title" => "Carrito",
            "active_menu" => "carrito",
            "web_seo_onpage" => Utilities::getWebSeoOnpage(),
            "showMenu" => false,
            "cart" => $cart,
            "hasCart" => $hasCart,
            "game_info" => json_decode(json_encode($game), true),
            "draw_info" => $proximos_sorteos,
            "datosAdmon" => $datosAdmon,
            "locationInfo" => $arLocationInfo,
            "user_addresses" => $userAddresses,
            "user_balance" => $userBalance,
            "shipping_methods" => $datosAdmon->shippings,
            "id_user" => $id_user,
            "total" => $total,
            "id_cart" => $cart_id,
            "user" => $this->session->get('user'),
        ]);

        $this->view->hoursToFirstShippable = 9999;
        $this->view->hoursToFirstNotShippable = 9999;
    }
}
