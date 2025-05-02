<?php

class TestController extends ControllerBase
{
    public function showPhpInfoAction()
    {
        $this->view->disable();
        phpinfo();
    }

    public function cartAction()
    {
        $this->view->disable();

        echo '<pre>';
        print_r($this->session->get('cart_ws'));
    }

    public function traceAction()
    {
        if (function_exists('xdebug_stop_trace')) {
            xdebug_stop_trace();

            printf('Fichero: %s'.PHP_EOL, xdebug_get_tracefile_name());

            xdebug_info();
        } else {
            $this->show_json([
                'error'        => 'No Xdebug support'
            ]);
        }
    }

    public function cacheGeneralAction()
    {
        $this->view->disable();

        $time = microtime(true);

        /*echo '<h1>Ciudades</h1>';
        var_dump($this->getDI()->getShared('infocities'));
        echo '<h1>Provincias</h1>';
        var_dump($this->getDI()->getShared('infoprovinces'));
        echo '<h1>Paises</h1>';
        var_dump($this->getDI()->getShared('infocountries'));
        echo '<h1>Juegos</h1>';
        var_dump($this->getDI()->getShared('getgames'));
        echo '<h1>Sorteos</h1>';
        var_dump($this->getDI()->getShared('infonextdrawsgeneral'));
        echo '<h1>Sorteos Navidad</h1>';
        var_dump($this->getDI()->getShared('infonextdrawsnavidad'));
        echo '<h1>Sorteos Niño</h1>';
        var_dump($this->getDI()->getShared('infonextdrawsnino'));
        echo '<h1>Ultimos Resultados</h1>';
        var_dump($this->getDI()->getShared('lastgameresults'));*/
        echo '<h1>Botes</h1>';
        var_dump($this->getDI()->getShared('infonextjackpots'));

        echo '<hr/>';
        printf('%.8f sec.', microtime(true) - $time);
        echo '<hr/>';
        exit;
    }
}
