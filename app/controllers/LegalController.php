<?php

use Infolot\Utilities;

class LegalController extends ControllerBase
{
    public function avisoLegalAction()
    {
        $this->view->header_title = "Aviso Legal";
        $this->view->active_menu = "";
        $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
    }
    public function politicaCookiesAction()
    {
        $this->view->header_title = "Política de Cookies";
        $this->view->active_menu = "";
        $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
    }

    public function politicaPrivacidadAction()
    {
        $this->view->header_title = "Política de Privacidad";
        $this->view->active_menu = "";
        $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
    }
}
