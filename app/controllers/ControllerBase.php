<?php

use Infolot\Phalcon\Mvc\Controller;
use Infolot\Utilities;

class ControllerBase extends Controller
{
    //id loteria nacional por defecto 7
    protected $idLn = 7;

    public function initialize()
    {

        if ($this->config->maintenance_enabled && !in_array($this->router->getControllerName(), ['maintenance', 'css'])) {
            $this->response->redirect('/mantenimiento')->send();
            exit();
        }

        $controller = Utilities::normalize(str_replace('Controller', '', $this->dispatcher->getControllerName()));
        if ($controller == "css") {
            return;
        }

        $this->response->setStatusCode(200, "");
        $this->view->config = $this->config;

        // $cookie_cart = json_decode($this->cookies->get('cart_ws')->getValue(), true);
        $cookie_cart = $this->session->get('cart_ws');

        if ($cookie_cart == null || !is_array($cookie_cart)) {
            $cart = [];
        } else {
            $cart = $cookie_cart;
        }

        $this->view->carrito_ws = $cart;

        $datosAdmon = $this->config->get('datosadmon');
        $baseconfig = $this->config->get('baseconfig');

        /*
        //posible redirección a domain especificado por usuario
        if($datosAdmon->data && $datosAdmon->data->url && $datosAdmon->data->url->redirect)
            return $this->response->redirect($datosAdmon->data->url->redirect,true,302);
        */

        $this->view->datosAdmon = isset($datosAdmon) ? $datosAdmon->data : null;
        $this->view->baseconfig = $baseconfig;
        $this->view->selae_url_with_game = 'https://juegos.loteriasyapuestas.es/CF/loginFromRetailer.do?retailerId=' . RECEPTOR_ID . '&gameId=%s';
        $this->view->selae_url_registration = 'https://juegos.loteriasyapuestas.es/CF/registration/modifyRetailerInput.do?newRetailerId=' . RECEPTOR_ID;

        if ($this->session->has('user')) {
            $this->view->userBalance_quantity = Utilities::getNewRestful('get-user-balance', 'POST', array('id_user' => $this->session->get('user')["id"]))->body->data;
        }

        $this->view->user_dropdown = [
            [
                "url" => $baseconfig->url_panel . '/backend/users/profile',
                "icon" => '<i class="fa fa-user" aria-hidden="true"></i>',
                "text"  => 'Perfil',
            ],
            [
                "url" => $baseconfig->url_panel . '/backend/pv-orders',
                "icon" => '<i class="fa fa-shopping-cart" aria-hidden="true"></i>',
                "text"  => 'Pedidos web',
            ],
            [
                "url" => $baseconfig->url_panel . '/backend/community-orders',
                "icon" => '<i class="fa fa-building" aria-hidden="true"></i>',
                "text"  => 'Pedidos Entidades',
            ],
            [
                "url" => $baseconfig->url_panel . '/backend/subscriptions/active',
                "icon" => '<i class="fa fa-refresh" aria-hidden="true"></i>',
                "text"  => 'Mis Abonos',
                ],
                
                [
                "url" => $baseconfig->url_panel . '/backend/transfers',
                "icon" => '<svg style="width: 0.9em;" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="coins" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" data-fa-i2svg=""><path fill="currentColor" d="M0 405.3V448c0 35.3 86 64 192 64s192-28.7 192-64v-42.7C342.7 434.4 267.2 448 192 448S41.3 434.4 0 405.3zM320 128c106 0 192-28.7 192-64S426 0 320 0 128 28.7 128 64s86 64 192 64zM0 300.4V352c0 35.3 86 64 192 64s192-28.7 192-64v-51.6c-41.3 34-116.9 51.6-192 51.6S41.3 334.4 0 300.4zm416 11c57.3-11.1 96-31.7 96-55.4v-42.7c-23.2 16.4-57.3 27.6-96 34.5v63.6zM192 160C86 160 0 195.8 0 240s86 80 192 80 192-35.8 192-80-86-80-192-80zm219.3 56.3c60-10.8 100.7-32 100.7-56.3v-42.7c-35.5 25.1-96.5 38.6-160.7 41.8 29.5 14.3 51.2 33.5 60 57.2z"></path></svg>',
                "text"  => 'Mis Movimientos',
            ],
            [
                "url" => $baseconfig->url_panel . '/backend/payments/pendent',
                "icon" => '<i class="fa fa-credit-card" aria-hidden="true"></i>',
                "text"  => 'Recargas',
            ],
            [
                "url" => $baseconfig->url_panel . '/backend/pay',
                "icon" => '<i class="fa fa-credit-card" aria-hidden="true"></i>',
                "text"  => 'Nueva recarga',
            ],
            [
                "url" => $baseconfig->url_panel . '/backend/money-requests',
                "icon" => '<svg style="width: 0.9em;" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="file-export" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 576 512" data-fa-i2svg=""><path fill="currentColor" d="M384 121.9c0-6.3-2.5-12.4-7-16.9L279.1 7c-4.5-4.5-10.6-7-17-7H256v128h128zM571 308l-95.7-96.4c-10.1-10.1-27.4-3-27.4 11.3V288h-64v64h64v65.2c0 14.3 17.3 21.4 27.4 11.3L571 332c6.6-6.6 6.6-17.4 0-24zm-379 28v-32c0-8.8 7.2-16 16-16h176V160H248c-13.2 0-24-10.8-24-24V0H24C10.7 0 0 10.7 0 24v464c0 13.3 10.7 24 24 24h336c13.3 0 24-10.7 24-24V352H208c-8.8 0-16-7.2-16-16z"></path></svg>',
                "text"  => 'Solicitudes de rescate',
            ],
            [
                "url" => $baseconfig->url_panel . '/logout',
                "icon" => '<i class="fa fa-sign-out" aria-hidden="true"></i>',
                "text"  => 'Salir',
            ],
        ];

        $this->view->shortMonthNames = $this->config->translated->shortMonthNames;
        $this->view->monthNames = $this->config->translated->monthNames;
        $this->view->dayNames = $this->config->translated->dayNames;

        $buy_urls = [];
        $results_urls = [];

        $all_games  = $this->getDI()->getShared('getgames');
        foreach ($all_games as $game) {
            if ($game->is_link_draw) {
                $buy_urls[$game->code] = $game->keyword;
            } else {
                $buy_urls[$game->code] = 'comprar-' . $game->keyword;
            }
            $results_urls[$game->code] = 'resultados-' . $game->keyword;

            if ($game->is_shippable && $game->is_link_draw && preg_match('/^LN.*/', $game->code)) {
                $this->idLn = $game->id;
            }
        }

        $this->view->buy_urls = $buy_urls;
        $this->view->result_urls = $results_urls;
        $this->view->idLn = $this->idLn;
        $this->view->drawsByNameSeo = Utilities::getSearchDrawsByNameSeo();
        $this->view->searchUrlByNameSeo = Utilities::getSearchUrlByNameSeo();
        if ($datosAdmon->data->is_search_numbers) {
            $hasSearcher = (is_null($this->view->drawsByNameSeo)) ? false : true;
        } else {
            $hasSearcher = false;
        }
        $this->view->hasSearcher = $hasSearcher;
        unset($hasSearcher);

        if (!empty($datosAdmon->data->google->recaptcha_v3_web_key) && !empty($datosAdmon->data->google->recaptcha_v3_secret_key)) {
            $this->view->recaptcha_version = 'v3';
        } else {
            $this->view->recaptcha_version = 'v2';
        }

        // $protocol = ((!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] != 'off') || $_SERVER['SERVER_PORT'] == 443) ? "https://" : "http://";
        // $CurPageURL = $protocol . $_SERVER['HTTP_HOST'];
        // $this->view->CurPageURL = $CurPageURL;
        //$this->view->showMenu = true;
        //$this->view->active_menu = "";

        $this->view->setVars([
            'showMenu'          => true,
            'active_menu'       => '',
            'css_class_section' => $controller,
            'controller'        => $controller,
            'all_games'         => (array)$all_games
        ]);

        if (file_exists(PUBLIC_PATH.DIRECTORY_SEPARATOR.'js'.DIRECTORY_SEPARATOR.$controller.'.js')) {
            $this->view->setVar('js_section', 'js/'.$controller.'.js');
        }

        if (BENCHMARK_ENABLED) {
            \Infolot\Benchmark::set_time('time_'.__CLASS__.'_'.__FUNCTION__, 1);
        }
    }

    /**
     * Muestra el vector en formato json
     *
     * @param   array   $data   Vector a mostrar
     *
     * @access  public
     * @return  string          Información en formato json
     */
    public function show_json($data)
    {
        $this->view->disable();

        header('Content-type: application/json; charset=utf-8');

        $json = json_encode($data);
        if ($error = json_last_error()) {
            switch ($error) {
                case JSON_ERROR_DEPTH: $data = array('error' => 'JSON: Superada profundidad'); break;
                case JSON_ERROR_SYNTAX: $data = array('error' => 'JSON: Error sintáctico'); break;
                case JSON_ERROR_UTF8: $data = array('error' => 'JSON: UTF-8 mal formado'); break;
                default: $data = array('error' => 'JSON: Error no contemplado');
            }

            echo json_encode($data);
        }

        echo $json;
    }
}
