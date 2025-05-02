<div class="modal fade" id="loginModalRoof2" tabindex="-1" role="dialog" aria-labelledby="loginModalRoof2" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 style="color:black;" class="modal-title" id="exampleModalLongTitle">Acceso Usuarios</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <ul class="nav nav-tabs">
                    <li id="tab-login-carrito" style="border-radius: 21px 21px 0px 0px;" class="tabs-login-register w-50 d-flex justify-content-center active bg-azul"><a class="text_color_ws" style="font-size: 15px;" data-toggle="tab" href="#modalLoginCarrito">Iniciar Sesión</a></li>
                    <li id="tab-register-carrito" style="border-radius: 21px 21px 0px 0px;" class="tabs-login-register w-50 d-flex justify-content-center bg-azul"><a class="text_color_ws" style="font-size: 15px;" data-toggle="tab" href="#modalRegisterCarrito">Registro</a></li>
                </ul>

                <div class="tab-content mt-3">
                    <div id="modalLoginCarrito" class="tab-pane fade in active show">
                        <form id="frm-login" action="{{ config.baseconfig.url_panel }}/extranet/login" enctype="multipart/form-data" method="post">
                            <div class="form-group">
                                <label class="control-label">Email</label>
                                <input id="email_carrito_login" class="form-control" type="text" name="email" value="" required>
                            </div>
                            <div class="form-group">
                                <label class="control-label">Contraseña</label>
                                <input id="pass_carrito_login" class="form-control" type="password" name="pass" value="" required>
                                <div class="row">
                                    <div class="col">
                                        <a style="font-size: 14px; float: right" class="text-alternative" href="{{ config.baseconfig.url_panel }}/forgot">Recuperar Contraseña</a>
                                    </div>
                                </div>
                            </div>
                            <div class="row d-flex justify-content-center" id="captcha_carrito_login">
                                <div style="margin-top: 10px;" class="g-recaptcha" data-error-callback="recaptchaErrorCallbackCarrito" data-callback="recaptchaCallbackCarritoLogin" data-sitekey="{{ datosAdmon.google.recaptcha_web_key}}"></div>
                            </div>
                            <div class="text-center">
                                <span id="spinner_procesando" class="carrito_span_procesando">
                                    <div class="loader carrito_div_procesando"></div>
                                </span><br>
                                <button type="submit" id="btn-carrito-login" disabled class="btn bg-azul"><span class="text_color_ws">Enviar</span></button>
                            </div>
                        </form>
                    </div>
                    <div id="modalRegisterCarrito" class="tab-pane fade">
                        <form autocomplete="false" id="frm-register" action="{{ config.baseconfig.url_panel }}/extranet/register" enctype="multipart/form-data" method="post">
                            <div class="form-group">
                                <label class="control-label">Email</label>
                                <input class="form-control" id="email_carrito_register" type="text" name="email" value="" required>
                            </div>
                            <div class="form-group">
                                <label class="control-label">Contraseña</label>
                                <input class="form-control" id="pass_carrito_register" type="password" name="pass" value="" required>
                            </div>
                            <div class="form-group">
                                <label class="control-label">Repetir Contraseña</label>
                                <input class="form-control" id="pass2_carrito_register" type="password" name="pass_confirm" value="" required>
                            </div>
                            {% if extraData is defined and extraData %}
                                <div class="form-group">
                                    <label class="control-label" for="user_cif">NIF/NIE/CIF</label>
                                    <input class="form-control" name="cif" required>
                                </div>
                                <div class="form-group">
                                    <label for="user_phone" class="control-label">Teléfono</label>
                                    <input class="form-control input-phone text-monospace" name="phone" required>
                                </div>
                            {% endif %}

                            <div class="form-check customCheckBox">
                                <div class="row">
                                    <div class="col-3 d-flex justify-content-end">
                                        <input type="checkbox" class="form-check-input" name="registro_checkEdad" id="registro_carrito_checkEdad" required>
                                    </div>
                                    <div class="col-9 d-flex justify-content-start">
                                        <label class="form-check-label" for="registro_checkEdad">Soy Mayor de Edad (18 años)</label>
                                    </div>
                                </div>
                            </div>
                            <div class="form-check my-3 customCheckBox">
                                <div class="row">
                                    <div class="col-3 d-flex justify-content-end">
                                        <input type="checkbox" class="form-check-input" name="registro_checkTerms" id="registro_carrito_checkTerms" required>
                                    </div>
                                    <div class="col-9 d-flex justify-content-start">
                                        <label class="form-check-label" for="registro_checkTerms"><a href="{{ url('aviso-legal') }}" target="_blank">Aceptar términos de uso y política de datos</a></label>
                                    </div>
                                </div>
                            </div>
                            <div class="form-check customCheckBox">
                                <div class="row">
                                    <div class="col-3 d-flex justify-content-end">
                                        <input type="checkbox" class="form-check-input" name="registro_checkConditions" id="registro_carrito_checkConditions" required>
                                    </div>
                                    <div class="col-9 d-flex justify-content-start">
                                        <label class="form-check-label" for="registro_checkConditions"><a href="{{ url('condiciones-generales') }}" target="_blank">Aceptar condiciones de contratación o compra</a></label>
                                    </div>
                                </div>
                            </div>
                            <div class="row d-flex justify-content-center" id="captcha_carrito_register">
                                <div style="margin-top: 10px;" class="g-recaptcha" data-error-callback="recaptchaErrorCallbackCarrito" data-callback="recaptchaCallbackCarritoRegister" data-sitekey="{{ datosAdmon.google.recaptcha_web_key}}"></div>
                            </div>
                            <div class="text-center">
                                <span id="spinner_procesando2" class="carrito_span_procesando">
                                    <div class="loader carrito_div_procesando"></div>
                                </span><br>
                                <button type="submit" id="btn-carrito-register" disabled class="btn bg-azul"><span class="text_color_ws">Enviar</span></button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    var captchaCarritoLogin = false;
    var captchaCarritoRegister = false;
    var errorCaptchaCarritoLogin = false;
    var errorCaptchaCarritoRegister = false;
    document.addEventListener("DOMContentLoaded", function(event) {
        $('#frm-login').on('submit', function(e) {
            e.preventDefault();

            $("#spinner_procesando").css('display', 'inline-flex');

            let action = $(this).attr('action');
            let params = {
                'uuid': '{{ config.baseconfig.uuid }}',
                'email': $(this).find('[name="email"]').val(),
                'pass': $(this).find('[name="pass"]').val()
            };

            $.ajax({
                type: 'POST',
                crossDomain: true,
                dataType: 'json',
                headers: {
                    'Accept': 'application/json; charset=utf-8',
                    'Origin': window.location.origin

                },
                xhrFields: {
                    withCredentials: true
                },
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify(params),
                url: action,
                success: function(userdata) {
                    if (userdata.error) {
                        customAlert("Error, usuario o contraseña incorrecto");
                        console.error(userdata.error);
                        console.error(userdata);
                        $("#spinner_procesando").css('display', 'none');
                    } else {
                        $.ajax({
                            type: "POST",
                            url: "setSessionUser",
                            data: userdata,

                            success: function(resData) {
                                location.reload();
                                $("#spinner_procesando").css('display', 'none');
                            },
                            error: function(e) {
                                customAlert("Error");
                                $("#spinner_procesando").css('display', 'none');
                            }
                        });
                    }
                }
            });
        });

        $('#frm-register').on('submit', function(e) {
            e.preventDefault();

            $("#spinner_procesando2").css('display', 'inline-flex');

            let action = $(this).attr('action');
            let params = {
                'uuid': '{{ config.baseconfig.uuid }}',
                'email': $(this).find('[name="email"]').val(),
                'pass': $(this).find('[name="pass"]').val(),
                'pass_confirm': $(this).find('[name="pass_confirm"]').val()
            };

            if ($(this).find('[name="cif"]').length) {
                params.cif = $(this).find('[name="cif"]').val()
            }

            if ($(this).find('[name="phone"]').length) {
                let isMovil = new RegExp(/^(\+?[0-9]{1,4})?[6-7][0-9]{8}$/)
                let isFijo = new RegExp(/^(\+?[0-9]{1,4})?[8-9][0-9]{8}$/)
                let phone = $(this).find('[name="phone"]').val()
                if (isMovil.test(phone)) {
                    params.mobile = phone
                } else {
                    params.phone = phone
                }
            }

            $.ajax({
                type: 'POST',
                crossDomain: true,
                dataType: 'json',
                headers: {
                    'Accept': 'application/json; charset=utf-8',
                    'Origin': window.location.origin
                },
                xhrFields: {
                    withCredentials: true
                },
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify(params),
                url: action,
                success: function(userdata) {
                    if (userdata.error) {
                        customAlert(userdata.error);
                        $("#spinner_procesando2").css('display', 'none');
                    } else {

                        $.ajax({
                            type: "POST",
                            url: "setSessionUser",
                            data: userdata,

                            success: function(resData) {
                                location.reload();
                                $("#spinner_procesando2").css('display', 'none');
                            },
                            error: function(e) {
                                customAlert("Error");
                                $("#spinner_procesando2").css('display', 'none');
                            }
                        });
                    }
                }
            });
        });

        $('.tabs-login-register').ready(function() {
            if ($('.tabs-login-register').first().hasClass('active')) {
                $('.tabs-login-register').last().removeClass('bg-azul').addClass('bg-alternative-border').css("border", "1px solid").children().addClass('text-alternative').removeClass('text_color_ws');
            }
        });

        $('.tabs-login-register').click(function(event) {
            var nodeName = event.target.nodeName;
            var elementId = '';
            if (nodeName == 'LI') {
                elementId = event.target.id;
            } else if (nodeName == 'A') {
                elementId = event.target.parentElement.id;
            }
            if (!$('#' + elementId).first().hasClass('active')) {
                $('#' + elementId).first().addClass('bg-azul').removeClass('bg-alternative-border active').css("border", "0px").children().addClass('text_color_ws_modals').removeClass('text-alternative');
                if (nodeName == 'LI') {
                    $('#' + elementId).first().children().click();
                }
                $('#' + elementId).siblings().removeClass('bg-azul active').addClass('bg-alternative-border').css("border", "1px solid").children().addClass('text-alternative').removeClass('text_color_ws_modals');
            }
        });

        $('#pass_carrito_login, #email_carrito_login').keyup(function() {
            checkFormCarritoLogin();
        });

        $('#pass_carrito_register, #pass2_carrito_register ,#email_carrito_register').keyup(function() {
            checkFormCarritoRegister();
        });

        $("#registro_carrito_checkEdad, #registro_carrito_checkTerms, #registro_carrito_checkConditions").click(function() {
            checkFormCarritoRegister();
        });
    })


    function recaptchaErrorCallbackCarrito() {
        errorCaptchaCarritoLogin = true;
        $('#captcha_carrito_login').remove();

        errorCaptchaCarritoRegister = true;
        $('#captcha_carrito_register').remove();

        checkFormCarritoLogin();
        checkFormCarritoRegister();
    }




    function recaptchaCallbackCarritoLogin() {
        captchaCarritoLogin = true;
        checkFormCarritoLogin();
    }

    function checkFormCarritoLogin() {
        if (errorCaptchaCarritoLogin === true) {
            /* En el caso de que el captcha de error lo validaremos como si fuese correcto*/
            captchaCarritoLogin = true;
        }

        if ($('#pass_carrito_login').val() !== "" && $('#email_carrito_login').val() !== "" && captchaCarritoLogin === true) {
            $('#btn-carrito-login').prop('disabled', false);
        } else {
            $('#btn-carrito-login').prop('disabled', true);
        }
    }


    function recaptchaCallbackCarritoRegister() {
        captchaCarritoRegister = true;
        checkFormCarritoRegister();
    };

    function checkFormCarritoRegister() {
        if (errorCaptchaCarritoRegister === true) {
            captchaCarritoRegister = true;
        }

        if ($('#pass_carrito_register').val() !== "" && $('#pass2_carrito_register').val() !== "" && $('#email_carrito_register').val() !== "" &&
            captchaCarritoRegister === true && $('#registro_carrito_checkEdad').is(':checked') && $('#registro_carrito_checkTerms').is(':checked') &&
            $('#registro_carrito_checkConditions').is(':checked')) {
            $('#btn-carrito-register').prop('disabled', false);
        } else {
            $('#btn-carrito-register').prop('disabled', true);
        }
    }
</script>