{% set indexHeader = 1 %}
<section class="container my-4">
    <div class="row">
        <div class="col-12 text-center">
            <h1 class="text-center">{{ web_seo_onpage['h1'] }}</h1>
        </div>

        {% if web_seo_onpage['txt_up'] is not empty %}
            <div class="col-12 text-center text-justify">
                <div>{{ web_seo_onpage['txt_up'] }}</div>
            </div>
        {% endif %}

        <div class="col-md-12 perfil_venta">

            {% if sizeof(carrito_ws) == 0 %}
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
            {% if !this.session.has('user') %}
                <div class="row mt-5">
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
                        {% include 'layouts/boxs/box_modal_login' with ['target': 'loginModalRoof2'] %}
                    </div>
                </div>
            {% endif %}
            <div class="row mt-5">
                <div class="col-12">
                    <h4 class="mb-0">
                        {{ indexHeader }}.Formas de Envío
                        {% set indexHeader = (indexHeader + 1) %}
                        <small class="display_none" id="label_fuera_peninsula">(Fuera de península)</small>
                    </h4>
                </div>
            </div>

            <hr class="mb-2">
            {# suponemos de momento juego loteria_nacional, habrá que hacer filtro con id game, cuando se reciba en el carrito #}
            {# siguiente versión debería ser, para todos los id_game encontrados en carrito, poner la sección correspondiente para selección de método de envío #}

            {% for gameId in gameIds %}
                <div class="d-block p-3 carrito_section my-3">
                    <div class="row">
                        <div class="col-12 col-md-5 carrito_header_text">
                            <img src="{{ games_info[gameId]['logo'] }}" height="39" width="39">
                            <span class="ml-2">{{ games_info[gameId]['name'] }}</span>
                        </div>
                        <div class="col-12 col-md-7 pt-2">
                            {% set autoSelectedGames = [] %}
                            {% set firstShipping = true %}
                            {% for shipping_method in shipping_methods %}
                                {# si el juego no es enviable mostrar metodos no enviables, si el juego es enviable se muestran todos #}
                                {% if (games_info[gameId]["is_shippable"] == "0" and shipping_method.is_shippable == 0) or (games_info[gameId]["is_shippable"] == "1") %}
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
                                                    {% if firstShipping %} checked="checked"{% endif %}
                                                    {% set firstShipping = false %}
                                                    {% set autoSelectedGames[autoSelectedGames | length] = gameId %}
                                                {% endif %}
                                            {% else %}
                                                data-shippable="0"
                                                {% if hoursToFirstNotShippable < shipping_method.hours_needed %}
                                                    disabled="disabled"
                                                {% else %}
                                                    {% if firstShipping %} checked="checked"{% endif %}
                                                    {% set firstShipping = false %}
                                                    {% set autoSelectedGames[autoSelectedGames | length] = gameId %}
                                                {% endif %}
                                            {% endif %}
                                            data-addressRequired="{{ is_null(shipping_method.is_address_required) ? 1 : shipping_method.is_address_required }}"
                                            value="{{ shipping_method.id }}"
                                            id="shipMethod_{{ shipping_method.id }}_game_{{ gameId }}"
                                            name="shipMethod_{{ gameId }}"
                                            onchange="checkChangedEnvio({{ gameId }})"
                                            type="radio"
                                            class="custom-control-input shipping_radio 
                                            {% if shipping_method.is_shippable == 1 %}
                                                radio-shippable radio-shippable_{{ shipping_method.id }}
                                            {% else %}
                                                radio-not-shippable radio-not-shippable_{{ shipping_method.id }}
                                            {% endif %}"
                                            required="">
                                        <label class="custom-control-label label-shipMethod_{{ shipping_method.id }}" for="shipMethod_{{ shipping_method.id }}_game_{{ gameId }}">
                                            <b>{{ shipping_method.name }}</b>: {{ shipping_method.price_in }} €
                                            {% if porcentaje != "" %}
                                                + {{ porcentaje }} % del envío sobre el importe
                                            {% endif %}
                                            {% if shipping_method.price_in != shipping_method.price_out %}
                                                ({{shipping_method.price_out}} €{% if porcentaje != "" %} + {{ porcentaje }} %{% endif %} fuera de la Península)
                                            {% endif %}
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
                        <h4 class="mb-0">{{ indexHeader }}. Datos de envío</h4>
                        {# en este no se incrementa el indexHeader porque por defecto viene oculto #}
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

            <div class="row mt-5 d-flex align-items-center">

                <div class="col-12 col-md-6">
                    <h4 class="mb-0" id="summary_title"> {{ indexHeader }}. Resumen de pedido</h4>
                    {% set indexHeader = (indexHeader + 1) %}
                </div>

                <div class="col-12 col-md-6 col-lg-5 d-flex justify-content-end">
                    <a href="{{ url('carrito?delete=all') }}" class="mt-1 btn btn-primary btn-login button_login">
                        Borrar todo&nbsp;&nbsp;<i class="fa-trash-o fa"></i>
                    </a>
                </div>
            </div>

            <hr class="mt-2 mb-3">

                {% set sorteos_ln_cargados = [] %}

                {# CARRITO PARA LOTERÍA NACIONAL #}
                {% for index, numeros in carrito_ws %}
                    {% if numeros["id_game"] == idLn %}
                        {# <!-- NO SE PUEDE MODIFICAR EL ARRAY CON LOS PRODUCTOS EN EL PARTIAL POR ESO SALEN REPETIDOS --> #}
                        {# <!-- {% include 'partial/carrito/resume_loteria_nacional' with ['carrito_ws': carrito_ws, 'numeros': numeros, 'sorteos_ln_cargados': sorteos_ln_cargados, 'gameInfo': games_info[idLn], 'index': index] %} --> #}
                        {% if array_search(numeros["id_draw"], sorteos_ln_cargados) === false %}
                            {% set sorteos_ln_cargados[sorteos_ln_cargados | length] = numeros["id_draw"] %}
                            <div class="col-12 d-block carrito_section p-3">
                                <div class="row carrito_pedido_header">
                                    <div class="col-12 col-lg-4 col-xl-3 carrito_header_info_data">
                                        <img src="{{games_info[idLn]['logo']}}" height="39" width="39">
                                        <span class="ml-2">{{games_info[idLn]['name']}}</span>
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
                                {% for i in index..(carrito_ws|length - 1) %}
                                    {% if array_key_exists("id_draw", numeros) and array_key_exists("id_draw", carrito_ws[i]) and numeros["id_draw"] == carrito_ws[i]["id_draw"] %}
                                        <div class="row mt-1">
                                            <div class="col-4 col-sm-3 carrito_header_info_data text-center">
                                                <span class="d-none d-sm-inline">N: </span>
                                                {{ carrito_ws[i]['number'] }}
                                            </div>
                                            <div class="col-4 col-sm-4 col-sm-3 col-xl-2">
                                                <span class="carrito_header_info_title d-none d-sm-inline">Cantidad: </span>
                                                <span class="carrito_line_main"> {{ intval(carrito_ws[i]['quantity']) }}</span>
                                            </div>
                                            <div class="col-auto col-sm-4 col-lg-4 col-xl-5">
                                                <span class="d-none d-sm-inline d-md-inline carrito_header_info_title">Importe:&nbsp;</span>
                                                <span class="carrito_line_main">{{ intval(carrito_ws[i]['quantity']) * intval(carrito_ws[i]['price_ticket']) }}€</span>
                                            </div>
                                            <div class="col-1 col-sm-1 col-lg-1 carrito_delete_container d-flex justify-content-center justify-content-lg-start">
                                                <a href="{{ url('carrito?delete=' ~ i) }}"><i class="fa fa-trash-o text-azul"></i></a>
                                            </div>
                                        </div>
                                    {% endif %}
                                {% endfor %}
                            </div>
                            <br>
                        {% endif %}

                    {% else %}
                        <div class="col-12 d-block carrito_section p-3">
                            <div class="row carrito_pedido_header">
                                <!-- RENDER NOT LOTERIA NACIONAL ITEM -->
                                <div class="col-12 col-lg-4 col-lg-3 carrito_header_info_data">
                                    <img src="{{ games_info[numeros['id_game']]['logo'] }}" height="39" width="39">
                                    <span class="ml-2">{{ games_info[numeros['id_game']]["name"] }}</span>
                                </div>
                                <div class="col-12 col-sm-8 col-md-7 col-lg-5">
                                    <span class="carrito_header_info_title">
                                        {% if numeros['numSorteos'] is defined and numeros['numSorteos'] > 1 %}
                                            Sorteos:&nbsp;
                                            {% set break_draws = 'block' %}
                                        {% else %}
                                            Sorteo:&nbsp;
                                            {% set break_draws = 'none' %}
                                        {% endif %}
                                    </span>
                                    <div class="w-100 d-{{break_draws}} d-lg-none"></div>
                                    <span class="carrito_line_main">
                                        {{ numeros['date_draw_ini'] | date_format('d-m-Y')}}
                                        {% if numeros['numSorteos'] is defined and numeros['numSorteos'] > 1 %}
                                            -&nbsp;{{ numeros['date_draw_last'] | date_format('d/m/Y') }}&nbsp;({{ numeros['numSorteos'] }})
                                        {% endif %}

                                        {% if numeros['is_subscription'] is defined and numeros['is_subscription'] == 1 %}
                                            &nbsp;(Abono{% if numeros['is_random'] is defined and numeros['is_random'] == 1 %} Aleatorio{% endif %}{% if numeros['is_jackpot'] is defined and numeros['is_jackpot'] == 1 and numeros['jackpot_min'] is defined %} Bote mínimo: {{ numeros['jackpot_min'] | number_int }}€{% endif %})
                                        {% endif %}
                                    </span>
                                </div>
                                <div class="col-10 col-sm-3 col-md-4 col-lg-2 justify-content-end justify-content-lg-start align-items-center">
                                    <span class="carrito_header_info_title">Importe:&nbsp;</span> <span class="carrito_line_main">{{ numeros['total'] | number_float }}€</span>
                                </div>
                                <div class="d-none col-12 col-md-4">
                                    <!-- Entrega estimada: -->
                                </div>
                                <div class="col-1 carrito_delete_container justify-content-center justify-content-lg-start">
                                    <a href="{{ url('carrito?delete=' ~ index) }}"><i class="fa fa-trash-o text-azul"></i></a>
                                </div>
                            </div>
                            <hr class="m-0">
                            {% for i in 0..(numeros["numbers"] | length) - 1 %}
                                <div class="row mt-1">
                                    <div class="col-12 col-md-9 offset-0 col-lg-9 offset-lg-1 carrito_header_info_data text-left">
                                        {% if games_info[numeros['id_game']]["id_type"] == 2 %}
                                            {# los juegos de tipo 2 pueden tener varios numeros en cada posicion #}
                                            {% include 'layouts/boxs/box_carrito_type_apuestas_numbers' with ['numeros': numeros, 'games_info': games_info, 'i': i] %}
                                            {# FIXME el loop.first es para saltarse la confusion con num_max_extras_per_slip #}
                                            {% if numeros["extras"] is defined and loop.first %}
                                                {% include 'layouts/boxs/box_carrito_type_apuestas_extras' with ['extras': numeros["extras"][i]] %}
                                            {% endif %}
                                        {% else %}
                                            {{ implode(' - ', numeros['numbers'][i]) }}
                                            {% if numeros["extras"] is defined and numeros["extras"][i] is defined %}
                                                <span>&nbsp;&nbsp;/&nbsp;&nbsp;</span>
                                                <span>
                                                    {% if numeros["extras"][i] is iterable %}
                                                        {% if numeros["extras"][i][0] is iterable %}
                                                            {% for extra in numeros["extras"][i] %}
                                                                {% if !loop.first %}
                                                                    &nbsp;-&nbsp;
                                                                {% endif %}
                                                                {{ implode(' ,', extra) }}
                                                            {% endfor %}
                                                        {% else %}
                                                            {{ implode(' - ', numeros["extras"][i]) }}
                                                        {% endif %}
                                                    {% else %}
                                                        {{ numeros["extras"][i] }}
                                                    {% endif %}
                                                </span>
                                            {% endif %}
                                        {% endif %}

                                        {# TODO falta refund, code_a y code_b por apuesta igual que los extras pero con icono si no se puede elegir #}
                                    </div>
                                </div>
                                <hr class="m-0">
                            {% endfor %}
                            {% if numeros["num_refund"] is defined and games_info[numeros['id_game']]["is_num_refund_per_slip"] %}
                                <div class="row mt-1">
                                    <div class="col-12 col-md-9 offset-0 col-lg-9 offset-lg-1 carrito_line_text text-left">
                                        <span class="carrito_header_info_title">Reintegro: </span>
                                        <span class="carrito_header_info_data">{{ numeros["num_refund"] }}</span>
                                    </div>
                                </div>
                            {% endif %}

                            {% if numeros["code_a"] is defined and games_info[numeros['id_game']]["is_code_a_per_slip"] %}
                                <div class="row mt-1 d-flex justify-content-center">
                                    <img style="width: 10em;" src="{{ url('img/code_a/' ~ numeros['id_game']) }}.svg" alt="{{ games_info[numeros['id_game']]['code_a_name'] }}">
                                </div>
                            {% endif %}

                            {% if numeros["code_b"] is defined and games_info[numeros['id_game']]["is_code_b_per_slip"] %}
                                <div class="row mt-1 d-flex justify-content-center">
                                    <img style="width: 10em;" src="{{ url('img/code_b/' ~ numeros['id_game']) }}.svg" alt="{{ games_info[numeros['id_game']]['code_b_name'] }}">
                                </div>
                            {% endif %}
                        </div>
                        <br>
                    {% endif %}
                {% endfor %}

                {% if user is defined %}
                    {% if !((user["phone"] or user["phone_2"] or user["mobile"] or user["mobile_2"]) and user["cif"]) %}
                        <div class="row mt-5">
                            <div class="col-12">
                                <h4 class="mb-0" id="moreData_Title">{{ indexHeader }}. Datos Requeridos</h4>
                                {% set indexHeader = (indexHeader + 1) %}
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
                    {% endif %}
                {% endif %}

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

                <div class="row w-100 px-2 mt-3 mb-5 d-flex justify-content-center align-items-center text-center customCheckBox">
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
                <div class="row d-flex justify-content-center">
                    <button class="btn btn-block carrito_button_finalizar" disabled id="carrito_button_finalizar" onclick="checkFinalizar()" type="button">
                        <span id="text-finalizar_pedido" style="display: inline;">Finalizar Pedido</span>
                        <span id="text-finalizar_pedido_procesando" style="display: none;">Procesando Pedido...</span>
                    </button>
                </div>
        </div>

        {% if web_seo_onpage['txt_down'] is not empty %}
            <div class="col-12 text-center text-justify">
                <div>{{ web_seo_onpage['txt_down'] }}</div>
            </div>
        {% endif %}
    </div>

</section>

<script>
    document.addEventListener("DOMContentLoaded", function(event) {
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

            if (newCartNeeded) {
                customAlert("Se han eliminado automáticamente las apuestas de fechas pasadas.");
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
            //console.log(userAddresses[address]);

            setPeninsula(!userAddresses[address]["province_out"])
        });
    });
</script>
<script type="text/javascript">
    var userAddresses = {{ json_encode(user_addresses) }};

    var gameIds = {{ json_encode(gameIds) }};

    var shippingMethods = {{ json_encode(shipping_methods) }};

    var userBalance = {{ false ? user_balance : '0.00' }};

    var showing_shipping_selector = false;

    var user_logged = {% if session.has('user') %}1{% else %}0{% endif %};

    var email_verified = {{session.get('user')["email_verified"]|default(0)}};

    var urlPanel = "{{ config.baseconfig.url_panel }}";

    var subTotal = {{ total }};

    var needUserAddressesReload = false;

    var peninsula = true;

    var autoSelectedGames = {{ json_encode(autoSelectedGames) }};

    var countries = {{ json_encode(locationInfo["countries"]) }};

    var provinces = {{ json_encode(locationInfo["provinces"]) }};

    var cities = {{ json_encode(locationInfo["cities"]) }};

    var hoursToFirstGame = {{ hoursToFirstGame != null ? hoursToFirstGame : 9999 }};

    var newCartNeeded = {{ newCartNeeded != null ? newCartNeeded : 0 }};


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
                if ($("#moreData_Title").length) {
                    $("#moreData_Title").html("4. Datos Requeridos");
                }
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

                console.log(moreData);

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
                url: "/createOrderWs",
                data: {
                    "ship": ship_shippable,
                    "not_ship": ship_not_shippable,
                    "address": address
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
