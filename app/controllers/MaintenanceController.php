<?php

class MaintenanceController extends ControllerBase
{
    public function indexAction()
    {
        $this->session->destroy();
        // $this->view->setVar('html', $this->cfg['msg_maintenance']);
    }
}
