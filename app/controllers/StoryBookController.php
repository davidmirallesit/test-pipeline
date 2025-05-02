<?php

class StoryBookController extends ControllerBase 
{
    public $template_folder  = '';
    public $storybook_folder = 'storybook-static';

    public function beforeExecuteRoute()
    {
        $di = \Phalcon\Di\Di::getDefault();

        // si no tiene definida la plantilla o es la default no se debe mostrar la documentación de las custom
        if (!property_exists($this->config->datosadmon->data, 'template') || $this->config->datosadmon->data->template == $this->config->application->defaultTemplate) {
            $dispatcher = $di->getShared('dispatcher');        
            return $dispatcher->forward([
                'namespace'  => $dispatcher->getNamespaceName(),
                'module'     => $dispatcher->getModuleName(),
                'controller' => 'error',
                'action'     => 'show404',
                'params'     => []
            ]);
        }

        // la plantilla con documentacion es la de secondary
        $this->template_folder = APP_PATH . DIRECTORY_SEPARATOR . $this->config->application->templatesDir . "secondary" . DIRECTORY_SEPARATOR . $this->storybook_folder . DIRECTORY_SEPARATOR;

        if (method_exists(parent::class, 'beforeExecuteRoute')) {
            return parent::beforeExecuteRoute();
        }
    }

    public function indexAction()
    {
        // Comprueba si el usuario está autenticado
        if (!$this->checkUser()) {
            $this->view->pick("storybook/index");
            return;
        }

        // Deshabilita el layout y la vista por defecto ya que serviremos un HTML estático
        $this->view->disable();

        // Lee y devuelve el contenido del archivo HTML estático
        $html = file_get_contents($this->template_folder . "/index.html");

        $html = str_replace(
            '<head>',
            '<head><base href="/storybook/">',
            $html
        );

        $this->response->setContent($html);
        return $this->response;
    }

    public function staticAction()
    {
        // Comprueba si el usuario está autenticado
        if (!$this->checkUser()) {
            $this->view->pick("storybook/index");
            return;
        }

        $this->view->disable();

        // Obtiene la ruta del archivo solicitado
        $filePath = $this->dispatcher->getParam('file');
        $fullPath = $this->template_folder . $filePath;

        $extension = pathinfo($fullPath, PATHINFO_EXTENSION);

        // Establece el tipo de contenido correcto basado en la extensión del archivo

        $contentTypes = [
            'css'  => 'text/css',
            'js'   => 'application/javascript',
            'png'  => 'image/png',
            'jpg'  => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'gif'  => 'image/gif',
            'svg'  => 'image/svg+xml',
            'html' => 'text/html',
            'json' => 'application/json'
        ];

        if (isset($contentTypes[$extension])) {
            $this->response->setContentType($contentTypes[$extension]);
        }

        // Lee y devuelve el contenido del archivo
        $this->response->setStatusCode(200, 'OK');
        $content = file_get_contents($fullPath);
        $this->response->setContent($content);
        return $this->response;
    }

    private function checkUser()
    {
        if ($this->session->has('docs')) {
            $post = $this->session->get('docs');
        } else {
            $post = $this->getInput(false);
        }

        if (empty($post)) {
            return false;
        }

        if (!array_key_exists('user', $post) || !array_key_exists('password', $post)) {
            $this->view->setVar("loginError", 'Usuario y contraseña incorrectos');
            return false;
        }

        if ($post['user'] != $this->config->docs->user || $post['password'] != $this->config->docs->password) {
            $this->view->setVar("loginError", 'Usuario y contraseña incorrectos');
            return false;
        }

        $this->session->set('docs', [
            "user"     => $post['user'],
            "password" => $post['password']
        ]);

        return true;
    }

    private function getInput($includeQuery = true)
    {
        $post = [];
        if (count($this->request->getPost())) {
            $post = $this->request->getPost();
        } elseif ($raw = file_get_contents('php://input')) {
            $json  = json_decode($raw, true);

            if (is_array($json) && $raw != $json) {

                // Miramos si es un vector [ {name: ..., value: ...}, ... ] y lo convertimos a asociativo
                if (is_array($json[0]) && count($json[0]) == 2 && isset($json[0]['name']) && isset($json[0]['value'])) {
                    $post = array();
                    foreach ($json as $v) {
                        $post[$v['name']] = $v['value'];
                    }
                } else {
                    $post = $json;
                }
            } else {
                parse_str($raw, $post);
            }
        } elseif ($includeQuery && count($this->request->getQuery())) {
            $post = $this->request->getQuery();
        }

        return $post;
    }
}