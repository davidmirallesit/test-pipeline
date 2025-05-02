<?php

use Infolot\Utilities;

/**
 * ErrorController
 */
class ErrorController extends ControllerBase
{
    public function show404Action()
    {
        $this->response->setStatusCode(404, 'Not Found');
        $this->view->pick('404/404');
    }
}
