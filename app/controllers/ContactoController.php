<?php


use GuzzleHttp\Client;
use Infolot\Utilities;
use PHPMailer\PHPMailer\Exception;

class ContactoController extends ControllerBase
{
    public function indexAction()
    {
        $coo = $this->cookies->get('email_enviado')->getValue();

        switch ($coo) {
            case 'true':
                $this->view->email_response = "Email enviado";
                $this->view->is_sended = true;
                break;
            case 'false':
                $this->view->email_response = "Ha ocurrido un error";
                $this->view->is_sended = false;
                break;
            case 'captcha':
                $this->view->email_response = "Error de Captcha";
                $this->view->is_sended = false;
                break;
            case 'mail_error':
                $this->view->email_response = "Error en el envío";
                $this->view->is_sended = false;
                break;
            case 'blacklist':
            case 'token':
                $this->view->email_response = "Se ha detectado que el mensaje puede ser SPAM y no será enviado";
                $this->view->is_sended = false;
                break;
        }

        $coo = $this->cookies->get('email_enviado');
        $coo->delete();
        $this->view->web_seo_onpage = Utilities::getWebSeoOnpage();
    }

    # get success response from recaptcha and return it to controller
    private function captchaverify($recaptcha)
    {
        $url = "https://www.google.com/recaptcha/api/siteverify";
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_HEADER, 0);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, array(
            "secret" => $this->config->get('datosadmon')->data->google->recaptcha_secret_key, "response" => $recaptcha
        ));
        $response = curl_exec($ch);
        curl_close($ch);
        $data = json_decode($response);
        return $data->success;
    }

    public function emailContactoAction()
    {
        /** Formulario deshabilitado temporalmente */
        return $this->response->redirect('contacto');
        /** ************************************** */

        if ($this->request->isPost()) {
            $nombre = $this->request->getPost('nombre');
            $email = $this->request->getPost('email');
            $mensaje = $this->request->getPost('mensaje');
            $acepta = $this->request->getPost('acepto');
            $acepta2 = $this->request->getPost('acepto_2');

            $datosAdmon = $this->config->get('datosadmon')->data;

            //En chrome si hay un recurso que no se encuentra (404) se vuelve a llamar al documento
            //principal y las claves cambian por lo que si no se carga todo bien esto no funciona nunca
            // if (!$this->security->checkToken()) {
            //     $this->cookies->set(
            //         'email_enviado',
            //         "token",
            //         time() + 15 * 86400
            //     );

            //     $this->response->redirect('contacto');

            //     return;
            // }

            if (!$this->captchaverify($this->request->getPost('g-recaptcha-response'))) {
                $this->cookies->set(
                    'email_enviado',
                    "captcha",
                    time() + 15 * 86400
                );

                $this->response->redirect('contacto');

                return;
            }

            if ($acepta != "on" || $acepta2 != "on") {
                $this->cookies->set(
                    'email_enviado',
                    "false",
                    time() + 15 * 86400
                );

                $this->response->redirect('contacto');

                return;
            }

            if (!is_null($datosAdmon->smtp->smtp_mail_body_blacklist) && !empty($datosAdmon->smtp->smtp_mail_body_blacklist)) {
                $curatedBlacklist = [];
                foreach ($datosAdmon->smtp->smtp_mail_body_blacklist as $mail_body_blacklist) {
                    if (preg_match('/^\/.*\/$/', $mail_body_blacklist)) {
                        $curatedBlacklist[] = trim($mail_body_blacklist, '/');
                    } else {
                        $curatedBlacklist[] = preg_quote($mail_body_blacklist);
                    }
                }
                $regex = '/(' . implode(')|(', $curatedBlacklist) . ')/';

                if (preg_match($regex, $mensaje)) {
                    $this->cookies->set(
                        'email_enviado',
                        "blacklist",
                        time() + 15 * 86400
                    );

                    $this->response->redirect('contacto');

                    return;
                }
            }

            if (!is_null($datosAdmon->smtp->smtp_mail_address_blacklist) && !empty($datosAdmon->smtp->smtp_mail_address_blacklist)) {
                $curatedBlacklist = [];
                foreach ($datosAdmon->smtp->smtp_mail_address_blacklist as $mail_address_blacklist) {
                    if (preg_match('/^\/.*\/$/', $mail_address_blacklist)) {
                        $curatedBlacklist[] = trim($mail_address_blacklist, '/');
                    } else {
                        $curatedBlacklist[] = preg_quote($mail_address_blacklist);
                    }
                }
                $regex = '/(' . implode(')|(', $curatedBlacklist) . ')/';

                if (preg_match($regex, $email)) {
                    $this->cookies->set(
                        'email_enviado',
                        "blacklist",
                        time() + 15 * 86400
                    );

                    $this->response->redirect('contacto');

                    return;
                }
            }

            $client = new Client([
                'base_uri' => $this->config->ws_url,
                // You can set any number of default request options.
                'timeout' => 35.0, // En segundos
                'verify' => false,
                'headers' => ['Content-Type' => 'application/json'],
                'debug' => false,
            ]);

            $domain_config = Utilities::getDomainConfig($input->domain);

            if (is_array($domain_config) && !is_null($domain_config["error"])) {
                $this->cookies->set(
                    'email_enviado',
                    "false",
                    time() + 15 + 86400
                );
                $this->response->redirect('contacto');
            }

            $decryptPass = Utilities::decrypt($domain_config->password);
            if ($decryptPass === false) {
                $this->cookies->set(
                    'email_enviado',
                    "false",
                    time() + 15 + 86400
                );
                $this->response->redirect('contacto');
            }

            $requestBody = [
                "name" => $nombre,
                "email" => $email,
                "body" => $mensaje,
                "token" => $domain_config->token,
                "pass"  => $decryptPass,
                "app_id"    => $this->config->app_id,
                "user_agent"=> $_SERVER["HTTP_USER_AGENT"],
                "ip"        => $_SERVER["REMOTE_ADDR"],
            ];

            try {
                $response = $client->request('POST', 'send-mail', array('body' => json_encode($requestBody)));
                $body = json_decode($response->getBody());

                if (isset($body->error)) {
                    $this->cookies->set(
                        'email_enviado',
                        "false",
                        time() + 15 + 86400
                    );
                } else {
                    $this->cookies->set(
                        'email_enviado',
                        "true",
                        time() + 15 + 86400
                    );
                }
                $this->response->redirect('contacto');
            } catch (Exception $e) {
                $this->cookies->set(
                    'email_enviado',
                    "false",
                    time() + 15 + 86400
                );
                $this->response->redirect('contacto');
            }
        } else {
            $this->response->redirect('contacto');
        }
    }
}
