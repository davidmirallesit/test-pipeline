<?php
/*
 * Modified: prepend directory path of current file, because of this file own different ENV under between Apache and command line.
 * NOTE: please remove this comment.
 */
defined('BASE_PATH') || define('BASE_PATH', getenv('BASE_PATH') ?: realpath(dirname(__FILE__) . '/../..'));
defined('PUBLIC_PATH') || define('PUBLIC_PATH', BASE_PATH . '/public');
defined('APP_PATH') || define('APP_PATH', BASE_PATH . '/app');
defined('TMP_PATH') || define('TMP_PATH', BASE_PATH . '/tmp');
defined('BASE_URI') || define('BASE_URI', '/');

define('T_GAME_LOTTO', 1);
define('T_GAME_APUESTAS', 2);
define('T_GAME_RIFA', 3);

// ambas constantes se definen en el index para poder incluir este archivo
// defined('BASE_PATH') || define('BASE_PATH', getenv('BASE_PATH') ?: realpath(dirname(__FILE__) . '/../..'));
// defined('APP_PATH') || define('APP_PATH', BASE_PATH . '/app');
defined('ENV_CRYPT_KEY') || define('ENV_CRYPT_KEY', 'eEAfR|_&G&f,+vU]:jFr!!A&+71w1Ms9~8_4L!<@[N@DyaIP_2My|:+.u>/6m,$D');

$_INI = [];
if (file_exists(BASE_PATH . '/.env.ini')) {
    $_INI  = parse_ini_file(BASE_PATH . '/.env.ini');
    $crypt = new \Phalcon\Encryption\Crypt();

    $crypt->setCipher('aes-256-ctr');
    //$crypt->setHashAlgorithm('sha256');
    $crypt->useSigning(true);
    $_INI['REDIS_HOST'] = $crypt->decryptBase64($_INI['REDIS_HOST'], ENV_CRYPT_KEY);
    $_INI['REDIS_PORT'] = $crypt->decryptBase64($_INI['REDIS_PORT'], ENV_CRYPT_KEY);
    $_INI['REDIS_PASS'] = $crypt->decryptBase64($_INI['REDIS_PASS'], ENV_CRYPT_KEY);

    if (isset($_INI['DOCS_USER']) && isset($_INI['DOCS_PASSWORD'])) {
        $_INI['DOCS_USER'] = $crypt->decryptBase64($_INI['DOCS_USER'], ENV_CRYPT_KEY);
        $_INI['DOCS_PASSWORD'] = $crypt->decryptBase64($_INI['DOCS_PASSWORD'], ENV_CRYPT_KEY);
    }
    unset($crypt);
}

$config = new \Phalcon\Config\Config([
    'local'      => false,
    'debug'      => false,
    'version'    => '1.1',
    /*'database' => [
        'adapter'     => 'Mysql',
        'host'        => 'localhost',
        'username'    => 'root',
        'password'    => '',
        'dbname'      => 'test',
        'charset'     => 'utf8',
    ],
    'db_panel' => [
        'adapter'     => 'Mysql',
        'host'        => 'bdinfolot.czcjv8mzijqt.eu-central-1.rds.amazonaws.com',
        'username'    => 'usu_php',
        'password'    => 'OOqAt6Dgct',
        'dbname'      => 'admin_infolot',
        'charset'     => 'utf8',
    ],*/
    'app_id' => 'a5de640e-7149-4b31-b296-7b1e9cc191f4',
    'app_key' => base64_decode('0QoHgYq4muQuSUb9/lRhIm2mktQm0PaZG9VsA4XXEX1NX+FxsAoBeEuJ81UGyh+0'),
    'maintenance_enabled' => intval($_INI['MAINTENANCE_ENABLED']),
    'application' => [
        'appDir'         => APP_PATH . '/',
        'controllersDir' => APP_PATH . '/controllers/',
        //'modelsDir'      => APP_PATH . '/models/',
        //'migrationsDir'  => APP_PATH . '/migrations/',
        'viewsDir'       => APP_PATH . '/views/',
        'pluginsDir'     => APP_PATH . '/plugins/',
        'libraryDir'     => APP_PATH . '/library/',
        'vendorDir'      => APP_PATH . '/vendor/',
        'cacheDir'       => BASE_PATH . '/cache/',
        'templatesDir'   => rtrim($_INI["CUSTOM_TEMPLATES_DIRECTORY"], '/').'/',
        'defaultTemplate'=> 'default',

        // This allows the baseUri to be understand project paths that are not in the root directory
        // of the webpspace.  This will break if the public/index.php entry point is moved or
        // possibly if the web server rewrite rules are changed. This can also be set to a static path.
        // 'baseUri'           => preg_replace('/public([\/\\\\])index.php$/', '', $_SERVER["PHP_SELF"]),
        'baseUri'           => BASE_URI,
        'publicUrl'        => isset($_SERVER['HTTP_HOST']) ? $_SERVER['REQUEST_SCHEME'] . '://' . idn_to_utf8($_SERVER['HTTP_HOST'], 0, INTL_IDNA_VARIANT_UTS46) . '/' : rtrim($_INI['APP_URL'], '/').'/',
        'publicUrlDefault'  => rtrim($_INI['APP_URL'], '/').'/',
        'enviroment'        => $_INI['APP_ENVIROMENT'],
        'web_server'        => !empty($_INI['WEB_SERVER']) ? $_INI['WEB_SERVER'] : 'apache',
    ],
    'ws_url' => rtrim($_INI['WS_URL'], '/').'/ws/',
    'local_password' => "#!x79`|=8&Qw.dR",
    'bl_url' => rtrim($_INI["BL_URL"], '/').'/',
    'bl_api_url' => rtrim($_INI["BL_URL"], '/').'/rest-api/',
    'cache' => [
        // rellenar los datos del config referentes a las administraciones con los datos que hay en cache
        'ini_config'      => true,
        'base_config_key' => 'ini_config_',
        'ttl'             => [
            'get_random_numbers' => 600
        ]
    ],
    'cache_backends' => [
        'params' => [
            'defaultSerializer' => 'Igbinary',
            'lifetime'          => 999999999999, // en segundos
            'prefix'            => 'webpre_'
        ],
        'redis'     => [
            'enabled'       => true,
            'host'          => $_INI['REDIS_HOST'],
            'port'          => $_INI['REDIS_PORT'],
            'auth'          => $_INI['REDIS_PASS'],
            'index'         => 6,
            'session_index' => 7
        ],
    ],
    'session' => [
        'defaultSerializer' => 'Igbinary',
        'lifetime'          => 3600, // Nº de segundos que se recordará la sesión de un usuario (ej 1 día: 86400)
        'prefix'            => 'session_'
    ],
    'search_urls' => [
        "fullNumber" => '/numero-',
        "tailNumber" => '/terminados-en-',
    ],

    // Logger
    'logger'             => [
        'enabled'  => true,
        'path'     => APP_PATH . '/logs/',
        'format'   => '[%date%] [%level%] %message%',
        'date'     => 'D j H:i:s',
        'logLevel' => \Phalcon\Logger\Logger::DEBUG,
        'filename' => 'application.log',
    ],

    // Juegos
    'games' => [
        'id_operator_selae'  => 1,
        'num_preloaded_bets' => 15, // Usado para mostrar info de jornadas
        'draws_t'            => [
            7 => [
                'loteria-navidad' => [
                    'name' => 'Lotería Navidad',
                    'id'   => 4
                ],
                'loteria-nino'    => [
                    'name' => 'Lotería del Niño',
                    'id'   => 5
                ]
            ]
        ]
    ],

    // Documentacion
    'docs' => [
        'user'     => $_INI['DOCS_USER'],
        'password' => $_INI['DOCS_PASSWORD']
    ],
    'translated' => [
        'monthNames' => [
            'Enero',
            'Febrero',
            'Marzo',
            'Abril',
            'Mayo',
            'Junio',
            'Julio',
            'Agosto',
            'Septiembre',
            'Octubre',
            'Noviembre',
            'Diciembre'
        ],
        'shortMonthNames' => [
            'Ene',
            'Feb',
            'Mar',
            'Abr',
            'May',
            'Jun',
            'Jul',
            'Ago',
            'Sep',
            'Oct',
            'Nov',
            'Dic'
        ],
        'dayNames' => [
            'lunes',
            'martes',
            'miércoles',
            'jueves',
            'viernes',
            'sábado',
            'domingo'
        ]
    ]
]);

if (is_readable(APP_PATH . '/config/config.dev.php')) {
    $override = include APP_PATH . '/config/config.dev.php';
    $config->merge($override);
}

return $config;
