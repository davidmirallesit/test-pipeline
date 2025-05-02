<?php

declare(strict_types=1);

use Infolot\Extranet;

class ValidateController extends ControllerBase
{
    public function indexAction()
    {
        // 1) Comprobamos que nos llega token
        $token = $this->request->getQuery('token');
        if (empty($token)) {
            return self::show404();
        }

        // 2) Intentamos validarlo
        $res = Extranet::validate_token([
            'token' => $token
        ]);

        if (empty($res) || isset($res['error']) || isset($res['code'])) {
            return self::show404();
        }

        // 3) Realizamos la operación con los datos recogidos
        $data = $res['data'];
        switch ($data['op']) {
                // 3.1) Login
            case 'REMOTE_LOGIN':
                $this->session->set('user', $data);

                if (!empty($data['redirect_url'])) {
                    return $this->response->redirect($data['redirect_url']);
                }

                return $this->response->redirect('/');
                break;

            case 'REMOTE_LOGOUT':
                $this->session->remove('user');

                if (!@empty($data['redirect_url'])) {
                    return $this->response->redirect($data['redirect_url']);
                }

                return $this->response->redirect('/');
                break;
        }

        return self::show404();
    }

    /**
     * Sirve para mostrar página no encontrada
     */
    public static function show404()
    {
        $di         = \Phalcon\Di\Di::getDefault();
        $dispatcher = $di->getShared('dispatcher');

        return $dispatcher->forward([
            'namespace'  => $dispatcher->getNamespaceName(),
            'module'     => $dispatcher->getModuleName(),
            'controller' => 'error',
            'action'     => 'show404',
            'params'     => []
        ]);
    }
}
