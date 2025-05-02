{% include 'layouts/boxs/box_css_game' with ['game': game_rules, 'pv': datosAdmon] %}
<style>
    .button_cambiar_multiple {
        border: 1px solid {% if datosAdmon.css.number_raffle_bg_color is defined %}{{datosAdmon.css.number_raffle_bg_color}}{% else %}{{game_rules.number_bg_color}}{% endif %};
    }

    .button_es_multiple {
        background-color: {% if datosAdmon.css.number_raffle_bg_color is defined %}{{datosAdmon.css.number_raffle_bg_color}}{% else %}{{game_rules.number_bg_color}}{% endif %};
        color: {% if datosAdmon.css.number_raffle_fg_color %}{{datosAdmon.css.number_raffle_fg_color}}{% else %}{{game_rules.number_fg_color}}{% endif %};
    }

    /* .parent {
        display: flex;
        flex-direction: row;
        flex-wrap: wrap;
        align-content: center;
        gap: 2px;
    }

    .child {
        flex: 1;
        flex-basis: 20%;
    } */
</style>
<div class="col-12 col-md-12 type-1">
    <div class="row mt-3 mb-3">
        <div class="offset-lg-1 col-lg-5 offset-md-1 col-md-11 col-sm-12">
            <img class="float-left mx-3" src="{{ game_rules.logo }}" height="60">
            <h1 class="title-games">{{ web_seo_onpage['h1'] }}</h1>
        </div>
        <div class="col-lg-4 col-sm-12 text-right">
            {% if next_jackpot.jackpot is defined %}
            <span class="span_bote_comprobador">BOTE {{ next_jackpot.jackpot | number_int }} €</span>
            {% endif %}
            <div class="span_cuenta_atras_comprobador" id="countdown"></div>
        </div>
        {% if web_seo_onpage['txt_up'] is not empty %}
            <div class="col-12 text-center text-justify">
                <div>{{ web_seo_onpage['txt_up'] }}</div>
            </div>
        {% endif %}
    </div>
    <div class="row">
        <div class="col-12 mt-sm-2">
            <!-- INICIO SECCION ESTANDAR -->
            <div class="row d-md-flex">
                <div class="hidden-xs col-md-1"><span class="anchor" id="comprarBoletos"></span></div>
                <div id="contenedorApuestas" class="col-12 col-md-10 contenedor_apuestas">
                    {% for i in 0..(num_preloaded_bets - 1) %}
                        <div class="style_tabla_comprar_euromillones {% if !loop.first %}disabled_tabla hidden_responsive" style="opacity: 0.3 {% endif %}" id="apuesta_{{i}}" style="scroll-snap-align: center;">
                            <div class="container_tabla_header" style="text-align: center">
                                <span style="cursor: pointer" onclick="aleatorioBoleto('{{i}}')" class="pull-left actionIcon text-azul">
                                    <i class="fa fa-random"></i>
                                </span>
                                <button onclick="prevApuestaResponsive()" style="width:12%; height:100%; font-size:10px" class="btn button_boleto_cambiar_apuesta_button_responsive p-0 d-sm-none">&lt;&lt;</button>
                                <span id="apuesta_{{i}}_title">Apuesta {{i+1}}</span>
                                <button onclick="nextApuestaResponsive()" style="width:12%; height:100%; font-size:10px" class="btn button_boleto_cambiar_apuesta_button_responsive p-0 d-sm-none">&gt;&gt;</button>
                                <span style="cursor: pointer" onclick="borrarBoleto('{{i}}')" class="pull-right actionIcon text-azul">
                                    <i class="fa fa-trash"></i>
                                </span>
                            </div>
                            <div class="container_tabla_euromillones_vertical pb-2" style="margin-top: 10px;">
                                <h5 id="apuesta_{{i}}_numInfo" class="text-center comprador_tabla_euromillones">Escoge {{ game_rules.num_number_per_bet }} números</h5>
                                <div id="container_boleto_{{i}}_numeros" class="number_container">
                                    {% if game_rules.is_custom_values_per_number %}
                                        {% for index, num in game_rules.custom_values_per_number %}
                                            <div id="apuesta_{{i}}_numero_{{num}}" class="number_box fa-stack">
                                                <i class="fa-stack-2x item_figure fa fa-square"></i>
                                                <span class="fa-stack-1x item_text">
                                                    {{num}}
                                                </span>
                                            </div>
                                            {% if (index + 1) % 5 == 0 and index != 0 %}
                                                <div class="w-100"></div>
                                            {% endif %}
                                        {% endfor %}
                                    {% else %}
                                        {% for index, num in game_rules.min_value_per_number..game_rules.max_value_per_number %}
                                            <div id="apuesta_{{i}}_numero_{{str_pad(num, (game_rules.max_value_per_number | length), '0', constant('STR_PAD_LEFT'))}}" class="number_box fa-stack">
                                                <i class="fa-stack-2x item_figure fa fa-square"></i>
                                                <span class="fa-stack-1x item_text">
                                                    {{str_pad(num, (game_rules.max_value_per_number|length), '0', constant('STR_PAD_LEFT'))}}
                                                </span>
                                            </div>
                                            {% if (index + 1) % 5 == 0 and index != 0 %}
                                                <div class="w-100"></div>
                                            {% endif %}
                                        {% endfor %}
                                    {% endif %}
                                </div>

                                {% if game_rules.is_num_refund and game_rules.is_num_refund_selectable %}
                                    <h5 class="text-center comprador_tabla_euromillones">Reintegro</h5>
                                    <div id="container_boleto_{{i}}_refund" class="comprador_container_numeros_tabla_euromillones refund_container">
                                        {% for index, num in game_rules.num_refund_min..game_rules.num_refund_max %}
                                            <div id="apuesta_{{i}}_refund_{{num}}" class="refund_box fa-stack">
                                                <i class="fa-stack-2x item_figure fa fa-square"></i>
                                                <span class="fa-stack-1x item_text">
                                                    {{num}}
                                                </span>
                                            </div>
                                            {% if (index + 1) % 5 == 0 and index != 0 %}
                                                <div class="w-100"></div>
                                            {% endif %}
                                        {% endfor %}
                                    </div>
                                {% endif %}
                            </div>

                            {% if game_rules.num_max_extras_per_slip %}
                                <div class="container_tabla_euromillones_estrellas">
                                    <h5 id="apuesta_{{i}}_extraInfo" class="text-center comprador_tabla_euromillones">Escoge {{ game_rules.num_extra_per_bet }} {{ game_rules.extra_name }}</h5>
                                    <div id="container_boleto_{{i}}_extras" class="comprador_container_numeros_tabla_euromillones extra_container">
                                        {% if game_rules.is_custom_values_per_number %}
                                            {% for index, num in game_rules.custom_values_per_number %}
                                                <div id="apuesta_{{i}}_extra_{{num}}" class="extra_box fa-stack fa-lg">
                                                    <i class="fa-stack-2x item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }}"></i>
                                                    <span class="fa-stack-1x item_text">
                                                        {{num}}
                                                    </span>
                                                </div>
                                                {% if (index + 1) % 4 == 0 and index != 0 %}
                                                    <div class="w-100"></div>
                                                {% endif %}
                                            {% endfor %}
                                        {% else %}
                                            {% for index, num in game_rules.min_value_per_extra..game_rules.max_value_per_extra %}
                                                <div id="apuesta_{{i}}_extra_{{str_pad(num, (game_rules.max_value_per_extra|length), '0', constant('STR_PAD_LEFT'))}}" class="extra_box fa-stack fa-lg">
                                                    <i class="fa-stack-2x item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }}"></i>
                                                    <span class="fa-stack-1x item_text">
                                                        {{str_pad(num, (game_rules.max_value_per_extra|length), '0', constant('STR_PAD_LEFT'))}}
                                                    </span>
                                                </div>
                                                {% if (index + 1) % 4 == 0 and index != 0 %}
                                                    <div class="w-100"></div>
                                                {% endif %}
                                            {% endfor %}
                                        {% endif %}
                                    </div>
                                </div>
                            {% endif %}

                            {# TODO falta por hacer si el code_a y b se puede elegir (actualmente no hay ningun caso para los de tipo 1) #}
                            {% if game_rules.is_code_a and game_rules.is_code_a_optional and !game_rules.is_code_a_selectable and !game_rules.is_code_a_per_slip %}
                                {# si tiene code_a es opcional y no se puede elegir se pone un check, no eliges valores pero eliges si juegas o no #}
                                <h5 class="text-center comprador_tabla_euromillones">{{game_rules.code_a_name}}</h5>
                                <div id="container_boleto_{{i}}_code_a" class="{% if game_rules.is_code_a_optional %}selectable{% endif %} comprador_container_numeros_tabla_euromillones code_a_container">
                                    <div id="apuesta_{{i}}_code_a" class="code_a_box">
                                        <img class="item_figure" src="img/code_a/{{game_id}}.svg" alt="{{game_rules.code_a_name}}">
                                    </div>
                                </div>
                            {% endif %}

                            {% if game_rules.is_code_b and game_rules.is_code_b_optional and !game_rules.is_code_b_selectable and !game_rules.is_code_a_per_slip %}
                                {# si tiene code_b es opcional y no se puede elegir se pone un check, no eliges valores pero eliges si juegas o no #}
                                <h5 class="text-center comprador_tabla_euromillones">{{game_rules.code_b_name}}</h5>
                                <div id="container_boleto_{{i}}_code_b" class="{% if game_rules.is_code_b_optional %}selectable{% endif %} comprador_container_numeros_tabla_euromillones code_b_container">
                                    <div id="apuesta_{{i}}_code_b" class="code_b_box">
                                        <img class="item_figure" src="img/code_b/{{game_id}}.svg" alt="{{game_rules.code_b_name}}">
                                    </div>
                                </div>
                            {% endif %}

                            <div class="w-100">
                                <button id="apuesta_{{i}}_btn_cambiar_multiple" class="btn button_cambiar_multiple">Sencilla</button>
                            </div>
                        </div>
                    {% endfor %}
                </div>
                <div class="hidden-xs col-md-1"></div>
            </div>
            <!-- FIN SECCION ESTANDAR -->
            <div class="row mx-0 mt-2">
                {% include 'partial/buy/select_weeks.volt' %}
            </div>
            <div class="row mx-0 mt-1">
                {% include 'partial/buy/select_days.volt' %}

                {% set show_code_a_per_slip = (game_rules.is_code_a and game_rules.is_code_a_optional and !game_rules.is_code_a_selectable and game_rules.is_code_a_per_slip) %}
                {% set show_code_b_per_slip = (game_rules.is_code_b and game_rules.is_code_b_optional and !game_rules.is_code_b_selectable and game_rules.is_code_b_per_slip) %}

                {% if show_code_a_per_slip or show_code_b_per_slip %}
                    <div class="col-12 col-xl-1 offset-md-1 offset-xl-0">
                        <div class="row">
                            {% if show_code_a_per_slip %}
                                {# si tiene code_a es opcional y no se puede elegir se pone un check, no eliges valores pero eliges si juegas o no #}
                                <div class="col-6 col-sm-auto code_a_box p-2" id="code_a">
                                    {# <!-- <input style="vertical-align: middle;" type="checkbox" value="1" name="code_a" id="code_a"> --> #}
                                    <img style="width: 10em; max-height: 5em;" src="img/code_a/{{game_id}}.svg" alt="{{game_rules.code_a_name}}" id="code_a_img">
                                </div>
                            {% endif %}
                            {% if show_code_b_per_slip %}
                                <div class="col-6 col-sm-auto code_b_box p-2" id="code_b">
                                    {# <!-- <input style="vertical-align: middle;" type="checkbox" value="1" name="code_b" id="code_b"> --> #}
                                    <img style="width: 10em; max-height: 5em;" src="img/code_b/{{game_id}}.svg" alt="{{game_rules.code_b_name}}" id="code_b_img">
                                </div>
                            {% endif %}                            
                        </div>
                    </div>
                {% endif %}
            </div>
            <div class="row" style="margin-top: 15px">

                <div class="col-md-10 offset-md-1">
                    <div class="div_containter_resumen_boleto">
                        <div class="row align_items_resumen_boleto">
                            <div class="col-xl-2 col-sm-6 text-left">
                                <span class="style_label_resumen">APUESTAS: <span id="num_apuestas" class="style_num_apuestas">0</span></span>
                            </div>
                            {% include 'layouts/boxs/box_buy_slips_info.volt' %}
                            <div class="col-xl-2 col-sm-6 text-left">
                                <span class="style_label_resumen">SORTEOS: <span id="total_sorteos" class="style_num_apuestas">0</span></span>
                            </div>
                            <div class="col-xl-2 col-sm-6 text-left">
                                <span class="style_label_resumen">TOTAL: <span id="total_price">0.00</span>€</span>
                            </div>
                            {% if config.datosadmon.data.is_subscription and game_rules.is_subscribable %}
                                <div class="col-xl-2">
                                    <div class="btn-group">
                                        <button type="button" class="btn btn-secondary" id="enable_subscription_button">Abonarme</button>
                                        <button type="button" class="btn btn-secondary dropdown-toggle-split" disabled="disabled" data-toggle="modal" data-target="#modal_abono" aria-haspopup="true" aria-expanded="false" id="subscription_config_button">
                                            <span class="text-white"><i class="fa fa-cog" aria-hidden="true"></i></span>
                                        </button>
                                    </div>
                                    <div class="modal fade" id="modal_abono" tabindex="-1" role="dialog" aria-labelledby="modal_abono" aria-hidden="true">
                                        <div class="modal-dialog modal-dialog-centered modal-sm" role="document">
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <h5 style="color:black;" class="modal-title" id="exampleModalLongTitle">Preferencias del Abono</h5>
                                                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                        <span aria-hidden="true">&times;</span>
                                                    </button>
                                                </div>
                                                <div class="modal-body">
                                                    <div class="row" id="is_randomable_box">
                                                        {% if game_rules.is_randomable %}
                                                            <div class="col-12">
                                                                <div class="form-check customCheckBox" style="line-height: 1.5em;">
                                                                    <input class="form-check-input" type="checkbox" name="is_randomable" id="is_randomable">
                                                                    <label class="form-check-label" for="is_randomable">
                                                                        Apuestas aleatorias para cada semana
                                                                    </label>
                                                                </div>
                                                            </div>
                                                        {% endif %}
                                                        <div class="col-12 mt-3">
                                                            <label for="jackpot_min">Bote mínimo para apuesta abonada: </label>
                                                            <div class="input-group mb-3" style="max-width: 15rem;">
                                                                <input type="text" class="form-control text-right hide-placeholder" name="jackpot_min" id="jackpot_min" placeholder="{{ next_jackpot.jackpot | number_int}}" aria-describedby="jackpot_min_currency">
                                                                <span class="input-group-text" id="jackpot_min_currency">€</span>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            {% endif %}
                            <div class="col-xl-2 text_align mt-3 mt-sm-0">
                                <button id="button_validarApuesta" onclick="validarApuesta()" disabled class="btn button_comprar_añadir_al_carrito"><i class="fa-shopping-cart fa"></i>&nbsp;&nbsp;Añadir</button>
                            </div>
                        </div>
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
</div>
<script type="text/javascript">
document.addEventListener("DOMContentLoaded", function(event) {

    //cuando cargue la página, ocultar las apuestas que queden fuera del contenedor
    $(document).ready(function() {
        apuestas = document.getElementsByClassName("disabled_tabla");
        contenedor_apuestas = document.getElementsByClassName("contenedor_apuestas");
        ocultarSobrantes();
        $(".div_day_semana").click();
        showRemaining(
            "{{ close_date }}",
            'countdown',
            true,
            null,
            true
        )
    });

    var resizeTimeout;

    $(window).resize(function() {
        if (!!resizeTimeout) {
            clearTimeout(resizeTimeout);
        }
        resizeTimeout = setTimeout(function() {
            ocultarSobrantes();
        }, 200);
    });

    {% if game_rules.is_code_a and game_rules.is_code_a_optional and !game_rules.is_code_a_selectable %}
        $('.code_a_box').on("click", event => {
            $(event.currentTarget).toggleClass("selected")
            if (gameRules.is_code_a_per_slip) {
                if ($(event.currentTarget).hasClass("selected")) {
                    // $('#code_a').prop('checked', true)
                    boletos.forEach(e => e.code_a = {"buy": true})
                } else {
                    // $('#code_a').prop('checked', false)
                    boletos.forEach(e => e.code_a = {"buy": false})
                }
            } else {
                boletos[event.currentTarget.id.split('_')[1]]["code_a"] = $(event.currentTarget).hasClass("selected")
            }
            comprobarPrecio()
        })
    {% endif %}

    {% if game_rules.is_code_b and game_rules.is_code_b_optional and !game_rules.is_code_b_selectable %}
        $('.code_b_box').on("click", event => {
            $(event.currentTarget).toggleClass("selected")
            if (gameRules.is_code_b_per_slip) {
                if ($(event.currentTarget).hasClass("selected")) {
                    // $('#code_b').prop('checked', true)
                    boletos.forEach(e => e.code_b = {"buy": true})
                } else {
                    // $('#code_b').prop('checked', false)
                    boletos.forEach(e => e.code_b = {"buy": false})
                }
            } else {
                boletos[event.currentTarget.id.split('_')[1]]["code_b"] = $(event.currentTarget).hasClass("selected")
            }
            comprobarPrecio()
        })
    {% endif %}

    {% if config.datosadmon.data.is_subscription and game_rules.is_subscribable %}
        $("#enable_subscription_button").on("click", event => {
            if ($("#enable_subscription_button").hasClass("btn-secondary")) {
                $("#modal_abono").modal("show")
                $("#subscription_config_button").removeAttr("disabled")
                $("#abono_semanas_button").data("sems", "X")
            } else {
                $("#subscription_config_button").attr("disabled", "disabled")
                $("#abono_semanas_button").data("sems", 1)
            }

            $("#enable_subscription_button").toggleClass("btn-secondary")
            $("#enable_subscription_button").toggleClass("btn-success")

            $("#subscription_config_button").toggleClass("btn-secondary")
            $("#subscription_config_button").toggleClass("btn-success")
        })
    {% endif %}

    $(document.body).on('click', '.div_day_semana', function(event) {

        event.preventDefault();

        if ($(this).hasClass('pointer_a')) {
            if ($(this).hasClass('selected_day')) {
                $(this).removeClass('selected_day');
                $(this).addClass('disabled_day');
                dayNames.forEach(day => {
                    if ($("#" + removeAccents(day)).hasClass('pointer_a')) {
                        if ($("#" + removeAccents(day)).hasClass('selected_day')) {
                            $("#" + removeAccents(day)).removeClass('selected_day');
                            $("#" + removeAccents(day)).addClass('disabled_day');
                        }
                    }
                })
            } else if ($(this).hasClass('disabled_day')) {
                $(this).addClass('selected_day');
                $(this).removeClass('disabled_day');
                dayNames.forEach(day => {
                    if ($("#" + removeAccents(day)).hasClass('pointer_a')) {
                        if ($("#" + removeAccents(day)).hasClass('disabled_day')) {
                            $("#" + removeAccents(day)).addClass('selected_day');
                            $("#" + removeAccents(day)).removeClass('disabled_day');
                        }
                    }
                })
            }
        }

        comprobarPrecio();

    });

    //EVENTO CLICK EN NUMERO
    $(document.body).on('click', '.number_box', function(event) {
        event.preventDefault();
        let id = $(this).attr('id');
        let bet = Number(id.split('_')[1])
        let number = id.split('_')[3]

        //AÑADIR NUMERO
        if (!$(this).hasClass('selected')) {
            //CHECKEAR SI EL BOLETO ESTA HABILITADO O YA TIENE EL MÁXIMO DE NÚMEROS
            if ($("#apuesta_" + bet).hasClass('disabled_tabla')) {
                customAlert("Debes rellenar primero el boleto anterior");
                return;
            }

            //TODO no comprobar el num_number_per_bet sino que el resultado este en gameRules.multiples o no (en bonoloto y primitiva hay un multiple con 5 numeros)
            if (boletos[bet]["numeros"].length == gameRules.num_number_per_bet && boletos[bet]["tipo"] == "simple") {
                cambiarMultiple(bet);
            } else if (boletos[bet]["numeros"].length == "{{ default_max_number_per_bet }}") {
                customAlert("No puedes seleccionar más de {{ default_max_number_per_bet }} números por apuesta");
                return;
            }

            boletos[bet]["numeros"].push(number);

            //DESMARCAR NUMERO
            $(this).addClass('selected');
        } else {
            //MARCAR NUMERO
            $(this).removeClass('selected');

            //se quita el numero del array
            var index = boletos[bet]["numeros"].indexOf(number);
            if (index !== -1) {
                boletos[bet]["numeros"].splice(index, 1);
            }

            if (boletos[bet]["numeros"].length <= gameRules.num_number_per_bet && boletos[bet]["tipo"] == "multiple") {
                cambiarMultiple(bet);
            }
        }
        comprobarCompleto(id);
        comprobarPrecio();
    });

    //evento click extras
    $(document.body).on('click', '.extra_box', function(event) {
        event.preventDefault();
        let id = $(this).attr('id');
        let bet = Number(id.split('_')[1])
        let number = String(id.split('_')[3])

        if (!$(this).hasClass('selected')) {
            //CHECKEAR SI EL BOLETO ESTA HABILITADO O YA TIENE EL MÁXIMO DE NÚMEROS
            if ($("#apuesta_" + bet).hasClass('disabled_tabla')) {
                customAlert("Debes rellenar primero el boleto anterior");
                return;
            }

            if (gameRules.is_link_num_refund_extra) {
                // Los extras de GP se comportan como si fuera un reintegro
                boletos[bet]["extras"] = [number]

                //deseleccionar otros
                $(`[id^="apuesta_${bet}_extra_"].selected`).removeClass('selected')

                $(this).addClass('selected');
                comprobarCompleto(id);
                comprobarPrecio();
                return
            }

            if (boletos[bet]["extras"].length == "{{ default_max_extra_per_bet }}") {
                customAlert("No puedes seleccionar más de {{ default_max_extra_per_bet }} " + gameRules.extra_name + " por apuesta");
                return;
            }

            if (boletos[bet]["extras"].length == gameRules.num_extra_per_bet && boletos[bet]["tipo"] == "simple") {
                cambiarMultiple(bet);
            }

            boletos[bet]["extras"].push(number);

            //MARCAR ESTRELLA
            $(this).addClass('selected');
        } else {
            $(this).removeClass('selected');

            var index = boletos[bet]["extras"].indexOf(number);
            if (index !== -1) {
                boletos[bet]["extras"].splice(index, 1);
            }

            if (boletos[bet]["extras"].length <= gameRules.num_extra_per_bet && boletos[bet]["tipo"] == "multiple") {
                cambiarMultiple(bet);
            }
        }

        comprobarCompleto(id);
        comprobarPrecio();
    });

    //EVENTO CLICK EN NUMERO DE REINTEGRO
    $(document.body).on('click', '.refund_box', function(event) {
        event.preventDefault();
        let id = $(this).attr('id');
        let bet = Number(id.split('_')[1])
        let refund = String(id.split('_')[3])

        //AÑADIR REINTEGRO
        if (!$(this).hasClass('selected')) {
            if ($("#apuesta_" + bet).hasClass('disabled_tabla')) {
                customAlert("Debes rellenar primero el boleto anterior");
                return;
            }

            boletos[bet]["refund"] = refund

            //deseleccionar otros
            $('#container_boleto_' + bet + '_refund').find('.selected').removeClass('selected')

            //MARCAR NUMERO
            $(this).addClass('selected');
        }
        comprobarCompleto(bet);
        comprobarPrecio();
    });
});



    function pintarBoleto(bet, boleto) {
        bet = Number(bet)

        boleto["numeros"].forEach(number => {
            $("#apuesta_" + bet + "_numero_" + number).addClass('selected');
        })

        if (boleto["refund"]) {
            $("#apuesta_" + bet + "_refund_" + boleto["refund"]).addClass('selected')
        }

        if (boleto["extras"]) {
            boleto["extras"].forEach(extra => {
                $("#apuesta_" + bet + "_extra_" + extra).addClass('selected')
            })
        }

        //comprobación múltiple/simple
        if (boleto.tipo == "simple") {
            $("#apuesta_" + bet + "_title").html("Apuesta " + (bet + 1));
            $("#apuesta_" + bet + "_btn_cambiar_multiple").removeClass("button_es_multiple");
            $("#apuesta_" + bet + "_btn_cambiar_multiple").html("Sencilla");
            $("#apuesta_" + bet + "_numInfo").html(`Escoge ${gameRules.num_number_per_bet} ${gameRules.number_name}`);
            if (gameRules.num_max_extras_per_slip) {
                $("#apuesta_" + bet + "_extraInfo").html(`Escoge ${gameRules.num_extra_per_bet} ${gameRules.extra_name}`);
            }
        } else {
            $("#apuesta_" + bet + "_title").html("Apuesta " + (bet + 1) + " Múltiple");
            $("#apuesta_" + bet + "_btn_cambiar_multiple").addClass("button_es_multiple");
            $("#apuesta_" + bet + "_btn_cambiar_multiple").html("Múltiple");
            if (gameRules.num_max_extras_per_slip) {
                $("#apuesta_" + bet + "_numInfo").html(`Escoge ${gameRules.num_number_per_bet}-{{ default_max_number_per_bet }} ${gameRules.number_name}`);
                $("#apuesta_" + bet + "_extraInfo").html(`Escoge ${gameRules.num_extra_per_bet}-{{ default_max_extra_per_bet }} ${gameRules.extra_name}`);
            } else {
                $("#apuesta_" + bet + "_numInfo").html(`Escoge ${gameRules.num_number_per_bet + 1}-{{ default_max_number_per_bet }} ${gameRules.number_name}`);
            }
        }

        comprobarPrecio();
    }

    function validarApuesta() {
        let numerosCarrito = [];

        let lineasPedido = [];
        let minBetsPerSlip = Math.ceil(gameRules.min_import_per_slip / gameRules.price)

        // Calcular la fecha del primer sorteo
        let selectedWeek = parseFloat($('#semana_label').text());
        let selectedYear = parseFloat($('#semana_label').data('year'));

        // Control de días marcados
        let numSorteos = $('.div_day.selected_day').length
        let numWeekSelected = $('.div_day.selected_day').first().data("index")
        let lastDay = $('.div_day.selected_day').last().data("index")

        let dat = getDateOfISOWeek(selectedWeek, selectedYear);
        dat.setDate(dat.getDate() + numWeekSelected);
        let formattedDate = dateToYMD(dat)

        let lastDate = null;
        if (numSorteos > 0) {
            let last_dat = new Date(dat.valueOf());
            last_dat.setDate(last_dat.getDate() + lastDay - numWeekSelected);
            lastDate = dateToYMD(last_dat)
        }

        let is_week = 0;

        if ($("#semana").hasClass("selected_day")) {
            is_week = 1;
        }

        let total = deFormatNumber($("#total_price").html());

        if (total <= 0) {
            customAlert("Boleto incompleto");
            return;
        }

        if (numWeekSelected == null) {
            customAlert("Seleccione semana");
            return;
        }

        if (total < gameRules.min_import_per_slip) {
            //si no hay otras apuestas en el carrito para poder agruparlar se corta
            customAlert(`Deben rellenarse mínimo ${minBetsPerSlip} apuestas`);
            return;
        }

        boletos.filter(b => b["completo"]).forEach(item => {
            let nuevaLinea = {
                "numeros": item.numeros,
                "tipo": item.tipo,
            }

            if (item.extras) {
                nuevaLinea.extras = item.extras;
            }

            if (item.refund) {
                nuevaLinea.refund = item.refund;
            }

            if (item.code_a) {
                nuevaLinea.code_a = item.code_a;
            }

            if (item.code_b) {
                nuevaLinea.code_b = item.code_b;
            }

            lineasPedido.push(nuevaLinea);
        })

        let objectCarrito = {
            "date": formattedDate,
            "lastDate": lastDate,
            "numSorteos": numSorteos,
            "lineasPedido": lineasPedido,
            "week": is_week,
            "is_subscription": 0,
            "id_game": gameRules.id,
        };

        if ($("#enable_subscription_button").length && $("#enable_subscription_button").hasClass("btn-success")) {
            objectCarrito.is_subscription = 1

            if ($("#is_randomable").length) {
                objectCarrito.is_random = Number($("#is_randomable")[0].checked)
            }

            if ($('#jackpot_min').val()) {
                objectCarrito.is_jackpot = 1
                objectCarrito.jackpot_min = deFormatNumber($('#jackpot_min').val())
            } else {
                objectCarrito.is_jackpot = 0
            }
        }

        let objectsCarrito = {
            "bloquesSemanales": []
        };
        objectsCarrito["bloquesSemanales"].push(objectCarrito);

        /* SECCION ABONO */

        //check semanas
        let sems = $("#abono_semanas_button").data('sems');

        if (sems != "X" && sems > 1) {
            //TODO esto ya no se usa porque se han quitado lo de 2, 3, 4 semanas
            let tempObjectCarrito = null;

            for (var i = 0; i < sems - 1; i++) {
                tempObjectCarrito = structuredClone(objectCarrito);

                let firstWeekPlayDay = parseInt(gameRules.id_days[0]) - 1;
                let lastWeekPlayDay = parseInt(gameRules.id_days[gameRules.id_days.length - 1]) - 1;

                if (is_week && i == 0) {
                    dat.setDate(dat.getDate() - numWeekSelected + firstWeekPlayDay + 7 * (i + 1));
                } else {
                    dat.setDate(dat.getDate() + 7);
                }

                formattedDate = dateToYMD(dat)

                lastDate = null;
                if (numSorteos > 0) {
                    last_dat = new Date(dat.valueOf());
                    if (is_week) {
                        last_dat.setDate(last_dat.getDate() + lastDay - firstWeekPlayDay);
                    } else {
                        last_dat.setDate(last_dat.getDate() + lastDay - numWeekSelected);
                    }
                    lastDate = dateToYMD(last_dat)
                }

                let lineasActualizadas = tempObjectCarrito.lineasPedido;
                if (is_week) {
                    //TODO si es para toda la semana varias semanas no se tiene en cuenta festivos
                    lineasActualizadas = JSON.parse(JSON.stringify(tempObjectCarrito.lineasPedido));

                    lineasActualizadas.forEach(linea => {
                        linea.precio = linea.precio / numSorteos * gameRules.id_days.length;
                    });
                } else if (PV_CALENDAR[formattedDate]) {
                    //si el dia elegido es festivo en una semana siguiente no se incluye
                    customAlert("El día " + formattedDate + " no se incluye por festivo: " + PV_CALENDAR[formattedDate])
                    continue
                }

                objectsCarrito["bloquesSemanales"].push({
                    "date": formattedDate,
                    "lastDate": lastDate,
                    "numSorteos": tempObjectCarrito.numSorteos,
                    "lineasPedido": lineasActualizadas,
                    "week": tempObjectCarrito.week,
                    "is_subscription": 0,
                    // "numeros": tempObjectCarrito.numeros,
                    // "extras": tempObjectCarrito.extras,
                    // "total": tempObjectCarrito.total
                });
            }
        }

        /* FIN SECCION ABONO */

        $.ajax({
            type: "POST",
            url: "save-cart-type-lotto",
            data: objectsCarrito,

            success: function(resData) {
                $('#continueBuyingModal').modal('show');
            },
            error: function(e) {
                customAlert("Error al guardar el boleto");
            }
        });
    }

    function cambiarMultiple(bet) {
        if (boletos[bet]["tipo"] == "simple") {
            boletos[bet]["tipo"] = "multiple";
            $("#apuesta_" + bet + "_title").html("Apuesta " + (bet + 1) + " Múltiple");
            $("#apuesta_" + bet + "_btn_cambiar_multiple").addClass("button_es_multiple");
            $("#apuesta_" + bet + "_btn_cambiar_multiple").html("Múltiple");
            if (gameRules.num_max_extras_per_slip) {
                $("#apuesta_" + bet + "_numInfo").html(`Escoge ${gameRules.num_number_per_bet}-{{ default_max_number_per_bet }} ${gameRules.number_name}`);
                $("#apuesta_" + bet + "_extraInfo").html(`Escoge ${gameRules.num_extra_per_bet}-{{ default_max_extra_per_bet }} ${gameRules.extra_name}`);
            } else {
                $("#apuesta_" + bet + "_numInfo").html(`Escoge ${gameRules.num_number_per_bet + 1}-{{ default_max_number_per_bet }} ${gameRules.number_name}`);
            }
        } else {
            boletos[bet]["tipo"] = "simple";
            // borrarBoleto(apuesta);
            $("#apuesta_" + bet + "_title").html("Apuesta " + (bet + 1));
            $("#apuesta_" + bet + "_btn_cambiar_multiple").removeClass("button_es_multiple");
            $("#apuesta_" + bet + "_btn_cambiar_multiple").html("Sencilla");
            $("#apuesta_" + bet + "_numInfo").html(`Escoge ${gameRules.num_number_per_bet} ${gameRules.number_name}`);
            if (gameRules.num_max_extras_per_slip) {
                $("#apuesta_" + bet + "_extraInfo").html(`Escoge ${gameRules.num_extra_per_bet} ${gameRules.extra_name}`);
            }
        }
        comprobarCompleto(bet)
    }
</script>
