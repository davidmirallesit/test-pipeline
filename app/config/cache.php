<?php
use Phalcon\Cache\Cache;
use Phalcon\Cache\AdapterFactory;
use Phalcon\Storage\SerializerFactory;

use Infolot\Utilities;

if (BENCHMARK_ENABLED) {
    \Infolot\Benchmark::set_time('time_include_cache', 1);
}

$di->setShared('cache', function () use ($di) {
    $config            = $di->getShared('config');
    $serializerFactory = new SerializerFactory();
    $adapterFactory    = new AdapterFactory($serializerFactory);

    $defaultSerializer = $config->cache_backends->params->defaultSerializer;
    $lifetime          = $config->cache_backends->params->lifetime;
    $prefix            = $config->cache_backends->params->prefix;

    if ($config->cache_backends->redis->enabled && extension_loaded('redis')) {
        $adapter = $adapterFactory->newInstance('redis', [
            'defaultSerializer' => $defaultSerializer,
            'lifetime'          => $lifetime,
            'prefix'            => $prefix,
            'persistent'        => true,
            'host'              => $config->cache_backends->redis->host,
            'port'              => $config->cache_backends->redis->port,
            'auth'              => $config->cache_backends->redis->auth,
            'index'             => $config->cache_backends->redis->index
        ]);
    }

    return new Cache($adapter);
});

if (BENCHMARK_ENABLED) {
    \Infolot\Benchmark::set_time('time_define_service_cache', 1);
}

//completar el config.php
Utilities::completeConfigFromCache();

if (BENCHMARK_ENABLED) {
    \Infolot\Benchmark::set_time('time_complete_config_cache', 1);
}

if (!is_null($config->datosadmon) && property_exists($config->datosadmon, 'data') && !is_null($config->datosadmon->data->cod_receptor)) {
    defined('RECEPTOR_ID') || define('RECEPTOR_ID', $config->datosadmon->data->cod_receptor);
} else {
    defined('RECEPTOR_ID') || define('RECEPTOR_ID', "ERROR");
}

if (BENCHMARK_ENABLED) {
    \Infolot\Benchmark::set_time('time_constants', 1);
}
