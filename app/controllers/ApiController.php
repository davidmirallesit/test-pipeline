<?php
/**
 * Created by PhpStorm.
 * User: mackbookpro
 * Date: 2019-09-30
 * Time: 11:02
 */

// namespace Infolot\Controllers;

use Phalcon\Http\Request;
use GuzzleHttp\Client;
use Infolot\Utilities;

/**
 * TODO
 *    $app->notFound(function () use ($app) {
 *        $app->response->setStatusCode(404, "Not Found")->sendHeaders();
 *
 */
#[\AllowDynamicProperties]
class ApiController extends \Phalcon\Mvc\Controller
{
    /**
     * Deshabilita la vista para todos los metodos, inicia las variables comunes y
     * comprueba que la contraseña de la llamada coincida con la almacenada en el config
     *
     * $this->server_name   Dominio del servidor sobre el que se quiere actuar
     * $this->requestBody   Array con los datos mínimos para hacer consultas al WS
     * $this->client        Cliente de conexion con el WS
     *
     * @access  public
     */
    public function initialize()
    {
        $this->view->disable();
        $input = $this->getInput();
        $this->response->setHeader('Content-Type', 'application/json');

        if ($this->config->maintenance_enabled) {
            $this->response->setStatusCode(403, "");
            echo(Utilities::raiseError("Web en mantenimiento, no se aceptan peticiones en este momento, inténtelo de nuevo más tarde", true));
            exit();
        }

        $this->response->setStatusCode(200, "");

        if ($_REQUEST['_url'] == '/api/ping') {
            // si se pide el ping no hace falta token/pass ni iniciar ningún tipo de lógica
            return;
        }

        if ($input->local_password !== $this->config->local_password) {
            echo(Utilities::raiseError("Error", true));
            exit();
        }

        $this->domain = Utilities::getCleanHost($input->domain, false);
        $this->serverName = Utilities::getServerName($input->domain, false);

        if ($_REQUEST['_url'] == '/api/admon') {
            if ($input->mode == 'delete') {
                return;
            }
            $decryptPass = Utilities::decrypt($input->password);
            if ($decryptPass === false) {
                echo(Utilities::raiseError("Error", true));
                exit();
            }

            $token = $input->token;
            $password = $decryptPass;
        } else {
            $domain_config = Utilities::getDomainConfig($input->domain);

            if (is_array($domain_config) && !is_null($domain_config["error"])) {
                echo(json_encode($domain_config));
                exit();
            }

            $decryptPass = Utilities::decrypt($domain_config->password);
            if ($decryptPass === false) {
                echo(Utilities::raiseError("Error", true));
                exit();
            }

            $token = $domain_config->token;
            $password = $decryptPass;
        }
        
        //TODO usar el getNewRestFull de Utilities
        $this->requestBody = [
            'token'     => $token,
            'pass'      => $password,
            'app_id'    => $this->config->app_id,
            'user_agent'=> $_SERVER['HTTP_USER_AGENT'],
            'ip'        => $_SERVER['REMOTE_ADDR'],
        ];

        $this->client = new Client([
            'base_uri' => $this->config->ws_url,
            // You can set any number of default request options.
            'timeout' => 35.0, // En segundos
            'verify' => false,
            'headers' => ['Content-Type' => 'application/json'],
            'debug' => false,
        ]);

        // $this->response->setContent($json);
        // $this->response->send();
    }

    // public function insertAdmonAction()
    // {
    //     // $this->view->disable();
    // }

    /**
     * Indica si se puede establecer conexión y muestra el tiempo del último commit si la
     * opcion del .env.ini COMMAND_TOUCHCOMMIT = 1
     *
     * @return array
     **/
    public function pingAction()
    {
        return json_encode([
            "data" => [
                'status'        => 'OK',
                'date_commited' => date('d/m/Y H:i:s', filemtime(BASE_PATH.'/public/commands/command.lck'))
            ]
        ]);
    }

    public function communityAction()
    {
        $input = $this->getInput();
        return Utilities::updateCommunity($input);
    }

    /**
     * Desde esta funcion se llaman a los metodos con la funcionalidad de los webhooks
     * según el que se haya pasado
     * Hooks definidos:
     * 'locations'
     * 'jackpots'
     * 'draws'
     * 'results'
     * 'config'
     * 'users'
     * 'pages'
     *
     * @param   array    hook  Array de strings con los hooks que se quieren ejecutar
     *
     * @access  public
     * @return  string          String en formato json con el resultado de la ejecución
     */
    public function webhooksAction()
    {
        $input = $this->getInput();
        $response = array("Hooks" => []);
        foreach ($input->hook as $hook) {
            switch ($hook) {
                case 'locations':
                    $response["Hooks"][] = array("locations" => $this->updateLocationsAction(false));
                    break;
                // case 'jackpots':
                    // $response["Hooks"][] = array("jackpots" => $this->updateJackpotsAction(false));
                    // break;
                case 'draws':
                    $response["Hooks"][] = array("draws" => $this->updateNextDrawsAction(false));
                    break;
                case 'results':
                    $response["Hooks"][] = array("results" => $this->updateGameResultsAction(false), "jackpots" => $this->updateJackpotsAction(false));
                    break;
                case 'config':
                    $response["Hooks"][] = array("config" => $this->updatePvInfo());
                    break;
                case 'users':
                    $response["Hooks"][] = array("users" => $this->updatePvInfo());
                    break;
                case 'pages':
                    $response["Hooks"][] = array("pages" => $this->updatePages());
                    break;
                case 'games':
                    $response["Hooks"][] = array("games" => $this->updateGames());
                    break;
                case 'user_calendar':
                    $response["Hooks"][] = array("user_calendar" => $this->updateUserCalendar());
                    break;
                case 'payment':
                    $response["Hooks"][] = array("payment" => true);
                    break;
                case 'order':
                    $response["Hooks"][] = array("order" => true);
                    break;
                default:
                    return Utilities::raiseError("No se ha definido el hook " . $hook, true);
                    break;
            }
        }

        return json_encode($response);
    }

    /**
     * Actualiza el calendario de festivos de un punto de venta
     *
     * @access  private
     * @return  array           ["updated" => true] si todo va bien y Utilities::raiseError si ha ocurrido un error
     **/
    private function updateUserCalendar()
    {
        return Utilities::updatePvCalendar();
    }

    /**
     * Lógica del webhook pages, actualiza la información de la carpeta pages.
     *
     * @param   string  url     Si se le pasa la url solo acutalizará la carpeta del admon indicado
     * @param   string  mode    default|add|delete tanto add como default devuelven el archivo a la config original,\
     * delete está deshabilitado, se puede pasar por input o por parametro, teniendo preferencia el parametro
     *
     * @access  private
     * @return  array           ["updated" => true] si todo va bien y Utilities::raiseError si ha ocurrido un error
     */
    private function updatePages($mode = null)
    {
        $input = $this->getInput();
        return Utilities::updatePages($input, $mode);
    }

    /**
     * Lógica del webhook users y config, actualiza la información del archivo datos_admon.ini
     *
     * @access  private
     * @return  array           ["updated" => true] si todo va bien y Utilities::raiseError si ha ocurrido un error
     */
    private function updatePvInfo()
    {
        return Utilities::updatePvInfo();
    }

    private function updateGames()
    {
        return Utilities::updateGames();
    }

    /**
     * Lógica del webhook results, actualiza la información de los resultados de los juegos, a parte del webhook se puede llamar directamente
     *
     * @param   array           $ids    Identificadores de los juegos que se quiere actualizar, si no se pasa se actualizan todos
     *
     * @access  public
     * @return  array           ["updated"]["games"][$id_game]["updated" => true] si todo va bien y Utilities::raiseError si ha ocurrido un error
     */
    public function updateGameResultsAction($returnJsonEncoded = true)
    {
        $input = $this->getInput();

        $ids = [];
        if (isset($input->params)) {
            if (is_object($input->params) && property_exists($input->params, 'ids')) {
                $ids = $input->params->ids;
            } elseif (is_array($input->params) && isset($input->params['ids'])) {
                $ids = $input->params['ids'];
            }
        }

        if (!empty($ids)) {
            foreach ($ids as $id_game) {
                $result[$id_game] = Utilities::updateGameResults($id_game, $input->domain);
            }
            /*} elseif (property_exists($input, "params") && property_exists($input->params, "id_game") && $input->params->id_game) {
                $result = Utilities::updateGameResults($input->params->id_game, $input->domain);*/
        } else {
            $result = Utilities::updateGameResults(null, $input->domain);
        }

        if ($returnJsonEncoded) {
            return json_encode($result);
        } else {
            return $result;
        }
    }

    /**
     * Lógica del webhook draws, actualiza la información de los sorteos, a parte del webhook se puede llamar directamente
     *
     * @access  public
     * @return  array           ["updated" => true] si todo va bien y Utilities::raiseError si ha ocurrido un error
     */
    public function updateNextDrawsAction($returnJsonEncoded = true)
    {
        $input = $this->getInput();
        $result = Utilities::updateNextDraws($input);
        $result['seo'] = Utilities::updateSeoDraws();

        if ($returnJsonEncoded) {
            return json_encode($result);
        } else {
            return $result;
        }
    }

    /**
     * Lógica del webhook jackpots, actualiza la información de los botes, a parte del webhook se puede llamar directamente
     *
     * @access  public
     * @return  array           ["updated" => true] si todo va bien y Utilities::raiseError si ha ocurrido un error
     */
    public function updateJackpotsAction($returnJsonEncoded = true)
    {
        $result = Utilities::updateJackpots();

        if ($returnJsonEncoded) {
            return json_encode($result);
        } else {
            return $result;
        }
    }

    /**
     * Lógica del webhook locations, actualiza la información de ciudades, provincias y paises, a parte del webhook se puede llamar directamente
     *
     * @access  public
     * @return  array           ["updated" => true] si todo va bien y Utilities::raiseError si ha ocurrido un error
     */
    public function updateLocationsAction($returnJsonEncoded = true)
    {
        $result = Utilities::updateLocations();

        if ($returnJsonEncoded) {
            return json_encode($result);
        } else {
            return $result;
        }
    }

    public function callApiAdmonAction()
    {
        // Operation to create a fresh robot
        $input = $this->getInput();
        $publicUrlDefault = Utilities::getServerName($this->config->application->publicUrlDefault, false);
        $blUrl = Utilities::getServerName($this->config->bl_url, false);
        $blackListWP = strpos($this->domain, $publicUrlDefault) !== false;
        $blackListBL = strpos($this->domain, $blUrl) !== false;
        // a webpremium y buscarloteria no se le generan vhost/certs
        $isWhitheListed = !($blackListWP || $blackListBL);

        // tanto en produccion como en los otros entornos el dominio debe empezar por www, ej. www.pre.webpremium.eu, www.webpremium.local
        // if (preg_match('/^www./', $this->domain) !== 1) {
        //     return Utilities::raiseError("La URL del dominio debe empezar por www.", true);
        // }

        if (!is_null($this->domain)) {
            $nuevo = false;
            if ($input->mode == "add") {
                $configSave = Utilities::saveBasicConfigOnCahce(json_decode(json_encode($input)));
                if ($configSave !== true) {
                    return $configSave;
                }

                $pvSave = Utilities::updatePvInfo(true);
                if (isset($pvSave["error"])) {
                    return json_encode($pvSave);
                }

                // si se llama a webpremium actualizar todos los datos
                if (strpos($this->domain, $publicUrlDefault) !== false) {
                    Utilities::completeConfigFromCache(true);
                }

                switch ($this->config->application->web_server) {
                    case 'nginx':
                        $hostFolder = '/hosts_nginx';
                        $hostFile = BASE_PATH . $hostFolder . '/' . $this->serverName;
                        $alias = ($this->serverName == $this->domain) ? $this->serverName : $this->serverName . ' ' . $this->domain;
                        $data =<<<EOT
                        server {
                            listen 80;
                            listen [::]:80;
                        
                            server_name $alias;
                            include /etc/nginx/conf.d/_webpremium_nginx_common;
                        }
                
                        EOT;

                    break;
                    case 'apache':
                    default:
                        $hostFolder = '/hosts_apache';
                        $hostFile = BASE_PATH . $hostFolder . '/' . $this->serverName . '.conf';
                        $alias = ($this->serverName == $this->domain) ? "" : "\n\tServerAlias $this->domain";
                        $data =<<<EOT
                        <VirtualHost *:80>
                        \tServerName $this->serverName$alias
                        \tInclude conf.d/_vhost_common_webpremium_http.conf
                        </VirtualHost>
                        <VirtualHost *:443>
                        \tServerName $this->serverName$alias
                        \tInclude conf.d/_vhost_common_webpremium_https.conf
                        </VirtualHost>
                
                        EOT;

                    break;
                }

                if (!is_dir(BASE_PATH . $hostFolder)) {
                    mkdir(BASE_PATH . $hostFolder);
                }

                if ($isWhitheListed) {
                    if (file_exists($hostFile)) {
                        $file = file_get_contents($hostFile);
                        switch ($this->config->application->web_server) {
                            case 'nginx':
                                if (preg_match('/.*ssl_certificate_key .*/', $file) !== 1) {
                                    $nuevo = true;
                                }
                                break;
                            case 'apache':
                            default:
                                if (preg_match('/.*SSLCertificateFile .*/', $file) !== 1) {
                                    $nuevo = true;
                                }
                                break;
                        }
                    } else {
                        $nuevo = true;
                        file_put_contents($hostFile, $data, LOCK_EX);
                    }
                }
            } elseif ($input->mode == "delete") {
                switch ($this->config->application->web_server) {
                    case 'nginx':
                        $hostFolder = '/hosts_nginx';
                        $hostFile = BASE_PATH . $hostFolder . '/' . $this->serverName;
                        break;
                    case 'apache':
                    default:
                        $hostFolder = '/hosts_apache';
                        $hostFile = BASE_PATH . $hostFolder . '/' . $this->serverName . '.conf';
                        
                        break;
                }
                
                //$removeHostStatus = Utilities::removeHost($this->domain, $hostFile, false);
                $removeHostStatus = Utilities::removeHost($this->serverName, $hostFile, false);
                if ($removeHostStatus !== true) {
                    return json_encode($removeHostStatus);
                }
            }

            //Actualización de certificado
            if ($_SERVER['SERVER_NAME'] != 'localhost' && !$this->config->local && $isWhitheListed) {
                if ($input->mode != "delete" && $nuevo) {
                    switch ($this->config->application->web_server) {
                        case 'nginx':
                            $output  = [];
                            $command = "sudo nginx_modsite -e " . $this->serverName;
                            exec($command . ' 2>&1', $output, $res);
                            if ($res != 0) {
                                if ($output[0] != 'nginx_modsite: ERROR: Site appears to already be enabled') {
                                    return Utilities::raiseError('Error in "' . $command .'": ' . "nginx (new domain, to make new files available before certbot command): " . implode(PHP_EOL, $output), true);
                                }
                            }
                            break;
                        case 'apache':
                        default:
                            $restartServerStatus = Utilities::restartServer("Error in first apachectl (new domain, to make new files available before certbot command): ");
                            if ($restartServerStatus !== true) {
                                return json_encode($restartServerStatus);
                            }
                            break;
                    }

                    

                    $testCert = '';
                    // if ($this->config->application->enviroment != 'production') {
                    //     $testCert = ' --test-cert';
                    // }

                    $output  = [];
                    $command = "sudo certbot --" . $this->config->application->web_server . " --redirect --non-interactive --agree-tos --no-self-upgrade --keep-until-expiring --non-interactive -m sistemas@infolot.es " . (($this->serverName == $this->domain) ? "-d $this->serverName" : "-d $this->serverName -d $this->domain") . $testCert;

                    exec($command . ' 2>&1', $output, $res);

                    if ($res != 0) {
                        $output  = [];
                        $command = "sudo certbot run -a webroot -i " . $this->config->application->web_server . " -w /var/www/html --agree-tos --no-self-upgrade --keep-until-expiring --no-redirect " . (($this->serverName == $this->domain) ? "-d $this->serverName" : "-d $this->serverName -d $this->domain") . $testCert;
                        exec($command . ' 2>&1', $output, $res);
                        if ($res != 0) {
                            return Utilities::raiseError(
                                [
                                    "error" => 'Error in first and second certbot "' . $command .'": ' . implode(PHP_EOL, $output),
                                    "command" => $command
                                ],
                                true
                            );
                        }
                    }
                    // se hace la llamada al pv-pages para obtener los textos de la web
                    // $this->updatePages('add');
                    //TODO a esta function hay que pasarle que id_pv_user se está publicando para actualizar sus pv-pages
                    // Utilities::updatePages(null, 'add');
                }

                // si se ha modificado el dominio eliminar el anterior
                if (isset($input->domain_old)) {
                    $oldServerName = Utilities::getServerName($input->domain_old, false);
                    $oldHostFile = BASE_PATH . $hostFolder . '/' . $oldServerName;
                    if ($this->config->application->web_server != 'nginx') {
                        $oldHostFile = $oldHostFile . '.conf';
                    }
                    $removeHostStatus = Utilities::removeHost($oldServerName, $oldHostFile, true);
                    if ($removeHostStatus !== true) {
                        return json_encode($removeHostStatus);
                    }
                }

                if ($input->mode == "delete" || $nuevo) {
                    //otro reinicio de apache, principalmente para que funcionen los nuevos dominios, también después de eliminar alguno
                    $restartServerStatus = Utilities::restartServer("Error in second apachectl (new domain, to make new files available before certbot command): ");
                    if ($restartServerStatus !== true) {
                        return json_encode($restartServerStatus);
                    }
                }
            }

            return json_encode(array("data" => true));
        } else {
            return Utilities::raiseError("Error: domain is null", true);
        }
    }


    /**
     * Devulve los datos de la petición
     *
     * @access  private
     * @return  array       Vector con los datos que se han pasado en la petición
     */
    private function getInput()
    {
        // return $this->request->getJsonRawBody();
        return json_decode($this->request->getRawBody());
    }
}
