{% include 'layouts/boxs/box_css_game' with ['game': game_rules, 'pv': datosAdmon] %}
<style>
    .button_cambiar_multiple {
        border: 1px solid {% if datosAdmon.css.number_raffle_bg_color is defined %}{{datosAdmon.css.number_raffle_bg_color}}{% else %}{{game_rules.number_bg_color}}{% endif %};
    }

    .button_es_multiple {
        background-color: {% if datosAdmon.css.number_raffle_bg_color is defined %}{{datosAdmon.css.number_raffle_bg_color}}{% else %}{{game_rules.number_bg_color}}{% endif %};
        color: {% if datosAdmon.css.number_raffle_fg_color %}{{datosAdmon.css.number_raffle_fg_color}}{% else %}{{game_rules.number_fg_color}}{% endif %};
    }

    .match_block {
        height: 2.5rem;
    }

    .section-buy .extra_container {
        justify-content: center;
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
<div class="col-12 col-md-12 type-2">
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
{% if first_play is not defined %}
    <div class="row">
        <div class="col-12 d-flex align-items-center justify-content-center py-4">
            <h5 class="text-buscador-numeros m-0">Aún no hay información disponible sobre la próxima jornada</h5>
        </div>
    </div>

    {% if web_seo_onpage['txt_down'] is not empty %}
        <div class="row">
            <div class="col-12 text-center text-justify">
                <div>{{ web_seo_onpage['txt_down'] }}</div>
            </div>
        </div>
    {% endif %}
</div>
{# si no hay jornadas el resto de la pagina no hace falta #}
<?php return; ?>
{% endif %}
    <div class="row">
        <div class="col-12 mt-2">
            <!-- INICIO SECCION ESTANDAR -->
            <div class="row d-md-flex">
                <!-- EQUIPOS -->
                <div class="hidden-xs col-md-3 col-xl-2 text-center">
                    <div class="d-none d-md-block">
                        {% if game_rules.is_code_a %}
                            <div class="code_a_box">
                                <img class="item_figure" src="img/code_a/{{game_id}}.svg" alt="{{game_rules.code_a_name}}">
                            </div>
                        {% else %}
                            <div class="code_a_box"></div>
                        {% endif %}

                        {% for partido in first_play %}
                            {% if loop.last and game_rules.num_max_extras_per_slip %}
                                {% set teams = explode("-", partido["name"]) %}
                                <p>{{game_rules.extra_name}}</p>
                                {% for k, team in teams %}
                                    <div class="row match_block">
                                        <div class="col-12">
                                            <span class='quiniela_match_name px-4' id='match_{{partido["num_match"]}}'>
                                                {{ trim(team) }}
                                            </span>
                                        </div>
                                    </div>
                                {% endfor %}
                            {% else %}
                                <div class="row match_block">
                                    <div class="col-12">
                                        <span class='quiniela_match_name px-4' id='match_{{partido["num_match"]}}' {% if game_rules.is_code_a %}onclick='selectMatchCodeA(event)'{% endif %}>
                                            {{ partido["name"] }}
                                        </span>
                                    </div>
                                </div>
                            {% endif %}
                        {% endfor %}
                    </div>
                </div>

                <!-- APUESTAS -->
                <div id="contenedorApuestas" class="col-12 col-md-8 col-xl-9 contenedor_apuestas">
                    {% for i in 0..(num_preloaded_bets - 1) %}
                        <div class="style_tabla_comprar_quiniela {{ i == 0 ? '' : 'disabled_tabla hidden_responsive' }}" style="{{ i == 0 ? 'scroll-snap-align: center;' : 'opacity: 0.3' }}" id="apuesta_{{i}}">

                            <div id="apuesta_{{i}}_simple_header" class="container_tabla_header_quinigol" style="text-align: center">
                                <span style="cursor: pointer" onclick="aleatorioBoleto({{i}})" class="pull-left actionIcon text-azul">
                                    <i class="fa fa-random"></i>
                                </span>
                                <button onclick="prevApuestaResponsive()" style="width:12%; height:100%; font-size:10px" class="btn button_boleto_cambiar_apuesta_button_responsive p-0 d-sm-none">&lt;&lt;</button>
                                <span id="apuesta_{{i}}_title">Apuesta {{ i + 1 }}</span>
                                <button onclick="nextApuestaResponsive()" style="width:12%; height:100%; font-size:10px" class="btn button_boleto_cambiar_apuesta_button_responsive p-0 d-sm-none">&gt;&gt;</button>
                                <span style="cursor: pointer" onclick="borrarBoleto({{i}})" class="pull-right actionIcon text-azul">
                                    <i class="fa fa-trash"></i>
                                </span>
                            </div>

                            <div id="container_boleto_{{i}}_numeros" class="container_tabla_quinigol_vertical mt-2 py-2" style="max-width: {{70 * (game_rules.is_custom_values_per_number ? (game_rules.custom_values_per_number | length - 1) : game_rules.max_value_per_number)}}px;">
                                {% for j, partido in first_play %}
                                    {% if loop.last and game_rules.num_max_extras_per_slip %}
                                        {% set teams = explode("-", partido["name"]) %}
                                        <p>{{game_rules.extra_name}}</p>
                                        {% for k, team in teams %}
                                            <div class="extra_container match_block px-2">
                                                {% if game_rules.is_custom_values_per_extra %}
                                                    {% for num in game_rules.custom_values_per_extra %}
                                                        <div id="apuesta_{{i}}_team_{{k}}_extra_{{num}}" class="extra_box fa-stack" data-partido="{{j}}" data-team="{{k}}">
                                                            <i class="fa-stack-2x item_figure fa fa-square"></i>
                                                            <span class="fa-stack-1x item_text">
                                                                {{num}}
                                                            </span>
                                                        </div>
                                                    {% endfor %}
                                                {% else %}
                                                    {% for num in game_rules.min_value_per_extra..game_rules.max_value_per_extra %}
                                                        <div id="apuesta_{{i}}_team_{{k}}_extra_{{num}}" class="extra_box fa-stack" data-partido="{{j}}" data-team="{{k}}">
                                                            <i class="fa-stack-2x item_figure fa fa-square"></i>
                                                            <span class="fa-stack-1x item_text">
                                                                {{num}}
                                                            </span>
                                                        </div>
                                                    {% endfor %}
                                                {% endif %}
                                                <div class="w-100"></div>
                                            </div>
                                        {% endfor %}
                                    {% else %}
                                        <div class="number_container match_block px-2">
                                            {% if game_rules.is_custom_values_per_number %}
                                                {% for index, num in game_rules.custom_values_per_number %}
                                                    <div id="apuesta_{{i}}_match_{{j}}_numero_{{num}}" class="number_box fa-stack" data-partido="{{j}}">
                                                        <i class="fa-stack-2x item_figure fa fa-square"></i>
                                                        <span class="fa-stack-1x item_text">
                                                            {{num}}
                                                        </span>
                                                    </div>
                                                {% endfor %}
                                            {% else %}
                                                {% for index, num in game_rules.min_value_per_number..game_rules.max_value_per_number %}
                                                    <div id="apuesta_{{i}}_match_{{j}}_numero_{{num}}" class="number_box fa-stack" data-partido="{{j}}">
                                                        <i class="fa-stack-2x item_figure fa fa-square"></i>
                                                        <span class="fa-stack-1x item_text">
                                                            {{num}}
                                                        </span>
                                                    </div>
                                                {% endfor %}
                                            {% endif %}
                                            <div class="w-100"></div>
                                        </div>
                                    {% endif %}
                                {% endfor %}
                            </div>

                            <div class="w-100 btn button_cambiar_multiple" style="cursor: default;" id="apuesta_{{i}}_btn_cambiar_multiple">
                                Sencilla
                            </div>
                        </div>
                    {% endfor %}
                </div>

                <div class="hidden-xs col-md-1"><span class="anchor" id="comprarBoletos"></span></div>
            </div>

            <!-- FIN SECCION ESTANDAR -->
            <div class="row" style="margin-top: 20px;">
                <div class="col-xl-4 offset-sm-1 col-md-5">
                    <div class="dropdown_date">
                        <span>Jornada: </span>
                        <button class="btn dropbtn primary_color_background">
                            <span id="semana_label" class="semana_button_text"></span>
                            <span id="semana_date_label" class="dias_button_text">
                                {{ array_keys(jornadas)[0] }}
                                <i class="fa fa-caret-down"></i>
                            </span>
                        </button>
                        <div id="dropdown_week" class="dropdown-content_date" style="width:100%;">
                            {% for jornada in array_keys(jornadas) %}
                                <a class="pointer_a display_dropdown" onclick="changeJornada('{{ jornada }}')">
                                    <span class="semana_button_text"></span>
                                    <span class="dias_button_text">
                                        {{ jornada }}
                                    </span>
                                </a>
                            {% endfor %}
                        </div>
                    </div>
                </div>
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
                                <span class="style_label_resumen">FECHA: <span id="selected_fecha" class="style_num_apuestas">{{ array_keys(jornadas)[0] }}</span></span>
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
            <!--fin div resultados recintes-->
        </div>
    </div>

    {% if web_seo_onpage['txt_down'] is not empty %}
        <div class="col-12 text-center text-justify">
            <div>{{ web_seo_onpage['txt_down'] }}</div>
        </div>
    {% endif %}

    <script type="text/javascript">
// {# NOTE no se permiten multiples si el multiple es solo del pleno al 15 #}
var ALLOW_EXTRA_MULTIPLE = false

document.addEventListener("DOMContentLoaded", function(event) {
        //cuando cargue la página, ocultar las apuestas que queden fuera del contenedor
        $(document).ready(function() {
            apuestas = document.getElementsByClassName("disabled_tabla");
            contenedor_apuestas = document.getElementsByClassName("contenedor_apuestas");
            ocultarSobrantes();
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

        //EVENTO CLICK EN NUMERO
        $(document.body).on('click', '.number_box', function(event) {
            event.preventDefault()
            let id = $(this).attr('id')
            let containerId = '#' + id.match(/[a-z]+_\d/)[0]
            // comprobar si la tabla esta habilitada
            if ($(containerId).hasClass('disabled_tabla')) {
                customAlert("Debes rellenar primero el boleto anterior")
                return
            }
            let boletoIndex = Number(containerId.split('_')[1])
            let partido = $(this).data('partido')
            if (!$(this).hasClass('selected')) {
                // AÑADIR NUMERO
                // comprobar que no se pase del máximo
                if (gameRules.multiples) {
                    let maxApuestas = gameRules.multiples.reduce((prev, current) => (prev.number > current.number) ? prev : current).number
                    if (maxApuestas >= getNumSportNumbers(boletos[boletoIndex]["numeros"])) {
                        // si se han seleccionado mas apuestas de las definidas en los multiples se tira para atras
                        customAlert("El número máximo de resultados por apuesta es " + maxApuestas)
                        return
                    }
                }
                boletos[boletoIndex]["numeros"][partido].push($(this).text().trim())
                // si hay dos resultados para un equipo se marca como multiple
                if (boletos[boletoIndex]["numeros"][partido].length > 1) {
                    boletos[boletoIndex]["tipo"] = 'multiple'
                    $(containerId + '_btn_cambiar_multiple').text('Múltiple')
                    $(containerId + '_btn_cambiar_multiple').addClass('button_es_multiple')
                }

                $(this).addClass('selected')
                if (gameRules.is_code_a && $('#match_' + (partido+1)).hasClass('partido_seleccionado_elige8') && boletoIndex == 0) {
                    $(this).find('.item_figure').addClass('item_figure_code_a_selected')
                }
            } else {
                // DESMARCAR NUMERO
                let valueIndex = boletos[boletoIndex]["numeros"][partido].indexOf($(this).text().trim())

                if (valueIndex > -1) {
                    boletos[boletoIndex]["numeros"][partido].splice(valueIndex, 1)
                }

                let tipo = 'simple'
                let completo = true

                // comprobar que siga siendo multiple
                boletos[boletoIndex]["numeros"].forEach(results => {
                    if (results.length > 1) {
                        tipo = 'multiple'
                    }
                })

                if (tipo == 'simple') {
                    $(containerId + '_btn_cambiar_multiple').text('Sencilla')
                    $(containerId + '_btn_cambiar_multiple').removeClass('button_es_multiple')
                } else {
                    $(containerId + '_btn_cambiar_multiple').text('Múltiple')
                    $(containerId + '_btn_cambiar_multiple').addClass('button_es_multiple')
                }
                boletos[boletoIndex]["tipo"] = tipo

                $(this).removeClass('selected')
                $(this).find('.item_figure').removeClass('item_figure_code_a_selected')
            }
            if (comprobarCompleto(boletoIndex)) {
                comprobarPrecio()
            }
            updateCodeAMatches()
        })

        //EVENTO CLICK EN EXTRA
        $(document.body).on('click', '.extra_box', function(event) {
            event.preventDefault()
            let id = $(this).attr('id')
            let containerId = '#' + id.match(/[a-z]+_\d/)[0]
            // comprobar si la tabla esta habilitada
            if ($(containerId).hasClass('disabled_tabla')) {
                customAlert("Debes rellenar primero el boleto anterior")
                return
            }
            let bet = Number(containerId.split('_')[1])
            let team = $(this).data('team')
            let prevCompleted = comprobarCompleto(bet)
            if (!$(this).hasClass('selected')) {
                if (ALLOW_EXTRA_MULTIPLE) {
                    // {# no permitir el multiple solo del extra #}
                    if (boletos[bet]["extras"][team].length == 1 && boletos[bet]["tipo"] == "simple") {
                        boletos[bet]["tipo"] = 'multiple'
                        $(containerId + '_btn_cambiar_multiple').text('Múltiple')
                        $(containerId + '_btn_cambiar_multiple').addClass('button_es_multiple')
                    }
                }

                boletos[bet]["extras"][team].push($(this).text().trim())

                $(this).addClass('selected')

                if (comprobarCompleto(bet)) {
                    comprobarPrecio()
                }
                updateCodeAMatches()
            } else {
                $(this).removeClass('selected')

                var index = boletos[bet]["extras"][team].indexOf($(this).text().trim());
                if (index !== -1) {
                    boletos[bet]["extras"][team].splice(index, 1);
                }

                if (boletos[bet]["extras"].every(e => e.length == 1) && boletos[bet]["tipo"] == "multiple") {
                    boletos[bet]["tipo"] = 'simple'
                    $(containerId + '_btn_cambiar_multiple').text('Sencilla')
                    $(containerId + '_btn_cambiar_multiple').removeClass('button_es_multiple')
                }

                if (prevCompleted) {
                    comprobarPrecio()
                }
                updateCodeAMatches()
            }
        });

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
});

        {% if game_rules.is_code_a %}
        // {# TODO esto es especifico a quiniela pero no hay ningun otro juego de este tipo con code_a para poder diferenciar #}
        function selectMatchCodeA(event) {
            let numMatch = $(event.target).attr("id").split("_")[1]
            let remove   = $(event.target).hasClass('partido_seleccionado_elige8')

            updateCodeAMatches(numMatch, remove)
        }
        {% endif %}

        function pintarBoleto(bet, boleto) {
            bet = Number(bet)
            // se quitan los resultados pintados
            limpiarBoleto(bet)
            // se pinta lo que hay en boletos[bet]
            boleto["numeros"].forEach((results, matchIndex) => {
                results.forEach(result => {
                    $(`#apuesta_${bet}_match_${matchIndex}_numero_${result}`).addClass('selected')
                })
            })

            boleto["extras"].forEach((result, team) => {
                $(`#apuesta_${bet}_team_${team}_extra_${result}`).addClass('selected')
            })

            if (CODE_A && CODE_A.length == ELIGE_8 && SLIPS.find(e => e[0]["index"] == boleto["index"]) !== undefined) {
                updateCodeAMatches()
            }
        }

        function changeJornada(jornada) {
            $("#semana_label").html("")
            $("#semana_date_label").html(jornada + " <i class=\"fa fa-caret-down\"></i>")

            $("#selected_fecha").html(jornada)
            jornada_seleccionada = jornada

            info_jornadas[jornada].forEach(partidoJornada => {
                $('#match_' + partidoJornada["num_match"] + '_team_0').html(partidoJornada["name"].split("-")[0].trim());
                $('#match_' + partidoJornada["num_match"] + '_team_1').html(partidoJornada["name"].split("-")[1].trim());
            });

            comprobarPrecio();

            document.getElementById("dropdown_week").style.pointerEvents = "none";

            setTimeout((function () {
                document.getElementById("dropdown_week").style.pointerEvents = "auto";
            }), 500);
        }

        {% if game_rules.is_code_a %}
        function updateCodeAMatches(matchId = null, remove = false) {
            // si se entra sin haber ningun cambio en el code_a se sale
            //(al cambiar los boletos se marca la primera apuesta con el code_a pero si no está elegido no hay que hacer nada)
            if (!$('.partido_seleccionado_elige8').length && matchId === null && !remove) {
                return
            }

            // borrar todos los partidos si no se pasa id y se quiere borrar
            if (matchId === null && remove) {
                let checkPrice = false
                if (CODE_A.length == ELIGE_8) {
                    checkPrice = true
                }

                CODE_A = []
                SLIPS.forEach(e => {
                    e[0]["code_a"] = CODE_A
                    boletos.find(bet => bet["index"] == e[0]["index"])["code_a"] = CODE_A
                })
                $('.item_figure_code_a_selected').removeClass('item_figure_code_a_selected')

                if (checkPrice) {
                    comprobarPrecio()
                }
                return
            }

            // refrescar los partidos que ya hay seleccionados
            if (matchId === null) {
                //FIXME code_a revisar cuando code_a es true y no un array en todos los sitios donde se use code_a
                CODE_A = []
                $('.partido_seleccionado_elige8').each((i, e) => {
                    CODE_A.push(e.id.split('_')[1])
                })
                $('.item_figure_code_a_selected').removeClass('item_figure_code_a_selected')

                CODE_A.forEach(idMatch => {
                    SLIPS.forEach(e => {
                        let bet = boletos.findIndex(globalBet => globalBet.index == e[0].index)
                        $('[id^="apuesta_'+bet+'_match_'+(idMatch - 1)+'_numero_"].selected').find('.item_figure').addClass('item_figure_code_a_selected')
                    })
                })

                SLIPS.forEach(e => {
                    e[0]["code_a"] = []
                })

                boletos.forEach(e => {
                    e["code_a"] = []
                })

                SLIPS.forEach(e => {
                    e[0]["code_a"] = CODE_A
                    boletos.find(bet => bet["index"] == e[0]["index"])["code_a"] = CODE_A
                })
                return
            }

            let matchIndex = Number(matchId) - 1

            // Desmarcar partido
            if (remove) {
                $('#match_' + matchId).removeClass('partido_seleccionado_elige8')
                CODE_A.splice(CODE_A.indexOf(matchId), 1)
                SLIPS.forEach(e => {
                    e[0]["code_a"] = CODE_A
                    let bet = boletos.findIndex(globalBet => globalBet.index == e[0].index)
                    boletos[bet]["code_a"] = CODE_A
                    $('[id^="apuesta_'+bet+'_match_'+matchIndex+'"]').find('.item_figure_code_a_selected').removeClass('item_figure_code_a_selected')
                })

                if (CODE_A.length == (ELIGE_8 - 1)) {
                    comprobarPrecio();
                }
                return;
            }

            // {# no hay definido code_a_max_number en el panel #}
            if (CODE_A.length == ELIGE_8) {
                customAlert(`Solo se pueden seleccionar ${ELIGE_8} partidos`);
                return;
            }

            // Marcar partido
            SLIPS.forEach(e => {
                let bet = boletos.findIndex(globalBet => globalBet.index == e[0].index)
                $('[id^="apuesta_'+bet+'_match_'+matchIndex+'_numero_"].selected').find('.item_figure').addClass('item_figure_code_a_selected')
            })

            $('#match_' + matchId).addClass('partido_seleccionado_elige8')
            CODE_A.push(matchId)
            CODE_A.sort((a, b) => Number(a) - Number(b))

            if (CODE_A.length == ELIGE_8) {
                SLIPS.forEach(e => {
                    e[0]["code_a"] = CODE_A
                    boletos.find(bet => bet["index"] == e[0]["index"])["code_a"] = CODE_A
                })
                comprobarPrecio();
            }
        }
        {% endif %}

        function validarApuesta() {
            let lineasPedido = []
            let is_week = 0
            let total = deFormatNumber($("#total_price").html())
            let minBetsPerSlip = gameRules.min_import_per_slip ? Math.round(((gameRules.min_import_per_slip / gameRules.price) + Number.EPSILON) * 100) / 100 : gameRules.num_min_bets_per_slip

            if (total <= 0) {
                customAlert("Boleto incompleto")
                return
            }

            if (total < gameRules.min_import_per_slip) {
                customAlert(`Deben rellenarse mínimo ${minBetsPerSlip} apuestas`);
                return;
            }

            if (gameRules.code == 'LQ' && CODE_A.length != 0 && CODE_A.length != ELIGE_8) {
                customAlert(`Termina tu apuesta de ${gameRules.code_a_name} marcando ${ELIGE_8} partidos`);
                return;
            }

            //rellenar lineas de pedido
            let lineaPedido = {}
            boletos.filter(e => e["completo"]).forEach((item, index) => {
                lineaPedido.numeros = item["numeros"]

                if (gameRules.num_max_extras_per_slip) {
                    lineaPedido.extras = item["extras"]
                }

                if (gameRules.is_code_a) {
                    if (gameRules.is_code_a_selectable && gameRules.is_code_a_per_slip) {
                        lineaPedido.code_a = CODE_A
                    } else {
                        lineaPedido.code_a = item["code_a"]
                    }
                }

                if (gameRules.is_code_b) {
                    if (gameRules.is_code_b_selectable && gameRules.is_code_b_per_slip) {
                        lineaPedido.code_b = CODE_B
                    } else {
                        lineaPedido.code_b = item["code_b"]
                    }
                }

                lineasPedido.push(lineaPedido)
                lineaPedido = {}
            })

            let objectCarrito = {
                "date": jornada_seleccionada,
                "week": is_week,
                "total": total,
                "game_code": gameRules.code,
                "lineasPedido": lineasPedido,
            }

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

            $.ajax({
                type: "POST",
                url: "save-cart-type-apuestas",
                data: objectCarrito,

                success: function(resData) {
                    $('#continueBuyingModal').modal('show')
                },
                error: function(e) {
                    customAlert("Error al guardar el boleto")
                }
            })
        }
    </script>
</div>
