<?php

use Infolot\Utilities;

class SearchController extends ControllerBase
{
    public function initialize()
    {
        parent::initialize();
        $this->urls = explode('/', $_SERVER["REQUEST_URI"]);
        array_shift($this->urls);
        $drawId = $this->config->get('datosadmon')->data->searcher->search_draw_assigned->{$this->urls[0]};
        $this->draw = Utilities::getSearchDrawsByNameSeo($drawId);
        $this->view->searcher_url = Utilities::getSearchUrlFromIdDraw($this->draw['id']);
        $stockInCart = [];
        $cart = $this->session->get('cart_ws');
        if (!is_null($cart)) {
            foreach ($cart as $value) {
                if (array_key_exists('number', $value)) {
                    $stockInCart[$value["number"]] = $value["quantity"];
                }
            }
        }
        $this->view->setVars([
            "draw_url"   => "/" . $this->urls[0],
            "search_url" => "/" . $this->urls[1],
            "number_url" => "/" . (array_key_exists(2, $this->urls) ? $this->urls[2] : ''),
            "draw" => $this->draw,
            "stockInCart" => $stockInCart,
        ]);
        $this->view->proximos_sorteos_10 = null;
        $this->view->sorteo_id = null;
    }

    public function indexAction()
    {
        if ($this->draw["date_draw"] > date('Y-m-d H:i:s') && $this->draw["date_publish"] < date('Y-m-d H:i:s')) {
            $randomNumbers = Utilities::getNewRestful('pv_draw_numbers', 'POST', ["id_draw" => $this->draw["id_draw"], "limit" => 1, "ignore_date_publish" => true])->body;
            if (!isset($randomNumbers->error) && !empty($randomNumbers->data)) {
                $hasStock = true;
            } else {
                $hasStock = false;
            }
        } else {
            $hasStock = false;
        }

        $this->view->setVars([
            "web_seo_onpage" => Utilities::getWebSeoOnpage(),
            "hasStock" => $hasStock,
        ]);
    }

    public function tailNumberAction($number = null)
    {
        $tailNumber = str_pad($number, 5, '*', STR_PAD_LEFT);
        $randomNumbers = [];
        $pv_draw_numbers = [];

        //si el sorteo no ha pasado y ya está publicado se busca stock
        if ($this->draw["date_draw"] > date('Y-m-d H:i:s') && $this->draw["date_publish"] < date('Y-m-d H:i:s')) {
            if (!is_null($this->draw)) {
                $pv_draw_numbers = Utilities::getNewRestful('pv_draw_numbers', 'POST', array("id_draw" => $this->draw["id_draw"], "order" => 'asc', "number" => $tailNumber, "limit" => 99, "ignore_date_publish" => true))->body->data;
            }
    
            if (count($pv_draw_numbers) == 0) {
                $randomNumbers = Utilities::getNewRestful('pv_draw_numbers', 'POST', array("id_draw" => $this->draw["id_draw"], "limit" => 30, "ignore_date_publish" => true))->body;
                if (!isset($randomNumbers->error) && !empty($randomNumbers->data)) {
                    $randomNumbers = $randomNumbers->data;
                }
            }
        }

        $cart = $this->session->get('cart_ws');
        $numbersInCart = [];

        if (isset($cart) && is_array($cart)) {
            foreach ($cart as $value) {
                if ($value['id_game'] == $this->idLn && $this->draw['id_draw'] == $value['id_draw']) {
                    $numbersInCart[] = $value['number'];
                }
            }
        }

        $this->view->setVars([
            "numbers"        => $pv_draw_numbers,
            "number"         => $number,
            "web_seo_onpage" => Utilities::getWebSeoOnpage(),
            "randomNumbers"  => $randomNumbers,
            "numbersInCart"  => $numbersInCart,
            "show_availability" =>     $this->config->datosAdmon->data->show_availability,
            "show_min_availability" => $this->config->datosAdmon->data->show_min_availability,
        ]);
    }

    public function fullNumberAction($number = null)
    {
        $pv_draw_number = null;
        $randomNumbers = [];
        $stock = 0;

        if (!is_null($this->draw)) {
            if ($this->draw["date_draw"] > date('Y-m-d H:i:s') && $this->draw["date_publish"] < date('Y-m-d H:i:s')) {
                $pv_draw_number = Utilities::getNewRestful('pv_draw_numbers', 'POST', array("id_draw" => $this->draw["id_draw"], "number" => $number, "limit" => 1, "ignore_date_publish" => true))->body;
            }
        }

        if (!is_null($pv_draw_number) && !isset($pv_draw_number->error) && !empty($pv_draw_number->data)) {
            $stock = $pv_draw_number->data[0]->available;
        }

        if ($stock == 0) {
            if ($this->draw["date_draw"] > date('Y-m-d H:i:s') && $this->draw["date_publish"] < date('Y-m-d H:i:s')) {
                $randomNumbers = Utilities::getNewRestful('pv_draw_numbers', 'POST', array("id_draw" => $this->draw["id_draw"], "limit" => 30, "ignore_date_publish" => true))->body;
                if (!isset($randomNumbers->error) && !empty($randomNumbers->data)) {
                    $randomNumbers = $randomNumbers->data;
                }
            }
        }

        $this->view->setVars([
            "number" => $number,
            "stock" => $stock,
            "randomNumbers" => $randomNumbers,
            "web_seo_onpage" => Utilities::getWebSeoOnpage(),
            "show_availability" =>     $this->config->datosAdmon->data->show_availability,
            "show_min_availability" => $this->config->datosAdmon->data->show_min_availability,
        ]);
    }

    public function redirectToFullNumberAction($number = null)
    {
        $url = explode('/', $this->request->getUri());
        array_pop($url);
        $url = implode('/', $url) . $this->config->search_urls["fullNumber"] . $number;

        //Redirigir al numero concreto
        return $this->response->redirect($url, false, 301);
    }
}
