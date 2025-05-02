<?php
/**
 * Script que será invocado para actualizar la web desde un repositorio GIT
 *
 * @user: Francis V. Romera
 * @date: 29/03/2019 18:00h
 */
$token = base64_encode('Mxa=mvc6v+sUcgHZi{b5PzM1]7^kblqPS-qR}4nb;sLXLUITCh}aKN5vWN3}');
if (!isset($_GET['token']) || $_GET['token'] != $token) {
    header("HTTP/1.0 404 Not Found", true);
    exit;
}

$_PWD = rtrim(getcwd(), DIRECTORY_SEPARATOR);
$base_dir   = dirname(dirname(__DIR__));
chdir($base_dir ) ;

error_reporting(E_ALL);
ini_set('display_errors', 'On');

// Leemos el INI
$_INI = file_exists('./.env.ini') ? parse_ini_file('./.env.ini') : [];

$_ECHO        = isset($_GET['COMMAND_ECHO'])               ? (bool)$_GET['COMMAND_ECHO']               : (isset($_INI['COMMAND_ECHO']) ? (bool)$_INI['COMMAND_ECHO'] : false);
$_LOGGING     = isset($_INI['COMMAND_LOGGING'])            ? (bool)$_INI['COMMAND_LOGGING']            : true;
$_MIGRATIONS  = isset($_INI['COMMAND_MIGRATIONS'])         ? (bool)$_INI['COMMAND_MIGRATIONS']         : false;
$_CACHE       = isset($_INI['COMMAND_CACHE'])              ? (bool)$_INI['COMMAND_CACHE']              : true;
$_WEBSOCKETS  = isset($_INI['COMMAND_WEBSOCKETS'])         ? (bool)$_INI['COMMAND_WEBSOCKETS']         : false;
$_TOUCHCOMMIT = isset($_INI['COMMAND_TOUCHCOMMIT'])        ? (bool)$_INI['COMMAND_TOUCHCOMMIT']        : true;
$_TEMPLATES   = isset($_INI['CUSTOM_TEMPLATES_DIRECTORY']) ? $_INI['CUSTOM_TEMPLATES_DIRECTORY']       : false;

// DATOS PHP
$_PHP = $_INI['PHP_COMMAND'];
if (empty($_PHP) || !file_exists($_PHP) || !is_executable($_PHP)) {
    die('Especifique el binario de PHP');
}

/**
 * GIT
 *
 * Miramos si hay cambios a descargar del repositorio GIT
 */
if (file_exists("./.git")) {
    $command = 'git checkout . && git pull';
} else {
    die('Debe inicializar GIT y conectarlo a la rama correspondiente');
    /*
        1) git init
        2) git remote add origin ssh://git-codecommit.[ZONE].amazonaws.com/v1/repos/[REPO]
        3) git pull origin [BRANCH]
        4) git checkout [BRANCH]
    */
}

//ob_implicit_flush(1);

if ($_LOGGING) {
    error_log('['.date('d/m/Y H:i:s').'] INI: GIT'.PHP_EOL, 3, $_PWD.'/command.log');
}

$res = execute($command);

if ($_ECHO) {
    echo "<pre>";
    echo "\n" . $res['code'];
    echo "\n" . $res['out'];
    echo "\n" . $res['err'];
    echo "</pre>";
}

if ($_LOGGING) {
    error_log($res['code'].PHP_EOL.$res['out'].PHP_EOL.$res['err'].PHP_EOL, 3, $_PWD.'/command.log');
    error_log('['.date('d/m/Y H:i:s').'] END: GIT'.PHP_EOL, 3, $_PWD.'/command.log');
}

if (function_exists('opcache_reset')) {
    if ($_LOGGING) {
        error_log('['.date('d/m/Y H:i:s').'] INI: OPCACHE Reset'.PHP_EOL, 3, $_PWD.'/command.log');
    }
    $res = opcache_reset();

    if ($_LOGGING) {
        error_log(($res ? 'OK' : 'KO').PHP_EOL, 3, $_PWD.'/command.log');
        error_log('['.date('d/m/Y H:i:s').'] END: OPCACHE Reset'.PHP_EOL, 3, $_PWD.'/command.log');
    }
}

/**
 * Plantillas
 *
 * se hace un pull tambien del repo de plantillas
 */
// se cambia a la carpeta public porque las plantillas parten de ahi
chdir('public');
if (file_exists($_TEMPLATES)) {
    chdir($_TEMPLATES);
    /**
     * GIT
     *
     * Miramos si hay cambios a descargar del repositorio GIT
     */
    if (file_exists("./.git")) {
        $command = 'git checkout . && git pull';
    } else {
        die('Debe inicializar GIT y conectarlo a la rama correspondiente');
    }
}

if ($_LOGGING) {
    error_log('['.date('d/m/Y H:i:s').'] INI: GIT'.PHP_EOL, 3, $_PWD.'/command.log');
}

$res = execute($command);

if ($_ECHO) {
    echo "<pre>";
    echo "\n" . $res['code'];
    echo "\n" . $res['out'];
    echo "\n" . $res['err'];
    echo "</pre>";
}

if ($_LOGGING) {
    error_log($res['code'].PHP_EOL.$res['out'].PHP_EOL.$res['err'].PHP_EOL, 3, $_PWD.'/command.log');
    error_log('['.date('d/m/Y H:i:s').'] END: GIT'.PHP_EOL, 3, $_PWD.'/command.log');
}

if (function_exists('opcache_reset')) {
    if ($_LOGGING) {
        error_log('['.date('d/m/Y H:i:s').'] INI: OPCACHE Reset'.PHP_EOL, 3, $_PWD.'/command.log');
    }
    $res = opcache_reset();

    if ($_LOGGING) {
        error_log(($res ? 'OK' : 'KO').PHP_EOL, 3, $_PWD.'/command.log');
        error_log('['.date('d/m/Y H:i:s').'] END: OPCACHE Reset'.PHP_EOL, 3, $_PWD.'/command.log');
    }
}
chdir($base_dir);

/**
 * MIGRACIONES
 *
 * Miramos si tenemos que hacer migraciones
 */
if ($_MIGRATIONS) {
    if ($_LOGGING) {
        error_log('['.date('d/m/Y H:i:s').'] INI: MIGRATION RUN'.PHP_EOL, 3, $_PWD.'/command.log');
    }

    // Iniciamos carpetas de phalcon para las migraciones
    /*if (!file_exists('.phalcon')) {
        mkdir('.phalcon', 0755);
        file_put_contents('./.phalcon/migration-version', '');
    }*/

    $res = execute($_PHP.' run migration run');

    if ($_ECHO) {
        echo "<pre>";
        echo "\n" . $res['code'];
        echo "\n" . $res['out'];
        echo "\n" . $res['err'];
        echo "</pre>";
    }

    if ($_LOGGING) {
        error_log($res['code'].PHP_EOL.$res['out'].PHP_EOL.$res['err'].PHP_EOL, 3, $_PWD.'/command.log');
        error_log('['.date('d/m/Y H:i:s').'] END: MIGRATION RUN'.PHP_EOL, 3, $_PWD.'/command.log');
        error_log('['.date('d/m/Y H:i:s').'] INI: MIGRATION LIST'.PHP_EOL, 3, $_PWD.'/command.log');
    }

    $res = execute($_PHP.' run migration list');

    if ($_ECHO) {
        echo "<pre>";
        echo "\n" . $res['code'];
        echo "\n" . $res['out'];
        echo "\n" . $res['err'];
        echo "</pre>";
    }

    if ($_LOGGING) {
        error_log($res['code'].PHP_EOL.$res['out'].PHP_EOL.$res['err'].PHP_EOL, 3, $_PWD.'/command.log');
        error_log('['.date('d/m/Y H:i:s').'] END: MIGRATION LIST'.PHP_EOL, 3, $_PWD.'/command.log');
    }
}

/**
 * CACHE
 *
 * Limpiamos cache por si hemos hecho cambios que afecten
 */
if ($_CACHE) {
    if ($_LOGGING) {
        error_log('['.date('d/m/Y H:i:s').'] INI: CLEAN ALL CACHE'.PHP_EOL, 3, $_PWD.'/command.log');
    }

    ob_start();

    // \Infolot\Utilities::clean_all_cache(true);
    //$res = execute($_PHP.' run system clean-all-cache');

    $cache_volt = realpath($base_dir . '/cache') . '/';
    if (!empty($cache_volt) && file_exists($cache_volt)) {
        if ($_ECHO) {
            echo $ini.'Limpiando cache VOLT'.$end;
        }

        $res = array_map('unlink', glob($cache_volt.'volt/*.php'));
        if ($_ECHO) {
            var_dump($res);
        }
    }

    $content = ob_get_clean();

    if ($_ECHO) {
        echo "<pre>";
        echo "\n" . $content;
        echo "</pre>";
    }

    if ($_LOGGING) {
        error_log($content.PHP_EOL, 3, $_PWD.'/command.log');
        error_log('['.date('d/m/Y H:i:s').'] END: CLEAN ALL CACHE'.PHP_EOL, 3, $_PWD.'/command.log');
    }
}

/**
 * WEBSOCKETS
 *
 * Reiniciarmos el servidor websockets por si hemos hecho cambios que afecten
 */
if ($_WEBSOCKETS) {
    if ($_LOGGING) {
        error_log('['.date('d/m/Y H:i:s').'] INI: RESTART WEBSOCKETS'.PHP_EOL, 3, $_PWD.'/command.log');
    }

    $res = execute('sudo supervisorctl restart websockets');

    if ($_ECHO) {
        echo "<pre>";
        echo "\n" . $res['code'];
        echo "\n" . $res['out'];
        echo "\n" . $res['err'];
        echo "</pre>";
    }

    if ($_LOGGING) {
        error_log($res['code'].PHP_EOL.$res['out'].PHP_EOL.$res['err'].PHP_EOL, 3, $_PWD.'/command.log');
        error_log('['.date('d/m/Y H:i:s').'] END: RESTART WEBSOCKETS'.PHP_EOL, 3, $_PWD.'/command.log');
    }
}

/**
 * Actualizamos un fichero para poder controlar la fecha del último commit desde el panel
 */
if ($_TOUCHCOMMIT) {
    touch('./public/commands/command.lck');
}

function execute($cmd)
{
    $workdir = getcwd();

    $descriptorspec = array(
        0 => array("pipe", "r"),  // stdin
        1 => array("pipe", "w"),  // stdout
        2 => array("pipe", "w"),  // stderr
    );

    $process = proc_open($cmd, $descriptorspec, $pipes, $workdir, null);

    $stdout = stream_get_contents($pipes[1]);
    fclose($pipes[1]);

    $stderr = stream_get_contents($pipes[2]);
    fclose($pipes[2]);

    return [
        'code' => proc_close($process),
        'out'  => trim($stdout),
        'err'  => trim($stderr),
    ];
}

function get_input()
{
    $raw = file_get_contents('php://input');

    $json = json_decode($raw, true);

    if (is_array($json) && $raw != $json) {
        // Miramos si es un vector [ {name:     ..., value: ...   }, ...]    y lo convertimos a asociativo
        if (isset($json[0]) && is_array($json[0]) && count($json[0]) == 2 && isset($json[0]['name']) && isset($json[0]['value'])) {
            $input = array();

            foreach ($json as $v) {
                $input[$v['name']] = $v['value'];
            }
        } else {
            $input = $json;
        }
    } else {
        parse_str($raw, $input);
    }

    return $input;
}
