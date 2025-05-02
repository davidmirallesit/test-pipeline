<div class="modal fade" id="{{target}}" tabindex="-1" role="dialog" aria-labelledby="{{target}}" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 style="color:black;" class="modal-title" id="{{target}}-exampleModalLongTitle">Acceso Usuarios</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <ul class="nav nav-tabs">
                    <li id="{{target}}-tab-login-carrito" style="border-radius: 21px 21px 0px 0px;" class="tabs-login-register w-50 d-flex justify-content-center active bg-azul"><a class="text_color_ws" style="font-size: 15px;" data-toggle="tab" href="#{{target}}-modalLoginCarrito">Iniciar Sesión</a></li>
                    <li id="{{target}}-tab-register-carrito" style="border-radius: 21px 21px 0px 0px;" class="tabs-login-register w-50 d-flex justify-content-center bg-azul"><a class="text_color_ws" style="font-size: 15px;" data-toggle="tab" href="#{{target}}-modalRegisterCarrito">Registro</a></li>
                </ul>

                <div class="tab-content mt-3">
                    <div id="{{target}}-modalLoginCarrito" class="tab-pane fade in active show">
                        <form id="{{target}}-frm-login" class="{{target}}-recaptcha-form" action="{{config.baseconfig.url_panel}}/extranet/login" enctype="multipart/form-data" method="post">
                            <input type="hidden" name="uuid" value="{{config.baseconfig.uuid}}">
                            <input type="hidden" name="referer" value="{{_SERVER['REQUEST_URI']}}">
                            <div class="form-group">
                                <label class="control-label">Email</label>
                                <input id="{{target}}-email_carrito_login" class="form-control" type="text" name="email" value="" required>
                            </div>
                            <div class="form-group">
                                <label class="control-label">Contraseña</label>
                                <input id="{{target}}-pass_carrito_login" class="form-control" type="password" name="pass" value="" required>
                                <div class="row">
                                    <div class="col">
                                        <a style="font-size: 14px; float: right" class="text-alternative" href="{{config.baseconfig.url_panel}}/forgot">Recuperar Contraseña</a>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div id="{{target}}-modalRegisterCarrito" class="tab-pane fade">
                        <form autocomplete="false" class="{{target}}-recaptcha-form" id="{{target}}-frm-register" action="{{config.baseconfig.url_panel}}/extranet/register" enctype="multipart/form-data" method="post">
                            <div class="form-group">
                                <label class="control-label">Email</label>
                                <input class="form-control" id="{{target}}-email_carrito_register" type="text" name="email" value="" required>
                            </div>
                            <div class="form-group">
                                <label class="control-label">Contraseña</label>
                                <input class="form-control" id="{{target}}-pass_carrito_register" type="password" name="pass" value="" required>
                            </div>
                            <div class="form-group">
                                <label class="control-label">Repetir Contraseña</label>
                                <input class="form-control" id="{{target}}-pass2_carrito_register" type="password" name="pass_confirm" value="" required>
                            </div>
                            <!-- <div class="form-group">
                                    <label class="control-label" for="user_cif">NIF/NIE/CIF</label>
                                    <input class="form-control" name="cif" required>
                                </div>
                                <div class="form-group">
                                    <label for="user_phone" class="control-label">Teléfono</label>
                                    <input class="form-control input-phone text-monospace" name="phone">
                                </div> -->

                            <div class="form-check customCheckBox">
                                <div class="row">
                                    <div class="col-3 d-flex justify-content-end">
                                        <input type="checkbox" class="form-check-input" name="registro_checkEdad" id="{{target}}-registro_carrito_checkEdad" required>
                                    </div>
                                    <div class="col-9 d-flex justify-content-start">
                                        <label class="form-check-label" for="registro_checkEdad">Soy Mayor de Edad (18 años)</label>
                                    </div>
                                </div>
                            </div>
                            <div class="form-check my-3 customCheckBox">
                                <div class="row">
                                    <div class="col-3 d-flex justify-content-end">
                                        <input type="checkbox" class="form-check-input" name="registro_checkTerms" id="{{target}}-registro_carrito_checkTerms" required>
                                    </div>
                                    <div class="col-9 d-flex justify-content-start">
                                        <label class="form-check-label" for="registro_checkTerms"><a href="{{url('aviso-legal')}}" target="_blank">Aceptar términos de uso y política de datos</a></label>
                                    </div>
                                </div>
                            </div>
                            <div class="form-check customCheckBox">
                                <div class="row">
                                    <div class="col-3 d-flex justify-content-end">
                                        <input type="checkbox" class="form-check-input" name="registro_checkConditions" id="{{target}}-registro_carrito_checkConditions" required>
                                    </div>
                                    <div class="col-9 d-flex justify-content-start">
                                        <label class="form-check-label" for="registro_checkConditions"><a href="{{url('condiciones-generales')}}" target="_blank">Aceptar condiciones de contratación o compra</a></label>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="text-center">
                        <div class="{{target}}-recaptcha_container g-recaptcha my-3 d-flex justify-content-center"></div>
                        <span id="{{target}}-spinner_procesando" class="carrito_span_procesando">
                            <div class="loader carrito_div_procesando"></div>
                        </span>
                        <br>
                        <button type="button" id="{{target}}-button-login" class="btn bg-azul">
                            <span class="text_color_ws">Enviar</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
{% include 'layouts/boxs/box_recaptcha_' ~ recaptcha_version with ['target': target] %}
<script>
    window.addEventListener("DOMContentLoaded", () => {
        $('#{{target}}-button-login').on("click", event => {
            let login = $(event.target).parents(".modal-body").find('#{{target}}-modalLoginCarrito')
            let register = $(event.target).parents(".modal-body").find('#{{target}}-modalRegisterCarrito')
            if (login.hasClass("show")) {
                recaptcha_check(login.find("form"))
                return
            }

            if (register.hasClass("show")) {
                recaptcha_check(register.find("form"))
                return
            }
        })

        $('#{{target}}-frm-login').on('submit', function(e) {
            e.preventDefault();
            
            if (!recaptcha_is_verified) {
                return
            }
            
            let recaptchaResponse = $('#{{target}}-frm-login').find('[name="g-recaptcha-response"]').val()

            let action = $(this).attr('action');
            let params = {
                'uuid': '{{config.baseconfig.uuid}}',
                'email': $(this).find('[name="email"]').val(),
                'pass': $(this).find('[name="pass"]').val(),
                "g-recaptcha-response": recaptchaResponse
            };

            if (params.pass === '') {
                customAlert("Rellene la contraseña")
                return
            }

            if (params.email === '') {
                customAlert("Rellene el email")
                return
            }

            $("#{{target}}-spinner_procesando").css('display', 'inline-flex');

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
                        "{% if recaptcha_version == 'v2' %}"
                        grecaptcha.reset()
                        "{% endif %}"
                        recaptcha_is_verified = false
                        customAlert(userdata.error);
                        $("#{{target}}-spinner_procesando").css('display', 'none');
                    } else {
                        $.ajax({
                            type: "POST",
                            url: "setSessionUser",
                            data: userdata,

                            success: function(resData) {
                                location.reload();
                                $("#{{target}}-spinner_procesando").css('display', 'none');
                            },
                            error: function(e) {
                                customAlert("Error");
                                $("#{{target}}-spinner_procesando").css('display', 'none');
                            }
                        });
                    }
                },
                error: function(e) {
                    console.log(e)
                }
            });
        });

        $('#{{target}}-frm-register').on('submit', function(e) {
            e.preventDefault();
            if (!recaptcha_is_verified) {
                return
            }
            let recaptchaResponse = $('#{{target}}-frm-register').find('[name="g-recaptcha-response"]').val()

            let action = $(this).attr('action');
            let params = {
                'uuid': '{{config.baseconfig.uuid}}',
                'email': $(this).find('[name="email"]').val(),
                'pass': $(this).find('[name="pass"]').val(),
                'pass_confirm': $(this).find('[name="pass_confirm"]').val(),
                "g-recaptcha-response": recaptchaResponse
                // 'cif': $(this).find('[name="cif"]').val(),
                // 'phone': $(this).find('[name="phone"]').val(),
            };

            if (params.pass === '') {
                customAlert("Rellene la contraseña")
                return
            }

            if (params.pass_confirm === '') {
                customAlert("Repita la contraseña")
                return
            }

            if (params.email === '') {
                customAlert("Rellene el email")
                return
            }

            $("#{{target}}-spinner_procesando").css('display', 'inline-flex');

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
                        $("#{{target}}-spinner_procesando").css('display', 'none');
                    } else {
                        $.ajax({
                            type: "POST",
                            url: "setSessionUser",
                            data: userdata,
                            success: function(resData) {
                                location.reload();
                                $("#{{target}}-spinner_procesando").css('display', 'none');
                            },
                            error: function(e) {
                                "{% if recaptcha_version == 'v2' %}"
                                grecaptcha.reset()
                                "{% endif %}"
                                recaptcha_is_verified = false
                                customAlert("Error");
                                $("#{{target}}-spinner_procesando").css('display', 'none');
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

//esto solo comprueba que no esté vacio el campo
        // $('#pass_carrito_login, #email_carrito_login').keyup(function() {
        //     checkFormCarritoLogin();
        // });

        // $('#pass_carrito_register, #pass2_carrito_register ,#email_carrito_register').keyup(function() {
        //     checkFormCarritoRegister();
        // });
        // $("#registro_carrito_checkEdad, #registro_carrito_checkTerms, #registro_carrito_checkConditions").click(function() {
        //     checkFormCarritoRegister();
        // });
    });
</script>