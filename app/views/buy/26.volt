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
        height: 5rem;
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
<div class="col-12 col-md-12">
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
{% else %}
    <div class="row">
        <div class="col-12 mt-2">
            <!-- INICIO SECCION ESTANDAR -->
            <div class="row d-md-flex">
                <!-- EQUIPOS -->
                <div class="hidden-xs col-md-3 col-xl-2" style="text-align: center; padding: 0px;">
                    <hr class="my-3" style="border: none">
                    <div class="d-none d-md-block mt-5">
                        {% for partido in first_play %}
                            {% set teams = explode('-', partido["name"]) %}
                            <div class="row mb-4 match_block">
                                <div class="col-md-3 col-lg-5 partidos_quinigol">{{ partido["num_match"] }}</div>
                                <div class="col-md-9 col-lg-7">
                                    {% for i, team in teams %}
                                        <span class='quiniela_match_name' id='name_match_{{partido["num_match"]}}_team_{{i}}'>
                                            {{ trim(team) }}
                                        </span>
                                        {% if teams | length != (i + 1) %}
                                            <hr class="margin_hr_quinigol" style="margin-top: 10px; margin-bottom: 10px;">
                                        {% endif %}
                                    {% endfor %}
                                </div>
                            </div>
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

                            <div id="container_boleto_{{i}}_numeros" class="container_tabla_quinigol_vertical mt-2 py-2" style="max-width: {{60 * (game_rules.is_custom_values_per_number ? (unique_custom_values | length - 1) : game_rules.max_value_per_number)}}px;">
                                {% for j, partido in first_play %}
                                    {% set teams = explode('-', partido["name"]) %}
                                    <div class="match_block number_container {% if !loop.last %}mb-4{% endif %}">
                                        {% for k, team in teams %}
                                            {% if game_rules.is_custom_values_per_number %}
                                                {% for index, num in unique_custom_values %}
                                                    <div id="apuesta_{{i}}_match_{{j}}_team_{{k}}_numero_{{num}}" class="number_box fa-stack fa-lg" data-partido="{{j}}" data-equipo="{{k}}">
                                                        <i class="fa-stack-2x item_figure fa fa-square"></i>
                                                        <span class="fa-stack-1x item_text">
                                                            {{num}}
                                                        </span>
                                                    </div>
                                                {% endfor %}
                                            {% else %}
                                                {% for index, num in game_rules.min_value_per_number..game_rules.max_value_per_number %}
                                                    <div id="apuesta_{{i}}_match_{{j}}_team_{{k}}_numero_{{num}}" class="number_box fa-stack fa-lg" data-partido="{{j}}" data-equipo="{{k}}">
                                                        <i class="fa-stack-2x item_figure fa fa-square"></i>
                                                        <span class="fa-stack-1x item_text">
                                                            {{num}}
                                                        </span>
                                                    </div>
                                                {% endfor %}
                                            {% endif %}
                                            <div class="w-100"></div>
                                        {% endfor %}
                                    </div>
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
                                <button id="button_validarApuesta" onclick="validarApuesta()" class="btn button_comprar_añadir_al_carrito"><i class="fa-shopping-cart fa"></i>&nbsp;&nbsp;Añadir</button>
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
            let equipo = $(this).data('equipo')
            if (!$(this).hasClass('selected')) {
                // AÑADIR NUMERO
                // comprobar que no se pase del máximo
                if (gameRules.multiples) {
                    let maxApuestas = gameRules.multiples.reduce((prev, current) => (prev.number > current.number) ? prev : current).number
                    if (maxApuestas >= (getNumSportNumbers(boletos[boletoIndex]["numeros"]) / gameRules.custom_values_per_number[0].split('-').length)) {
                        // si se han seleccionado mas apuestas de las definidas en los multiples se tira para atras
                        customAlert("El número máximo de resultados por apuesta es " + maxApuestas)
                        return
                    }
                }
                boletos[boletoIndex]["numeros"][partido][equipo].push($(this).text().trim())
                // si hay dos resultados para un equipo se marca como multiple
                if (boletos[boletoIndex]["numeros"][partido][equipo].length > 1) {
                    boletos[boletoIndex]["tipo"] = 'multiple'
                    $(containerId + '_btn_cambiar_multiple').text('Múltiple')
                    $(containerId + '_btn_cambiar_multiple').addClass('button_es_multiple')
                }

                $(this).addClass('selected')

                // marcar como completo y habilitar/crear siguiente apuesta
                // numero de apuestas dividido entre numero de equipos por partidos
                // 12 apuestas 2 equipos por partido = 6
                if ((getNumSportNumbers(boletos[boletoIndex]["numeros"]) / gameRules.custom_values_per_number[0].split('-').length) >= gameRules.num_number_per_bet) {
                    // comprobar que todos los partidos tienen un resultado
                    let completo = true
                    boletos[boletoIndex]["numeros"].forEach(partido => {
                        partido.forEach(equipo => {
                            if (!equipo.length) {
                                completo = false
                            }
                        })
                    })
                    if (completo) {
                        boletos[boletoIndex]["completo"] = true
                        if ($('#apuesta_' + (boletoIndex + 1)).length) {
                            habilitarBoleto(boletoIndex + 1)
                        } else {
                            crearDivApuestaQuinigol()
                        }
                    } else {
                        boletos[boletoIndex]["completo"] = false
                    }
                } else {
                    boletos[boletoIndex]["completo"] = false
                }
            } else {
                // DESMARCAR NUMERO
                let valueIndex = boletos[boletoIndex]["numeros"][partido][equipo].indexOf($(this).text().trim())

                if (valueIndex > -1) {
                    boletos[boletoIndex]["numeros"][partido][equipo].splice(valueIndex, 1)
                }

                let tipo = 'simple'
                let completo = true

                // comprobar que siga siendo multiple y que esté completo
                boletos[boletoIndex]["numeros"].forEach(partido => {
                    partido.forEach(equipo => {
                        if (equipo.length > 1) {
                            tipo = 'multiple'
                        }
                        if (!equipo.length) {
                            completo = false
                        }
                    })
                })

                if (tipo == 'simple') {
                    $(containerId + '_btn_cambiar_multiple').text('Sencilla')
                    $(containerId + '_btn_cambiar_multiple').removeClass('button_es_multiple')
                } else {
                    $(containerId + '_btn_cambiar_multiple').text('Múltiple')
                    $(containerId + '_btn_cambiar_multiple').addClass('button_es_multiple')
                }
                boletos[boletoIndex]["tipo"] = tipo
                boletos[boletoIndex]["completo"] = completo

                if (!completo) {
                    // deshabilitar los siguientes boletos y marcarlos como completo = false
                    for (let i = (boletoIndex + 1); i < boletos.length; i++) {
                        boletos[i]["completo"] = false
                    }

                    $('#contenedorApuestas').children().slice(boletoIndex + 1).attr('style', 'opacity: 0.3').addClass('disabled_tabla')
                }

                $(this).removeClass('selected')
            }
            comprobarPrecio()
        })

        "{% if config.datosadmon.data.is_subscription and game_rules.is_subscribable %}"
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
        "{% endif %}"
});

        function pintarBoleto(bet, boleto) {
            bet = Number(bet)
            // se quitan los resultados pintados
            limpiarBoleto(bet)
            // se pinta lo que hay en boletos[bet]
            boleto["numeros"].forEach((matches, matchIndex) => {
                matches.forEach((results, team) => {
                    results.forEach(result => {
                        $(`#apuesta_${bet}_match_${matchIndex}_team_${team}_numero_${result}`).addClass('selected')
                    })
                })
            })
        }

        function changeJornada(jornada) {
            $("#semana_label").html("")
            $("#semana_date_label").html(jornada + " <i class=\"fa fa-caret-down\"></i>")

            $("#selected_fecha").html(jornada)
            jornada_seleccionada = jornada

            info_jornadas[jornada].forEach(partidoJornada => {
                $('#name_match_' + partidoJornada["num_match"] + '_team_0').html(partidoJornada["name"].split("-")[0].trim());
                $('#name_match_' + partidoJornada["num_match"] + '_team_1').html(partidoJornada["name"].split("-")[1].trim());
            });

            comprobarPrecio();

            document.getElementById("dropdown_week").style.pointerEvents = "none";

            setTimeout((function () {
                document.getElementById("dropdown_week").style.pointerEvents = "auto";
            }), 500);
        }

        function validarApuesta() {
            let lineasPedido = []
            let is_week = 0
            let total = parseFloat($("#total_price").html())

            if (total <= 0) {
                customAlert("Boleto incompleto")
                return
            }

            //rellenar lineas de pedido
            boletos.filter(e => e["completo"]).forEach(item => {
                lineasPedido.push(item["numeros"])
            })

            let objectCarrito = {
                "date": jornada_seleccionada,
                "week": is_week,
                "total": total,
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
                url: "guardarCarritoQuinigol",
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
{% endif %}
