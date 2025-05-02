<div class="page-header col-12" style="background: url('{{config.datosadmon.data.media.header}}')">
    <div class="container">
        <div class="page-header-inner">
            <ol class="breadcrumb wow fadeInDown" data-wow-delay="300ms">
                <li><a href="/">Inicio <span class="pl-2">/</span></a></li>
                <li class="page pl-2"> Contacto</li>
            </ol>
            <h1 class="text-white wow fadeInRight" data-wow-delay="300ms">
                {{web_seo_onpage['h1']}}
            </h1>
        </div>
    </div>
</div>

{% if web_seo_onpage['txt_up'] is not empty %}
    <div class="text-center text-justify page-header">
        <div>{{web_seo_onpage['txt_up']}}</div>
    </div>
{% endif %}

<section id="map" class="col-12 p-0" style="height: 53.4rem;">
    <div class="container-fluid">
        <div class="row">
            <div id="map_canvas"></div>
        </div>
    </div>
</section>


<div class="main-content">

    <section id="contact">
        <div class="container">
            <div class="row wow fadeInDown" data-wow-delay="0.3s">
                <div class="col-md-8 col-sm-7 contact-form">
                    {% if is_sended is defined %}
                        <div class="alert {% if is_sended %}alert-success{% else %}alert-danger{% endif %}" role="alert">{{email_response}}</div>
                    {% endif %}

                    <form role="form" id="contactForm" data-toggle="validator" method="post" action="email-contacto">
                        <input type='hidden' name='{{security.getTokenKey()}}' value='{{security.getToken()}}' />
                        <div class="title-header">
                            <h3 class="title-medium pull-left">Envíanos un mensaje</h3>
                            <div class="icon pull-right"><i class="fa fa-envelope-o"></i></div>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="label-line">
                                    <span class="span"></span>
                                    <!-- <label class="label transition">Nombre:</label> -->
                                    <input style="width: 100%" name="nombre" id="inputNombre" type="text" class="input" id="nombre" required data-error="Por favor introduce tu nombre" placeholder="Nombre">
                                    <div class="help-block with-errors"></div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="label-line">
                                    <span class="span"></span>
                                    <!-- <label class="label transition">Email:</label> -->
                                    <input style="width: 100%" name="email" id="inputEmail" type="email" class="input" id="email" required data-error="Por favor introduce tu email" placeholder="Email">
                                    <div class="help-block with-errors"></div>
                                </div>
                            </div>
                            <div class="col-md-12">
                                <div class="label-line textarea">
                                    <span class="span"></span>
                                    <!-- <label class="label transition">Mensaje:</label> -->
                                    <textarea name="mensaje" id="mensaje" class="input" required data-error="Por favor introduce tu mensaje" placeholder="Mensaje"></textarea>
                                    <div class="help-block with-errors"></div>
                                </div>
                                <div class="form-check">
                                    <input name="acepto" type="checkbox" required required data-error="Es obligatorio aceptar las condiciones" class="form-check-input" style="height:initial" id="envio_datos">
                                    <label class="form-check-label" for="envio_datos">Acepto enviar mis datos</label>
                                </div>
                                <div class="form-check">
                                    <input name="acepto_2" type="checkbox" required required data-error="Es obligatorio aceptar las condiciones" class="form-check-input" style="height:initial" id="envio_datos_2">
                                    <label class="form-check-label" for="envio_datos_2">Soy mayor de 18 años y he leido la <a href="/politica-privacidad">política de privacidad</a> y las <a href="aviso-legal">condiciones de uso</a></label>
                                </div>
                                <!-- captcha v2-->
                                <div style="margin-top: 10px" class="g-recaptcha" data-callback="recaptchaCallback" data-sitekey="{{datosAdmon.google.recaptcha_web_key}}"></div>
                                <button type="submit" id="form-submit" disabled class="btn btn-common">Enviar <i class="fa fa-paper-plane" aria-hidden="true"></i></button>
                                <div id="msgSubmit" class="h3 text-center hidden"></div>
                                <div class="clearfix"></div>
                            </div>
                        </div>
                    </form>



                </div>
                <div class="col-md-4 col-sm-5 information">
                    <div class="title-header">
                        <h3 class="title-medium">Información de Contacto</h3>
                    </div>
                    <div class="contact-datails">
                        <div class="icon">
                            <i class="fa fa-map-marker"></i>
                        </div>
                        <div class="info">
                            <span class="detail">{{datosAdmon.address.address}}<br>{{datosAdmon.address.cp}} {{datosAdmon.address.city}}<br>{{datosAdmon.address.province}}</span>
                        </div>
                    </div>
                    <div class="contact-datails">
                        <div class="icon">
                            <i class="fa fa-phone"></i>
                        </div>
                        <div class="info">
                            <span class="detail">+34 {{datosAdmon.phone}}</span>
                        </div>
                    </div>
                    <div class="contact-datails">
                        <div class="icon">
                            <i class="fa fa-envelope"></i>
                        </div>
                        <div class="info">
                            <span class="detail"><a href="/cdn-cgi/l/email-protection" class="__cf_email__ custom_a_link" data-cfemail="aec7c0c8c1eecfcccdca80cdc1c3">{{datosAdmon.email}}</a></span>
                        </div>
                    </div>
                    {% if datosAdmon is defined and datosAdmon.social is defined %}
                    <div class="social text-center">
                            {% for red in datosAdmon.social %}
                                <a style="margin-right: 15px;" class="social {{red.name}}" href="{{red.url}}" target="_blank"><i class="fa {{red.icon}}"></i></a>
                            {% endfor %}
                    </div>
                    {% endif %}
                </div>
            </div>
        </div>
    </section>
</div>

{% if web_seo_onpage['txt_down'] is not empty %}
    <div class="text-center text-justify">
        <div>{{web_seo_onpage['txt_down']}}</div>
    </div>
{% endif %}
{% if recaptcha_version == 'v3' %}
    <script id="recaptcha-script" src="https://www.google.com/recaptcha/api.js?render={{datosAdmon.google.google_recaptcha_v3_web_key}}" async defer></script>
{% else %}
    <script id="recaptcha-script" src="https://www.google.com/recaptcha/api.js?render=explicit" async defer></script>
{% endif %}
<script>
    var captcha = false;

    function recaptchaCallback() {
        captcha = true;
        checkForm();
    };

    function checkForm() {
        if ($('#inputNombre').val() !== "" && $('#inputEmail').val() !== "" && $('#mensaje').val() !== "" &&
            $('#envio_datos').is(':checked') && $('#envio_datos_2').is(':checked') && captcha === true) {
            $('#form-submit').prop('disabled', false);
        } else {
            $('#form-submit').prop('disabled', true);
        }
    }

    document.addEventListener("DOMContentLoaded", function(event) {
        $('#inputNombre, #inputEmail, #mensaje').keyup(function() {
            checkForm();
        });
        $("#envio_datos, #envio_datos_2").click(function() {
            checkForm();
        });
    })
</script>
