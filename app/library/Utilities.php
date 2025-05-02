<?php


namespace Infolot;

use DateTime;
use GuzzleHttp\Client;
use Infolot\Phalcon\Mvc\Controller;
use Phalcon\Http\Request;

class Utilities
{
    /**
     * Intenta sustituir los $params en el fichero de la vista $viewfile, usando
     * el procesador de plantillas Volt
     *
     * @param   int $id_draw    Id del sorteo
     * @param   int $limit      Cantidad de numeros a mostrar
     *
     * @return  array           Array con los numeros
     */
    public static function getRandomNumbers(int $id_draw, int $limit = 6): array
    {
        $di     = \Phalcon\Di\Di::getDefault();
        $config = $di->getShared('config');
        $cache  = $di->getShared('cache');
        $numbers = [];

        $key    = 'get_draw_numbers_'.$config->datosadmon->data->id_web.'_'.$id_draw;
        if ($cache->has($key)) {
            $numbers = $cache->get($key);

            if (BENCHMARK_ENABLED) {
                \Infolot\Benchmark::set_time('time_'.__CLASS__.'_'.__FUNCTION__.'::desde cache', 1);
            }
        } else {
            $tmp = self::getNewRestful('pv-draw-numbers', 'POST', array('id_draw' => $id_draw, 'limit' => 60, 'order' => 'random'));
            if (!empty($tmp) && isset($tmp->body->data)) {
                $numbers = $tmp->body->data;
                $cache->set($key, $numbers, $config->cache->ttl->get_random_numbers);
            }

            if (BENCHMARK_ENABLED) {
                \Infolot\Benchmark::set_time('time_'.__CLASS__.'_'.__FUNCTION__.'::sin cache', 1);
            }
        }

        if (is_array($numbers)) {
            shuffle($numbers);

            return array_slice($numbers, 0, $limit);
        }

        return [];
    }

    /**
     * Borra la cache de los numeros del featured_ln
     *
     * @param   int $id_draw    Id del sorteo en formato 2024102
     *
     * @return  bool            Resultado de la operacion
     */
    public static function deleteFeaturedCache(int $id_draw): bool
    {
        $di     = \Phalcon\Di\Di::getDefault();
        $config = $di->getShared('config');
        $cache  = $di->getShared('cache');

        $key    = 'get_draw_numbers_'.$config->datosadmon->data->id_web.'_'.$id_draw;
        if (!$cache->has($key)) {
            return true;
        };
        
        $res = $cache->delete($key);
        return $res;
    }

    /**
     * Intenta sustituir los $params en el fichero de la vista $viewfile, usando
     * el procesador de plantillas Volt
     *
     * @param   string  $viewfile       Ruta de la vista(relativa al directorio views)
     * @param   array   $params         Vector asociativo con los parametros a inyectar en la vista
     *
     * @return  string                  Contenido de la vista generado
     */
    public static function parseTemplate(string $template, array $params): string
    {
        $di = \Phalcon\Di\Di::getDefault();

        $filepath = $di->get('view')->getViewsDir().$template.'.volt';
        if (file_exists($filepath)) {
            $content = file_get_contents($filepath);
        }

        return self::parseString($content, $params);
    }

    /**
     * Usa el sistema de plantillas Volt para facilitar:
     *
     * - reemplazo de variables
     * - uso de alguna estructura control (sobre todo condicionales)
     *
     * @param   string  $content    Contenido
     * @param   array   $params     Vector asociativo con comodines a sustituir
     *
     * @access public
     * @return string               Contenido tratado
     */
    public static function parseString(string $content = null, array $params = []): string
    {
        if ($content === '') {
            return '';
        }

        try {
            $compiler = new \Phalcon\Mvc\View\Engine\Volt\Compiler();
            /*$di       = \Phalcon\Di\Di::getDefault();
            $t        = $di->getShared('translate');*/

            self::completeCompiler($compiler);

            error_reporting(0);

            ob_start();
            \extract($params, EXTR_OVERWRITE);
            eval(' ?>'.$compiler->compileString($content));

            return ob_get_clean();
        } catch (\Exception $e) {
            return preg_replace('#(\{\{|\}\})#u', '', $content);
        }
    }

    /**
     * Funcion que se encarga de eliminar todas las caches de la aplicación
     */
    public static function clean_all_cache($debug = false)
    {
        $di     = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();

        if (php_sapi_name() == 'cli') {
            $ini = '';
            $end = PHP_EOL;
        } else {
            if ($debug) {
                echo '<pre>';
            }
            $ini = '<h1>';
            $end = '</h1>';
        }

        // CACHE GENERAL
        $cache = $di->getShared('cache');
        $keys  = [
            $config->cache->base_config_key . 'game_results_1',
            $config->cache->base_config_key . 'game_results_2',
            $config->cache->base_config_key . 'game_results_21',
            $config->cache->base_config_key . 'game_results_25',
            $config->cache->base_config_key . 'game_results_26',
            $config->cache->base_config_key . 'game_results_4',
            $config->cache->base_config_key . 'game_results_5',
            $config->cache->base_config_key . 'game_results_7',
            $config->cache->base_config_key . 'getgames',
            $config->cache->base_config_key . 'getseodraws',
            $config->cache->base_config_key . 'infocities',
            $config->cache->base_config_key . 'infocountries',
            $config->cache->base_config_key . 'infonextdrawsgeneral',
            $config->cache->base_config_key . 'infonextdrawsnavidad',
            $config->cache->base_config_key . 'infonextdrawsnino',
            $config->cache->base_config_key . 'infoprovinces',
            $config->cache->base_config_key . 'lastgameresults'
        ];
        if ($debug) {
            $time = microtime(true);

            echo $ini.'Limpiando caches de la aplicación'.$end;
            echo PHP_EOL.'⚫ '.implode(PHP_EOL.'⚫ ', $keys).PHP_EOL;
        }

        $res = $cache->deleteMultiple($keys);
        if ($debug) {
            var_dump($res);
        }

        // CACHE APCu
        if (function_exists('apcu_clear_cache') && $config->cache_backends->apcu->enabled) {
            if ($debug) {
                echo $ini.'Limpiando cache de APCu'.$end;
            }
            $res = apcu_clear_cache();
//            var_dump(apcu_cache_info());
            if ($debug) {
                var_dump($res);
            }
        }

        // CACHE opcache
         if (function_exists('opcache_reset')) {
            if ($debug) {
                echo $ini.'Limpiando opcache'.$end;
            }
            $res = opcache_reset();
            if ($debug) {
                var_dump($res);
            }
        }

        // CACHE VOLT
        $cache_volt = $di->getConfig()->application->cacheDir;
        if (!empty($cache_volt) && file_exists($cache_volt)) {
            if ($debug) {
                echo $ini.'Limpiando cache VOLT'.$end;
            }

            $res = array_map('unlink', glob($cache_volt . '*/*/*.volt.php'));
            if ($debug) {
                var_dump($res);
            }
        }

        if ($debug) {
            printf("Cache borrado en %s sec.", microtime(true) - $time);
        }
    }

    /**
     * Función que formateará el sorteo para mejorar la legibilidad
     *
     * @param  string   $sorteo     Sorteo (YYYYNNN)
     *
     * @access public
     * @return string               Sorteo formateado (NNN/YY)
     */
    public static function view_sorteo($sorteo)
    {
        $tmp = str_split($sorteo, 4);

        return sprintf('%03d/%02d', $tmp[1], substr($tmp[0], 2));
    }

    /**
     * Comprueba si existe $url
     *
     * @param     string    $url    URL a comprobar
     *
     * @return    bool              Si existe o no
     */
    public static function check_remote_file(string $url): bool
    {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);

        // don't download content
        curl_setopt($ch, CURLOPT_NOBODY, 1);
        curl_setopt($ch, CURLOPT_FAILONERROR, 1);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

        $result = curl_exec($ch);
        curl_close($ch);

        if ($result !== false) {
            return true;
        }

        return false;
    }

    /**
     * Devuelve la figura que hay que usar para $field, según $pv o $game
     *
     * @param   string  $field          Campo del que obtener la figura (number | extra | complementary | refund | serie | fraction | jackpot | code_a | code_b)
     * @param   string  $type           Tipo de css (fg | bg | figure)
     * @param   array   $game           Información del juego
     * @param   array   $pv             Información del PV
     *
     * @access  public
     * @return  string                  Devuelve los estilos para mostrar la figura
     */
    public static function get_item_css($field, $type, $game, $pv)
    {
        if (!in_array($type, ['fg','bg','figure'])) {
            return '';
        }
        if (!in_array($field, ['primary','number','extra','complementary','refund','serie','fraction','jackpot','code_a','code_b'])) {
            return '';
        }

        $return     = '';
        $field_game = $field;
        $field_pv   = $field;

        switch ($field) {
            case 'primary':
                return ($type == 'fg') ? $pv->css->color_texto : $pv->css->color_tema;
                break;
            case 'complementary':
            case 'refund':
            case 'serie':
            case 'fraction':
                $field_game = 'num_'.$field_game;
                $field_pv   = 'num_'.$field_pv;
                break;
            case 'number':
                $field_pv .= ($game->id_type == T_GAME_RIFA ? '_raffle' : '_no_raffle');
                break;
        }

        $field_game .= '_'.$type;
        $field_pv .= '_'.$type;
        switch ($type) {
            case 'fg':
            case 'bg':
                $field_game .= '_color';
                $field_pv   .= '_color';
                break;
        }

        $return = !empty($pv->css->$field_pv) ? $pv->css->$field_pv : $game->$field_game;

        if ($type == 'figure') {
            switch ($return) {
                case 'circle': $return = 'fa fa-circle'; break;
                case 'square': $return = 'fa fa-square'; break;
                case 'star': $return = 'fa fa-star'; break;
                case 'sun': $return = 'fa fa-certificate'; break;
            }
        }

        return $return;
    }

    /**
     * A partir de una url devuleve el nombre del archivo con el web_seo_onpage
     *
     * @param   string  $url        URL de la web de la que se quiere sacar el archivo
     * @param   string  $extension  incluir el .ini en el resultado
     *
     * @access  public
     * @return  string  String con el nombre del archivo
     */
    public static function getPageFileNameFromUrl($url, $extension = true)
    {
        if ($url == '/') {
            $result = 'index.ini';
        }
        $path     = preg_replace('/.*\./', '', $url);         // https://www.webpremium.eu/botes/{id} -> eu/botes/{id}
        $fileName = substr($path, strpos($path, '/') + 1);    // eu/botes/{id} -> botes/{id}
        $fileName = preg_replace('/{+|}+/', '_', $fileName);  // botes/{id} -> botes/_id_
        $fileName = self::normalize($fileName);                     // botes/_id_ -> botes-_id_
        if ($fileName == '') {
            $result = 'index.ini';
        } else {
            $result = ($fileName . '.ini');
        }

        if (!$extension) {
            $result = rtrim($result, '.ini');
        }
        return $result;
    }

    /**
     * Devuelve el array con los textos de las paginas si existe el archivo
     *
     * @access  public
     * @return  array   Vector con los datos
     */
    public static function getWebSeoOnpage()
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();

        $cache = $di->getShared('cache');
        $urls = explode('/', $_SERVER["REQUEST_URI"]);
        $match_route = $di->getRouter()->getMatchedRoute();
        if (!empty($match_route)) {
            $match_route_paths = @$match_route->getPaths();
        }

        array_shift($urls);
        $hasAddon = false;

        // si el PV no tiene el servicio de web_seo_onpage se usan las default
        if (!property_exists($config->datosadmon->data, 'is_web_seo_onpage') || !$config->datosadmon->data->is_web_seo_onpage) {
            $baseKey = $config->cache->base_config_key . 'default_pages_';
        } else {
            $baseKey = $config->cache->base_config_key . rtrim(self::getServerName($config->baseconfig->domain), '/') . '_pages_';
            $hasAddon = true;
        }

        if ($_SERVER['REQUEST_URI'] == '/' || is_null($match_route)) {
            // $pageFile = $config->application->admonsDir . $_SERVER['SERVER_NAME'] . '/pages/'. self::getPageFileNameFromUrl('/');
            $cacheKey = $baseKey . self::getPageFileNameFromUrl('/', false);
        } else {
            // $pageFile = $config->application->admonsDir . $_SERVER['SERVER_NAME'] . '/pages/' . self::getPageFileNameFromUrl($match_route->getPattern());
            $cacheKey = $baseKey . self::getPageFileNameFromUrl($match_route->getPattern(), false);
        }

        // si es una entidad se saca el pages de venta-participaciones-_keyword_
        if (!is_null($match_route) && isset($match_route_paths['action']) && $match_route_paths["action"] == 'ventaParticipacionesWithKeyword') {
            // $pageFile = $config->application->admonsDir . $_SERVER['SERVER_NAME'] . '/pages/venta-participaciones-_keyword_.ini';
            $cacheKey = $baseKey . '_pages_venta-participaciones-_keyword_';
        }

        // si no existe url especifica se usa /{sorteo}/{buscador} o la que coincida con la url
        if (
            !is_null($match_route) &&
            $match_route_paths["controller"] == 'search' &&
            // se comprueba el cacheKey por si se ha introducido una url del buscador manualmente
            !$cache->has($cacheKey)
        ) {
            // el $match_route->getPattern() con los comodines no funciona para pillar la url
            $cacheKey = $baseKey . "_pages_" . self::getPageFileNameFromUrl("/" . $urls[0] . "/" . $urls[1], false);

            switch ($match_route_paths["action"]) {
                case 'index':
                    $defaultCacheKey = $baseKey . self::getPageFileNameFromUrl('/{sorteo}/{buscador}', false);
                    break;
                case 'tailNumber':
                    $cacheKey .= "-" . $urls[2];
                    $defaultCacheKey = $baseKey . self::getPageFileNameFromUrl('/{sorteo}/{buscador}/terminados-en-{numero}', false);
                    break;
                case 'fullNumber':
                    $cacheKey .= "-" . $urls[2];
                    $defaultCacheKey = $baseKey . self::getPageFileNameFromUrl('/{sorteo}/{buscador}/numero-{numero}', false);
                    break;
            }

            // se comprueba si webseo tiene la url especifica tipo /sorteo-navidad/buscador-numeros y sino tiene se usa el default /{sorteo}/{buscador}
            if (!$cache->has($cacheKey)) {
                $cacheKey = $defaultCacheKey;
            }
        }

        if (!$cache->has($cacheKey)) {
            if ($hasAddon) {
                $updatedPages = self::updatePages(null, 'add');
            } else {
                $updatedPages = self::updatePages(null, 'default');
            }
            if (isset($updatedPages["error"])) {
                return [];
            }
        }

        $web_seo_onpage = $cache->get($cacheKey);
        if (is_null($web_seo_onpage)) {
            return [];
        }

        $searcherRouteNames = ['search-number', 'search-tail-number', 'search-full-number'];
        $searchDraw = '';
        $dates = null;
        $draws = $di->getShared('getseodraws');
        if (!is_null($match_route) && in_array($match_route->getName(), $searcherRouteNames)) {
            $drawId = $config->get('datosadmon')->data->searcher->search_draw_assigned->{$urls[0]};
            if (!is_null($drawId)) {
                $draw = null;
                foreach ($draws as $d) {
                    if ($d["id"] == $drawId) {
                        $draw = $d;
                        break;
                    }
                }
                if (!is_null($draw)) {
                    $searchDraw = $draw["name_pretty"];
                    $date_sorteo = DateTime::createFromFormat('Y-m-d H:i:s', $draw["date_draw"]);

                    $old = setlocale(LC_TIME, 0);
                    $locale = $_SERVER['HTTP_ACCEPT_LANGUAGE'] ? substr($_SERVER['HTTP_ACCEPT_LANGUAGE'], 0, 5) : 'es-ES';
                    setlocale(LC_TIME, $locale, 0, 5);
                    $drawTimestamp = strtotime($draw["date_draw"]);
                    $day = ucfirst($config->translated->dayNames[date('N', $drawTimestamp) - 1]);
                    $dayWithNumber = $day . ' ' . ucfirst(date('d', $drawTimestamp));
                    $dayWithNumberAndMonth = $dayWithNumber . " de " . ucfirst($config->translated->monthNames[date('n', $drawTimestamp) - 1]);
                    $dayWithNumberAndMonthAndYear = $dayWithNumberAndMonth . " de " . ucfirst(date('Y', $drawTimestamp));
                    $dates = [
                        "{{search_draw_date_f1}}" => $date_sorteo->format('d/m/Y'),
                        "{{search_draw_date_f2}}" => $date_sorteo->format('Y-m-d'),
                        "{{search_draw_date_f3}}" => $date_sorteo->format('d/m/Y H:i:s'),
                        "{{search_draw_date_f4}}" => $date_sorteo->format('Y-m-d H:i:s'),
                        "{{search_draw_date_f5}}" => $day,
                        "{{search_draw_date_f6}}" => $date_sorteo->format('d'),
                        "{{search_draw_date_f7}}" => $dayWithNumber,
                        "{{search_draw_date_f8}}" => $dayWithNumberAndMonth,
                        "{{search_draw_date_f9}}" => $dayWithNumberAndMonthAndYear,
                    ];
                    setlocale(LC_TIME, $old);
                }
            }
        }

        //{{name_comercial}}    -> Nombre del PV ej. "Webpremium"
        //{{pretty_name}}       -> Nombre del sorteo pretty
        //{{short_date}}        -> Fecha ej. "dd-mm-YYYY"
        //{{search_number}}     -> Número buscador
        $wildcards = [
            "{{name_comercial}}" => $config->datosadmon->data->company->name_comercial ? $config->datosadmon->data->company->name_comercial : '',
            "{{pretty_name}}" => $draw["name_pretty"],
            "{{short_date}}" => date('d-m-Y'),
            "{{search_number}}" => isset($urls[2]) ? end(explode("-", $urls[2])) : '',
            "{{search_draw}}" => $searchDraw,
        ];

        if (is_array($dates)) {
            $wildcards = array_merge($wildcards, $dates);
        }

        // se sustituyen los comodines
        foreach ($wildcards as $wildcard => $wildcardValue) {
            foreach ($web_seo_onpage as $seoKey => $seoValue) {
                if (is_null($seoValue)) {
                    continue;
                }
                if (preg_match('/.*' . $wildcard . '.*/', $seoValue)) {
                    $web_seo_onpage[$seoKey] = str_replace($wildcard, $wildcardValue, $seoValue);
                }
            }
        }

        return $web_seo_onpage;
        /*
         echo $web_seo_onpage['meta_title'];
         echo $web_seo_onpage['meta_description'];
         echo $web_seo_onpage['h1'];
         echo $web_seo_onpage['txt_up'];
         echo $web_seo_onpage['txt_down'];
        */
    }

    /**
     * Devuelve un mensaje $msg de error
     *
     * @param   mixed   $msg            Mensaje de error, objeto, array, ...
     * @param   bool    $jsonStringify  Devolver un string o no
     * @param   int     $code           Nº código
     *
     * @access  public
     * @return  mixed   Vector con el error o String si se codifica
     */
    public static function raiseError($msg, $jsonStringify = false, $code = null)
    {
        $res = ['error' => $msg];

        if (!is_null($code) && strlen($code)) {
            $res['code'] = $code;
        }

        if ($jsonStringify) {
            return json_encode($res);
        } else {
            return $res;
        }
    }

    /**
     * Trata un texto para que pueda servir como parte de una URL
     *
     * @param  string   $texto      Texto a tratar
     * @param  bool     $with_dir   Permitir directorios
     * @param  bool     $trim       Quitar los guiones inicial/final
     * @param  string   $remove     Caracteres a quitar de la normalizacion
     * @param  bool     $strict     Indicara si se puede usar guion bajo (false) o no (true)
     *
     * @return string   Texto tratado
     */
    public static function normalize($texto, $with_dir = false, $trim = true, $remove = '', $strict = false)
    {
        if (is_null($with_dir)) {
            $with_dir = false;
        }
        if (is_null($trim)) {
            $trim = true;
        }
        if (is_null($remove)) {
            $remove = '';
        }

        $re = '-a-z0-9.';
        if (!$strict) {
            $re .= '_';
        }
        if ($with_dir) {
            $re .= '/';
        }

        $keyword = self::removeAccents($texto);
        $keyword = trim($keyword);
        //$keyword = preg_replace('#[ ]+#', '-', $keyword);
        $keyword = strtolower(preg_replace('#[^'.$re.']+#i', '-', $keyword));
        if (!empty($remove)) {
            $keyword = trim(preg_replace('#['.$remove.']+#i', '', $keyword));
        }
        $keyword = preg_replace('#[-]+#', '-', $keyword);
        if ($trim) {
            $keyword = trim(preg_replace('#^[-]+|[-]+$#', '', $keyword));
        }

        return $keyword;
    }

    /**
     * Le quita los acentos y otros signos a las letras
     *
     * @param   string  $texto  Texto a tratar
     *
     * @access public
     * @return string          Texto tratado
     */
    public static function removeAccents($texto)
    {
        $trans = [
            'À' => 'A',
            'Á' => 'A',
            'Â' => 'A',
            'Ã' => 'A',
            'Ä' => 'A',
            'Å' => 'A',
            'à' => 'a',
            'á' => 'a',
            'â' => 'a',
            'ã' => 'a',
            'ä' => 'a',
            'å' => 'a',
            'Ò' => 'O',
            'Ó' => 'O',
            'Ô' => 'O',
            'Õ' => 'O',
            'Ö' => 'O',
            'Ø' => 'O',
            'ò' => 'o',
            'ó' => 'o',
            'ô' => 'o',
            'õ' => 'o',
            'ö' => 'o',
            'ø' => 'o',
            'È' => 'E',
            'É' => 'E',
            'Ê' => 'E',
            'Ë' => 'E',
            'è' => 'e',
            'é' => 'e',
            'ê' => 'e',
            'ë' => 'e',
            'Ç' => 'C',
            'ç' => 'c',
            'Ì' => 'I',
            'Í' => 'I',
            'Î' => 'I',
            'Ï' => 'I',
            'ì' => 'i',
            'í' => 'i',
            'î' => 'i',
            'ï' => 'i',
            'Ù' => 'U',
            'Ú' => 'U',
            'Û' => 'U',
            'Ü' => 'U',
            'ù' => 'u',
            'ú' => 'u',
            'û' => 'u',
            'ü' => 'u',
            'ÿ' => 'y',
            'Ñ' => 'N',
            'ñ' => 'n'
        ];

        return strtr($texto, $trans);
    }

    /**
     * Guarda la información de los resultados en el archivo game_results_{id_game}.ini
     *
     * @param   int     $idGame id del juego que se quiere actualizar si no se indica se actualizan todos
     *
     * @access  public
     * @return  array   Vector con los datos del juego actualizado
     *
     */
    public static function updateGameResults($idGame = null, $domain = null)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $cache = $di->getShared('cache');

        if ($idGame) {
            $gamesToUpdate = [strval($idGame)];
        } else {
            $gamesToUpdate = $config->availableGames;
        }

        $domain_config = self::getDomainConfig($domain ? $domain : $config->baseconfig->domain);

        if (is_array($domain_config) && !is_null($domain_config["error"])) {
            return $domain_config;
        }

        $requestBody = self::getRequestBody();
        $client = self::getClient();
        $ar = array('games' => []);

        foreach ($gamesToUpdate as $idGameToUpdate) {
            try {
                $requestBody['id_game'] = $idGameToUpdate;
                $response = $client->request(
                    'GET',
                    'last-game-results',
                    ['body' => json_encode($requestBody)]
                );
                $body = json_decode($response->getBody());
                if (empty($body)) {
                    $ar["games"][$idGameToUpdate] = self::raiseError('No hay resultados');
                } elseif (property_exists($body, 'error')) {
                    $ar["games"][$idGameToUpdate] = self::raiseError($body->error);
                } else {
                    $gameResultsIndexCacheKey = $config->cache->base_config_key . 'lastgameresults';
                    $gameResultsCacheKey = $config->cache->base_config_key . 'game_results_' . $idGameToUpdate;

                    self::updateCacheIndex($gameResultsIndexCacheKey, $gameResultsCacheKey);
                    if ($cache->set($gameResultsCacheKey, $body->data) !== true) {
                        self::updateCacheIndex($gameResultsIndexCacheKey, $gameResultsCacheKey, true);
                        $ar["games"][$idGameToUpdate] = self::raiseError("No se ha podido guardar el archivo");
                    } else {
                        $ar["games"][$idGameToUpdate] = array("updated" => true);
                    }
                    // if (file_put_contents($config->application->admonsDir . 'game_results_'.$idGameToUpdate.'.ini', json_encode($body)) === false) {
                    //     $ar["games"][$idGameToUpdate] = self::raiseError("No se ha podido guardar el archivo");
                    // } else {
                    //     $ar["games"][$idGameToUpdate] = array("updated" => true);
                    // }
                }
            } catch (Exception $e) {
                $ar["games"][$idGameToUpdate] = self::raiseError("Error en last-game-results");
            }
        }

        return array('updated' => $ar);
    }

    /**
     * Guarda la información de los próximos sorteos \
     * en el archivo info_next_draws_{navidad | nino | general}.ini
     *
     * @param   object  Input de la peticion se acepta el dominio a actualizar {"domain": "www.webpremium.eu"}
     *
     * @access  public
     * @return  array   Vector con el error o updated -> true si todo ha ido correctamente
     */
    public static function updateNextDraws($input = null)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $cache = $di->getShared('cache');

        if (is_null($input)) {
            $domain_config = self::getDomainConfig($config->baseconfig->domain);
        } else {
            $domain_config = self::getDomainConfig($input->domain);
        }

        if (is_array($domain_config) && !@is_null($domain_config["error"])) {
            return $domain_config;
        }

        $requestBody = self::getRequestBody();
        $client = self::getClient();

        try {
            $response = $client->request('POST', 'next-draws', array('body' => json_encode($requestBody)));

            $body = json_decode($response->getBody(), true);
            $bodyNavidad = [];
            $bodyNino = [];

            if (isset($body['error'])) {
                $err["error"][] = "No se ha podido obtener los sorteos";
            } else {
                if (isset($body['data'])) {
                    foreach ($body['data'] as $nextDraw) {
                        if ($nextDraw['id_type'] == "4") {
                            $bodyNavidad[] = $nextDraw;
                        }
                        if ($nextDraw['id_type'] == "5") {
                            $bodyNino[] = $nextDraw;
                        }
                    }

                    $err = ["error" => []];

                    if ($cache->set($config->cache->base_config_key . 'infonextdrawsnavidad', $bodyNavidad) !== true) {
                        $err["error"][] = array_values(self::raiseError("No se ha podido guardar el archivo del sorteo de navidad"))[0];
                    }

                    if ($cache->set($config->cache->base_config_key . 'infonextdrawsnino', $bodyNino) !== true) {
                        $err["error"][] = array_values(self::raiseError("No se ha podido guardar el archivo del sorteo del niño"))[0];
                    }

                    if ($cache->set($config->cache->base_config_key . 'infonextdrawsgeneral', $body['data']) !== true) {
                        $err["error"][] = array_values(self::raiseError("No se ha podido guardar el archivo de los sorteos generales"))[0];
                    }
                }

                // if (file_put_contents($config->application->admonsDir . 'info_next_draws_navidad.ini', $jsonNavidad) === false) {
                //     $err["error"][] = array_values(self::raiseError("No se ha podido guardar el archivo del sorteo de navidad"))[0];
                // }

                // if (file_put_contents($config->application->admonsDir . 'info_next_draws_nino.ini', $jsonNino) === false) {
                //     $err["error"][] = array_values(self::raiseError("No se ha podido guardar el archivo del sorteo del niño"))[0];
                // }

                // if (file_put_contents($config->application->admonsDir . 'info_next_draws_general.ini', $jsonParams) === false) {
                //     $err["error"][] = array_values(self::raiseError("No se ha podido guardar el archivo de los sorteos generales"))[0];
                // }
            }
            if (empty($err["error"])) {
                $result = array("updated" => true);
            } else {
                $result = $err;
            }
        } catch (Exception $e) {
            $result = self::raiseError("Error in set-info-loteria general");
        }
        return $result;
    }

    /**
     * Guarda la información en cache de los sorteos SEO sacados de los ultimos 105 sorteos
     *
     * @access  public
     * @return  array   Vector con el error o updated -> true si todo ha ido correctamente
     */
    public static function updateSeoDraws()
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $cache = $di->getShared('cache');

        $requestBody = self::getRequestBody();
        if (array_key_exists('error', $requestBody) && !is_null($requestBody['error'])) {
            return $requestBody;
        }

        $client = self::getClient();

        try {
            $response = $client->request('POST', 'get-seo-draws', ['body' => json_encode($requestBody)]);
            $body = json_decode($response->getBody());

            if (is_null($body)) {
                return self::raiseError("Error en get-seo-draws null response");
            }

            if (property_exists($body, 'error') && isset($body->error)) {
                return self::raiseError("Error en get-seo-draws " . $body->error);
            }

            if ($cache->set($config->cache->base_config_key . 'getseodraws', json_decode(json_encode($body->data), true)) !== true) {
                return self::raiseError("No se ha podido guardar el archivo");
            }

            //actualizar el search_draw_assigned si han cambiado los sorteos
            self::checkSearchDraws();
        } catch (Exception $e) {
            return self::raiseError("Error updateSeoDraws");
        }

        return ["updated" => true];
    }

    /**
     * Guarda la información de los próximos jackpots en el archivo info_next_jackpots.ini
     *
     * @access  public
     * @return  array   Vector con el error o updated -> true si todo ha ido correctamente
     */
    public static function updateJackpots()
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $cache = $di->getShared('cache');

        $domain_config = self::getDomainConfig($config->baseconfig->domain);
        if (is_array($domain_config) && !is_null($domain_config["error"])) {
            return $domain_config;
        }

        $requestBody = self::getRequestBody();
        $client = self::getClient();

        try {
            $response = $client->request('POST', 'next-jackpots', array('body' => json_encode($requestBody)));

            $body = json_decode($response->getBody(), true);
            if (!isset($body['data'])) {
                $result = self::raiseError("No se ha podido obtener info_next_jackpots");
            } elseif ($cache->set($config->cache->base_config_key . 'infonextjackpots', $body['data']) !== true) {
                $result = self::raiseError("No se ha podido guardar el archivo info_next_jackpots");
            } else {
                $result = array("updated" => true);
            }
            // if (file_put_contents($config->application->admonsDir . 'info_next_jackpots.ini', $jsonParams) === false) {
            //     $result = self::raiseError("No se ha podido guardar el archivo info_next_jackpots");
            // } else {
            //     $result = array("updated" => true);
            // }
        } catch (Exception $e) {
            $result = self::raiseError("Error in set-next-jackpots");
        }

        return $result;
    }

    public static function updatePvInfo($saveOnConfig = false)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $cache = $di->getShared('cache');

        $requestBody = self::getRequestBody();
        if (array_key_exists('error', $requestBody) && !is_null($requestBody['error'])) {
            return $requestBody;
        }

        $client = self::getClient();

        try {
            $response = $client->request('POST', 'pv-info', ['body' => json_encode($requestBody)]);
            $body = json_decode($response->getBody());
            if (isset($body->error)) {
                return self::raiseError("Error en pv-info " . $body->error);
            }

            self::checkSearcherLastMod(json_decode(json_encode($body->data->searcher->search_url), true));

            if ($cache->set($config->cache->base_config_key . self::getServerName($config->baseconfig->domain) . '_datosadmon', $body) !== true) {
                return self::raiseError("No se ha podido guardar el archivo");
            }

            if ($saveOnConfig) {
                $config->offsetSet('datosadmon', $body);
            }
            // if (file_put_contents($config->application->admonsDir . $serverName . '/datos_admon.ini', $jsonParams) === false) {
            //     return self::raiseError("No se ha podido guardar el archivo");
            // }
        } catch (Exception $e) {
            return self::raiseError("Error updating info");
        }

        return array("updated" => true);
    }

    public static function updateGames()
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $cache = $di->getShared('cache');

        $requestBody = self::getRequestBody();
        if (array_key_exists('error', $requestBody) && !is_null($requestBody['error'])) {
            return $requestBody;
        }

        $client = self::getClient();

        try {
            $response = $client->request('POST', 'get-games', ['body' => json_encode($requestBody)]);
            $body = json_decode($response->getBody());
            if (isset($body->error)) {
                return self::raiseError("Error en get-games " . $body->error);
            }

            //TODO el error este no va a parar a ninguna parte
            if ($cache->set($config->cache->base_config_key . 'getgames', $body->data) !== true) {
                $err["error"][] = array_values(self::raiseError("No se ha podido guardar el archivo de los sorteos generales"))[0];
            }
            // if (file_put_contents($config->application->admonsDir . 'get_games.ini', $jsonParams) === false) {
            //     return self::raiseError("No se ha podido guardar el archivo");
            // }
        } catch (Exception $e) {
            return self::raiseError("Error in get-games");
        }

        return array("updated" => true);
    }

    /**
     * Si se pierde la información de cache se debe actualizar desde el panel porque no tiene el uuid
     * {
     *   "uuid": "02df615a-67af-47c2-a89b-8162512df825",
     *   "mode": "add",
     *   "is_test": false,
     *   "domain": "www.webpremium.local",
     *   "local_password": "{{local_password}}"
     *   "old_keyword": "tk7"
     * }
     */
    public static function updateCommunity($input)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $cache = $di->getShared('cache');
        $serverName = self::getServerName($config->baseconfig->domain);
        $communityIndexCacheKey = $config->cache->base_config_key . rtrim($serverName, '/') . '_communities';
        
        if ($input->mode == "add") {
            $requestBody = self::getRequestBody();
            if (array_key_exists('error', $requestBody) && !is_null($requestBody['error'])) {
                return $requestBody;
            }
    
            $client = self::getClient();
            $requestBody['uuid'] = $input->uuid;
            try {
                $response = $client->request(
                    'POST',
                    'get-community-info',
                    ['body' => json_encode($requestBody)]
                );
    
                $body = json_decode($response->getBody(), true);
                if (isset($body["error"])) {
                    return self::raiseError("Error en get-community-info " . $body["error"], true);
                }
            } catch (Exception $e) {
                return self::raiseError("Error en get-community-info", true);
            }
    
            $communityCacheKey = $communityIndexCacheKey . '_' . $body["data"]["keyword"];
            // si se ha cambiado el keyword se renombra el archivo de antes
            if (isset($input->old_keyword)) {
                $oldCommunityCacheKey = $communityIndexCacheKey . '_' . $input->old_keyword;
                self::updateCacheIndex($communityIndexCacheKey, $oldCommunityCacheKey, true);
                $cache->delete($oldCommunityCacheKey);
            }

            self::updateCacheIndex($communityIndexCacheKey, $communityCacheKey);
            if ($cache->set($communityCacheKey, $body) !== true) {
                self::updateCacheIndex($communityIndexCacheKey, $communityCacheKey, true);
                return Utilities::raiseError("Error al guardar la comunidad, no se ha podido guardar la información de " . $body["data"]["keyword"], true);
            }

            $ar = array(
                "Completado" => "Se ha guardado la info de la comunidad - https://" . $serverName . "/" . $body["data"]["keyword"],
                "updated" => true
            );

            return json_encode($ar);
        } elseif ($input->mode == "delete") {
            $communityCacheKey = $communityIndexCacheKey . '_' . $input->keyword;
            self::updateCacheIndex($communityIndexCacheKey, $communityCacheKey, true);
            if ($cache->delete($communityCacheKey) !== true) {
                self::updateCacheIndex($communityIndexCacheKey, $communityCacheKey);
                return Utilities::raiseError("Error al borrar la comunidad de caché " . $input->keyword, true);
            }

            $ar = array(
                "Completado" => "Se ha borrado la info de la comunidad",
                "updated" => true
            );

            return json_encode($ar);
        }
    }

    public static function updatePages($input, $mode = null)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $cache = $di->getShared('cache');

        $requestBody = self::getRequestBody();
        if (array_key_exists('error', $requestBody) && !is_null($requestBody['error'])) {
            return $requestBody;
        }

        $client = self::getClient();

        if (!is_null($input)) {
            if (property_exists($input->params, 'url') && !is_null($url)) {
                $url = $input->params->url;
                // actualizar solo una url
                $requestBody['url'] = $url;
            }

            if (property_exists($input->params, 'mode')) {
                $mode = $input->params->mode;
            }
        }
        // si se pasa el mode 'default' devolverá el por defecto de la url o todos si no se especifica url
        $requestBody['mode'] = $mode;

        try {
            $response = $client->request('POST', 'pv-pages', ['body' => json_encode($requestBody)]);
            $body = json_decode($response->getBody());
            if (isset($body->error)) {
                return self::raiseError("Error en pv-pages " . $body->error);
            }

            // si el PV no tiene el servicio de web_seo_onpage se guardan las paginas generales
            if ($mode == 'default' || (!property_exists($config->datosadmon->data, 'is_web_seo_onpage') || !$config->datosadmon->data->is_web_seo_onpage)) {
                $pageIndexCacheKey = $config->cache->base_config_key . 'default_pages';
            } else {
                $pageIndexCacheKey = $config->cache->base_config_key . rtrim(self::getServerName($config->baseconfig->domain), '/') . '_pages';
            }

            if (!isset($body->data) || count($body->data) == 0) {
                // si se ha pasado la url y no hay datos, comprobar que está el archivo para borrarlo
                if ($url) {
                    $pageCacheKey = $pageIndexCacheKey . '_' . self::getPageFileNameFromUrl($url, false);
                    self::updateCacheIndex($pageIndexCacheKey, $pageCacheKey, true);
                    $cache->delete($pageCacheKey);
                }
            } else {
                switch ($mode) {
                    case 'default':
                    case 'add':
                        foreach ($body->data as $webSeo) {
                            $pageCacheKey = $pageIndexCacheKey . '_' . self::getPageFileNameFromUrl($webSeo->url, false);
                            self::updateCacheIndex($pageIndexCacheKey, $pageCacheKey);
                            if ($cache->set($pageCacheKey, json_decode(json_encode($webSeo), true)) !== true) {
                                self::updateCacheIndex($pageIndexCacheKey, $pageCacheKey, true);
                                return Utilities::raiseError("Error al guardar el seo onpage, no se ha podido guardar la información de " . $webSeo->url, true);
                            }
                        }
                        break;
                    case 'delete':
                        // no se va a borrar desde el panel, solo se sustituye por el default
                        foreach ($body->data as $webSeo) {
                            $pageCacheKey = $pageIndexCacheKey . '_' . self::getPageFileNameFromUrl($webSeo->url, false);
                            self::updateCacheIndex($pageIndexCacheKey, $pageCacheKey, true);
                            $cache->delete($pageCacheKey);
                        }
                        break;
                    default:
                        # code...
                        break;
                }
            }
        } catch (Exception $e) {
            return self::raiseError("Error updating info");
        }

        return array("updated" => true);
    }

    /**
     * Guarda la información de las ciudades/provincias/paises en los archivos\
     * info_cities.ini, info_provinces.ini y info_countries.ini
     *
     * @access  public
     * @return  array   Vector con el error o updated -> true si todo ha ido correctamente
     */
    public static function updateLocations()
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $cache = $di->getShared('cache');

        $domain_config = self::getDomainConfig($config->baseconfig->domain);

        if (is_array($domain_config) && !is_null($domain_config["error"])) {
            return $domain_config;
        }

        $requestBody = [
            'token'     => $domain_config->token,
            'pass'      => self::decrypt($domain_config->password),
            'app_id'    => $config->app_id,
            'user_agent'=> $_SERVER['HTTP_USER_AGENT'],
            'ip'        => $_SERVER['REMOTE_ADDR'],
        ];

        $client = new Client([
            'base_uri' => $config->ws_url,
            // You can set any number of default request options.
            'timeout' => 35.0, // En segundos
            'verify' => false,
            'headers' => ['Content-Type' => 'application/json'],
            'debug' => false,
        ]);

        $err = ["error" => []];

        try {
            $response = $client->request(
                'GET',
                'get-cities',
                ['body' => json_encode($requestBody)]
            );

            $citiesBody = json_decode($response->getBody(), true);
            if (isset($citiesBody['error'])) {
                $err["error"][] = self::raiseError("No se ha podido obtener infocities: ".$citiesBody['error']);
            } elseif ($cache->set($config->cache->base_config_key . 'infocities', $citiesBody['data']) !== true) {
                $err["error"][] = self::raiseError("No se ha podido guardar infocities en cache");
            }
            // if (file_put_contents($config->application->admonsDir . 'info_cities.ini', json_encode($citiesBody)) === false) {
            //     $err["error"][] = self::raiseError("No se ha podido guardar el archivo info_cities");
            // }
        } catch (Exception $e) {
            $err["error"][] = self::raiseError("Error en get-cities");
        }

        try {
            $response = $client->request(
                'GET',
                'get-provinces',
                ['body' => json_encode($requestBody)]
            );

            $provincesBody = json_decode($response->getBody(), true);
            if (isset($provincesBody['error'])) {
                $err["error"][] = self::raiseError("No se ha podido obtener infocities: ".$provincesBody['error']);
            } elseif ($cache->set($config->cache->base_config_key . 'infoprovinces', $provincesBody['data']) !== true) {
                $err["error"][] = self::raiseError("No se ha podido guardar infoprovinces en cache");
            }
            // if (file_put_contents($config->application->admonsDir . 'info_provinces.ini', json_encode($provincesBody)) === false) {
            //     $err["error"][] = self::raiseError("No se ha podido guardar el archivo info_provinces");
            // }
        } catch (Exception $e) {
            $err["error"][] = self::raiseError("Error en get-provinces");
        }

        try {
            $response = $client->request(
                'GET',
                'get-countries',
                ['body' => json_encode($requestBody)]
            );

            $countriesBody = json_decode($response->getBody(), true);
            if (isset($countriesBody['error'])) {
                $err["error"][] = self::raiseError("No se ha podido obtener infocities: ".$countriesBody['error']);
            } elseif ($cache->set($config->cache->base_config_key . 'infocountries', $countriesBody['data']) !== true) {
                $err["error"][] = self::raiseError("No se ha podido guardar infocountries en cache");
            }
            // if (file_put_contents($config->application->admonsDir . 'info_countries.ini', json_encode($countriesBody)) === false) {
            //     $err["error"][] = self::raiseError("No se ha podido guardar el archivo info_countries");
            // }
        } catch (Exception $e) {
            $err["error"][] = self::raiseError("Error en get-countries");
        }

        if (empty($err["error"])) {
            $result = array("updated" => true);
        } else {
            $result = $err;
        }

        return $result;
    }

    public static function saveBasicConfigOnCahce($data)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $cache = $di->getShared('cache');

        if ($cache->set($config->cache->base_config_key . self::getServerName($data->domain) . '_baseconfig', $data) !== true) {
            return Utilities::raiseError("No se ha podido guardar baseconfig en cache", true);
        }

        $config->offsetSet('baseconfig', $data);
        return true;
    }

    public static function setBaseconfigConfigParam($domain)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $cache = $di->getShared('cache');

        if ($data = $cache->get($config->cache->base_config_key . self::getServerName($domain) . '_baseconfig') !== true) {
            return Utilities::raiseError("No se ha podido guardar baseconfig en config", true);
        }

        $config->offsetSet('baseconfig', $data);
        return true;
    }

    /**
     * Devuelve los datos del basic.ini de la administración indicada
     *
     * @param   string  $domain nombre del dominio del que se quiere la información, si no se indica se usa $_SERVER['SERVER_NAME']
     *
     * @access  public
     * @return  array   Vector con los datos de la administración
     */
    public static function getDomainConfig($domain = null)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        try {
            $cache = $di->getShared('cache');

            $server_name = self::getServerName($domain);

            if (!$cache->has($config->cache->base_config_key . $server_name . '_baseconfig')) {
                return self::raiseError("No existe configuracion para el dominio: " . $server_name);
            }

            $domain_config = $cache->get($config->cache->base_config_key . $server_name . '_baseconfig');
        } catch (\Throwable $th) {
            var_dump($th);
        }

        // $admonConfigPath = $config->application->admonsDir . $server_name . '/basic.ini';

        // if (!file_exists($admonConfigPath)) {
        //     return self::raiseError("No existe configuracion para el dominio: " . $server_name);
        // }

        // $domain_config = file_get_contents($admonConfigPath);
        // $domain_config = json_decode($domain_config, true);

        return $domain_config;
    }

    /**
     * Devuelve el nombre del servidor sin http o https\
     * https://www.webpremium.local -> webpremium.local
     *
     * @param   string  $domain                 nombre del dominio
     * @param   boolean $defaultToServerGlobal  en caso de no tener un dominio usar $_SERVER['HTTP_HOST']
     *
     * @access  public
     * @return  string  nombre del dominio
     */
    public static function getServerName($domain = null, $defaultToServerGlobal = true)
    {
        if (empty($domain)) {
            if (!$defaultToServerGlobal) {
                return null;
            }
            $domain = $_SERVER['HTTP_HOST'];
        }

        // https://
        $domain = preg_replace('#[^:]+:/+#i', '', $domain);
        // queryString
        $domain = preg_replace('#/.*$#i', '', $domain);
        // port
        $domain = preg_replace('#:[0-9]+$#i', '', $domain);

        // $host = explode('.', $domain);
        // $host = implode('.', array_slice($host, -2));
        $host = preg_replace('/^www./', '', $domain);

        return idn_to_ascii($host, 0, INTL_IDNA_VARIANT_UTS46);
    }

    /**
     * Devuelve el nombre del servidor sin http o https\
     * https://www.webpremium.local -> www.webpremium.local
     *
     * @param   string  $domain                 nombre del dominio
     * @param   boolean $defaultToServerGlobal  en caso de no tener un dominio usar $_SERVER['HTTP_HOST']
     *
     * @access  public
     * @return  string  nombre del dominio
     */
    public static function getCleanHost($domain = null, $defaultToServerGlobal = true)
    {
        if (empty($domain)) {
            if (!$defaultToServerGlobal) {
                return null;
            }
            $domain = $_SERVER['HTTP_HOST'];
        }
        $domain = preg_replace('#[^:]+:/+#i', '', $domain);
        $domain = preg_replace('#/.*$#i', '', $domain);

        return idn_to_ascii($domain, 0, INTL_IDNA_VARIANT_UTS46);
    }

    /**
     * Desencripta un texto
     *
     * @param   string  $text   texto encriptado
     *
     * @access  public
     * @return  mixed   Datos desencriptados
     */
    public static function decrypt($text)
    {
        $crypt  = new \Phalcon\Encryption\Crypt();

        $crypt->setCipher('aes-256-ctr');
        //$crypt->setHashAlgorithm('sha256');
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        // Force calculation of a digest of the message based on the Hash algorithm
        $crypt->useSigning(true);
        try {
            $res = $crypt->decryptBase64($text, $config->app_key);
        } catch (Exception $ex) {
        } catch (Error $err) {
        } catch (Mismatch $mis) {
        } catch (\Phalcon\Encryption\Crypt\Exception $crpex) {
            // var_dump($crpex, $mis, $err, $ex);
            // exit(0);
            $res = false;
        }

        return $res;
    }


    /**
     * Devuelve las fechas de cierre que ha establecido el punto de venta para los sorteos
     *
     * @param   int     $idGame Id del juego que se quiere la fecha del siguiente sorteo (si no se pasa se devuelven todos)
     *
     * @access  public
     * @return  mixed   Vector con los juegos y sus fechas o un String con la fecha del que se ha pasado
     */
    public static function getCloseDateNextDraw($idGame = null)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $days = [
            "1" => 'monday',
            "2" => 'tuesday',
            "3" => 'wednesday',
            "4" => 'thursday',
            "5" => 'friday',
            "6" => 'saturday',
            "7" => 'sunday',
        ];
        $now = new DateTime();
        $numberToday = $now->format("N");
        if ($config->datosadmon->data->games->buy_online !== 1 || $config->datosadmon->data->games->club_amigo_online !== 0) {
            return ($idGame ? '' : []);
        }

        if ($idGame) {
            $result = '';
            $closeDateAssoc = json_decode(json_encode($config->datosadmon->data->games->close_dates), true);

            // si hay fechas para ese juego
            if (is_array($closeDateAssoc) && array_key_exists($idGame, $closeDateAssoc)) {
                // si el juego tiene fecha de hoy
                // var_dump($closeDateAssoc[$idGame], $closeDateAssoc[$idGame][$numberToday], $numberToday);
                // exit(0);
                if (array_key_exists($numberToday, $closeDateAssoc[$idGame])) {
                    // si la hora del juego de hoy todavia no ha pasado se devuelve esa
                    $drawDate = self::getCloseDateByDayNumber($closeDateAssoc[$idGame][$numberToday]["close_id_day"]) . ' ' . $closeDateAssoc[$idGame][$numberToday]["close_hour"];
                    if (strtotime($drawDate) > strtotime($now->format('Y-m-d H:i:s'))) {
                        // devolver fecha del sorteo
                        // $result = $now->format('Y-m-d') . ' ' . $closeDateAssoc[$idGame][$numberToday];
                        $result = $drawDate;
                    }
                }

                if (empty($result) && !empty($closeDateAssoc[$idGame])) {
                    // si no está en el array pillar el siguiente ej.
                    // [1,4,5] si se pasa un 3 devolver 4, si se pasa 6 devolver 1
                    $nextDay = null;
                    foreach ($closeDateAssoc[$idGame] as $key => $value) {
                        if (is_null($nextDay)) {
                            $nextDay = $value;
                        }
                        if ($key > $numberToday) {
                            $nextDay = $value;
                            break;
                        }
                    }
                    $nextDrawDay = new DateTime('next ' . $days[$nextDay["close_id_day"]]);
                    $result = $nextDrawDay->format('Y-m-d') . ' ' . $nextDay["close_hour"];
                    unset($nextDay);
                }
            }

            $result = date('Y-m-d H:i:s', strtotime('-'.self::getBestHoursNeeded($idGame).' hours', strtotime($result)));
        } else {
            $result = [];
            foreach ($config->datosadmon->data->games->close_dates as $game => $close_dates) {
                $close_dates = json_decode(json_encode($close_dates), true);

                if (array_key_exists($numberToday, $close_dates) && $close_dates[$numberToday]) {
                    $drawDate = self::getCloseDateByDayNumber($close_dates[$numberToday]["close_id_day"]) . ' ' . $close_dates[$numberToday]["close_hour"];
                    if (strtotime($drawDate) > strtotime($now->format('Y-m-d H:i:s'))) {
                        // devolver fecha del sorteo
                        $result[$game] = $drawDate;
                    }
                }

                if (!isset($result[$game]) && !empty($close_dates)) {
                    // si no está en el array pillar el siguiente ej.
                    // [1,4,5] si se pasa un 3 devolver 4, si se pasa 6 devolver 1
                    $nextDay = null;
                    foreach ($close_dates as $key => $value) {
                        if (is_null($nextDay)) {
                            $nextDay = $value;
                        }
                        if ($key > $numberToday) {
                            $nextDay = $value;
                            break;
                        }
                    }
                    $nextDrawDay = new DateTime('next ' . $days[$nextDay["close_id_day"]]);
                    $result[$game] = $nextDrawDay->format('Y-m-d') . ' ' . $nextDay["close_hour"];
                    unset($nextDay);
                }

                $result[$game] = date('Y-m-d H:i:s', strtotime('-'.self::getBestHoursNeeded($game).' hours', strtotime($result[$game])));
            }
        }

        return $result;
    }

    /**
     * Devuelve el día de la semana correspondiente al número que se recibe, si el número
     * de la semana es menor que el que se ha recibido se devuelve el día de la semana anterior
     *
     * lunes -> 1
     * domingo -> 7
     *
     * @param string    $number             Número del día de la semana
     * @param string    $date               Fecha desde donde contar la semana
     * @param boolean   $includeTime        Incluir la hora, minutos y segundos o no
     *
     * @access public
     * @return string                       Fecha en formato 'Y-m-d' o 'Y-m-d H:i:s'
     **/
    public static function getCloseDateByDayNumber($number, $date = 'now', $includeTime = false)
    {
        try {
            $today = new DateTime($date);
        } catch (\Throwable $th) {
            return null;
        }

        $number = strval($number);
        $days = [
            "1" => 'monday',
            "2" => 'tuesday',
            "3" => 'wednesday',
            "4" => 'thursday',
            "5" => 'friday',
            "6" => 'saturday',
            "7" => 'sunday',
        ];

        if (!isset($days[$number])) {
            return null;
        }

        if ($today->format('N') < $number) {
            // si hoy es 3(miercoles) y te pasan un 6(sabado) no quieres el siguiente sabado sino el anterior
            $resultDayPrompt = $days[$number] . ' last week';
        } else {
            $resultDayPrompt = $days[$number] . ' this week';
        }

        $result = date('Y-m-d', strtotime($resultDayPrompt, $today->getTimestamp()));

        if ($includeTime) {
            $result .= ' ' . $today->format('H:i:s');
        }

        return $result;
    }

    /**
     * Devuelve el día de la semana correspondiente al número que se recibe
     *
     * lunes -> 1
     * domingo -> 7
     *
     * @param string    $number             Número del día de la semana
     * @param string    $date               Fecha desde donde contar la semana
     * @param boolean   $includeTime        Incluir la hora, minutos y segundos o no
     *
     * @access public
     * @return string                       Fecha en formato 'Y-m-d' o 'Y-m-d H:i:s'
     **/
    public static function getDateByDayNumber($number, $date = 'now', $includeTime = false)
    {
        try {
            $today = new DateTime($date);
        } catch (\Throwable $th) {
            return null;
        }

        $number = strval($number);
        $days = [
            "1" => 'monday',
            "2" => 'tuesday',
            "3" => 'wednesday',
            "4" => 'thursday',
            "5" => 'friday',
            "6" => 'saturday',
            "7" => 'sunday',
        ];

        if (!isset($days[$number])) {
            return null;
        }

        $result = date('Y-m-d', strtotime($days[$number] . ' this week', strtotime($today->format('Y-m-d H:i:s'))));

        if ($includeTime) {
            $result .= ' ' . $today->format('H:i:s');
        }

        return $result;
    }

    /**
     * Devuelve el primer dia de la semana disponible para hacer compras contando los festivos y
     * las horas de demora de los pagos y envíos
     *
     * lunes -> 1
     * domingo -> 7
     *
     * @param int       $idGame Número del juego para las horas de cierre
     *
     * @access public
     * @return string           Fecha en formato 'Y-m-d H:i:s'
     **/
    public static function getFirstEnabledDay($idGame)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $close_dates = json_decode(json_encode($config->datosadmon->data->games->close_dates->{$idGame}), true);
        if (!is_array($close_dates)) {
            return '';
        }
        $pvCalendar = array_keys(json_decode(json_encode($config->pvCalendar), true));
        $today = strtotime('now');
        // empezar a contar a partir del dia de hoy
        $dayNumber = (int) date('N', $today);
        $j = 0;
        $neededHours = Utilities::getBestHoursNeeded($idGame);
        $enabled = false;
        while (!$enabled) {
            for ($i=$dayNumber; $i <= 7; $i++) {
                if (!array_key_exists($i, $close_dates)) {
                    continue;
                }
                $nextDay = Utilities::getDateByDayNumber($close_dates[$i]['close_id_day'], date('Y-m-d H:i:s', strtotime('+' . $j . ' weeks')));
                if (!in_array($nextDay, $pvCalendar) && $today < strtotime('-' . $neededHours . ' hours', strtotime($nextDay . ' ' . $close_dates[$i]['close_hour']))) {
                    $result = $nextDay . ' ' . $close_dates[$i]['close_hour'];
                    $enabled = true;
                    break;
                }
            }

            // la siguiente semana empezar por el lunes
            $dayNumber = 1;
            $j += 1;
        }

        return $result;
    }

    /**
     * Devuelve las horas minimas para hacer un pedido (mejor envio y pago)
     *
     * @access public
     * @return int
     **/
    public static function getBestHoursNeeded($idGame)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();

        $paymentHours = null;
        foreach ($config->datosadmon->data->payments as $payment) {
            $payment = json_decode(json_encode($payment), true);
            if (!array_key_exists("hours_needed", $payment)) {
                continue;
            }

            if (is_null($paymentHours)) {
                $paymentHours = $payment["hours_needed"];
            }

            if ($paymentHours > $payment["hours_needed"]) {
                $paymentHours = $payment["hours_needed"];
            }
        }

        if (is_null($paymentHours)) {
            $paymentHours = 0;
        }

        // $isShippable = 0 comprobar solo $shipping["is_shippable"] == 0
        // $isShippable = 1 comprobar todos $shipping
        $isShippable = (int)$di->getShared('getgames')->{$idGame}->is_shippable;
        $shippingHours = null;
        foreach ($config->datosadmon->data->shippings as $shipping) {
            $shipping = json_decode(json_encode($shipping), true);
            if ($isShippable === 0 && intval($shipping["is_shippable"]) == 1) {
                continue;
            }
            if (is_null($shippingHours)) {
                $shippingHours = $shipping["hours_needed"];
            }

            if ($shippingHours > $shipping["hours_needed"]) {
                $shippingHours = $shipping["hours_needed"];
            }
        }

        if (is_null($shippingHours)) {
            $shippingHours = 0;
        }

        return ($paymentHours + $shippingHours);
    }

    /**
     * Devuelve los datos del juego que se ha filtrado por el code
     *
     * @param   string  $code   String con el codigo del juego ("EMIL"|"LAPR"|"BONO"|"GP"|"LN20"|"TU"|"LQ"|"QGOL")
     *
     * @access  public
     * @return  array   Vector con los datos del juego que se ha filtrado por el code
     */
    public static function getGameByCode($code)
    {
        $di = \Phalcon\Di\Di::getDefault();
        //$config = $di->getConfig();
        $games = $di->getShared('getgames');

        if (gettype($games) != 'array') {
            if (method_exists($games, "toArray")) {
                $games = $games->toArray();
            } else {
                $games = json_decode(json_encode($games), true);
            }
        }

        $selectedGame = array_filter($games, function ($game) use ($code) {
            if ($game["code"] == $code) {
                return true;
            }
        });

        // return $selectedGame[array_key_first($selectedGame)];
        return $selectedGame[array_keys($selectedGame)[0]];
    }

    /**
     * Combina 2 arrays con todas las posibilidades del primero al segundo ej.
     * * ["a"], ["b"] => ["a-b"]\
     * * ["a", "c"], ["b"] => ["a-b", "c-b"]\
     * * ["a", "c"], ["b", "a"] => ["a-b", "a-a", "c-b", "c-a"]\
     * * ["a", "c"], ["b", "a"] !=> ~~["a-b", "a-a", "c-b", "c-a", "a-c", "b-c"]~~
     *
     * @param   array   $fisrtArray     primer array
     * @param   array   $secondArray    segundo array
     * @param   string  $separator      separador para los valores finales
     * @param   boolean $sort           ordenar los valores finales
     *
     * @return  array   array con los valores combinados
     */
    public static function arrayCombineValues($fisrtArray, $secondArray, $separator = '-', $sort = true)
    {
        $result = [];
        for ($x=0; $x < count($fisrtArray); $x++) {
            for ($z=0; $z < count($secondArray); $z++) {
                $result[] = $fisrtArray[$x] . $separator . $secondArray[$z];
            }
        }

        if ($sort) {
            sort($result);
        }

        return $result;
    }

    /**
     * Funcion para el calculo de apuestas para los juegos de tipo Apuestas Deportivas
     *
     * @param   array   $array  Array con los datos de la apuesta
     * * [['2'],           ['X'],      ['2'], ['X'], ['2'], ['1'], ['2'], ['1'], ['1'], ['X'], ['X'], ['1'], ['2'], ['X']]
     * * [['2', '1', 'X'], ['X', '1'], ['2'], ['X'], ['2'], ['1'], ['2'], ['1'], ['1'], ['X'], ['X'], ['1'], ['2'], ['X']]
     *
     * * [['2-2'],               ['1-1'], ['1-M'], ['2-2'], ['2-2'], ['M-1']]
     * * [['2-2', '1-1', '1-M'], ['1-1'], ['1-M'], ['2-2'], ['2-2'], ['M-1']]
     *
     * @access  public
     * @return  int     Número total de apuestas
     */
    public static function getNumSportBets($array)
    {
        $total = 1;

        foreach ($array as $bets) {
            if (is_array($bets[0])) {
                $total *= self::getNumSportBets($bets);
            } else {
                $total *= count($bets);
            }
        }

        return $total;
    }

    /**
     * Elimina (renombra con _del) el dominio indicado borrando tambien el certificado para https
     *
     * @param   string  $serverName     nombre del dominio del que se quiere borrar el host ej. webpremium.eu o pre.webpremium.eu (sin el www)
     * @param   string  $hostFile       ruta del archivo del vhost ej. hosts_apache/webpremium.eu.conf o hosts_nginx/webpremium.eu
     * @param   boolean $restartServer  reiniciar el servidor tras el borrado o no
     *
     * @access  public
     * @return  mixed   true o Vector con el error
     */
    public static function removeHost($serverName, $hostFile, $restartServer = false)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $cache = $di->getShared('cache');
        $publicUrlDefault = self::getServerName($config->application->publicUrlDefault, false);

        //deshabilitar la web
        switch ($config->application->web_server) {
            case 'nginx':
                $res     = 0;
                $output  = [];
                $command = 'sudo nginx_modsite -d ' . $serverName;
                exec($command . ' 2>&1', $output, $res);

                if ($res != 0) {
                    if ($output[0] != 'nginx_modsite: ERROR: Site does not appear to be enabled.') {
                        return self::raiseError('Error in "' . $command .'": ' . implode(PHP_EOL, $output) . ' | code: ' . $res);
                    }
                }
                break;
            case 'apache':
            default:
                // para apche no hace falta ejecutar nada
                break;
        }

        //eliminar el fichero del vhost
        $pos = strpos($serverName, $publicUrlDefault);
        if ($pos === false) {
            if (file_exists($hostFile)) {
                if (!unlink($hostFile)) {
                    return self::raiseError(json_encode(error_get_last()));
                }
                // $res     = 0;
                // $output  = [];
                // $command = 'rm ' . $hostFile;
                // exec($command . ' 2>&1', $output, $res);

                // if ($res != 0) {
                //     return self::raiseError('Error in "' . $command .'": ' . implode(PHP_EOL, $output) . ' | code: ' . $res);
                // }
            }
        }

        $res     = 0;
        $output  = [];
        $command = 'sudo certbot certificates -d ' . $serverName . ' 2>&1 | grep "Certificate Name" | cut -f2 -d":" | sed -E "s/^\s+//g"';
        exec($command . ' 2>&1', $output, $res);

        if ($res != 0) {
            return self::raiseError('Error in "' . $command .'": ' . implode(PHP_EOL, $output) . ' | code: ' . $res);
        }

        if (!empty($output[0])) {
            $certName = $output[0];
    
            //eliminar el certificado
            $res     = 0;
            $output  = [];
            $command = "sudo certbot delete --non-interactive --agree-tos --no-self-upgrade --cert-name " . $certName;
            exec($command . ' 2>&1', $output, $res);
    
            if ($res != 0) {
                return self::raiseError('Error in "' . $command .'": ' . implode(PHP_EOL, $output) . ' | code: ' . $res);
            }
        }

        //borrar los datos de la administracion
        if (!empty($serverName)) {
            $keys = $cache->getAdapter()->getKeys();
            foreach ($keys as $key) {
                if (preg_match('/^webpre_.*'.$serverName.'/', $key)) {
                    // getKeys lo devuelve con el prefijo pero para borrarlas hay que quitarlo
                    $cache->delete(ltrim($key, 'webpre_'));
                }
            }
        }

        if ($restartServer) {
            $restartStatus = self::restartServer('Error trying to restart the server after removing vhost: ');
            if ($restartStatus !== true) {
                return $restartStatus;
            }
        }
        return true;
    }

    /**
     * Reinicia el servidor apache/nginx
     *
     * @param   string  $errorMsg   mensaje con el error que se quiera devolver en caso de fallo, se
     * le concatenará el error que devuelva el comando
     *
     * @access  public
     * @return  mixed   true o Vector con el error
     */
    public static function restartServer($errorMsg = 'Error restarting server: ')
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();

        switch ($config->application->web_server) {
            case 'nginx':
                // no se sabe si es necesario reiniciar el nginx
                // $output  = [];
                // $command = "sudo nginx_modsite -r";
                // exec($command, $output, $res);

                // if ($res != 0) {
                //     return self::raiseError($errorMsg . implode(PHP_EOL, $output));
                // }
                break;
            case 'apache':
            default:
                $output  = [];
                $command = "sudo apachectl graceful";
                exec($command, $output, $res);

                if ($res != 0) {
                    return self::raiseError($errorMsg . implode(PHP_EOL, $output));
                }
                break;
        }
        return true;
    }

    public static function getNewRestful($url, $method, $body = null)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $response_object = new RestfulResponse;

        $headers = [
            'Content-Type' => 'application/json',
        ];

        if (is_array($_COOKIE) && array_key_exists('PHPSESSID', $_COOKIE) && !empty($_COOKIE['PHPSESSID'])) {
            $headers['Cookie'] = 'PHPSESSID=' . $_COOKIE['PHPSESSID'];
        }

        $client = new Client([
            'base_uri' => $config->ws_url,
            // You can set any number of default request options.
            'timeout' => 35.0, // En segundos
            'verify' => false,
            'headers' => $headers,
            'debug' => false,
        ]);

        $arr_body = array(
            'token' => $config->baseconfig->token,
            'pass' => self::decrypt($config->baseconfig->password),
            'app_id' => $config->get('app_id')
        );

        foreach ($body as $k => $b) {
            $arr_body[$k] = $b;
        }

        $json_body = json_encode($arr_body);

        try {
            $response = $client->request(
                $method,
                $url,
                ['body' => $json_body]
            );

            if (BENCHMARK_ENABLED) {
                \Infolot\Benchmark::set_time('time_'.__CLASS__.'_'.__FUNCTION__.'_'.$url.'::request', 2);
            }

            $response_object->code = $response->getStatusCode();
            $response_object->phrase = $response->getReasonPhrase();
            $response_object->body_type = 3;
            $response_object->body = json_decode($response->getBody());
        } catch (Exception $e) {
            $response_object->code = "Error";
            $response_object->phrase = "Error";
            $response_object->body_type = 3;
            $response_object->body = "Error";
        }

        return $response_object;
    }

    public static function getClient()
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();

        $client = new Client([
            'base_uri' => $config->ws_url,
            'timeout' => 35.0, // En segundos
            'verify' => false,
            'headers' => ['Content-Type' => 'application/json'],
            'debug' => false,
        ]);

        return $client;
    }

    public static function getRequestBody()
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();

        $domain_config = self::getDomainConfig($config->baseconfig->domain);

        if (is_array($domain_config) && !is_null($domain_config["error"])) {
            return $domain_config;
        }
        // var_dump(
        //     $domain_config->token, $domain_config->password,
        //     $domain_config["token"], $domain_config["password"]
        // );
        // exit(0);
        $requestBody = [
            'token'     => $domain_config->token,
            'pass'      => self::decrypt($domain_config->password),
            'app_id'    => $config->app_id,
            'user_agent'=> $_SERVER['HTTP_USER_AGENT'],
            'ip'        => $_SERVER['REMOTE_ADDR'],
        ];

        return $requestBody;
    }

    public static function getResults($idGame)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $cache = $di->getShared('cache');
        if (!$cache->has($config->cache->base_config_key . 'game_results_' . $idGame)) {
            self::updateGameResults($idGame, $config->baseconfig->domain);
        }
        return $cache->get($config->cache->base_config_key . 'game_results_' . $idGame);
    }

    public static function updateAvailableGames()
    {
        $di     = \Phalcon\Di\Di::getDefault();
        $config = $di->getShared('config');
        $cache = $di->getShared('cache');
        if (!$cache->has($config->cache->base_config_key . self::getServerName($config->baseconfig->domain) . '_datosadmon')) {
            self::updatePvInfo(true);
        }
        $datosAdmon = $cache->get($config->cache->base_config_key . self::getServerName($config->baseconfig->domain) . '_datosadmon');
        $availableGames = [];

        if (is_null($datosAdmon)) {
            return;
        }
        // pillarlo como array assoc para poder mirar las claves dinamicamente
        $allGames = json_decode(json_encode($datosAdmon->data->games->all), true);
        foreach ($datosAdmon->data->games->active as $value) {
            if ($allGames[$value]) {
                $availableGames[] = $allGames[$value]['id'];
            }
        }

        if ($cache->set($config->cache->base_config_key . self::getServerName($config->baseconfig->domain) . '_availableGames', $availableGames) !== true) {
            return Utilities::raiseError("No se ha podido guardar el archivo basic.ini", true);
        }
    }

    public static function updatePvCalendar()
    {
        $di     = \Phalcon\Di\Di::getDefault();
        $config = $di->getShared('config');
        $cache = $di->getShared('cache');
        if (!$cache->has($config->cache->base_config_key . self::getServerName($config->baseconfig->domain) . '_datosadmon')) {
            self::updatePvInfo(true);
        }

        $requestBody = self::getRequestBody();
        $client = self::getClient();

        try {
            $response = $client->request(
                'GET',
                'pv-calendar',
                ['body' => json_encode($requestBody)]
            );

            $body = json_decode($response->getBody());

            if (isset($body->error)) {
                return self::raiseError("Error en pv-calendar " . $body->error);
            }

            $config->pvCalendar = $body->data;

            if ($cache->set($config->cache->base_config_key . self::getServerName($config->baseconfig->domain) . '_pvCalendar', $config->pvCalendar) !== true) {
                return self::raiseError("No se ha podido guardar en cache");
            }
        } catch (Exception $e) {
            return self::raiseError("Error updating pv-calendar");
        }

        return array("updated" => true);
    }

    /**
     * Completa la configuración del config con los datos en cache
     * si no están en cache se actualizan llamando al webservice
     *
     * @return void
     **/
    public static function completeConfigFromCache($generalOnly = false)
    {
        $di         = \Phalcon\Di\Di::getDefault();
        $config     = $di->getShared('config');
        $cache      = $di->getShared('cache');
        $request    = new Request();
        $input      = json_decode($request->getRawBody());
        $serverName = null;

        if (BENCHMARK_ENABLED) {
            \Infolot\Benchmark::set_time('time_complete_config_cache_ini', 2);
        }

        if (!is_null($input) && !empty($input->domain)) {
            $serverName = $input->domain;
        }
        // solo rellenarla si se ha llamado antes al api/admon para rellenar el baseconfig
        if (!$config->cache->ini_config) {
            return;
        }

        if (!$cache->has($config->cache->base_config_key . self::getServerName($serverName) . '_baseconfig')) {
            return;
        }
        if (BENCHMARK_ENABLED) {
            \Infolot\Benchmark::set_time('time_complete_config_cache_check', 2);
        }
        $generalConfigKeys = [
            //key del config/cache     function             params
            'getgames'             => ['updateGames'       => []], //get_games.ini
            'infocities'           => ['updateLocations'   => []], //info_cities.ini
            'infoprovinces'        => ['updateLocations'   => []], //info_provinces.ini
            'infocountries'        => ['updateLocations'   => []], //info_countries.ini
            'infonextdrawsgeneral' => ['updateNextDraws'   => []], //info_next_draws_general.ini
            'infonextdrawsnavidad' => ['updateNextDraws'   => []], //info_next_draws_navidad.ini
            'infonextdrawsnino'    => ['updateNextDraws'   => []], //info_next_draws_nino.ini
            'infonextjackpots'     => ['updateJackpots'    => []], //info_next_jackpots.ini
            'lastgameresults'      => ['updateGameResults' => []], //admonsPath. 'game_results_%%idgame%%.ini
            'getseodraws'          => ['updateSeoDraws'    => []],
            'default_pages'        => ['updatePages'       => [null, 'default']],
        ];

        $pv_cache_key  = $config->cache->base_config_key . self::getServerName($serverName) . '_';
        $pvConfigKeys = [
            'baseconfig' => ['setBaseconfigConfigParam' => [$serverName]],     //basic.ini
            'availableGames' => ['updateAvailableGames' => []], //$datos_admon->data->games->active del datos_admon.ini
            'datosadmon' => ['updatePvInfo' => []],     //datos_admon.ini
            'pvCalendar' => ['updatePvCalendar' => []],
        ];

        $notConfigPvFiles = [
            // que esto llame al pv-pages y las compare con la cache
            // 'pages' => ['updatePages' => [null, 'add']],
            // 'communities' => ['updateCommunity' => [json_decode(json_encode(["mode" => 'add', "uuid" => '?']))]],
            // communities tiene la funcion updateCommunity para poder actualizarlo pero si no se dispone del
            // uuid de la entidad no se puede hacer la llamada al ws
            'communities' => [],
        ];

        if (!$generalOnly) {
            //Configuraciones especificas para cada punto de venta
            unset($configParam);
            unset($updateFunctions);
            foreach ($pvConfigKeys as $configParam => $updateFunctions) {
                // las configuraciones propias del PV (datosadmon, availableGames, ...) se guardan con el nombre del dominio
                if (!$cache->has($pv_cache_key . $configParam) || ($configParam == 'datosadmon' && is_null($cache->get($pv_cache_key . $configParam)))) {
                    foreach ($updateFunctions as $fn => $params) {
                        if (method_exists(self::class, $fn)) {
                            self::$fn(...$params);
                        }
                    }
                }
                $config->offsetSet($configParam, $cache->get($pv_cache_key . $configParam));
            }
        }
        if (BENCHMARK_ENABLED) {
            \Infolot\Benchmark::set_time('time_complete_config_cache_offset_pv', 2);
        }

        // solo consultar el pv-pages propio si tiene el addon
        if (property_exists($config->datosadmon->data, 'is_web_seo_onpage') && $config->datosadmon->data->is_web_seo_onpage) {
            $notConfigPvFiles['pages'] = ['updatePages' => [null, 'add']];
        }
        
        //Configuraciones generales para todos los puntos de venta
        foreach ($generalConfigKeys as $configParam => $updateFunctions) {
            if (!$cache->has($config->cache->base_config_key . $configParam)) {
                foreach ($updateFunctions as $fn => $params) {
                    if (method_exists(self::class, $fn)) {
                        self::$fn(...$params);
                    }
                }
                // una vez que se hayan ejecutado las funciones
                // de actualizacion el valor debería estar en cache
            }
            // solo se asignan claves del primer nivel del array (en un futuro hacerlo pudiendo pasar el array)
            //TODO puede que el webservice devuelva un  error
            // $config->$configParam = $cache->get($config->cache->base_config_key . $configParam);
            // FRANCIS (31/07/2023): No lo inyectamos en el config, porq sino:
            // - engordamos el config
            // - se ejecuta cada vez la obtención de datos, cuando a lo mejor sólo se usa en secciones concretas
            //$config->offsetSet($configParam, $cache->get($config->cache->base_config_key . $configParam));

            if (BENCHMARK_ENABLED) {
                \Infolot\Benchmark::set_time('time_complete_config_cache_offset_general_'.$configParam, 3);
            }
        }
        if (BENCHMARK_ENABLED) {
            \Infolot\Benchmark::set_time('time_complete_config_cache_offset_general', 2);
        }
        if (!$generalOnly) {
            //Datos que no se guardan en la configuración y son especificos para cada punto de venta
            unset($configParam);
            unset($updateFunctions);
            foreach ($notConfigPvFiles as $configParam => $updateFunctions) {
                if (!$cache->has($pv_cache_key . $configParam)) {
                    foreach ($updateFunctions as $fn => $params) {
                        if (method_exists(self::class, $fn)) {
                            self::$fn(...$params);
                        }
                    }
                }
            }
        }
        if (BENCHMARK_ENABLED) {
            \Infolot\Benchmark::set_time('time_complete_config_cache_end', 2);
        }
    }

    /**
     * Almacena un array de keys de cache de la cache
     * Sirve para saber si valores generados dinamicamente están almacenados en la cache
     * A un grupo de valores dinamicos como el webseo se le asigna el index pages y si
     * existe este indice es porque existen los valores
     *
     * @param string    $indexKey   key de la cache donde está guardado el index con las otras keys
     * @param string    $cacheKey   key que se quiere almacenar/borar en el index
     * @param boolean   $remove     false para añadir al index, true para borrar del index
     * @return type
     * @throws conditon
     **/
    public static function updateCacheIndex($indexKey, $cacheKey, $remove = false)
    {
        $di     = \Phalcon\Di\Di::getDefault();
        $cache = $di->getShared('cache');

        $result = false;

        if ($remove) {
            // si el index no esiste no hay nada por borrar
            $result = true;
            if ($cache->has($indexKey)) {
                $storedKeys = $cache->get($indexKey);
                // si el $cacheKey no está guardado no hay nada por borrar
                if (in_array($cacheKey, $storedKeys)) {
                    array_splice($storedKeys, array_search($cacheKey, $storedKeys), 1);
                    if (count($storedKeys) == 0) {
                        // si se han borrado todas la keys se borra el index
                        $result = $cache->delete($indexKey);
                    } else {
                        $result = $cache->set($indexKey, $storedKeys);
                    }
                }
            }
        } else {
            if ($cache->has($indexKey)) {
                $storedKeys = $cache->get($indexKey);
                $result = true;
                // si la clave nueva no esta se guarda
                if (!in_array($cacheKey, $storedKeys)) {
                    $storedKeys[] = $cacheKey;
                    $result = $cache->set($indexKey, $storedKeys);
                }
            } else {
                //crear el page index con la clave que se ha pasado
                $result = $cache->set($indexKey, [$cacheKey]);
            }
        }

        return $result === true;
    }

    public static function removeOldResults($resultados)
    {
        $sorteos_filtro = [];
        foreach ($resultados as $prox_sorteo) {
            if (strtotime($prox_sorteo["date_draw"]) > strtotime("now")) {
                $sorteos_filtro[] = $prox_sorteo;
            }
        }

        return $sorteos_filtro;
    }

    /**
     * Comprueba que los sorteos del buscador de numeros están actualizados
     *
     * @return void
     **/
    public static function checkSearchDraws()
    {
        $di     = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();

        if (is_null($config->datosadmon) || is_null($config->datosadmon->data->searcher->search_draw_assigned)) {
            return;
        }

        if (!$config->datosadmon->data->is_search_numbers) {
            return;
        }

        $oldDraws = json_decode(json_encode($config->datosadmon->data->searcher->search_draw_assigned), true);
        $newDraws = $di->getShared('getseodraws');

        if (empty($oldDraws) || empty($newDraws)) {
            self::updateSearchDraws();
            return;
        }

        if (count(array_diff(array_keys($oldDraws), array_keys($newDraws))) != 0) {
            self::updateSearchDraws();
            return;
        }

        foreach ($oldDraws as $name_seo => $drawId) {
            $draw = null;
            foreach ($newDraws as $d) {
                if ($d["id"] == $drawId) {
                    $draw = $d;
                    break;
                }
            }

            if (is_null($draw)) {
                self::updateSearchDraws();
                return;
            }
        }
    }

    /**
     * Actualiza los sorteos del buscador de números de las webs
     *
     * @return void
     **/
    public static function updateSearchDraws()
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $cache = $di->getShared('cache');

        $domain_config = self::getDomainConfig($domain ? $domain : $config->baseconfig->domain);

        if (is_array($domain_config) && !is_null($domain_config["error"])) {
            return $domain_config;
        }

        $requestBody = self::getRequestBody();
        $client = self::getClient();

        try {
            $response = $client->request(
                'GET',
                'update-search-draws',
                ['body' => json_encode($requestBody)]
            );

            $body = json_decode($response->getBody());

            if (isset($body->error)) {
                return self::raiseError("Error en pv-info " . $body->error);
            }

            $config->datosadmon->data->searcher->search_draw_assigned = $body->data;

            if ($cache->set($config->cache->base_config_key . self::getServerName($config->baseconfig->domain) . '_datosadmon', $config->datosadmon) !== true) {
                return self::raiseError("No se ha podido guardar en cache");
            }

            // actualizar los sorteos por si estan obsoletos
            $cache->delete($config->cache->base_config_key . 'getseodraws');
        } catch (Exception $e) {
            return self::raiseError("Error updating info");
        }
    }

    /**
     * Devuelve los sorteos del buscador de números por name_seo
     *
     * @param   $drawId     id del sorteo del que se quieren los datos
     *
     * @return array        Devuelve el array de sorteo o null si no hay searcher o sorteos asociados
     **/
    public static function getSearchDrawsByNameSeo($drawId = null)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();

        $searcherDrawArray = json_decode(json_encode($config->datosadmon->data->searcher->search_draw_assigned), true);
        if ($config->datosadmon->data->is_search_numbers) {
            $hasSearcher = (is_array($searcherDrawArray) && count($searcherDrawArray) > 0);
        } else {
            $hasSearcher = false;
        }
        if (!$hasSearcher) {
            return null;
        }

        $draws = $di->getShared('getseodraws');
        if (!is_null($drawId)) {
            $draw  = null;
            foreach ($draws as $d) {
                if ($d["id"] == $drawId) {
                    $draw = $d;
                    break;
                }
            }

            return $draw;
        }

        $drawsByNameSeo = [];
        // Si hay un sorteo en las urls que todavia no está subido no se va a mostrar
        foreach ($config->datosadmon->data->searcher->search_draw_assigned as $nameSeo => $drawId) {
            if (array_key_exists($nameSeo, $draws)) {
                $drawsByNameSeo[$nameSeo] = $draws[$nameSeo];
            }/*
            foreach ($draws as $d) {
                if ($d['id'] == $drawId) {
                    $drawsByNameSeo[$nameSeo] = $d;
                    break;
                }
            }*/
        }

        return (count($drawsByNameSeo) > 0) ? $drawsByNameSeo : null;
    }

    /**
     * Devuelve el nombre de las urls del buscador de numeros con los sorteos actuales, si hay una url con
     * un sorteo que no está en cache no se devuelve
     *
     * @return array
     **/
    public static function getSearchUrlByNameSeo()
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        
        $draws = self::getSearchDrawsByNameSeo();
        if (is_null($draws)) {
            return null;
        }
        
        $names = [];
        foreach (array_keys($draws) as $nameSeo) {
            $names[$nameSeo] = $config->datosadmon->data->searcher->search_url->{$nameSeo};
        }

        return $names;
    }

    /**
     * Devuelve el nombre de las urls del buscador de numeros con los sorteos actuales excluyendo los que
     * no tengan marcado el sitema habilitado
     * si hay una url con un sorteo que no está en cache no se devuelve
     *
     * @return array
     **/
    public static function getSitemapSearchUrlByNameSeo()
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();

        // si no tiene configurado el excluir sitemaps se pasan todos
        if (!$config->datosadmon->data->searcher->search_sitemap) {
            return self::getSearchUrlByNameSeo();
        }
        
        $draws = self::getSearchDrawsByNameSeo();
        if (is_null($draws)) {
            return null;
        }

        $enabledSitemaps = array_keys(json_decode(json_encode($config->datosadmon->data->searcher->search_sitemap), true));

        $names = [];
        foreach (array_keys($draws) as $nameSeo) {
            if (in_array($nameSeo, $enabledSitemaps)) {
                $names[$nameSeo] = $config->datosadmon->data->searcher->search_url->{$nameSeo};
            }
        }

        return $names;
    }

    /**
     * Devuelve el [name_seo => search_url] de un sorteo por id
     *
     * @param   $drawId     id del sorteo del que se quieren los datos
     *
     * @return array        Devuelve el array con los datos o null si no hay search_url asociada
     **/
    public static function getSearchUrlFromIdDraw($drawId = null)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        
        $searcherDrawArray = json_decode(json_encode($config->datosadmon->data->searcher->search_draw_assigned), true);


        if (!$config->datosadmon->data->is_search_numbers) {
            return null;
        }

        if (is_null($searcherDrawArray)) {
            return null;
        }

        $nameSeoDraw = null;
        // se saca el name seo del sorteo que se ha pasado
        foreach ($searcherDrawArray as $nameSeo => $id) {
            if ($id == $drawId) {
                $nameSeoDraw = $nameSeo;
                break;
            }
        }

        if (is_null($nameSeoDraw)) {
            return null;
        }

        // se devuelve con el name_seo y el search_url de ese sorteo
        return [$nameSeoDraw => $config->datosadmon->data->searcher->search_url->{$nameSeoDraw}];
    }

    /**
     * Devuelve el sitemap del numero indicado
     *
     * Los sitemaps se separan en 50k urls por archivo
     *
     * @param int   $number Numero del sitemap
     * @return array        Array con las url en el formato xml para recorrerlo haciendo echo
     **/
    public static function getSitemap($number)
    {
        $di = \Phalcon\Di\Di::getDefault();
        // $cache = $di->getShared('cache');
        // $config = $di->getConfig();
        // cada incremento del $index es un sitemap nuevo
        $index = 0;
        $allSitemaps = [];

        if ($number == 0) {
            // las rutas principales deben ir antes del buscador por si se cambia alguna url del
            // buscador que no desplace el index de urls que son fijas
            $routes = $di->getRouter()->getRoutes();
            // rutas dinamicas que incluye phalcon
            $excludedUrls = [
                '#^/([\w0-9\_\-]+)[/]{0,1}$#u',
                '#^/([\w0-9\_\-]+)/([\w0-9\.\_]+)(/.*)*$#u',
            ];
            // controladores y actions que no se quieren en el sitemap
            // si el action esta vacio se excluye el controlador entero
            $excludedPaths = [
                'search'    => [], // las urls del buscador se incluyen abajo
                'sitemap'   => [],
                'ajax'      => [],
                'order'     => ['resumeOrder'],
                'carrito'   => ['carritoComunidad'],
                'sections'  => ['ventaParticipacionesWithKeyword', 'getHeader', 'getFooter'], // las entidades no entran
                'css'       => [],
                'validate'  => [],
                'api'       => [],
                'test'      => [],
                'scripts'   => [],
                'storybook' => [],
            ];
    
            foreach ($routes as $route) {
                $controller = mb_strtolower($route->getPaths()['controller']);
                $action     = $route->getPaths()['action'];
                $url        = $route->getPattern();

                if (in_array($url, $excludedUrls)) {
                    continue;
                }

                if (in_array($controller, array_keys($excludedPaths))) {
                    if (empty($excludedPaths[$controller])) {
                        continue;
                    }
                    if (in_array($action, $excludedPaths[$controller])) {
                        continue;
                    }
                }

                $allSitemaps[$index][] = $route->getPattern();
            }
            $index++;
        }

        // URLS del buscador de numeros (ya no se calculan al vuelo, se usan archivos volt)
        /*
        if ($config->datosadmon->data->is_search_numbers && $number != 0) {
            $urls = [];
            $tmp = Utilities::getSearchUrlByNameSeo();
            foreach ($tmp as $key => $value) {
                $urls[] = "/$key/$value";
            }
            unset($tmp);

            $urlsQuantity = count($urls);
            /**
             * Cada sitemap tendrá x urls con un minimo de 50.000 por sitemap
             * esto se traduce a tener con 2 sitemaps sitemap1.xml.gz y sitemap2.xm.gz
             * y con 4 sitemap1.xml.gz, sitemap2.xm.gz, sitemap3.xml.gz y sitemap4.xm.gz
             *
             * Cuantos mas sitemaps menos tarda en cargar la url
             * Si no se elige un divisor justo faltarán urls
             * El sitemapindex puede tener hasta 50.000 sitemaps en total
             *
             * | Sitemaps | Números por sitemap |
             * |----------|---------------------|
             * | 2        | 50000               |
             * | 4        | 25000               |
             * | 5        | 20000               |
             * | 8        | 12500               |
             * | 10       | 10000               |
             * | 16       | 6250                |
             * | 20       | 5000                |
             * | 25       | 4000                |
             * | 32       | 3125                |
             * | 40       | 2500                |
             * | 50       | 2000                |
             * | 80       | 1250                |
             * | 100      | 1000                |
             * | 125      | 800                 |
             * | 160      | 625                 |
             * | 200      | 500                 |
             * | 250      | 400                 |
             * | 400      | 250                 |
             * | 500      | 200                 |
             * | 625      | 160                 |
             * | 800      | 125                 |
             *
             *//*
            $sitemapsToCreate = 10;
            // 100.000 son los numeros que tiene un sorteo, del 00000 al 99999
            $numbersPerSitemap = 100000/$sitemapsToCreate;
            for ($i=0; $i < $urlsQuantity; $i++) {
                // 100.000 numeros repartidos en varios archivos
                for ($m=0; $m < $sitemapsToCreate; $m++) {
                    // si se ha elegido 9 se salta del 0 al 8
                    // si se ha elegido el 14 y solo se crean 10 es que esta en la siguiente url
                    // y se saltan todos los primeros del $m = 0 al 9 y de la siguiente tanda del 0 al 3
                    if ($index < $number) {
                        $index++;
                        continue;
                    }

                    for ($n=($m*$numbersPerSitemap); $n < ($m*$numbersPerSitemap+$numbersPerSitemap); $n++) {
                        $allSitemaps[$index][] = $urls[$i] . $config["search_urls"]["fullNumber"] . str_pad($n, 5, '0', STR_PAD_LEFT);
                    }

                    // una vez se haya calculado el sitemap elegido se corta el bucle
                    if ($index == $number) {
                        break 2;
                    }

                    $index++;
                }

                // si llega aqui o se estan buscando las terminaciones o esta en la siguiente url
                // si $index == $number es la terminacion y si es < está en las siguientes urls
                if ($index < $number) {
                    $index++;
                    continue;
                }

                // index del buscador
                $allSitemaps[$index][] = $urls[$i];

                // 10.000 terminaciones
                for ($l=0; $l < 10000; $l++) {
                    $allSitemaps[$index][] = $urls[$i] . $config["search_urls"]["tailNumber"] . $l;
                }
                $index++;

                // si llega aqui se andaban buscando las terminaciones y se cierra el bucle
                break;
            }
        }
        */

        return $allSitemaps[$number];
    }

    /**
     * Devuelve la fecha de last_mod de un sorteo del buscador de numeros
     *
     * @param string    $nameSeo    Nombre de la url del buscador ej. 'sorteo-navidad'
     *
     * @return string               Devuelve la fecha en formato Y-m-d
     **/
    public static function getLastModByNameSeo($nameSeo)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $cache = $di->getShared('cache');
        $cacheKey = $config->cache->base_config_key . self::getServerName($config->baseconfig->domain) . "_searcher_last_mod";

        if ($cache->has($cacheKey)) {
            $data = $cache->get($cacheKey);
            if (is_array($data) && isset($cache->get($cacheKey)[$nameSeo])) {
                return $cache->get($cacheKey)[$nameSeo];
            }
        }

        return self::updateSearcherLastMod($nameSeo);
    }

    /**
     * Actualiza la fecha de last_mod del sitemap del buscador de numeros indicado
     *
     * @param string    $nameSeo    Nombre de la url del buscador ej. 'sorteo-navidad'
     *
     * @return string               Fecha actualizada
     **/
    public static function updateSearcherLastMod($nameSeo)
    {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getConfig();
        $cache = $di->getShared('cache');
        $lastMod = date('Y-m-d');
        
        $cacheKey = $config->cache->base_config_key . self::getServerName($config->baseconfig->domain) . "_searcher_last_mod";
        
        $array = $cache->get($cacheKey);
        if (is_null($array)) {
            $array = [];
        }

        $array[$nameSeo] = $lastMod;
        $cache->set($cacheKey, $array);
        
        return $lastMod;
    }

    /**
     * Comprueba que las fechas de last_mod esten al dia con los datos del buscador de numeros
     *
     * @param array     $newSearchUrls  Array con las urls actualizadas del buscador del pv-info
     *
     * @return boolean                  Devuelve true si todo ha ido bien
     **/
    public static function checkSearcherLastMod($newSearchUrls)
    {
        if (is_null($newSearchUrls)) {
            return;
        }

        $di         = \Phalcon\Di\Di::getDefault();
        $config     = $di->getConfig();
        $cache      = $di->getShared('cache');
        $lastMod    = date('Y-m-d');
        $cacheKey   = $config->cache->base_config_key . self::getServerName($config->baseconfig->domain) . "_searcher_last_mod";
        $result     = [];

        $oldLastMods = $cache->get($cacheKey);
        if (is_null($oldLastMods)) {
            $oldLastMods = [];
        }

        $oldSearchUrls = $cache->get($config->cache->base_config_key . self::getServerName($config->baseconfig->domain) . '_datosadmon');
        if ($oldSearchUrls) {
            if (is_null($oldSearchUrls->data->searcher->search_url)) {
                $oldSearchUrls = [];
            } else {
                $oldSearchUrls = json_decode(json_encode($oldSearchUrls->data->searcher->search_url), true);
            }
        } else {
            $oldSearchUrls = [];
        }

        foreach ($newSearchUrls as $newNameSeo => $newNameUrl) {
            if (!in_array($newNameSeo, array_keys($oldSearchUrls)) || $oldSearchUrls[$newNameSeo] != $newNameUrl) {
                //si es un seo nuevo o se ha cambiado el nombre se actualiza la fecha
                $result[$newNameSeo] = $lastMod;
            } else {
                // si no se ha modificado se queda como antes, y si antes no tenia fecha se le pone la actual
                $result[$newNameSeo] = $oldLastMods[$newNameSeo] ? $oldLastMods[$newNameSeo] : $lastMod;
            }
        }

        // si ha habido cambios se guarda en cache y se hace ping a google
        if (count(array_diff_assoc($oldLastMods, $result)) || count(array_diff_assoc($result, $oldLastMods))) {
            if ($cache->set($cacheKey, $result) === true) {
                if (!$config->local) {
                    $ch = curl_init();
                    curl_setopt($ch, CURLOPT_URL, 'https://www.google.com/ping?sitemap=' . rtrim($config->datosadmon->data->url->main, '/') . '/sitemap_index.xml.gz');
                    curl_setopt($ch, CURLOPT_NOBODY, 1);
                    curl_exec($ch);
                    curl_close($ch);
                }

                return true;
            }
            return false;
        }

        return true;
    }

    /**
     * Modificador |number_int
     *
     * @param string $content   Contenido del bloque
     *
     * @access public
     * @return string           Número entero formateado
     **/
    public static function number_int($content)
    {
        if (strlen($content) == 0) {
            return '';
        }

        return number_format((int)round($content), 0, '', '.');
    }

    /**
     * Modificador |number_float
     *
     * @param string $content   Contenido del bloque
     *
     * @access public
     * @return string           Número real formateado
     **/
    public static function number_float($content, $dec = 2)
    {
        if (is_null($content) || strlen($content) == 0) {
            return '';
        }

        return number_format((float)$content, (int)$dec, ',', '.');
    }

    /**
     * Modificador |number_float
     *
     * @param string $content   Contenido del bloque
     *
     * @access public
     * @return string           Número real formateado
     **/
    public static function max_value($content, $maxValue)
    {
        if (is_null($content) || strlen($content) == 0) {
            return '';
        }
        
        if (floatval($content) > $maxValue) {
            return $maxValue;
        }

        return $content;
    }

    public static function void_output(...$i)
    {
        return '';
    }

    /**
     * Completa el compilador con filtros y funciones personalizadas
     *
     * @param   \Phalcon\Mvc\View\Engine\Volt\Compiler $compiler
     */
    public static function completeCompiler(\Phalcon\Mvc\View\Engine\Volt\Compiler &$compiler)
    {
        $phpextension = '\\'.__NAMESPACE__.'\PhpFunctionExtension';

        $compiler
            // FILTROS
            ->addFilter('max_value', __NAMESPACE__.'\Utilities::max_value')
            ->addFilter('number_float', __NAMESPACE__.'\Utilities::number_float')
            ->addFilter('number_int', __NAMESPACE__.'\Utilities::number_int')
            ->addFilter('date_format', function ($resolvedArgs, $exprArgs) use ($compiler) {
                $text   = $compiler->expression($exprArgs[0]['expr']);
                $format = $compiler->expression($exprArgs[1]['expr']);
                $alreadyTimestamped = null;
                if (array_key_exists(2, $exprArgs)) {
                    $alreadyTimestamped = $compiler->expression($exprArgs[2]['expr']);
                }

                if ($alreadyTimestamped == 'true') {
                    return 'date('.$format.', '.$text.')';
                }

                return  'date('.$format.',strtotime('.$text.'))';
            })
            ->addFilter('getAttribute', function ($resolvedArgs, $exprArgs) {
                return vsprintf('%s->%s', explode(', ', $resolvedArgs));
            })

            // FUNCIONES
            ->addFunction('normalize', function ($resolvedArgs) {
                return '\\'.__NAMESPACE__.'\Utilities::normalize('.$resolvedArgs.')';
            })
            ->addFunction('get_item_css', function ($resolvedArgs) {
                return '\\'.__NAMESPACE__.'\Utilities::get_item_css('.$resolvedArgs.')';
            })
            ->addFunction('check_remote_file', function ($resolvedArgs) {
                return '\\'.__NAMESPACE__.'\Utilities::check_remote_file('.$resolvedArgs.')';
            })
            ->addFunction('view_sorteo', function ($resolvedArgs) {
                return '\\'.__NAMESPACE__.'\Utilities::view_sorteo('.$resolvedArgs.')';
            })
            ->addFunction('void_output', function ($resolvedArgs) {
                return '\\'.__NAMESPACE__.'\Utilities::void_output('.$resolvedArgs.')';
            })

            // EXTENSIONES
            ->addExtension(new $phpextension());
    }

    /**
     * Devuelve si una plantilla existe
     */
    public static function template_exists($template)
    {
        $di = \Phalcon\Di\Di::getDefault();

        return file_exists($di->getShared('view')->getViewsDir().$template.'.volt');
    }

    /**
     * Comprueba si dos apuestas pueden estar en el mismo boleto
     *
     * 
     *
     * @param array $game   Configuracion del juego
     * @param array $betA   Apuesta 1
     * @param array $betB   Apuesta 2
     * @return bool
     **/
    public static function isBetOnSameSlip($game, $betA = null, $betB = null)
    {
        // var_dump($betA, $betB);
        // exit(0);
        if (is_null($betA) || is_null($betB)) {
            // si solo se pasa 1 apuesta no se puede comparar por lo que la propio apuesta si está en el mismo boleto
            return true;
        }

        if ($betA["tipo"] == "multiple" || $betB["tipo"] == "multiple") {
            return false;
        }

        // se pueden elegir diferentes reintegros por boleto en cada apuesta, hay que comprobar que sean iguales para que entren en el mismo
        if ($game["is_num_refund"] && $game["is_num_refund_per_slip"]) {
            if ($game["is_link_num_refund_extra"]) {
                if (is_array($betA['extras'])) {
                    foreach ($betA["extras"] as $i => $value) {
                        if (json_encode($value) != json_encode($betB["extras"][$i])) {
                            return false;
                        }
                    }
                    // if (!$betA["extras"].every((e, i) => e == $betB["extras"][i])) {
                    //     return false;
                    // }
                } else {
                    if (json_encode($betA['extras']) != json_encode($betB['extras'])) {
                        return false;
                    }
                }
            } else if (json_encode($betA["refund"]) != json_encode($betB["refund"])) {
                return false;
            }
        }

        // si hay un mismo extra para varias apuestas hay que tener en cuenta si los extras son iguales
        if ($game["num_max_bets_per_slip"] != $game["num_max_extras_per_slip"]) {
            if (is_array($betA['extras'])) {
                foreach ($betA["extras"] as $i => $value) {
                    if (json_encode($value) != json_encode($betB["extras"][$i])) {
                        return false;
                    }
                }
                // if (!$betA["extras"].every((e, i) => JSON.stringify(e) == JSON.stringify($betB["extras"][i]))) {
                //     return false;
                // }
            } else {
                if (json_encode($betA['extras']) != json_encode($betB['extras'])) {
                    return false;
                }
            }
        }

        if ($game["is_code_a"] && $game["is_code_a_per_slip"]) {
            if ($game["is_code_a_selectable"]) {
                foreach ($betA["code_a"] as $i => $value) {
                    if (json_encode($value) != json_encode($betB["code_a"][$i])) {
                        return false;
                    }
                }
                // if (!$betA["code_a"].every((e, i) => e == $betB["code_a"][i])) {
                //     return false;
                // }
            } else if (json_encode($betA["code_a"]) != json_encode($betB["code_a"])) {
                return false;
            }
        }

        if ($game["is_code_b"] && $game["is_code_b_per_slip"]) {
            if ($game["is_code_b_selectable"]) {
                foreach ($betA["code_b"] as $i => $value) {
                    if (json_encode($value) != json_encode($betB["code_b"][$i])) {
                        return false;
                    }
                }
                // if (!$betA["code_b"].every((e, i) => e == $betB["code_b"][i])) {
                //     return false;
                // }
            } else if (json_encode($betA["code_b"]) != json_encode($betB["code_b"])) {
                return false;
            }
        }

        return true;
    }

    // ########################################################################################################
    // ##                                                                                                    ##
    // ## Estas funciones se han modificado para funcionar con quiniela y no se han probado con otros juegos ##
    // ##                                                                                                    ##
    // ########################################################################################################
    public static function getItemPrice(array $item, array $game, int $num_days, array $draw = null)
    {
        // Rifa (Mirar si tiene id_draw)
        if ($game['id_type'] == 3 && $game['is_link_draw']) {
            /* No tenemos en cuenta la cantidad, porque irá un boleto por línea, y este precio se calcula por linea
               con lo que siempre será 1
            $quantity = (int)$item['quantity'];
            if (empty($quantity)) {
                $quantity = 1;
            }*/
            $quantity = 1;

            // Si ya tenemos el sorteo devolvemos el precio
            if (!empty($draw)) {
                return (float)($draw['price_ticket'] * $quantity);
            }

            // SINO lo consultamos
            if (empty($item['id_draw'])) {
                return Utilities::raiseError('Debe indicar el ID del sorteo');
            }

            $draw = Draw::findFirst([
                'conditions' => 'id_draw = :id_draw:',
                'bind'       => ['id_draw' => $item['id_draw']]
            ]);
            if (!empty($draw)) {
                return (float)($draw->price_ticket * $quantity);
            }

            return Utilities::raiseError('Sorteo incorrecto');
        }

        // Resto de juegos, hay que mirar el precio del sorteo
        $price_bet = (float)$game['price'];
        if (empty($price_bet)) {
            return Utilities::raiseError('Precio del juego no configurado');
        }

        $num_bets = Utilities::get_num_bets($item, $game);

        if (empty($num_bets)) {
            return Utilities::raiseError('No se ha podido calcular el número de apuestas totales del boleto');
        }

        $total = $num_bets * $price_bet;

        // Código A: Obligatorio o si es opcional viene rellenado
        if (!$game['is_code_a_optional'] || (isset($item['code_a']) && !empty($item['code_a']))) {
            // Si supone coste adicional miramos si es por boleto o apuesta
            $code_price = (float)$game['code_a_price'];
            if ($code_price > 0) {
                $total_code = $game['is_code_a_per_slip'] ? $code_price: $num_bets * $code_price;

                if ($game['is_code_a_selectable']) {
                    $total_code *= Utilities::get_num_bets_code($item, $game, $item['code_a']);
                }

                $total += $total_code;
            }
        }

        // Código B
        if (!$game['is_code_b_optional'] || (isset($item['code_b']) && !empty($item['code_b']))) {
            // Si supone coste adicional miramos si es por boleto o apuesta
            $code_price = (float)$game['code_b_price'];
            if ($code_price > 0) {
                $total_code = $game['is_code_b_per_slip'] ? $code_price: $num_bets * $code_price;

                if ($game['is_code_b_selectable']) {
                    $total_code *= Utilities::get_num_bets_code($item, $game, $item['code_b']);
                }

                $total += $total_code;
            }
        }

        return $total * $num_days;
    }

    public static function get_num_bets(&$slip, &$game)
    {
        // Apuesta múltiple
        if (self::is_slip_multiple($slip, $game)) {
            switch ($game['id_type']) {
                case 2:
                    $num_bets = 1;
                    if (isset($slip['numeros']) && is_array($slip['numeros']) && isset($slip['numeros'][0]) && is_array($slip['numeros'][0])) {
                        foreach ($slip['numeros'] as $bet) {
                            $num_bets *= count($bet);
                        }

                        if (!empty($game['num_extra_per_bet']) && isset($slip['extras']) && is_array($slip['extras']) && isset($slip['extras'][0]) && is_array($slip['extras'][0])) {
                            foreach ($slip['extras'] as $extra) {
                                $num_bets *= count($extra);
                            }
                        }
                    }

                    return $num_bets;
                    break;

                case 1:
                    $t_numbers = 1;
                    if (isset($slip['numeros']) && is_array($slip['numeros']) && isset($slip['numeros'][0]) && is_array($slip['numeros'][0])) {
                        $t_numbers = Utilities::combinatoria(count($slip['numeros'][0]), $game['num_number_per_bet']);

                        if (!empty($game['num_extra_per_bet'])) {
                            $t_extras        = Utilities::combinatoria(count($slip['extras'][0]), $game['num_extra_per_bet']);
                            $t_combinaciones = $t_numbers * $t_extras;

                            return $t_numbers * $t_extras;
                        }
                    }

                    return $t_numbers;
                    break;
            }
        }

        return count($slip['numeros']);
    }

    public static function is_slip_multiple(&$slip, &$game)
    {
        $num_bets   = 0;
        $num_extras = 0;

        // Juegos tipo apuestas deportivas
        if ($game['id_type'] == 2) {
            if (isset($slip['numeros']) && is_array($slip['numeros']) && isset($slip['numeros'][0]) && is_array($slip['numeros'][0])) {
                foreach ($slip['numeros'] as $bet) {
                    if (count($bet) > 1) {
                        return true;
                    }
                }
            }

            if ($game['num_extra_per_bet'] > 0) {
                if (isset($slip['extras']) && is_array($slip['extras']) && isset($slip['extras'][0]) && is_array($slip['extras'][0])) {
                    foreach ($slip['extras'] as $extra) {
                        if (count($extra) > 1) {
                            return true;
                        }
                    }
                }
            }

            // Juegos tipo lotto
        } elseif ($game['id_type'] == 1) {
            $num_bets   = (isset($slip['numeros']) && is_array($slip['numeros']) && isset($slip['numeros'][0]) && is_array($slip['numeros'][0])) ? count($slip['numeros'][0]) : 0;
            if ($num_bets > $game['num_number_per_bet']) {
                return true;
            }

            if ($game['num_extra_per_bet'] > 0) {
                $num_extras = (isset($slip['extras'])  && is_array($slip['extras']) && isset($slip['extras'][0]) && is_array($slip['extras'][0])) ? count($slip['extras'][0])  : 0;
                if ($num_extras > $game['num_extra_per_bet']) {
                    return true;
                }
            }
        }

        return false;
    }

    public static function combinatoria($m, $n)
    {
        if ($m == $n) {
            return 1;
        }

        return self::factorial($m) / (self::factorial($n) * self::factorial($m - $n));
    }

    public static function factorial($n)
    {
        if ($n > 2) {
            return $n * self::factorial($n - 1);
        }

        return $n;
    }

    public static function get_num_bets_code(&$slip, &$game, &$code)
    {
        // Apuesta múltiple
        if (self::is_slip_multiple($slip, $game)) {
            switch ($game['id_type']) {
                case 2:
                    $num_bets = 1;
                    if (isset($code) && isset($slip['numeros'][0]) && is_array($slip['numeros'][0])) {
                        foreach ($code as $k => $v) {
                            if (isset($slip['numeros'][$v-1])) {
                                $num_bets *= count($slip['numeros'][$v-1]);
                            }
                        }
                    }
                    return $num_bets;
                    break;
            }
        }

        return 1;
    }
    // ########################################################################################################
    // ########################################################################################################

}
