<?php

use Infolot\Utilities;

class AboutController extends ControllerBase
{
    public function condicionesGeneralesAction()
    {
        $this->view->header_title = "Condiciones Generales";
        $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
    }

    public function quienesSomosAction()
    {
        $this->view->header_title = "Quienes Somos";
        $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
    }
}
