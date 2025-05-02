<?php

use Phalcon\Mvc\View;
use Phalcon\Support\HelperFactory;

use \Infolot\Phalcon\Mvc\View\Engine\Volt as VoltEngine;
use Infolot\Utilities;
use Infolot\CustomView;
//use Phalcon\Mvc\View\Engine\Volt as VoltEngine;
use Phalcon\Mvc\Url as UrlResolver;
use Phalcon\Mvc\Model\Metadata\Memory as MetaDataAdapter;
use Phalcon\Mvc\Dispatcher as MvcDispatcher;
use Phalcon\Dispatcher\Exception as DispatcherException;
//use Phalcon\Tag;
use Phalcon\Html\Escaper;
use Phalcon\Html\TagFactory;

use Phalcon\Session\Manager as SessionManager;
use Phalcon\Storage\SerializerFactory;
use Phalcon\Storage\AdapterFactory as SessionAdapterFactory;
use Phalcon\Session\Adapter\Stream as SessionStream;
use Phalcon\Session\Adapter\Redis as SessionRedis;

use Phalcon\Flash\Session as Flash;

use Phalcon\Encryption\Crypt;

use Phalcon\Logger\Logger;
use Phalcon\Logger\Adapter\Stream as FileLogger;
use Phalcon\Logger\Formatter\Line as FormatterLine;

/**
 * Shared configuration service
 */
$di->setShared('config', function () {
    return include APP_PATH . "/config/config.php";
});

/**
 * The URL component is used to generate all kind of urls in the application
 */
$di->setShared('url', function () {
    $config = $this->getConfig();

    $url = new UrlResolver();
    $url->setBaseUri($config->application->baseUri);

    return $url;
});

$di->setShared('tag', function () {
    $escaper = new Escaper();
    $factory = new TagFactory($escaper);
    //$tag = new Tag();
    //return $tag;

    return $factory;
});

$di->setShared('voltService', function (\Phalcon\Mvc\View $view) {
    $config = $this->getConfig();

    $volt = new VoltEngine($view, $this);
    $voltCacheDir = $config->application->cacheDir . 'volt' . DIRECTORY_SEPARATOR . $config->application->defaultTemplate . DIRECTORY_SEPARATOR;

    if (!is_dir($voltCacheDir)) {
        mkdir($voltCacheDir);
    }

    $volt->setOptions([
        'always'    => true,
        'separator' => '_',
        'stat'      => true,
        // la cache de las plantillas debera estar en una carpeta al mismo nivel que default
        'path'      => $voltCacheDir,
    ]);

    $compiler = $volt->getCompiler();
    // si es el compilador custom no hay que completarlo, se hace en el construct
    if (strpos(get_class($compiler), 'Infolot') === false){
        \Infolot\Utilities::completeCompiler($compiler);
    }

    return $volt;
});

/**
 * Setting up the view component
 */
$di->setShared('view', function () use ($di) {
    $config = $this->getConfig();

    $view = new CustomView();
    $view->setViewsDir($config->application->viewsDir);

    $view->setEventsManager($di->getShared('eventsManager'));
    $view->registerEngines([
        '.volt' => 'voltService'
    ]);

    return $view;
});

$di->setShared('helper', function () {
    return new HelperFactory();
});

/**
 * Database connection is created based in the parameters defined in the configuration file
 */
/*$di->setShared('db', function () {
    $config = $this->getConfig();

    $class = 'Phalcon\Db\Adapter\Pdo\\' . $config->database->adapter;
    $params = [
        'host'     => $config->database->host,
        'username' => $config->database->username,
        'password' => $config->database->password,
        'dbname'   => $config->database->dbname,
        'charset'  => $config->database->charset
    ];

    if ($config->database->adapter == 'Postgresql') {
        unset($params['charset']);
    }

    $connection = new $class($params);

    return $connection;
});*/


/**
 * Database connection is created based in the parameters defined in the configuration file
 */
// $di->setShared('db_panel', function () {
//     $config = $this->getConfig();

//     $class = 'Phalcon\Db\Adapter\Pdo\\' . $config->db_panel->adapter;
//     $params = [
//         'host'     => $config->db_panel->host,
//         'username' => $config->db_panel->username,
//         'password' => $config->db_panel->password,
//         'dbname'   => $config->db_panel->dbname,
//         'charset'  => $config->db_panel->charset
//     ];

//     if ($config->db_panel->adapter == 'Postgresql') {
//         unset($params['charset']);
//     }

//     $connection = new $class($params);

//     return $connection;
// });


/**
 * If the configuration specify the use of metadata adapter use it or use memory otherwise
 */
/*$di->setShared('modelsMetadata', function () {
    return new MetaDataAdapter();
});*/

/**
 * Register the session flash service with the Twitter Bootstrap classes
 */
$di->setShared('flash', function () {
    $escaper = new Escaper();
    $flash   = new Flash($escaper);

//    $flash->setCssIconClasses([
//        'error'   => 'fas fa-ban',
//        'success' => 'fas fa-check-circle',
//        'notice'  => 'fas fa-info-circle',
//        'warning' => 'fas fa-exclamation-triangle'
//    ]);

    $flash->setCssClasses([
        'error'   => 'alert alert-danger',
        'success' => 'alert alert-success',
        'notice'  => 'alert alert-info',
        'warning' => 'alert alert-warning'
    ]);

    return $flash;
});

$di->setShared('crypt', function () {
    $crypt = new Crypt();

    /**
     * Set the cipher algorithm.
     *
     * The `aes-256-gcm' is the preferable cipher, but it is not usable until the
     * openssl library is upgraded, which is available in PHP 7.1.
     *
     * The `aes-256-ctr' is arguably the best choice for cipher
     * algorithm in these days.
     */
    $crypt->setCipher('aes-256-ctr');

    /**
     * Setting the encryption key.
     *
     * The key should have been previously generated in a cryptographically safe way.
     *
     * Bad key:
     * "le password"
     *
     * Better (but still unsafe):
     * "#1dj8$=dp?.ak//j1V$~%*0X"
     *
     * Good key:
     * "T4\xb1\x8d\xa9\x98\x054t7w!z%C*F-Jk\x98\x05\x5c"
     *
     * Use your own key. Do not copy and paste this example key.
     */
    // $key = "T4\xb1\x8d\xa9\x98\x054t7w!z%C*F-Jk\x98\x05\x5c";
    $key = "\x79\x5b].avu\x2c=/Z\x5d23],-\x69Bica-[\x2c,\x2cYi61]";

    $crypt->setKey($key);

    return $crypt;
});

$di->setShared('dispatcher', function () use ($di) {
    $evManager = $di->getShared('eventsManager');

    // Camelize actions: Para llegar al métido camelized (ej: MiFuncionAction)
    // Seteamos Controller::Action por defecto
    $evManager->attach(
        "dispatch:beforeDispatchLoop",
        function ($event, $dispatcher) {
            $dispatcher->setDefaultController('error');
            $dispatcher->setDefaultAction('show404');
        }
    );

    // $evManager->attach(
    //     'view:beforeRender',
    //     // new \Infolot\Plugins\CustomTemplatePlugin
    //     function ($view) use ($di) {
    //         var_dump($view);
    //         exit(0);
    //     }
    // );

    // Esto no hace falta porque el customView ya se encarga de cambiar los templates
    // $evManager->attach(
    //     'view:beforeRenderView',
    //     // new \Infolot\Plugins\CustomTemplatePlugin
    //     function ($event, $view, $path) use ($di) {
    //         $router = $di->getShared("router");
    //         $config = $di->getShared("config");
    //         $template = $router->getControllerName() . '/' .$router->getActionName();
    //         $oldDir = $view->getViewsDir();
    //         $view->setViewsDir($config->application->templatesDir);
    //         if (!Utilities::template_exists($template)) {
    //             $view->setViewsDir($oldDir);
    //         }
    //     }
    // );
    
    // $evManager->attach(
    //     'view:afterRender',
    //     // new \Infolot\Plugins\CustomTemplatePlugin
    //     function (...$params) use ($di) {
    //         var_dump($params);
    //         exit(0);
    //     }
    // );
    
    // $evManager->attach(
    //     //no interrumpe
    //     'view:afterRenderView',
    //     // new \Infolot\Plugins\CustomTemplatePlugin
    //     function (...$params) use ($di) {
    //         var_dump($params);
    //         exit(0);
    //     }
    // );

    // $evManager->attach(
    //     //no interrumpe
    //     'view:notFoundView',
    //     // new \Infolot\Plugins\CustomTemplatePlugin
    //     function (...$params) use ($di) {
    //         var_dump($params);
    //         exit(0);
    //     }
    // );

    //TODO la function include meterla en el completeCompiler
    //TODO o crear un CustomVolt y sobreescribir ahi el metodo include

    //TODO la variable de si tiene un tema custom se tiene que pasar en el pvInfo, de momento injectarla en la cache de docker

    $evManager->attach(
        "dispatch:beforeException",
        function ($event, $dispatcher, $exception) use ($di) {
            switch ($exception->getCode()) {
                case DispatcherException::EXCEPTION_HANDLER_NOT_FOUND:
                case DispatcherException::EXCEPTION_ACTION_NOT_FOUND:
                    // $server_name = $_SERVER['SERVER_NAME'];
                    // try {
                        // $server_name = idn_to_ascii($server_name);
                    // } catch (\Error $e) {
                    // }

                    // $community_exists = file_exists($community_path = $di->getConfig()->application->admonsDir . $server_name . '/communities' . $_SERVER['REQUEST_URI'] . '.ini');

                    // if ($community_exists) {
                    //     $dispatcher->forward(
                    //         array(
                    //             'controller' => 'sections',
                    //             'action'     => 'ventaParticipacionesWithKeyword',
                    //             'params' => ["keyword" => $_SERVER['REQUEST_URI']]
                    //         )
                    //     );
                    // } else {
                        $dispatcher->forward(
                            array(
                                'controller' => 'error',
                                'action'     => 'show404'
                            )
                        );
                    // }
                    return false;
            }
        }
    );

    /**
     * Handle canonical URL to avoid duplicated URL and URL/
     */
    $evManager->attach(
        'dispatch:beforeExecuteRoute',
        new \Infolot\Plugins\CanonicalUrlPlugin
    );

    $dispatcher = new MvcDispatcher();
    $dispatcher->setEventsManager($evManager);
    return $dispatcher;
});

/**
 * Start the session the first time some component request the session service
 */
$di->setShared('session', function () {
    $config            = $this->getConfig();
    $session           = new SessionManager();

    $options = [
        'defaultSerializer' => $config->session->defaultSerializer,
        'prefix'            => $config->session->prefix,
        'lifetime'          => $config->session->lifetime
    ];

    if ($config->cache_backends->redis->enabled && extension_loaded('redis')) {
        $options['statsKey'] = '_PHCR';
        $options['host']     = $config->cache_backends->redis->host;
        $options['port']     = $config->cache_backends->redis->port;
        $options['auth']     = $config->cache_backends->redis->auth;
        $options['timeout']  = 1;

        // Importante, para que las ponga en un almacen separado del resto de cache
        // y así se pueda hacer un flush sobre el objecto cache, sin que se eliminen
        // las sesiones
        $options['index']  = $config->cache_backends->redis->session_index;

        $session->setOptions($options);

        $serializerFactory = new SerializerFactory();
        $factory           = new SessionAdapterFactory($serializerFactory);
        $adapter           = new SessionRedis($factory, $options);
    } else {
        $options['savePath'] = '/tmp';

        $adapter = new SessionStream($options);
    }

    $session->setAdapter($adapter)->start();

    return $session;
});

/*$di->setShared('session', function () {
    $config = $this->getConfig();

    $session = new \Infolot\Session([
        'table'       => 'user_session',
        'db'          => $this->getShared('db_panel'),
        'id_web'      => $config->baseconfig->id_web,
        'maxlifetime' => 691200 // 8 días (en segundos)
    ]);
    $session->start();

    return $session;
});*/

/**
 * Logger service
 */
$di->setShared('logger', function ($filename = null, $format = null) use ($di) {
    $config = $di->getConfig();

    $filename = trim($filename ?: $config->logger->filename, '\\/');
    $path     = rtrim($config->logger->path, '\\/') . DIRECTORY_SEPARATOR;

    // Formato
    $format    = $format ?: $config->logger->format;
    $formatter = new FormatterLine($format, $config->logger->date);

    // Log en fichero + Formato
    $adapter   = new FileLogger($path . $filename/*, ['mode' => 'ab']*/);
    $adapter->setFormatter($formatter);

    $logger    = new Logger('messages', ['main' => $adapter]);
    $logger->setLogLevel($config->logger->logLevel);

    return $logger;
});

$di->setShared('infocities', function () use ($di) {
    $config = $di->getConfig();
    $cache  = $di->getShared('cache');
    $name   = 'infocities';
    $key    = $config->cache->base_config_key . $name;

    if ($cache->has($key)) {
        return $cache->get($key);
    }

    return [];
});

$di->setShared('infoprovinces', function () use ($di) {
    $config = $di->getConfig();
    $cache  = $di->getShared('cache');
    $name   = 'infoprovinces';
    $key    = $config->cache->base_config_key . $name;

    if ($cache->has($key)) {
        return $cache->get($key);
    }

    return [];
});

$di->setShared('infocountries', function () use ($di) {
    $config = $di->getConfig();
    $cache  = $di->getShared('cache');
    $name   = 'infocountries';
    $key    = $config->cache->base_config_key . $name;

    if ($cache->has($key)) {
        return $cache->get($key);
    }

    return [];
});

$di->setShared('getgames', function () use ($di) {
    $config = $di->getConfig();
    $cache  = $di->getShared('cache');
    $name   = 'getgames';
    $key    = $config->cache->base_config_key . $name;

    if ($cache->has($key)) {
        return $cache->get($key);
    }

    return [];
});

$di->setShared('infonextdrawsgeneral', function () use ($di) {
    $config = $di->getConfig();
    $cache  = $di->getShared('cache');
    $name   = 'infonextdrawsgeneral';
    $key    = $config->cache->base_config_key . $name;

    if ($cache->has($key)) {
        return $cache->get($key);
    }

    return [];
});

$di->setShared('infonextdrawsnavidad', function () use ($di) {
    $config = $di->getConfig();
    $cache  = $di->getShared('cache');
    $name   = 'infonextdrawsnavidad';
    $key    = $config->cache->base_config_key . $name;

    if ($cache->has($key)) {
        return $cache->get($key);
    }

    return [];
});

$di->setShared('infonextdrawsnino', function () use ($di) {
    $config = $di->getConfig();
    $cache  = $di->getShared('cache');
    $name   = 'infonextdrawsnino';
    $key    = $config->cache->base_config_key . $name;

    if ($cache->has($key)) {
        return $cache->get($key);
    }

    return [];
});

$di->setShared('getseodraws', function () use ($di) {
    $config = $di->getConfig();
    $cache  = $di->getShared('cache');
    $name   = 'getseodraws';
    $key    = $config->cache->base_config_key . $name;

    if ($cache->has($key)) {
        return $cache->get($key);
    }

    return [];
});

$di->setShared('lastgameresults', function () use ($di) {
    $config = $di->getConfig();
    $cache  = $di->getShared('cache');
    $name   = 'lastgameresults';
    $key    = $config->cache->base_config_key . $name;

    if ($cache->has($key)) {
        return $cache->get($key);
    }

    return [];
});

$di->setShared('infonextjackpots', function () use ($di) {
    $config = $di->getConfig();
    $cache  = $di->getShared('cache');
    $name   = 'infonextjackpots';
    $key    = $config->cache->base_config_key . $name;

    if ($cache->has($key)) {
        return $cache->get($key);
    }

    return [];
});
