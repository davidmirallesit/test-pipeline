<?php

namespace Infolot\Plugins;

use \Phalcon\Events\Event;
use \Phalcon\Di\Injectable;
use \Phalcon\Mvc\Dispatcher as MvcDispatcher;

/**
 * CanonicalUrlPlugin
 *
 * Evita que la URL se pueda llamar con y sin barra final para evitar duplicados
 */
#[\AllowDynamicProperties]
class CanonicalUrlPlugin extends Injectable
{
    /**
     * This action is executed before perform any action in the application
     *
     * @param Event $event
     * @param MvcDispatcher $dispatcher
     * @return boolean
     */
    public function beforeExecuteRoute(Event $event, MvcDispatcher $dispatcher)
    {
        $url = $this->request->getUri();
        //$url = $this->router->getRewriteUri();

        // Si no es portada, si no es un fichero (contiene punto), termina en barra y no tiene parámetros redirigimos a barra
        if ($url != '/' && !preg_match('|\.|', $url) && preg_match('|/$|', $url) && !preg_match('|\?|', $url)) {
            $this->response->redirect(rtrim($url, '/'), true, 301);

            return false;
        }
    }
}
