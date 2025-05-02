<?php

use Infolot\Utilities;

class OrderController extends ControllerBase
{
    public function resumeOrderAction($id)
    {
        $this->view->header_title = "Pedido";

        $id_user = $this->session->get('user')['id'];

        //$datosAdmon = $this->config->get('datosadmon');
        $order = array(
            "id_order" => $id
        );
        $order_info = Utilities::getNewRestful('get-order', 'POST', $order)->body;
        $games = $this->getDI()->getShared('getgames');
        $datosAdmon = $this->config->get('datosadmon');

        $this->view->id_pedido = $id;
        $this->view->id_user = $id_user;
        $this->view->order_info = $order_info;
        $this->view->games_info = json_decode(json_encode($games), true);
        $this->view->datosAdmon = $datosAdmon->data;
        $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
    }
}
