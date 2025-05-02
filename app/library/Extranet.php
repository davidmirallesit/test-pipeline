<?php

namespace Infolot;

/**
 * Clase que permite lanzar peticiones a la extranet de usuarios
 * y recoger las respuestas, para poder gestionar las sesiones
 * de usuarios de forma centralizada, independientemente del dominio
 * del que se accede, permitiendo la gestión multidominio.
 *
 * En la configuración se requiere los siguientes parámetros
 *
 *      $config->web->uuid     : UUID de la web que realiza la petición
 *      $config->web->url_panel: URL del panel al que hacer la llamada
 *
 * Además de estos dos parámetros, cada operación puede necesitar
 * indicar parámetros adicionales, que vendrán indicados en sus comentarios
 */
class Extranet
{

    // Si la activamos mostrará el código RAW obtenido mediante CURL (útil cuando hay algún error no contemplado)
    const DEBUG = false;

    /**
     * Constantes definidas (No modificar)
     */
    const ACTION_REGISTER                  = 'register';
    const ACTION_LOGIN                     = 'login';
    const ACTION_LOGOUT                    = 'logout';
    const ACTION_IS_LOGGED                 = 'is_logged';
    const ACTION_ME                        = 'me';
    const ACTION_FORGOT                    = 'forgot';
    const ACTION_VALIDATE_TOKEN            = 'validate_token';
    const ACTION_CHANGE_PASS               = 'change_password';
    const ACTION_RESEND_EMAIL_CONFIRMATION = 'resend_email_confirmation';

    /**
     * Valida un token.
     *
     * Los parámetros tiene la siguiente sintaxis:
     *
     *      [
     *          'token'        => 'XXXX-XXX-XXX-XXX'
     *      ]
     *
     * @param   array   $params     Vector con los datos
     *
     * @access public
     * @return array                Vector con la respuesta
     */
    public static function validate_token($params = [])
    {
        return self::getContentURL(self::ACTION_VALIDATE_TOKEN, $params);
    }

    /**
     * Registra una cuenta de usuario.
     *
     * Los parámetros tiene la siguiente sintaxis:
     *
     *      [
     *          'email'        => 'email@dominio.com',
     *          'pass'         => 'contraseña',
     *          'pass_confirm' => 'repetición contraseña'
     *      ]
     *
     * @param   array   $params     Vector con los datos
     *
     * @access public
     * @return array                Vector con la respuesta
     */
    public static function register($params = [])
    {
        return self::getContentURL(self::ACTION_REGISTER, $params);
    }

    /**
     * Intenta conectar a un usuario.
     *
     * Los parámetros tiene la siguiente sintaxis:
     *
     *      [
     *          'email' => 'email@dominio.com',
     *          'pass'  => 'contraseña'
     *      ]
     *
     * @param   array   $params     Vector con los datos
     *
     * @access public
     * @return array                Vector con la respuesta
     */
    public static function login($params = [])
    {
        return self::getContentURL(self::ACTION_LOGIN, $params);
    }

    /**
     * Intenta desconectar a un usuario
     *
     * @access public
     * @return array                Vector con la respuesta
     */
    public static function logout()
    {
        return self::getContentURL(self::ACTION_LOGOUT);
    }


    /**
     * Comprueba si el usuario está conectado en la extranet
     *
     * @access public
     * @return bool
     */
    public static function isLogged()
    {
        $res = self::getContentURL(self::ACTION_IS_LOGGED);

        return isset($res['error']) ? false : $res['data'];
    }

    /**
     * Devuelve los datos del usuario de la extranet
     *
     * @access public
     * @return array
     */
    public static function me()
    {
        return self::getContentURL(self::ACTION_ME);
    }

    /**
     * Intenta recuperar la contraseña de un usuario.
     *
     * Los parámetros tiene la siguiente sintaxis:
     *
     *      [
     *          'email' => 'email@dominio.com',
     *      ]
     *
     * @param   array   $params     Vector con los datos
     *
     * @access public
     * @return array                Vector con la respuesta
     */
    public static function forgot($params = [])
    {
        return self::getContentURL(self::ACTION_FORGOT, $params);
    }

    /**
     *  Funcion que intentará obtener el contenido de una URL usando CURL
     *
     *  @param  string  $action         Acción a realizar
     *  @param  string  $data           Cadena con las variables del post (opcional)
     *  @param  bool    $login          Si es verdadero se creará un fichero cookie limpio (optional)
     *  @param  bool    $json           Codificar en JSON (opcional)
     */
    private static function getContentURL($action, $data = null, $login = true, $json = true)
    {
        $di             = \Phalcon\Di\Di::getDefault();
        $config         = $di->getConfig();

        if (empty($config->baseconfig->uuid)) {
            return Utilities::raiseError('Debe configurar el parámetro config->web->uuid');
        }
        if (empty($config->baseconfig->url_panel)) {
            return Utilities::raiseError('Debe configurar el parámetro config->web->url_panel');
        }

        $data['uuid'] = $config->baseconfig->uuid;
        $baseurl      = rtrim($config->baseconfig->url_panel, '/') . '/extranet/';

        if ($action != self::ACTION_VALIDATE_TOKEN && !isset($data['redirect']) && isset($_SERVER['REQUEST_SCHEME']) && isset($_SERVER['HTTP_HOST']) && isset($_SERVER['REQUEST_URI'])) {
            $data['redirect'] = $_SERVER['REQUEST_SCHEME'] . '://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'];
        }

        // Importante sólo ejecutarlo si no existe el archivo, porque sino nos cargaríamos las sesiones
        $cookie = __DIR__ . DIRECTORY_SEPARATOR . 'cookie.txt';
        if ($login && !file_exists($cookie)) {
            $fp     = fopen($cookie, "w");
            fclose($fp);
        }

        if (!empty($data) && $json) {
            $data = json_encode($data);
        }

        $url = $baseurl . $action;

        $ch  = curl_init();

        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_HEADER, self::DEBUG);
        curl_setopt($ch, CURLOPT_VERBOSE, self::DEBUG);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($ch, CURLOPT_MAXREDIRS, 6);
        curl_setopt($ch, CURLOPT_TIMEOUT, 12);
        curl_setopt($ch, CURLOPT_AUTOREFERER, true);

        if ($login) {
            curl_setopt($ch, CURLOPT_COOKIEJAR, $cookie);
            curl_setopt($ch, CURLOPT_COOKIEFILE, $cookie);
            curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
        }

        if (!empty($_SERVER['HTTP_USER_AGENT'])) {
            curl_setopt($ch, CURLOPT_USERAGENT, $_SERVER['HTTP_USER_AGENT']);
        } else {
            curl_setopt($ch, CURLOPT_USERAGENT, "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)");
        }

        $headers = [];
        if (!empty($data) || $json) {
            curl_setopt($ch, CURLOPT_POST, true);
        }
        if (!empty($json)) {
            $headers[] = 'Content-Type: application/json';
        }
        if (!empty($headers)) {
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        }
        if (!empty($data)) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        }

        // curl_setopt($ch, CURLOPT_COOKIE,"XDEBUG_SESSION=XDEBUG_ECLIPSE");

        $content = curl_exec($ch);
        $code    = curl_getinfo($ch, CURLINFO_HTTP_CODE);

        if (self::DEBUG) {
            echo '<pre>';
            echo '-----------------------------------------------------' . PHP_EOL;
            echo 'PETICION' . PHP_EOL;
            echo '-----------------------------------------------------' . PHP_EOL;
            echo 'URL: ' . $url . PHP_EOL;
            echo 'DATA: ' . $data . PHP_EOL;
            echo '-----------------------------------------------------' . PHP_EOL;
            echo 'RESPUESTA' . PHP_EOL;
            echo '-----------------------------------------------------' . PHP_EOL;
            echo 'CODIGO: ' . $code . PHP_EOL;
            echo 'BEGIN CONTENT' . PHP_EOL;
            echo $content;
            echo PHP_EOL . 'END CONTENT' . PHP_EOL;
            echo '</pre>';
            exit();
        }

        curl_close($ch);

        if ($code != 200) {
            return Utilities::raiseError(self::http_code_text($code), false, $code);
        }

        return $json ? json_decode($content, true) : $content;
    }

    /**
     * Funcion que devuelve el mensaje asociado al Código HTTP
     *
     * @param   int     $code   Código HTTP
     *
     * @access public
     * @return string           Mensaje
     */
    public static function http_code_text($code)
    {
        switch ($code) {
            case 100:
                return "Continue";
            case 101:
                return "Switching Protocols";

            case 200:
                return "OK";
            case 201:
                return "Created";
            case 202:
                return "Accepted";
            case 203:
                return "Non-Authoritative Information";
            case 204:
                return "No Content";
            case 205:
                return "Reset Content";
            case 206:
                return "Partial Content";

            case 300:
                return "Multiple Choices";
            case 301:
                return "Moved Permanently";
            case 302:
                return "Found";
            case 303:
                return "See Other";
            case 304:
                return "Not Modified";
            case 305:
                return "Use Proxy";
            case 306:
                return "(Unused)";
            case 307:
                return "Temporary Redirect";

            case 400:
                return "Bad Request";
            case 401:
                return "Unauthorized";
            case 402:
                return "Payment Required";
            case 403:
                return "Forbidden";
            case 404:
                return "Not Found";
            case 405:
                return "Method Not Allowed";
            case 406:
                return "Not Acceptable";
            case 407:
                return "Proxy Authentication Required";
            case 408:
                return "Request Timeout";
            case 409:
                return "Conflict";
            case 410:
                return "Gone";
            case 411:
                return "Length Required";
            case 412:
                return "Precondition Failed";
            case 413:
                return "Request Entity Too Large";
            case 414:
                return "Request-URI Too Long";
            case 415:
                return "Unsupported Media Type";
            case 416:
                return "Requested Range Not Satisfiable";
            case 417:
                return "Expectation Failed";

            case 500:
                return "Internal Server Error";
            case 501:
                return "Not Implemented";
            case 502:
                return "Bad Gateway";
            case 503:
                return "Service Unavailable";
            case 504:
                return "Gateway Timeout";
            case 505:
                return "HTTP Version Not Supported";
        }

        return '';
    }

    /**
     * Comprueba si $obj es un error de tipo ExtranetError
     *
     * @access public
     * @return bool
     */
    public static function isError($v)
    {
        return isset($v['error']);
    }
}
