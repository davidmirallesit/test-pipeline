<?php


namespace Infolot;

class CustomView extends \Phalcon\Mvc\View
{
    /**
     * This action is executed before perform any action in the application
     *
     * @param string $controllerName
     * @param string $actionName
     * @param array $params
     * @param bool $fireEvents
     * @return bool
     */
    public function processRender(string $controllerName, string $actionName, array $params = [], bool $fireEvents = true) : bool {
        $di = \Phalcon\Di\Di::getDefault();
        $router = $di->getShared("router");
        $config = $di->getShared("config");

        // si no tiene definida la plantilla o es la default se sigue como de normal
        if (!property_exists($config->datosadmon->data, 'template') || $config->datosadmon->data->template == $config->application->defaultTemplate) {
            return parent::processRender($controllerName, $actionName, $params, $fireEvents);
        }

        $template = $router->getControllerName() . DIRECTORY_SEPARATOR . $router->getActionName();

        if ($router->getControllerName() == 'results' || $router->getControllerName() == 'buy') {
            $params = $router->getParams();
            $template = $router->getControllerName() . DIRECTORY_SEPARATOR . $params['id_game'];
            if (!Utilities::template_exists($template)) {
                $template = $router->getControllerName() . DIRECTORY_SEPARATOR . 'type-' . $params['id_type'];
            }
        }

        $this->setViewsDir($config->application->templatesDir . $config->datosadmon->data->template . DIRECTORY_SEPARATOR);
        // si la plantilla no tiene la vista se vuelve a la default
        if (!Utilities::template_exists($template)) {
            $this->setViewsDir($config->application->viewsDir);
        }

        // borrado de cache de las plantillas cuando se está desarrollando
        if ($config->local) {
            $cache_volt = $config->application->cacheDir . 'volt' . DIRECTORY_SEPARATOR . $config->datosadmon->data->template . DIRECTORY_SEPARATOR;
            array_map('unlink', glob($cache_volt.'*.php'));
        }

        return parent::processRender($controllerName, $actionName, $params, $fireEvents);
    }
}