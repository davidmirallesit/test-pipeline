{% set indexHeader = 1 %}
<div class="col-12 text-center">
    <h1 class="text-center">{{ web_seo_onpage['h1'] }}</h1>
</div>

{% if web_seo_onpage['txt_up'] is not empty %}
    <div class="col-12 text-center text-justify">
        <div>{{ web_seo_onpage['txt_up'] }}</div>
    </div>
{% endif %}

<div class="col-md-12 perfil_venta">

    {% if sizeof(cart) == 0 %}
        <div class="alert alert-danger" role="alert">No hay productos en el carrito</div>
    </div>
    {% if web_seo_onpage['txt_down'] is not empty %}
        <div class="col-12 text-center text-justify">
            <div>{{ web_seo_onpage['txt_down'] }}</div>
        </div>
    {% endif %}
    </div>
    </section>
    <?php return ?>
    {% endif %}
    <div class="row">
        {% if id_user is not defined %}
            <div class="col-12" id="step0" data-step="0">
                <div class="row mt-3">
                    <div class="col-12">
                        <h4 class="mb-0">{{ indexHeader }}. Identificarse</h4>
                        {% set indexHeader = (indexHeader + 1) %}
                    </div>
                </div>
        
                <hr class="mb-2">
        
                <div class="d-block p-3 carrito_section my-3 text-center">
                    <span class="h6">Para continuar con el proceso de compra inicie sesión o registre una nueva cuenta</span>
                    <div class="mt-3 mb-3 d-flex justify-content-center align-items-center">
                        <a class="btn btn-primary btn-login button_login mr-3" data-toggle="modal" data-target="#loginModalRoof2">Acceso Usuarios</a>
                        {% include 'partial/modals/register_cart' with ["extraData": true] %}
                    </div>
                </div>
            </div>
        {% endif %}

        <div class="col-12 {% if id_user is not defined %}d-none{% endif %}" id="step1" data-step="1">
            <div class="row mt-3">
                <div class="col-12">
                    <h4 class="mb-0">
                        {{ indexHeader }}. Formas de Envío
                        {% set indexHeader = (indexHeader + 1) %}
                    </h4>
                </div>
            </div>
        
            <hr class="mb-2">

            {# suponemos de momento juego loteria_nacional, habrá que hacer filtro con id game, cuando se reciba en el carrito #}
            {# siguiente versión debería ser, para todos los id_game encontrados en carrito, poner la sección correspondiente para selección de método de envío #}

            <div class="d-block p-3 carrito_section my-3">
                <div class="row">
                    {#
                    <div class="col-12 col-md-5 carrito_header_text">
                        <img src="{{ game_info['logo'] }}" height="39" width="39">
                        <span class="ml-2">{{ game_info['name'] }}</span>
                    </div>
                    #}
                    <div class="col-12 col-md-7 pt-2">
                        {% set autoSelectedGames = [] %}
                        {% set firstShipping = true %}
                        {% for shipping_method in shipping_methods %}
                            {# si el juego no es enviable mostrar metodos no enviables, si el juego es enviable se muestran todos #}
                            <div class="custom-control custom-radio mb-3">
                                {% set porcentaje = "" %}
                                {% if shipping_method.perc_incr != "0" %}
                                    {% set porcentaje = shipping_method.perc_incr %}
                                {% endif %}
                                <input
                                    data-porcentaje="{{ porcentaje }}"
                                    data-price="{{ shipping_method.price_in }}"
                                    data-price_out="{{ shipping_method.price_out }}"
                                    {% if shipping_method.is_shippable == 1 %}
                                        data-shippable="1"
                                        {% if hoursToFirstShippable < shipping_method.hours_needed %}
                                            disabled="disabled"
                                        {% else %}
                                            {% if firstShipping %}
                                                checked="checked"
                                                {% set selectedShipping = shipping_method %}
                                            {% endif %}
                                            {% set firstShipping = false %}
                                            {% set autoSelectedGames[autoSelectedGames | length] = game_info['id'] %}
                                        {% endif %}
                                    {% else %}
                                        data-shippable="0"
                                        {% if hoursToFirstNotShippable < shipping_method.hours_needed %}
                                            disabled="disabled"
                                        {% else %}
                                            {% if firstShipping %}
                                                checked="checked"
                                                {% set selectedShipping = shipping_method %}
                                            {% endif %}
                                            {% set firstShipping = false %}
                                            {% set autoSelectedGames[autoSelectedGames | length] = game_info['id'] %}
                                        {% endif %}
                                    {% endif %}
                                    data-addressRequired="{{ is_null(shipping_method.is_address_required) ? 1 : shipping_method.is_address_required }}"
                                    value="{{ shipping_method.id }}"
                                    id="shipMethod_{{ shipping_method.id }}_game_{{ game_info['id'] }}"
                                    name="shipMethod_{{ game_info['id'] }}"
                                    onchange="checkChangedEnvio({{ game_info['id'] }})"
                                    type="radio"
                                    class="custom-control-input shipping_radio 
                                    {% if shipping_method.is_shippable == 1 %}
                                        radio-shippable radio-shippable_{{ shipping_method.id }}
                                    {% else %}
                                        radio-not-shippable radio-not-shippable_{{ shipping_method.id }}
                                    {% endif %}"
                                    required="">
                                <label class="custom-control-label label-shipMethod_{{ shipping_method.id }}" for="shipMethod_{{ shipping_method.id }}_game_{{ game_info['id'] }}">
                                    <b>{{ shipping_method.name }}</b>: {{ shipping_method.price_in }} €
                                    {% if porcentaje != "" %}
                                        + {{ porcentaje }} % del envío sobre el importe
                                    {% endif %}
                                    {% if shipping_method.price_in != shipping_method.price_out %}
                                        ({{shipping_method.price_out}} €{% if porcentaje != "" %} + {{ porcentaje }} %{% endif %} fuera de la Península)
                                    {% endif %}
                                </label>
                            </div>
                        {% endfor %}
                    </div>
                </div>
            </div>
        </div>

        <div class="col-12 d-none" id="step2" data-step="2" {% if !selectedShipping.is_shippable or id_user is not defined %}data-skip="true"{% endif %}>
            <div id="shipment_data_container">
                <div class="row mt-3">
                    <div class="col-12">
                        <h4 class="mb-0">{{ indexHeader }}. Datos de envío</h4>
                        {% if selectedShipping.is_shippable and id_user is defined %}
                            {% set indexHeader = indexHeader + 1 %}
                        {% endif %}
                    </div>
                </div>
                <hr class="mb-2">
                <div class="p-4 carrito_section mb-3">
                    <div class="row" id="address_content_container">
                        <div class="col-12" id="addressContent" data-id="-1">
                        </div>
                        <div class="col-12 col-md-6 d-flex mt-3 align-items-center justify-content-center">
                            <button style="max-width:300px" id="addressModalButton" class="btn btn-azul btn-block" data-toggle="modal" data-target="#addressModal" style="border-radius: 34px;" type="button">
                                Seleccionar otra
                            </button>
                        </div>
                        <div class="col-12 col-md-6 d-flex mt-3 align-items-center justify-content-center">
                            <button style="max-width:300px" id="newAddressButton" class="btn btn-azul btn-block" style="border-radius: 34px;" type="button">
                                Añadir Dirección
                            </button>
                        </div>
                        <div class="modal fade" id="addressModal" tabindex="-1" role="dialog" aria-labelledby="addressModalTitle" aria-hidden="true">
                            <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title" id="exampleModalLongTitle">Seleccionar dirección</h5>
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">&times;</span>
                                        </button>
                                    </div>
                                    <div class="modal-body" id="user_addresses_modal_body">
        
                                    </div>
                                    <div class="modal-footer justify-content-end">
                                        <button type="button" class="btn btn-primary" data-dismiss="modal">Guardar</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row d-none" id="new_address_container">
                        <div class="col-12">
                            <form class="needs-validation" id="form_new_address" novalidate>
                                <div class="row">
                                    <div class="col-12 mb-3">
                                        <label for="address_name_contact">Nombre Destinatario</label>
                                        <input type="text" class="form-control" minlength="5" id="name_contact" placeholder="" value="" required>
                                        <div class="text-muted small">(Ej: Pedro García Gómez)</div>
                                        <div class="invalid-feedback">
                                            El nombre es obligatorio.
                                        </div>
                                    </div>
                                    <div class="row mx-0 w-100">
                                        <div class="col-12 col-md-6">
                                            <div class="form-group">
                                                <label for="address_id_country">País</label>
                                                <div class="input-group">
                                                    <select class="form-control" name="address_id_country" id="address_id_country" required onchange="changedNewAddressCountry(this)">
                                                        <option value></option>
                                                        {% for country in locationInfo["countries"] %}
                                                            <option value="{{ country['id'] }}">{{ country['name'] }}</option>
                                                        {% endfor %}
                                                    </select>
                                                    <div class="invalid-feedback">El país es obligatorio</div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-12 col-md-6">
                                            <div class="form-group">
                                                <label for="address_id_province">Provincia</label>
                                                <div class="input-group">
                                                    <select class="form-control" name="address_id_province" id="address_id_province" required onchange="changedNewAddressProvince(this)">
                                                        <option value></option>
                                                    </select>
                                                    <div class="invalid-feedback">La provincia es obligatoria</div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-12 col-md-6">
                                            <div class="form-group">
                                                <label for="address_id_city">Población</label>
                                                <div class="input-group">
                                                    <select class="form-control" name="address_id_city" required id="address_id_city">
                                                        <option value></option>
                                                    </select>
                                                    <div class="invalid-feedback">La población es obligatoria</div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-12 col-md-6">
                                            <div class="form-group">
                                                <label for="address_cp" class="control-label">Código Postal</label>
                                                <input class="form-control input-cp text-monospace" type="text" name="address_cp" id="address_cp" value="" size="5" minlength="5" maxlength="5" required>
                                                <div class="invalid-feedback">
                                                    Código postal incorrecto.
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-12">
                                            <div class="form-group">
                                                <label for="address_address">Dirección</label>
                                                <input type="text" class="form-control" id="address_address" size="60" minlength="5" maxlength="60" placeholder="" value="" required>
                                                <div class="invalid-feedback">
                                                    La dirección es obligatoria.
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row mx-0 w-100">
                                        <div class="col-12 col-md-6">
                                            <div class="form-group">
                                                <label for="address_phone" class="control-label">Teléfono</label>
                                                <input class="form-control input-phone text-monospace" type="tel" name="address_phone" id="address_phone" value="" size="9" minlength="9" maxlength="922" list="phones" data-formatted="true">
                                            </div>
                                        </div>
                                        <div class="col-12 col-md-6">
                                            <div class="form-group">
                                                <label for="address_phone2" class="control-label">Teléfono 2</label>
                                                <input class="form-control input-phone text-monospace" type="tel" name="address_phone2" id="address_phone2" value="" size="9" minlength="9" maxlength="922" list="phones" data-formatted="true">
                                            </div>
                                        </div>
                                        <div class="col-12 col-md-6">
                                            <div class="form-group">
                                                <label for="address_mobile" class="control-label">Móvil</label>
                                                <input class="form-control input-mobile text-monospace" type="tel" name="address_mobile" id="address_mobile" value="" size="9" minlength="9" maxlength="922" list="mobiles" data-formatted="true">
                                            </div>
                                        </div>
                                        <div class="col-12 col-md-6">
                                            <div class="form-group">
                                                <label for="address_mobile2" class="control-label">Móvil 2</label>
                                                <input class="form-control input-mobile text-monospace" type="tel" name="address_mobile2" id="address_mobile2" value="" size="9" minlength="9" maxlength="922" list="mobiles" data-formatted="true">
                                            </div>
                                        </div>
                                        <!--
                                                    <div class="col-12 col-md-6">
                                                        <div class="form-group">
                                                            <label for="address_email" class="control-label">Email</label>
                                                            <input class="form-control text-left" type="text" name="address_email" id="address_email" value="" size="60" maxlength="100">
                                                        </div>
                                                    </div>
                                                    -->
                                    </div>
                                </div>
                                <div class="row d-flex">
                                    <div class="col-12 col-md-6 d-flex mt-3 align-items-center justify-content-center">
                                        <button style="max-width:300px" id="cancelNewAddressButton" class="btn btn-azul btn-block" style="border-radius: 34px;" type="button">
                                            <i class="fa-arrow-left fa"></i>&nbsp;&nbsp;Direcciones Guardadas
                                        </button>
                                    </div>
                                    <div class="col-12 col-md-6 d-flex mt-3 align-items-center justify-content-center">
                                        <button style="max-width:300px" class="btn btn-azul btn-block" style="border-radius: 34px;" type="submit">
                                            <i class="fa-save fa"></i>&nbsp;&nbsp;Guardar Dirección
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-12 d-none" id="step3" data-step="3" {% if user is defined %}{% if ((user["phone"] or user["phone_2"] or user["mobile"] or user["mobile_2"]) and user["cif"]) %}data-skip="true"{% endif %}{% else %}data-skip="true"{% endif %}>
            <div class="row mt-3">
                <div class="col-12">
                    <h4 class="mb-0" id="moreData_Title">{{ indexHeader }}. Datos Requeridos</h4>
                    {% if user is defined %}
                        {% if !((user["phone"] or user["phone_2"] or user["mobile"] or user["mobile_2"]) and user["cif"]) %}
                            {% set indexHeader = (indexHeader + 1) %}
                        {% endif %}
                    {% endif %}
                </div>
            </div>

            <hr class="mb-2">
            <div class="d-block p-3 carrito_section my-3">
                <p class="text-danger bold">Su cuenta de usuario aún no tiene algunos datos necesarios:</p>
                <form class="needs-validation" id="form_data_needed" novalidate>
                    <div class="row">
                        {% if user["cif"] is empty %}
                            <div class="col-12 mb-3">
                                <label for="user_cif">NIF/NIE/CIF</label>
                                <input type="text" class="form-control" minlength="8" id="user_cif" placeholder="" value="" required>
                            </div>
                        {% endif %}
                        {% if user["phone"] is empty and user["phone_2"] is empty and user["mobile"] is empty and user["mobile_2"] is empty %}
                            <!-- si no tiene ningun telefono se le pide uno -->
                            <div class="col-12">
                                <div class="form-group">
                                    <label for="user_phone" class="control-label">Teléfono</label>
                                    <input class="form-control input-phone text-monospace" type="tel" name="user_phone" id="user_phone" value="" size="9" minlength="9" maxlength="922" data-formatted="true">
                                </div>
                            </div>
                        {% endif %}
                        <div class="col-12 mt-4 text-muted small">Estos datos se guardarán para futuras compras</div>
                    </div>
                </form>
            </div>
        </div>

        <div class="col-12 d-none" id="step4" data-step="4">
            <div class="row mt-3 d-flex align-items-center">
                <div class="col-12 col-md-6">
                    <h4 class="mb-0" id="summary_title"> {{ indexHeader }}. Resumen de pedido</h4>
                    {% set indexHeader = (indexHeader + 1) %}
                </div>
            </div>
        
            <hr class="mt-2 mb-3">
        
            {# CARRITO PARA LOTERÍA NACIONAL #}
            {% for index, numeros in cart %}
                {# <!-- NO SE PUEDE MODIFICAR EL ARRAY CON LOS PRODUCTOS EN EL PARTIAL POR ESO SALEN REPETIDOS --> #}
                {# <!-- {% include 'partial/carrito/resume_loteria_nacional' with ['cart': cart, 'numeros': numeros, 'sorteos_ln_cargados': sorteos_ln_cargados, 'gameInfo': games_info[idLn], 'index': index] %} --> #}
                <div class="col-12 d-block carrito_section p-3">
                    <div class="row carrito_pedido_header">
                        <div class="col-12 col-lg-4 col-xl-3 carrito_header_info_data">
                            <img src="{{game_info['logo']}}" height="39" width="39">
                            <span class="ml-2">{{game_info['name']}}</span>
                        </div>
                        <div class="col-12 col-sm-12 col-lg-5">
                            <span class="carrito_header_info_title">Sorteo: </span><span class="carrito_line_main">{{numeros['date_draw_ini'] | date_format('d/m/Y')}} - ({{view_sorteo(numeros["id_draw"])}})</span>
                        </div>
                        <div class="d-none col-12 col-md-4">
                            <!-- Entrega estimada: -->
                        </div>
                    </div>
                    <hr class="m-0">
                    <div class="row mt-1 d-sm-none carrito_header_info_data">
                        <div class="col-4 col-sm-5 text-center">Número</div>
                        <div class="col-4">Cantidad</div>
                        <div class="col-3">€</div>
                    </div>
                    {# agrupamiento del mismo sorteo visualmente #}
                    {% for i in index..(cart|length - 1) %}
                        {% if array_key_exists("id_draw", numeros) and array_key_exists("id_draw", cart[i]) and numeros["id_draw"] == cart[i]["id_draw"] %}
                            <div class="row mt-1">
                                <div class="col-4 col-sm-3 carrito_header_info_data text-center">
                                    <span class="d-none d-sm-inline">N: </span>
                                    {{ cart[i]['number'] }}
                                </div>
                                <div class="col-4 col-sm-4 col-sm-3 col-xl-2">
                                    <span class="carrito_header_info_title d-none d-sm-inline">Cantidad: </span>
                                    <span class="carrito_line_main"> {{ intval(cart[i]['quantity']) }}</span>
                                </div>
                                <div class="col-auto col-sm-4 col-lg-4 col-xl-5">
                                    <span class="d-none d-sm-inline d-md-inline carrito_header_info_title">Importe:&nbsp;</span>
                                    <span class="carrito_line_main">{{ intval(cart[i]['quantity']) * intval(cart[i]['price_ticket']) }}€</span>
                                </div>
                                <div class="col-1 col-sm-1 col-lg-1 carrito_delete_container d-flex justify-content-center justify-content-lg-start">
                                    <a href="{{ url('carrito?delete=' ~ i) }}"><i class="fa fa-trash-o text-azul"></i></a>
                                </div>
                            </div>
                        {% endif %}
                    {% endfor %}
                </div>
                <br>
            {% endfor %}
        
            <hr class="mb-4 d-none">
        
            <div class="row mb-3 d-flex align-items-center justify-content-center">
                <span class="carrito_header_info_title">Importe del pedido:&nbsp;</span><span class="carrito_line_main" id="total_subtotal">{{ total | number_float }}</span><span class="carrito_line_main">€</span>
            </div>
            <div class="row mb-3 d-flex align-items-center justify-content-center">
                {# TODO El gasto de envio deberia ser el de que venga seleccionado por defecto no asumir que es deposito que vale 0 #}
                <span class="carrito_header_info_title">Gastos de envío:&nbsp;</span><span class="carrito_line_main" id="total_envio">0.00</span><span class="carrito_line_main">€</span>
            </div>
            <div class="row mb-5 d-flex align-items-center justify-content-center">
                <span class="textImporte custom-block-100W">Total a pagar:&nbsp;</span>
                <span class="d-flex align-items-center">
                    <span class="resumen-pedido-importe-total resumen-pedido-importe-total-value" id="total_total">{{ total | number_float }}</span>
                    <span class="resumen-pedido-importe-total resumen-pedido-importe-total-value">€</span>
                </span>
            </div>
        
            <div class="row my-2 mx-1 d-flex justify-content-center align-items-center text-center customCheckBox">
                <label for="compra_checkTerms" class="my-0 ml-2">
                    <input class="mr-1" type="checkbox" name="compra_checkTerms" id="compra_checkTerms" required onchange="checkCondiciones(this)">
                    Acepto las <a style="color: #007bff !important; padding: 0 !important;" href="{{ url('condiciones-generales') }}" target="_blank">Condiciones Generales de Contratación</a> y he leído la <a style="color: #007bff !important; padding: 0 !important;" href=" {{ url('politica-privacidad') }}" target="_blank">política de privacidad</a>.
                </label>
            </div>
            <div class="row d-flex justify-content-center text-center" id="pendingData">
                <div class="col-12 justify-content-center no_display" id="pendingData_envio">
                    <p class="text-danger bold">Debe seleccionar un método de envío para todos los juegos</p>
                </div>
                <div class="col-12 justify-content-center no_display" id="pendingData_direccion">
                    <p class="text-danger bold">Debe seleccionar o añadir una dirección de envío</p>
                </div>
                <div class="col-12 justify-content-center{% if user is defined %} no_display{% endif %}" id="pendingData_login">
                    <p class="text-danger bold">Debe registrarse o iniciar sesión con su usuario</p>
                </div>
                <div class="col-12 justify-content-center" id="pendingData_Condiciones">
                    <p class="text-danger bold">Debe aceptar las condiciones de contratación y la política de privacidad</p>
                </div>
            </div>
        </div>

        <div class="col-12" style="position: sticky; bottom: 0em; background-color: white;">
            <div class="row">
                <div class="col-6 text-center my-2">
                    <button style="min-width: 6em;" id="prevStepBtn" class="btn btn-primary" disabled="disabled">Anterior</button>
                </div>
                <div class="col-6 text-center my-2">
                    <button style="min-width: 6em;" id="nextStepBtn" class="btn btn-primary">Siguiente</button>
                </div>
                <div class="col-6 text-center my-2 d-none">
                    <button style="min-width: 6em;" class="btn btn-verde-claro mt-0" disabled id="carrito_button_finalizar" onclick="checkFinalizar()" type="button">
                        <span id="text-finalizar_pedido" style="display: inline;">Finalizar Pedido</span>
                        <span id="text-finalizar_pedido_procesando" style="display: none;">Procesando...</span>
                    </button>
                </div>
            </div>
        </div>
    </div>

</div>

{% if web_seo_onpage['txt_down'] is not empty %}
    <div class="col-12 text-center text-justify">
        <div>{{ web_seo_onpage['txt_down'] }}</div>
    </div>
{% endif %}

<style>
    .back-to-top {
        display: none;
    }
</style>

<script>
    var userAddresses             = {{ json_encode(user_addresses) }};
    var user_logged               = {% if session.has('user') %}1{% else %}0{% endif %};
    // var email_verified            = {{session.get('user')["email_verified"]|default(0)}};
    var urlPanel                  = "{{ config.baseconfig.url_panel }}";
    var needUserAddressesReload   = false;
    var peninsula                 = true;
    var autoSelectedGames         = {{ json_encode(autoSelectedGames) }};
    var countries                 = {{ json_encode(locationInfo["countries"]) }};
    var provinces                 = {{ json_encode(locationInfo["provinces"]) }};
    var cities                    = {{ json_encode(locationInfo["cities"]) }};

    var gameIds = [{{ game_info['id'] }}];
    // var shippingMethods = {{ json_encode(shipping_methods) }};
    // var userBalance = {{ false ? user_balance : '0.00' }};
    var subTotal = {{ total }};
    // var hoursToFirstGame = {{ hoursToFirstGame != null ? hoursToFirstGame : 9999 }};

    //REVIEW - cambiar de pagina con un swipe (puedo poner flechas de background y mostrarlas cuando se hace swipe)
    var swipeStart = null;
    window.addEventListener("touchstart", function(event) {
        if ($('.custom-alert-background').length || $('.modal.show').length) {
            return
        }
        if(event.touches.length === 1){
            // just one finger touched
            swipeStart = event.touches.item(0).clientX;
        }else{
            // a second finger hit the screen, abort the touch
            swipeStart = null;
        }
    });

    window.addEventListener("touchend", function(event) {
        if ($('.custom-alert-background').length || $('.modal.show').length) {
            return
        }
        let offset = 100; // at least 100px are a swipe
        if(swipeStart){
            // the only finger that hit the screen left it
            let end = event.changedTouches.item(0).clientX;

            if(end > swipeStart + offset){
                // a left -> right swipe
                console.log('right swipe')
                $('#prevStepBtn').click()
            }
            if(end < swipeStart - offset ){
                // a right -> left swipe
                console.log('left swipe')
                $('#nextStepBtn').click()
            }
        }
    });
    //REVIEW - 

    function prevSwipe(event) {
        if ($('#prevStepBtn').attr("disabled")) {
            return
        }

        let currentStep  = $('[id^="step"]:not([data-skip="true"]):not(.d-none)')
        let previousStep = currentStep.prevAll('[id^="step"]:not([data-skip="true"])').first()
        let firstStep    = $('[id^="step"]:not([data-skip="true"])').first()

        currentStep.addClass('swipe-right-animation')
        setTimeout(() => {
            $('#nextStepBtn').parent().removeClass("d-none")
            $('#carrito_button_finalizar').parent().addClass("d-none")

            $('#nextStepBtn').removeAttr("disabled")

            if (previousStep.attr('id') == firstStep.attr('id')) {
                $('#prevStepBtn').attr("disabled", "disabled")
            } else {
                $('#prevStepBtn').removeAttr("disabled")
            }

            currentStep.removeClass('swipe-right-animation')
            currentStep.addClass("d-none")
            previousStep.removeClass("d-none")
        }, 500);
    }

    function nextSwipe(event) {
        if ($('#nextStepBtn').attr("disabled")) {
            return
        }

        let currentStep = $('[id^="step"]:not([data-skip="true"]):not(.d-none)')
        let nextStep    = currentStep.nextAll('[id^="step"]:not([data-skip="true"])').first()
        let lastStep    = $('[id^="step"]:not([data-skip="true"])').last()

        currentStep.addClass('swipe-left-animation')
        setTimeout(() => {
            $('#prevStepBtn').removeAttr("disabled")

            if (nextStep.attr('id') == lastStep.attr('id')) {
                $('#nextStepBtn').attr("disabled", "disabled")
                $('#nextStepBtn').parent().addClass("d-none")
                $('#carrito_button_finalizar').parent().removeClass("d-none")
            } else {
                $('#nextStepBtn').removeAttr("disabled")
            }

            currentStep.removeClass('swipe-left-animation')
            currentStep.addClass("d-none")
            nextStep.removeClass("d-none")
        }, 500);
    }

    document.addEventListener("DOMContentLoaded", function(event) {
        $('#prevStepBtn').on("click", prevSwipe)
        $('#nextStepBtn').on("click", nextSwipe)

        $(document).on('keyup', '#address_phone', function() {
            $("#address_phone").val($("#address_phone").val().replace(/\D/g, '').replace(/\s+/g, '').replace(/(\d{3})(?=.)/g, "$1 "));
        });

        $(document).on('keyup', '#address_phone2', function() {
            $("#address_phone2").val($("#address_phone2").val().replace(/\D/g, '').replace(/\s+/g, '').replace(/(\d{3})(?=.)/g, "$1 "));
        });

        $(document).on('keyup', '#address_mobile', function() {
            $("#address_mobile").val($("#address_mobile").val().replace(/\D/g, '').replace(/\s+/g, '').replace(/(\d{3})(?=.)/g, "$1 "));
        });

        $(document).on('keyup', '#address_mobile2', function() {
            $("#address_mobile2").val($("#address_mobile2").val().replace(/\D/g, '').replace(/\s+/g, '').replace(/(\d{3})(?=.)/g, "$1 "));
        });

        $(document).on('change', '#user_phone', function() {
            // si no es user_mobile se mete en phone
            let isMovil = new RegExp(/^(\+?[0-9]{1,4})?[6-7][0-9]{8}$/)
            let isFijo = new RegExp(/^(\+?[0-9]{1,4})?[8-9][0-9]{8}$/)
            let input = $('#user_phone').val()
            if (isMovil.test(input)) {
                $('#user_phone').attr('name', 'mobile')
            } else if (isFijo.test(input)) {
                $('#user_phone').attr('name', 'phone')
            } else {
                customAlert('Introduce un número de teléfono válido');
            }
        });

        window.onfocus = function() {
            //console.log("focus");
            if (needUserAddressesReload) {
                fetch_user_Addresses();
            }
        };

        window.onblur = function() {
            //console.log("blur");
        };

        $('#newAddressButton').on('click', function(e) {
            e.preventDefault();

            $('#address_content_container').addClass("d-none");
            $('#new_address_container').removeClass("d-none");
        });

        $('#cancelNewAddressButton').on('click', function(e) {
            e.preventDefault();

            $('#new_address_container').addClass("d-none");
            $('#address_content_container').removeClass("d-none");
        });

        $("#form_new_address").submit(function(event) {
            if (!this.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            } else {
                event.preventDefault();
                event.stopPropagation();
                //Get user data
                let name_contact = $("#name_contact").val();
                let address = $("#address_address").val();
                let id_country = $("#address_id_country").val();
                let id_province = $("#address_id_province").val();
                let id_city = $("#address_id_city").val();
                let cp = $("#address_cp").val();
                let phone = $("#address_phone").val().replace(/\D/g, '').replace(/\s+/g, '');
                let phone_2 = $("#address_phone2").val().replace(/\D/g, '').replace(/\s+/g, '');
                let mobile = $("#address_mobile").val().replace(/\D/g, '').replace(/\s+/g, '');
                let mobile_2 = $("#address_mobile2").val().replace(/\D/g, '').replace(/\s+/g, '');

                $.ajax({
                    type: "POST",
                    url: "/saveNewAddressWS",
                    data: {
                        "name_contact": name_contact,
                        "address": address,
                        "id_country": id_country,
                        "id_province": id_province,
                        "id_city": id_city,
                        "cp": cp,
                        "phone": phone,
                        "phone_2": phone_2,
                        "mobile": mobile,
                        "mobile_2": mobile_2
                    },
                    success: function(resData) {
                        if (resData.success == false) {
                            customAlert("Error: " + resData.error);
                            console.log(resData.carrito);
                        } else {
                            console.log("Dirección guardada");
                            console.log("Id: " + resData.address_id);
                            $('#form_new_address').get(0).reset();
                            fetch_user_Addresses(resData.address_id);
                            $('#new_address_container').addClass("d-none");
                            $('#address_content_container').removeClass("d-none");

                            $('#form_new_address').removeClass('was-validated');
                        }
                    },
                    error: function(e) {
                        customAlert("Error");
                    }
                });
            }
        });

        $(document).ready(function() {
            load_user_Addresses();
        });

        $('#addressModal').on('hide.bs.modal', function(e) {
            var address = $('input[name=RadioInputAddress]:checked').val();
            if (!address) {
                address = 0;
            }

            $divContent = "";
            $divContent += "<div><span>" + userAddresses[address]["address"] + "</span></div>";
            $divContent += "<div><span>" + userAddresses[address]["city"] + ", " + userAddresses[address]["province"] + ", " + userAddresses[address]["cp"] + ", " + userAddresses[address]["country"] + "</span></div>";
            $("#addressContent").html($divContent);
            $("#addressContent").attr('data-id', userAddresses[address]["id"]);
            //console.log(userAddresses[address]);

            setPeninsula(!userAddresses[address]["province_out"])
        });
    });
</script>

{#<script src='https://www.google.com/recaptcha/api.js?hl=es'></script>#}
<script type="text/javascript">



    // $(document).on('keyup','#user_phone',function(){
    //     var phone = $('#user_phone').val();
    //     if((phone[0] !=='8') && (phone[0] !== '9') && (phone[0] !== undefined )  ){
    //         customAlert('El teléfono debe empezar por 8 o 9');
    //         $('#user_phone').val("");
    //     }
    //     $("#user_phone").val( $("#user_phone").val().replace(/\D/g,'').replace(/\s+/g, '').replace(/(\d{3})(?=.)/g, "$1 ") );
    // });

    // $(document).on('keyup','#user_phone2',function(){
    //     var phone = $('#user_phone2').val();
    //     if((phone[0] !=='8') && (phone[0] !== '9') && (phone[0] !== undefined )  ){
    //         customAlert('El teléfono debe empezar por 8 o 9');
    //         $('#user_phone2').val("");
    //     }
    //     $("#user_phone2").val( $("#user_phone2").val().replace(/\D/g,'').replace(/\s+/g, '').replace(/(\d{3})(?=.)/g, "$1 ") );
    // });

    // $(document).on('keyup','#user_mobile',function(){
    //     var phone = $('#user_mobile').val();
    //     if((phone[0] !=='6') && (phone[0] !== '7') && (phone[0] !== undefined )  ){
    //         customAlert('El teléfono debe empezar por 6 o 7');
    //         $('#user_mobile').val("");
    //     }
    //     $("#user_mobile").val( $("#user_mobile").val().replace(/\D/g,'').replace(/\s+/g, '').replace(/(\d{3})(?=.)/g, "$1 ") );
    // });

    // $(document).on('keyup','#user_mobile2',function(){
    //     var phone = $('#user_mobile2').val();
    //     if((phone[0] !=='6') && (phone[0] !== '7') && (phone[0] !== undefined )  ){
    //         customAlert('El teléfono debe empezar por 6 o 7');
    //         $('#user_mobile2').val("");
    //     }
    //     $("#user_mobile2").val( $("#user_mobile2").val().replace(/\D/g,'').replace(/\s+/g, '').replace(/(\d{3})(?=.)/g, "$1 ") );
    // });

    (function() {
        'use strict';
        window.addEventListener('load', function() {
            // Fetch all the forms we want to apply custom Bootstrap validation styles to
            var forms = document.getElementsByClassName('needs-validation');
            // Loop over them and prevent submission
            var validation = Array.prototype.filter.call(forms, function(form) {
                form.addEventListener('submit', function(event) {
                    if (form.checkValidity() === false) {
                        event.preventDefault();
                        event.stopPropagation();
                    }
                    form.classList.add('was-validated');
                }, false);
            });
        }, false);
    })();

    function checkChangedEnvio(idgame) {
        var obj = document.querySelector('input[name=shipMethod_' + idgame + ']:checked');
        if (!obj) {
            return;
        }
        shipping_id = obj.value;
        value = $(obj).data('price');
        porcentaje = $(obj).data('porcentaje');
        shippable = $(obj).data('shippable');
        addressRequired = $(obj).data('addressrequired');

        if (shippable == 1) {
            //deactivate all shippables and activate only this shippable id
            $('.radio-shippable').prop('checked', false);
            $('.radio-shippable_' + shipping_id).prop('checked', true);

            if (addressRequired == 1 && user_logged == 1) {
                //activar shipping
                $("#step2").removeAttr("data-skip");
                $("#shipment_data_container").removeClass("d-none");
                //TODO sacar el numero del nthchild que sea el step este $('[id^="step"]:not([data-skip="true"])')
                $("#summary_title").html("3. Resumen de pedido");
                if (!$("#moreData_Title").parents('[data-step]').data("skip")) {
                    $("#moreData_Title").html("4. Datos Requeridos");
                }
            } else if (addressRequired == 0) {
                //desactivar div shipping
                $("#shipment_data_container").addClass("d-none");
                $("#step2").attr("data-skip", true);
                $("#summary_title").html("2. Resumen de pedido");
                if (!$("#moreData_Title").parents('[data-step]').data("skip")) {
                    $("#moreData_Title").html("3. Datos Requeridos");
                }
            }
        } else {
            //deactivate all non-shippables and activate only this non-shippable id
            $('.radio-not-shippable').prop('checked', false);
            $('.radio-not-shippable_' + shipping_id).prop('checked', true);

            //desactivar div shipping
            $("#shipment_data_container").addClass("d-none");
            $("#step2").attr("data-skip", true);
            $("#summary_title").html("2. Resumen de pedido");
            if (!$("#moreData_Title").parents('[data-step]').data("skip")) {
                $("#moreData_Title").html("3. Datos Requeridos");
            }
        }

        updateTotal();

        checkComplete();
    }

    function checkFinalizar() {
        $("#text-finalizar_pedido").css("display", "none");
        $("#text-finalizar_pedido_procesando").css("display", "inline");
        $("#carrito_button_finalizar").prop("disabled", true);

        if (user_logged) {

            if (!$("#moreData_Title").parents('[data-step]').data("skip")) {
                var moreData = {};
                //cif or phone required
                if ($("#user_cif").length) {
                    if ($("#user_cif").val() != "") {
                        moreData.cif = $("#user_cif").val().toUpperCase();
                    } else {
                        customAlert("Rellene el campo NIF/NIE/CIF");
                        $("#text-finalizar_pedido").css("display", "inline");
                        $("#text-finalizar_pedido_procesando").css("display", "none");
                        $("#carrito_button_finalizar").prop("disabled", false);
                        return;
                    }
                }
                if ($("#user_phone").length) {
                    var phoneComplete = false;
                    if ($("#user_phone").val() != "") {
                        let phoneField = $("#user_phone").attr('name')
                        moreData[phoneField] = $("#user_phone").val().replace(/\D/g, '').replace(/\s+/g, '');
                        phoneComplete = true;
                    }
                    if (!phoneComplete) {
                        customAlert("Rellene algún campo de teléfono");
                        $("#text-finalizar_pedido").css("display", "inline");
                        $("#text-finalizar_pedido_procesando").css("display", "none");
                        $("#carrito_button_finalizar").prop("disabled", false);
                        return;
                    }
                }

                $.ajax({
                    type: "POST",
                    url: "/saveUserDataWS",
                    data: {
                        "jsonData": JSON.stringify(moreData)
                    },
                    success: function(resData) {
                        console.log(resData);
                        if (resData.success == false) {
                            customAlert("Error: " + resData.error);
                            $("#text-finalizar_pedido").css("display", "inline");
                            $("#text-finalizar_pedido_procesando").css("display", "none");
                            $("#carrito_button_finalizar").prop("disabled", false);
                        } else {
                            createOrder();
                        }
                    },
                    error: function(e) {
                        customAlert("Error: " + e);
                        $("#text-finalizar_pedido").css("display", "inline");
                        $("#text-finalizar_pedido_procesando").css("display", "none");
                        $("#carrito_button_finalizar").prop("disabled", false);
                    }
                });
            } else {
                createOrder();
            }
        } else {
            customAlert("Debe registrarse o iniciar sesión con su usuario");
            $("#text-finalizar_pedido").css("display", "inline");
            $("#text-finalizar_pedido_procesando").css("display", "none");
            $("#carrito_button_finalizar").prop("disabled", false);
            return;
        }
    }

    function createOrder() {
        not_shippable_input = $('.radio-shippable');
        ship_shippable = $('.radio-shippable:checked').attr('id');
        ship_not_shippable = $('.radio-not-shippable:checked').attr('id');
        address = $("#addressContent").data('id');
        if (!ship_shippable) {
            ship_shippable = ship_not_shippable;
        }
        if (!ship_not_shippable) {
            ship_not_shippable = -1;
        }
        if (user_logged) {
            $.ajax({
                type: "POST",
                url: "/createOrderWs",
                data: {
                    "ship": ship_shippable,
                    "not_ship": ship_not_shippable,
                    "address": address,
                    "is_voice_server": 1
                },
                success: function(resData) {
                    console.log("checkfinalizar_res");
                    $("#text-finalizar_pedido").css("display", "inline");
                    $("#text-finalizar_pedido_procesando").css("display", "none");
                    $("#carrito_button_finalizar").prop("disabled", false);

                    if (resData.success == false) {
                        customAlert("Error: " + resData.error);
                        console.log(resData.carrito);
                    } else {
                        //customAlert("Pedido creado");
                        console.log("Pedido recibido");
                        console.log(resData);

                        var order = resData.order;
                        console.log("order: " + order);
                        if (!order) {
                            customAlert("Error: No se ha creado correctamente el pedido");
                            return;
                        }
                        window.location.href = urlPanel + "/backend/pay?io=" + order;
                    }
                },
                error: function(e) {
                    customAlert("Error");
                }
            });
        }
    }
</script>
