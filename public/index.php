<?php
declare(strict_types=1);

define('INI_TIME', microtime(true));
define('INI_MEM', memory_get_usage(true));
define('BENCHMARK_ENABLED', false);
define('XDEBUG_TRACE_ENABLED', false);

if (BENCHMARK_ENABLED) {
    require __DIR__.'/../app/library/Benchmark.php';
}

if (XDEBUG_TRACE_ENABLED && function_exists('xdebug_start_trace')) {
    ini_set('xdebug.collect_assignments', true);
    ini_set('xdebug.collect_return', true);
    ini_set('xdebug.log', __DIR__.'/cache/trace.log');
    ini_set('xdebug.log_level', 7);
    ini_set('xdebug.mode', 'develop,trace,debug,profile');
    ini_set('xdebug.output_dir', '/tmp');
    ini_set('xdebug.start_with_request', 'default');
    ini_set('xdebug.trace_format', 0);
    ini_set('xdebug.trace_options', 0);
    ini_set('xdebug.trace_output_name', 'trace.%c');
    ini_set('xdebug.trigger_value', '');
    ini_set('xdebug.use_compression', true);
    ini_set('xdebug.var_display_max_children', 128);
    ini_set('xdebug.var_display_max_data', 512);
    ini_set('xdebug.var_display_max_depth', 3);

    xdebug_start_trace();
}

header('Referrer-Policy: no-referrer-when-downgrade');

date_default_timezone_set('Europe/Madrid');
setlocale(LC_TIME, '');
setlocale(LC_ALL, 'es_ES');

use Infolot\Utilities;
use Phalcon\Di\FactoryDefault;

ini_set('precision', 14);
ini_set('phalcon.orm.disable_assign_setters', '1');
ini_set('phalcon.orm.cast_on_hydrate', '1');

define('BASE_PATH', dirname(__DIR__));
define('APP_PATH', BASE_PATH . '/app');

try {
    /**
     * The FactoryDefault Dependency Injector automatically registers
     * the services that provide a full stack framework.
     */
    $di = new FactoryDefault();
    if (BENCHMARK_ENABLED) {
        \Infolot\Benchmark::set_time('time_factory_default', 0);
    }

    /**
     * Read services
     */
    include APP_PATH . '/config/services.php';
    if (BENCHMARK_ENABLED) {
        \Infolot\Benchmark::set_time('time_services', 0);
    }

    /**
     * Get config service for use in inline setup below
     */
    $config = $di->getConfig();

    if (BENCHMARK_ENABLED) {
        \Infolot\Benchmark::set_time('time_config', 0);
    }

    if ($di->getShared('request')->getQuery('debug')) {
        $config->debug = true;
    }

    // Francis: Activamos el mostrar errores según el debug
    if ($config->debug) {
        //error_reporting(E_ALL & ~E_NOTICE & ~E_DEPRECATED);
        error_reporting(E_ALL & ~E_NOTICE & ~E_DEPRECATED & ~E_WARNING);
        ini_set('display_errors', 'On');
        ini_set('display_startup_errors', 'On');

        (new Phalcon\Support\Debug())->listen();
    } else {
        error_reporting(0);
        ini_set('display_errors', 'Off');
        ini_set('display_startup_errors', 'Off');
    }

    /**
     * Include Autoloader
     */
    include APP_PATH . '/config/loader.php';
    if (BENCHMARK_ENABLED) {
        \Infolot\Benchmark::set_time('time_loader', 0);
    }
    if ($config->debug) {
        /*$profiler = new \Fabfuel\Prophiler\Profiler();
        $profiler->addAggregator(new \Fabfuel\Prophiler\Aggregator\Database\QueryAggregator());
        $profiler->addAggregator(new \Fabfuel\Prophiler\Aggregator\Cache\CacheAggregator());

        $di->setShared('profiler', $profiler);

        $pluginManager = new \Fabfuel\Prophiler\Plugin\Manager\Phalcon($profiler);
        $pluginManager->register();
        die('llego');*/
    }
    $config->detect = (new \Infolot\Mobile_Detect);

    if (BENCHMARK_ENABLED) {
        \Infolot\Benchmark::set_time('time_mobile_detect', 0);
    }

    include APP_PATH . '/config/cache.php';

    if (BENCHMARK_ENABLED) {
        \Infolot\Benchmark::set_time('time_cache', 0);
    }

    // comprobar que los sorteos del buscador de números están al día antes de montar las rutas
    if (!$config->maintenance_enabled) {
        Utilities::checkSearchDraws();

        if (BENCHMARK_ENABLED) {
            \Infolot\Benchmark::set_time('time_check_search_draws', 0);
        }
    }

    /**
     * Handle routes
     */
    include APP_PATH . '/config/router.php';

    /**
     * Handle the request
     */
    if (BENCHMARK_ENABLED) {
        \Infolot\Benchmark::set_time('time_router', 0);
    }

    $application = new \Phalcon\Mvc\Application($di);

    if (BENCHMARK_ENABLED) {
        \Infolot\Benchmark::set_time('time_application_build', 0);
    }

    $handle = $application->handle($_SERVER['REQUEST_URI']);

    if (BENCHMARK_ENABLED) {
        \Infolot\Benchmark::set_time('time_application_handle', 0);
    }

    echo $handle->getContent();

    if (BENCHMARK_ENABLED) {
        \Infolot\Benchmark::set_time('time_end', 0);

        $mem = memory_get_usage(true);
        echo Utilities::parseTemplate('layouts/boxs/box_benchmark', [
            'benchmark_times'          => \Infolot\Benchmark::get_times(),
            'benchmark_mem'            => sprintf('+%.2f MB (%.2f MB)', ($mem - INI_MEM) / 1048576, $mem / 1048576)
        ]);
        /*$toolbar = new \Fabfuel\Prophiler\Toolbar($profiler);
        $toolbar->addDataCollector(new \Fabfuel\Prophiler\DataCollector\Request());
        echo $toolbar->render();*/
    }
    // try {
    //     echo $application->handle()->getContent();
    // } catch (\Throwable $th) {
    // } catch (Error $th) {
    //     var_dump($th);
    //     exit(0);
    // }
} catch (\Throwable $e) {
    if ($config->debug) {
        echo '<pre>';
        echo '<hr/><h1>'.$e->getFile().':'.$e->getLine().'</h1><hr/>'.PHP_EOL;
        echo $e->getMessage() .PHP_EOL;
        echo $e->getTraceAsString().PHP_EOL;
        echo '</pre>';
    } else {
        echo $e->getMessage() . '<br>';
        echo '<pre>' . $e->getTraceAsString() . '</pre>';
        $ar = array(
            "error" => "Unhandled Exception: " . $e->getMessage()
        );

        return json_encode($ar);
    }
} catch (\Error $e) {
    if ($config->debug) {
        echo '<pre>';
        echo '<hr/><h1>'.$e->getFile().':'.$e->getLine().'</h1><hr/>'.PHP_EOL;
        echo $e->getMessage() .PHP_EOL;
        echo $e->getTraceAsString().PHP_EOL;
        echo '</pre>';
    } else {
        $ar = array(
            "error" => "Unhandled Error: " . $e->getMessage()
        );

        return json_encode($ar);
    }
}
