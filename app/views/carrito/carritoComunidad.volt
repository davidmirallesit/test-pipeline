</section> {# <!-- Se cierra el section class container que se crea en sections phtml --> #}
<div class="row " style="margin:0 !important;">
    <div class="container">
        {% include 'layouts/boxs/box_community_header.volt' %}
    </div>
</div>
<section class="container my-4">
    <div class="row">
        {% if web_seo_onpage['h1'] %}
            <div class="col-12 text-center">
                <h1 class="text-center">{{web_seo_onpage['h1']}}</h1>
            </div>
        {% endif %}

        {% if web_seo_onpage['txt_up'] is not empty %}
            <div class="col-12 text-center text-justify">
                <div>{{web_seo_onpage['txt_up']}}</div>
            </div>
        {% endif %}
        <div class="col-md-12 perfil_venta">
            {% if !array_key_exists("lines", carrito_comunidad) or carrito_comunidad["lines"] is null or (carrito_comunidad["lines"]|length) == 0 %}
                <div class="alert alert-danger" role="alert">No hay productos en el carrito</div>
            {% else %}
                {#  si no ha iniciado sesión #}
                {% if !session.has('user') %}
                    <div class="row mt-5">
                        <div class="col-12">
                            <h4 class="mb-0">1. Identificarse</h4>
                        </div>
                    </div>

                    <hr class="mb-2">

                    <div class="d-block p-3 carrito_section my-3 text-center">
                        <span class="h6">Para continuar con el proceso de compra inicie sesión o registre una nueva cuenta</span>
                        <div class="mt-3 mb-3 d-flex justify-content-center align-items-center">
                            <a class="btn btn-primary btn-login button_login mr-3" data-toggle="modal" data-target="#loginModalRoof2">Acceso Usuarios</a>
                            {% include 'layouts/boxs/box_modal_login' with ['target': 'loginModalRoof2'] %}
                        </div>
                    </div>
                {% endif %}
                {#  --fin si no ha iniciado sesión-- #}
                <div class="row mt-5">
                    <div class="col-12">
                        <h4 class="mb-0">
                            {% if !session.has('user') %}
                                2.
                            {% else %}
                                1.
                            {% endif %}
                            Formas de Envío
                            <small class="display_none" id="label_fuera_peninsula">(Fuera de península)</small>
                        </h4>
                    </div>
                </div>

                <hr class="mb-2">
                {% for gameId in gameIds %}
                    {% set gameInfo = null %}
                    {% for game_info in games_info %}
                        {% if gameId == game_info["id"] %}
                            {% set gameInfo = game_info %}
                            {% break %}
                        {% endif %}
                    {% endfor %}
                    <div class="d-block p-3 carrito_section my-3">
                        <div class="row">
                            <div class="col-12 col-md-5 carrito_header_text">
                                <img src="{{gameInfo['logo']}}" height="39" width="39">
                                <span class="ml-2">{{gameInfo["name"]}}</span>
                            </div>
                            <div class="col-12 col-md-7 pt-2">
                                {% set autoSelectedGames = [] %}
                                {% for shipping_method in shipping_methods %}
{#
                                    //si el juego no es enviable mostrar metodos no enviables, si el juego es enviable se muestran todos
                                    //TODO: Hay que obtener los enviables de la entidad y no del juego o administración
#}
                                    {% if ((carrito_comunidad["isShippable"] == false and shipping_method.is_shippable == 0) or (carrito_comunidad["isShippable"] == true)) %}
                                        <div class="custom-control custom-radio mb-3">
                                            {% set porcentaje = "" %}
                                            {% if shipping_method.perc_incr != "0" %}
                                                {% set porcentaje = shipping_method.perc_incr %}
                                            {% endif %}
                                            <input
                                                data-porcentaje="{{porcentaje}}"
                                                data-price="{{shipping_method.price_in}}"
                                                data-price_out="{{shipping_method.price_out}}"
                                                data-shippable="{% if shipping_method.is_shippable %}{{shipping_method.is_shippable}}{% else %}0{% endif %}"
                                                {% if shipping_method.hours_needed > hoursToDraw %}
                                                    disabled
                                                {% endif %}
                                                {% if loop.first %}
                                                    checked
                                                    {{array_push(autoSelectedGames, gameId)}}
                                                {% endif %}
                                                data-addressRequired="{% if shipping_method.is_address_required is defined and shipping_method.is_address_required %}1{% else %}0{% endif %}"
                                                value="{{shipping_method.id}}"
                                                id="shipMethod_{{shipping_method.id}}_game_{{gameId}}"
                                                name="shipMethod_{{gameId}}"
                                                onchange="checkChangedEnvio({{gameId}})"
                                                type="radio"
                                                class="custom-control-input shipping_radio {% if shipping_method.is_shippable %}radio-shippable radio-shippable_{% else %}radio-not-shippable radio-not-shippable_{% endif %}{{shipping_method.id}}"
                                                required="">
                                            <label class="custom-control-label label-shipMethod_{{shipping_method.id}}" for="shipMethod_{{shipping_method.id}}_game_{{gameId}}"><b>{{shipping_method.name}}</b>: {{shipping_method.price_in}}€
                                                <br>
                                                {% if porcentaje != "" %} + {{porcentaje}} % del envío sobre el importe {% endif %}
                                                {% if shipping_method.price_in != shipping_method.price_out %}({{shipping_method.price_out}} €{% if porcentaje != "" %} + {{porcentaje}} %{% endif %} fuera de la Península){% endif %}
                                            </label>
                                        </div>
                                    {% endif %}
                                {% endfor %}
                            </div>
                        </div>
                    </div>
                {% endfor %}

                <div id="shipment_data_container" class="d-none">
                    <div class="row mt-5">
                        <div class="col-12">
                            <h4 class="mb-0">2. Datos de envío</h4>
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
                        <div class="row no_display" id="new_address_container">
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
                                                                <option value="{{country['id']}}">{{country['name']}}</option>
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
                                            {# <!--
                                                        <div class="col-12 col-md-6">
                                                            <div class="form-group">
                                                                <label for="address_email" class="control-label">Email</label>
                                                                <input class="form-control text-left" type="text" name="address_email" id="address_email" value="" size="60" maxlength="100">
                                                            </div>
                                                        </div>
                                                        --> #}
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

                <div class="row mt-5 d-flex align-items-center">
                    <div class="col-12 col-md-6">
                        <h4 class="mb-0" id="summary_title">
                            {% if !session.has('user') %}
                                3.
                            {% else %}
                                2.
                            {% endif %}
                            Resumen de pedido
                        </h4>
                    </div>

                    <div class="col-12 col-md-6 col-lg-5 d-flex justify-content-end no_display">
                        <a href="/carrito-comunidad?delete=all" class="mt-1 btn btn-primary btn-login button_login">
                            Borrar todo&nbsp;&nbsp;<i class="fa-trash-o fa"></i>
                        </a>
                    </div>
                </div>

                <hr class="mt-2 mb-3">
                {% set subtotal = floatval(carrito_comunidad['total']) %}

                {% set sorteos_ln_cargados = [] %}
                {% for gameId in gameIds %}
                    {# //CARRITO PARA LOTERÍA NACIONAL #}
                    {% if gameId == idLn %}
                        {% for index, numeros in carrito_comunidad["lines"] %}
                            {% if numeros is not iterable or array_search(numeros["id_draw"], sorteos_ln_cargados) === false %}
                                {% if numeros is iterable %}
                                    {{void_output(array_push(sorteos_ln_cargados, numeros["id_draw"]))}}
                                {% endif %}
                                {% set newDateString = "" %}
                                {% if carrito_comunidad["draw_info"] %}
                                    {% if numeros is iterable and numeros["id_draw"] %}
                                        {% for draw_info in carrito_comunidad["draw_info"] %}
                                            {% if draw_info["id_draw"] == numeros["id_draw"] %}
                                                {% set newDateString = draw_info["date_draw"] %}
                                                {% break %}
                                            {% endif %}
                                        {% endfor %}
                                    {% else %}
                                        {% set newDateString = carrito_comunidad["draw_info"][array_keys(carrito_comunidad["draw_info"])[0]]["date_draw"] %}
                                    {% endif %}
                                {% endif %}
                                <div class="col-12 d-block carrito_section p-3">
                                    <div class="row carrito_pedido_header">
                                        {# <!-- RENDER LOTERIA NACIONAL ITEM --> #}

                                        <div class="col-12 col-lg-4 col-xl-3 carrito_participaciones_header_info_data">
                                            <img src="{{gameInfo['logo']}}" height="39" width="39">
                                            <span class="ml-2">{{gameInfo["name"]}}</span>
                                        </div>
                                        <div class="col-12 col-sm-12 col-lg-5">
                                            <span class="carrito_header_info_title">Sorteo: </span>
                                            <span class="carrito_line_main">
                                                {% if newDateString != '' %}{{newDateString|date_format('d/m/Y')}}{% endif %} - ({% if numeros is iterable and numeros["id_draw"] %}{{view_sorteo(numeros["id_draw"])}}{% else %}{{view_sorteo(carrito_comunidad["draw_info"][array_keys(carrito_comunidad["draw_info"])[0]]["id_draw"])}}{% endif %})
                                            </span>
                                        </div>
                                        <div class="d-none col-12 col-md-4">
                                        </div>
                                    </div>
                                    <hr class="m-0">
                                    <div class="row mt-1 d-flex d-md-none carrito_participaciones_header_info_data">
                                        <div class="col-4 text-center">Número</div>
                                        <div class="col-5">
                                            {% if carrito_comunidad['is_fractional'] %}
                                                Participaciones
                                            {% else %}
                                                Décimos
                                            {% endif %}
                                        </div>
                                        <div class="col-3 text-right">€</div>
                                    </div>
                                    {# //mostrar todas las lineas aquí #}
                                    {% if numeros is defined and numeros is iterable %}
                                        {% for i in index..(carrito_comunidad["lines"]|length) %}
                                            {% if numeros["id_draw"] == carrito_comunidad["lines"][i]["id_draw"] %}
                                                <div class="row mt-1 align-items-center">
                                                    <div class="carrito_header_info_title text-center col-4">
                                                        <span class="d-none d-md-inline">Número:</span>
                                                        <span class="carrito_line_main"> {% if carrito_comunidad["lines"][i]["number"] is defined %}{{carrito_comunidad["lines"][i]["number"]}}{% else %}{{implode(' - ', array_keys(carrito_comunidad["extraData"]))}}{% endif %}</span>
                                                    </div>
                                                    <div class="col-5 col-md-4 col-lg-3">
                                                        <span class="carrito_header_info_title d-none d-md-inline">
                                                            {% if carrito_comunidad['is_fractional'] %}
                                                                Participaciones
                                                            {% else %}
                                                                Décimos
                                                            {% endif %}: </span>
                                                        <span class="carrito_line_main"> {% if carrito_comunidad["lines"][i]["quantity"] is not null %}{{carrito_comunidad["lines"][i]["quantity"]}}{% else %}{{carrito_comunidad["lines"]["quantity"]}}{% endif %}</span>
                                                    </div>
                                                    <div class="col-3 col-lg-4 text-right text-lg-left">
                                                        <span class="d-none d-md-inline carrito_header_info_title d-none d-md-inline">Importe:&nbsp;</span><span class="carrito_line_main">{% if carrito_comunidad["lines"][i]["quantity"] %}{{(carrito_comunidad["lines"][i]["quantity"] * carrito_comunidad["play_price"])|number_float}}{% else %}{{(carrito_comunidad["lines"]["quantity"] * carrito_comunidad["play_price"])|number_float}}{% endif %}€</span>
                                                    </div>
                                                    <div class="col-12 col-md-1 carrito_delete_container d-flex justify-content-end justify-content-lg-start no_display">
                                                        <a href="carrito?delete={{i}}"><i class="fa fa-trash-o text-azul"></i></a>
                                                    </div>
                                                </div>
                                            {% endif %}
                                        {% endfor %}
                                    {% else %}
                                        <div class="row mt-1 align-items-center">
                                            <div class="carrito_header_info_title text-center col-4">
                                                <div class="row">
                                                    {% for key, number in carrito_comunidad["extraData"] %}
                                                    <div class="col-12">
                                                        {{ carrito_comunidad["draw_info"][key]['name_short'] }}    
                                                    </div>
                                                    <div class="col-12">
                                                        <span class="carrito_line_main">Número{{count(array_keys(number)) > 1 ? 's' : ''}}: {{implode(' - ', array_keys(number))}}</span>
                                                    </div>
                                                    {% endfor %}
                                                </div>
                                            </div>
                                            <div class="col-5 col-md-4 col-lg-3">
                                                <span class="carrito_header_info_title d-none d-md-inline">
                                                    {% if carrito_comunidad['is_fractional'] %}
                                                        Participaciones
                                                    {% else %}
                                                        Décimos
                                                    {% endif %}: </span>
                                                <span class="carrito_line_main"> {{carrito_comunidad["lines"]["quantity"]}}{% if !carrito_comunidad["is_individual"] and !carrito_comunidad['is_fractional'] %} (por número){% endif %}</span>
                                            </div>
                                            <div class="col-3 col-lg-4 text-right text-lg-left">
                                                <span class="d-none d-md-inline carrito_header_info_title d-none d-md-inline">Importe:&nbsp;</span><span class="carrito_line_main">{{(carrito_comunidad["lines"]["quantity"] * carrito_comunidad["play_price"])|number_float}}€</span>
                                            </div>
                                            <div class="col-12 col-md-1 carrito_delete_container d-flex justify-content-end justify-content-lg-start no_display">
                                                <a href="carrito?delete={{i}}"><i class="fa fa-trash-o text-azul"></i></a>
                                            </div>
                                        </div>
                                    {% endif %}
                                </div>
                                <br>
                            {% endif %}
                        {% endfor %}
                    {#% elseif gameId == 1 or gameId == 4 or gameId == 5 or gameId == 2 or gameId == 25 or gameId == 21 %#}
                    {% else %}
                        <div class="col-12 d-block carrito_section p-3">
                            <div class="row carrito_pedido_header">
                                {# <!-- RENDER NOT LOTERIA NACIONAL ITEM --> #}
                                <div class="col-12 col-lg-4 col-lg-3 carrito_header_info_data">
                                    <img src="{{gameInfo['logo']}}" height="39" width="39">
                                    <span class="ml-2">{{gameInfo['name']}}</span>
                                </div>
                                <div class="col-12 col-md-8 col-lg-5">
                                </div>
                                <div class="col-12 col-md-4 col-lg-3 d-flex justify-content-end justify-content-lg-start align-items-center">
                                    <span class="carrito_header_info_title">Importe:&nbsp;</span> <span class="carrito_line_main">{{(floatval(carrito_comunidad["lines"]["quantity"]) * floatval(carrito_comunidad["play_price"]))|number_float}}&nbsp;€</span>
                                </div>
                                <div class="d-none col-12 col-md-4">
                                </div>
                            </div>
                            <hr class="m-0">
                            <div class="row mt-1">
                                <div class="col-12">
                                    <span class="carrito_header_info_title d-none d-sm-inline">
                                        {% if carrito_comunidad['is_fractional'] %}
                                            Participaciones
                                        {% else %}
                                            Décimos
                                        {% endif %}: </span>
                                    <span class="carrito_line_main"> {{carrito_comunidad["lines"]["quantity"]}}</span>
                                </div>
                            </div>
                        </div>
                        <br>
                    {% endif %}
                {% endfor %}

                {% if session.get('user') and
                     !((session.get('user')["phone"] or session.get('user')["phone_2"] or session.get('user')["mobile"] or session.get('user')["mobile_2"]) and session.get('user')["cif"]) %}
                    <div class="row mt-5">
                        <div class="col-12">
                            <h4 class="mb-0" id="moreData_Title">4. Datos Requeridos</h4>
                        </div>
                    </div>

                    <hr class="mb-2">
                    <div class="d-block p-3 carrito_section my-3">
                        <p class="text-danger bold">Su cuenta de usuario aún no tiene algunos datos necesarios:</p>
                        <form class="needs-validation" id="form_data_needed" novalidate>
                            <div class="row">
                                {% if !session.get('user')["cif"] %}
                                    <div class="col-12 mb-3">
                                        <label for="user_cif">NIF/NIE/CIF</label>
                                        <input type="text" class="form-control" minlength="8" id="user_cif" placeholder="" value="" required>
                                    </div>
                                {% endif %}
                                {% if !session.get('user')["phone"] and !session.get('user')["phone_2"] and !session.get('user')["mobile"] and !session.get('user')["mobile_2"] %}
                                    {# <!-- si no tiene ningun telefono se le pide uno --> #}
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
                {% endif %}

                <hr class="mb-4 d-none">

                {# <!--Dejamos la linea original en d-none para comprobaciones-->#}
                <div class="row mb-3 d-flex align-items-center justify-content-center no_display">
                    <span class="carrito_header_info_title">Importe del pedido:&nbsp;</span><span class="carrito_line_main" id="total_subtotal">{{subtotal|number_float}}</span><span class="carrito_line_main">€</span>
                </div>
                {# <!-- ^^^^^ --> #}
                {% set total_quantity = 0 %}
                {% if intval(carrito_comunidad['is_individual']) %}
                    {% for linea in carrito_comunidad["lines"] %}
                        {% set total_quantity += intval(linea["quantity"]) %}
                    {% endfor %}
                {% else %}
                    {# // si se juega sobre todo no hay total por número #}
                    {% set total_quantity = intval(carrito_comunidad["lines"]["quantity"]) %}
                {% endif %}
                <div class="row mb-3 d-flex align-items-center justify-content-center">
                    <span class="carrito_header_info_title">Importe del pedido:&nbsp;</span><span class="carrito_line_main" id="total_pedido">{{(floatval(carrito_comunidad["play_price"]) * total_quantity)|number_float}}</span><span class="carrito_line_main">€</span>
                </div>
                {% if carrito_comunidad["play_donation"] %}
                    <div class="row mb-3 d-flex align-items-center justify-content-center">
                        <span class="carrito_header_info_title">Donativo:&nbsp;</span><span class="carrito_line_main" id="total_donaciones">{{(floatval(carrito_comunidad["play_donation"]) * total_quantity)|number_float}}</span><span class="carrito_line_main">€</span>
                    </div>
                {% endif %}
                <div class="row mb-3 d-flex align-items-center justify-content-center">
                    <span class="carrito_header_info_title">Gastos de envío:&nbsp;</span><span class="carrito_line_main" id="total_envio">{{0|number_float}}</span><span class="carrito_line_main">€</span>
                </div>
                <div class="row mb-5 d-flex align-items-center justify-content-center">
                    <span class="textImporte custom-block-100W">Total a pagar:&nbsp;</span>
                    <span class="d-flex align-items-center">
                        <span class="resumen-pedido-importe-total resumen-pedido-importe-total-value" id="total_total">{{subtotal|number_float}}</span>
                        <span class="resumen-pedido-importe-total resumen-pedido-importe-total-value">€</span>
                    </span>
                </div>
{#
                <!--
                            <button class="btn btn-azul btn-block" onclick="checkFinalizar()" type="button">
                                Finalizar Pedido
                                <span id="spinner_procesando" class="carrito_span_procesando"> <span class="d-none d-sm-block">Procesando...  </span><div class="loader carrito_div_procesando"></div></span>
                            </button>
                            -->#}
                <div class="row w-100 px-2 mt-3 mb-5 d-flex justify-content-center align-items-center text-center customCheckBox">
                    <label for="compra_checkTerms" class="my-0 ml-2">
                        <input class="mr-1" type="checkbox" name="compra_checkTerms" id="compra_checkTerms" required onchange="checkCondiciones(this)">
                        Acepto las <a style="color: #007bff !important; padding: 0 !important;" href="/condiciones-generales" target="_blank">Condiciones Generales de Contratación</a> y he leído la <a style="color: #007bff !important; padding: 0 !important;" href="/politica-privacidad" target="_blank">política de privacidad</a>.
                    </label>
                </div>
                <div class="row d-flex justify-content-center text-center" id="pendingData">
                    <div class="col-12 justify-content-center no_display" id="pendingData_envio">
                        <p class="text-danger bold">Debe seleccionar un método de envío para todos los juegos</p>
                    </div>
                    <div class="col-12 justify-content-center no_display" id="pendingData_direccion">
                        <p class="text-danger bold">Debe seleccionar o añadir una dirección de envío</p>
                    </div>
                    <div class="col-12 justify-content-center{% if session.has('user') %} no_display{% endif %}" id="pendingData_login">
                        <p class="text-danger bold">Debe registrarse o iniciar sesión con su usuario</p>
                    </div>
                    <div class="col-12 justify-content-center" id="pendingData_Condiciones">
                        <p class="text-danger bold">Debe aceptar las condiciones de contratación y la política de privacidad</p>
                    </div>
                </div>
                <div class="row d-flex justify-content-center">
                    <button class="btn btn-block carrito_button_finalizar" disabled id="carrito_button_finalizar" onclick="checkFinalizar()" type="button">
                        <span id="text-finalizar_pedido" style="display: inline;">Finalizar Pedido</span>
                        <span id="text-finalizar_pedido_procesando" style="display: none;">Procesando Pedido...</span>
                    </button>
                </div>
            {% endif %}
        </div>

        {% if web_seo_onpage['txt_down'] is not empty %}
            <div class="col-12 text-center text-justify">
                <div>{{web_seo_onpage['txt_down']}}</div>
            </div>
        {% endif %}

        {# XXX Francis: Para que muestran la información de sesión del usuario en una capa oculta? Aun así sigue mostrandose en el código HTML y lo pueden interceptar robots, etc.
        <div class="d-none">
            {{var_dump(session.get('user'))}}
        </div>
        #}
    </div>
{# XXX Francis: Que pinta este formulario de pago por tarjeta de redsys aqui???
    <form action="https://sis-t.redsys.es:25443/sis/realizarPago" method="POST" id="redsys_form" name="redsys_form">
        <input type="hidden" id="Ds_SignatureVersion" name="Ds_SignatureVersion" value="" />
        <input type="hidden" id="Ds_MerchantParameters" name="Ds_MerchantParameters" value="" />
        <input type="hidden" id="Ds_Signature" name="Ds_Signature" value="" />
    </form>
#}
</section>

<script>
    document.addEventListener("DOMContentLoaded", function(event) {
        $('#frm-login').on('submit', function(e) {
            e.preventDefault();

            $("#spinner_procesando").css('display', 'inline-flex');

            let action = $(this).attr('action');
            let params = {
                'uuid': '{{config.baseconfig.uuid}}',
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
                'uuid': '{{config.baseconfig.uuid}}',
                'email': $(this).find('[name="email"]').val(),
                'pass': $(this).find('[name="pass"]').val(),
                'pass_confirm': $(this).find('[name="pass_confirm"]').val()
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

        $('#pass_carrito_comunidad_login, #email_carrito_comunidad_login').keyup(function() {
            checkFormCarritoComunidadLogin();
        });

        $('#pass_carrito_comunidad_register, #pass2_carrito_comunidad_register ,#email_carrito_comunidad_register').keyup(function() {
            checkFormCarritoComunidadRegister();
        });
        $("#registro_carrito_comunidad_checkEdad, #registro_carrito_comunidad_checkTerms, #registro_carrito_comunidad_checkConditions").click(function() {
            checkFormCarritoComunidadRegister();
        });

        $('.tabs-login-register-carrito-comunidad').ready(function() {
            if ($('.tabs-login-register-carrito-comunidad').first().hasClass('active')) {
                $('.tabs-login-register-carrito-comunidad').last().removeClass('bg-azul').addClass('bg-alternative-border').css("border", "1px solid").children().addClass('text-alternative').removeClass('text_color_ws');
            }

        });
        $('.tabs-login-register-carrito-comunidad').click(function(event) {
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

        $('.div-navbar-svg').mouseenter(function(event) {
            //$(this.children[0]).css('backgroundColor', 'red');
            $(this.children[0]).addClass('btn-header');
            $(this.children[0].children[0]).removeClass('text-azul');
            $(this.children[0].children[1]).removeClass('text-azul');
            $(this.children[0].children[0]).addClass('text-header');
            $(this.children[0].children[1]).addClass('text-header');
        });
        $('.div-navbar-svg').mouseleave(function(event) {
            $(this.children[0]).removeClass('btn-header');
            $(this.children[0].children[0]).removeClass('text-header');
            $(this.children[0].children[1]).removeClass('text-header');
            $(this.children[0].children[0]).addClass('text-azul');
            $(this.children[0].children[1]).addClass('text-azul');
        });

        $('#newAddressButton').on('click', function(e) {
            e.preventDefault();

            $('#address_content_container').addClass("no_display");
            $('#new_address_container').removeClass("no_display");
        });

        $('#cancelNewAddressButton').on('click', function(e) {
            e.preventDefault();

            $('#new_address_container').addClass("no_display");
            $('#address_content_container').removeClass("no_display");
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
                    url: "saveNewAddressWS",
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
                            $('#new_address_container').addClass("no_display");
                            $('#address_content_container').removeClass("no_display");

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
            //fetch_user_Addresses();
            subTotal = subTotal.replace(',', '.');
            if (parseFloat(subTotal) >= parseFloat(userBalance)) {
                $("#method_saldo").prop("disabled", true);
            }

            try {
                checked = false;
                //vamos a marcar los métodos de envío siempre y cuando estén disponibles
                if (sessionStorage.getItem("ship_notShippable_option")) {
                    if ($('.radio-not-shippable_' + sessionStorage.getItem("ship_notShippable_option")).prop('disabled') == false) {
                        $('.radio-not-shippable_' + sessionStorage.getItem("ship_notShippable_option")).prop('checked', true);
                    }
                }
                if (sessionStorage.getItem("ship_shippable_option")) {
                    if ($('.radio-shippable_' + sessionStorage.getItem("ship_shippable_option")).prop('disabled') == false) {
                        $('.radio-shippable_' + sessionStorage.getItem("ship_shippable_option")).prop('checked', true);
                        if (sessionStorage.getItem("ship_shippable_option_game")) {
                            checkChangedEnvio(sessionStorage.getItem("ship_shippable_option_game"));
                            checked = true;
                        }
                    }
                }
                if (autoSelectedGames) {
                    autoSelectedGames.forEach(idgame => checkChangedEnvio(idgame));
                }
            } catch (error) {
                console.error(error);
                if (autoSelectedGames) {
                    autoSelectedGames.forEach(idgame => checkChangedEnvio(idgame));
                }
            }

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
            // al hacer el createOrder se llama con jquery por lo que hay que meter el valor con jquery tambien
            $("#addressContent").data('id', userAddresses[address]["id"])
            //console.log(userAddresses[address]);

            setPeninsula(!userAddresses[address]["province_out"])
        });
    });

    var errorCaptchaCarritoComunidadLogin = false;
    var errorCaptchaCarritoComunidadRegister = false;

    function recaptchaErrorCallbackCarritoComunidad() {
        errorCaptchaCarritoComunidadLogin = true;
        $('#captcha_carrito_comunidad_login').remove();

        errorCaptchaCarritoComunidadRegister = true;
        $('#captcha_carrito_comunidad_register').remove();

        checkFormCarritoComunidadLogin();
        checkFormCarritoComunidadRegister();
    }
    var captchaCarritoComunidadLogin = false;

    function recaptchaCallbackCarritoComunidadLogin() {
        captchaCarritoComunidadLogin = true;
        checkFormCarritoComunidadLogin();
    }

    function checkFormCarritoComunidadLogin() {

        if (errorCaptchaCarritoComunidadLogin === true) {
            /* En el caso de que el captcha de error lo validaremos como si fuese correcto*/
            captchaCarritoComunidadLogin = true;
        }

        if ($('#pass_carrito_comunidad_login').val() !== "" && $('#email_carrito_comunidad_login').val() !== "" && captchaCarritoComunidadLogin === true) {
            $('#btn-carrito-comunidad-login').prop('disabled', false);
        } else {
            $('#btn-carrito-comunidad-login').prop('disabled', true);
        }
    }

    var captchaCarritoComunidadRegister = false;

    function recaptchaCallbackCarritoComunidadRegister() {
        captchaCarritoComunidadRegister = true;
        checkFormCarritoComunidadRegister();
    }

    function checkFormCarritoComunidadRegister() {

        if (errorCaptchaCarritoComunidadRegister === true) {
            captchaCarritoComunidadRegister = true;
        }

        if ($('#pass_carrito_comunidad_register').val() !== "" && $('#pass2_carrito_comunidad_register').val() !== "" && $('#email_carrito_comunidad_register').val() !== "" &&
            captchaCarritoComunidadRegister === true && $('#registro_carrito_comunidad_checkEdad').is(':checked') && $('#registro_carrito_comunidad_checkTerms').is(':checked') &&
            $('#registro_carrito_comunidad_checkConditions').is(':checked')) {
            $('#btn-carrito-comunidad-register').prop('disabled', false);
        } else {
            $('#btn-carrito-comunidad-register').prop('disabled', true);
        }
    }
</script>

{#<script src='https://www.google.com/recaptcha/api.js?hl=es'></script>#}
<script type="text/javascript">
    var userAddresses = {{json_encode(user_addresses)}};

    var gameIds = {{json_encode(gameIds)}};

    var shippingMethods = {{json_encode(shipping_methods)}};

    var userBalance = {% if user_balance is defined %}{{user_balance}}{% else %}0.00{% endif %};

    var showing_shipping_selector = false;

    var user_logged = {% if session.has('user') %}1{% else %}0{% endif %};

    var email_verified = "{{session.get('user')["email_verified"]|default(0)}}";

    var urlPanel = "{{config.baseconfig.url_panel}}";

    var subTotal = "{{subtotal}}";

    var needUserAddressesReload = false;

    var peninsula = true;

    var autoSelectedGames = {{json_encode(autoSelectedGames)}};

    var countries = {{json_encode(locationInfo["countries"])}};

    var provinces = {{json_encode(locationInfo["provinces"])}};

    var cities = {{json_encode(locationInfo["cities"])}};

{#
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
#}
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

    function cantidad_changed(sorteo, numero, importe, el) {
        cantidad = $(el).val();

        $(".cantidad_" + sorteo + "_" + numero).val(cantidad);

        if (cantidad == 0) {
            $(".cantidad_" + sorteo + "_" + numero).val(1);
        }

        total = cantidad * importe;

        $(".total_" + sorteo + "_" + numero).html(total);

        actualizar_subtotal();
    }

    function actualizar_subtotal() {
        subtotal = 0;

        Array.from(document.getElementsByClassName("cantidades")).forEach(
            function(element, index, array) {
                subtotal += parseInt(element.innerHTML);
            }
        );

        subtotal = subtotal / 2;

        $("#subtotal").html(subtotal);

        value = document.querySelector('input[name=shipMethod]:checked').value;
        subtotal = $("#subtotal").html();

        total_total = parseFloat(value) + parseFloat(subtotal);

        $("#total_envio").html(formatNumber(parseFloat(value), 2));

        $("#total_subtotal").html(formatNumber(parseFloat(subtotal), 2));

        $("#total_total").html(formatNumber(total_total, 2));
    }

    function checkChangedEnvio(idgame) {
        subTotal = subTotal.replace(',', '.');
        shipping_id = document.querySelector('input[name=shipMethod_' + idgame + ']:checked').value;
        value = $(document.querySelector('input[name=shipMethod_' + idgame + ']:checked')).data('price');
        porcentaje = $(document.querySelector('input[name=shipMethod_' + idgame + ']:checked')).data('porcentaje');
        shippable = $(document.querySelector('input[name=shipMethod_' + idgame + ']:checked')).data('shippable');
        addressRequired = $(document.querySelector('input[name=shipMethod_' + idgame + ']:checked')).data('addressrequired');

        //console.log("selected: " + shippable + " --- shipping-id: " + shipping_id + " --- needs-shipping: " + showing_shipping_selector + " ---- price: " + value);

        if (shippable == 1) {
            sessionStorage.setItem("ship_shippable_option", shipping_id);
            sessionStorage.setItem("ship_shippable_option_game", idgame);
            //deactivate all shippables and activate only this shippable id
            $('.radio-shippable').prop('checked', false);
            $('.radio-shippable_' + shipping_id).prop('checked', true);

            if (!showing_shipping_selector && addressRequired == 1 && user_logged == 1) {
                //activar shipping
                showing_shipping_selector = true;
                $("#shipment_data_container").removeClass("d-none");
                $("#summary_title").html("3. Resumen de pedido");
                if ($("#moreData_Title").length)
                    $("#moreData_Title").html("4. Datos Requeridos");
            } else if (showing_shipping_selector && addressRequired == 0) {
                //desactivar div shipping
                showing_shipping_selector = false;
                $("#shipment_data_container").addClass("d-none");
                $("#summary_title").html("2. Resumen de pedido");
                if ($("#moreData_Title").length) {
                    $("#moreData_Title").html("3. Datos Requeridos");
                }
            }
        } else {
            //si tenemos un método shippable guardado en sesión para este juego, lo borramos
            if (sessionStorage.getItem("ship_shippable_option_game") && sessionStorage.getItem("ship_shippable_option_game") == idgame) {
                sessionStorage.removeItem("ship_shippable_option_game");
                sessionStorage.removeItem("ship_shippable_option");
            }

            sessionStorage.setItem("ship_notShippable_option", shipping_id);
            //deactivate all non-shippables and activate only this non-shippable id
            $('.radio-not-shippable').prop('checked', false);
            $('.radio-not-shippable_' + shipping_id).prop('checked', true);

            if (showing_shipping_selector) {
                //desactivar div shipping
                showing_shipping_selector = false;
                $("#shipment_data_container").addClass("d-none");
                $("#summary_title").html("2. Resumen de pedido");
                if ($("#moreData_Title").length) {
                    $("#moreData_Title").html("3. Datos Requeridos");
                }
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

            if (!email_verified) {
                customAlert("Verifique su e-mail y vuelva a loguearse antes de realizar el pedido");
                $("#text-finalizar_pedido").css("display", "inline");
                $("#text-finalizar_pedido_procesando").css("display", "none");
                $("#carrito_button_finalizar").prop("disabled", false);
                $('.btn-logout')[0].click();
                return;
            }
            if ($("#moreData_Title").length) {
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
                    url: "saveUserDataWS",
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
                url: "createCommunityOrderWs",
                data: {
                    "ship": ship_shippable,
                    "not_ship": ship_not_shippable,
                    "address": address
                },
                success: function(resData) {
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
                        console.log("order: " + order);
                        window.location.href = urlPanel + "/backend/pay?ia=" + order;
                    }
                },
                error: function(e) {
                    customAlert("Error");
                }
            });
        }
    }
</script>
