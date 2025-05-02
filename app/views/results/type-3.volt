{% include 'layouts/boxs/box_css_game' with ['game': game_rules, 'pv': datosAdmon] %}
<div class='col-12 my-4'>
    <div class='row mb-3'>
        <div class='col-lg-6 col-md-12 col-sm-12 d-md-block'>
            <img class='float-left mx-1' src='{{game_rules.logo}}' height='60'>
            <h1 class='span_comprobar_title'>
                {{web_seo_onpage['h1']}}
            </h1>
        </div>

        <div class='col-lg-6 col-md-6 text-right m-auto'>
            {% if datosAdmon.games.buy_online %}
            <h2 onclick="location.href='{% if datosAdmon.games.club_amigo_online == 1 %}https://juegos.loteriasyapuestas.es/CF/loginFromRetailer.do?retailerId={{ constant('RECEPTOR_ID') }}&gameId={{game_rules.lae.code}}{% else %}loteria-nacional{% if sorteo_id is defined %}?idsorteo={{sorteo_id}}{% endif %}{% endif %}'" class='span_comprobar_comprar'>
                Comprar {{game_rules.name}} &nbsp;&nbsp;<i class='fa fa-angle-right'></i>
            </h2>
            {% endif %}
        </div>

        {% if web_seo_onpage['txt_up'] is not empty %}
            <div class='col-12 text-center text-justify'>
                <div>{{web_seo_onpage['txt_up']}}</div>
            </div>
        {% endif %}

        <div class='col-md-12 div_comprobador'>
            <div class='row' id='id_draw' data-id_draw='{{sorteo['id_draw']}}'>
                <div class='col-lg-8 order-lg-1 order-2 separator_sections'>
                    <div class='row'>
                        <div class='col-lg-12'>
                            <h5 class='pb-2 text_tabla_loteria_nacional'>1. Introduce tu número</h5>
                            <input
                                type='text'
                                style='background-color: {% if datosAdmon.css.number_raffle_bg_color is defined %}{{datosAdmon.css.number_raffle_bg_color}}{% else %}{{game_rules.number_bg_color}}{% endif %};
                                    color: {% if datosAdmon.css.number_raffle_fg_color is defined %}{{datosAdmon.css.number_raffle_fg_color}}{% else %}{{game_rules.number_fg_color}}{% endif %}'
                                class='input_numero_loteria_nacional width_number'
                                id='number' />
                        </div>
                    </div>
                    <div class='row'>
                        <div class='col-lg-3 col-6'>
                            <h5 class='pb-2 text_tabla_euromillones'>2. Serie</h5>
                            <input
                                type='text'
                                style='background-color: {% if datosAdmon.css.num_serie_bg_color %}{{datosAdmon.css.num_serie_bg_color}}{% else %}{{game_rules.num_serie_bg_color}}{% endif %};
                                    color: {% if datosAdmon.css.num_serie_fg_color %}{{datosAdmon.css.num_serie_fg_color}}{% else %}{{game_rules.num_serie_fg_color}}{% endif %};'
                                class='input_numero_loteria_nacional width_serie'
                                id='serie' />
                        </div>
                        <div class='col-lg-3 col-6'>
                            <h5 class='pb-2 text_tabla_euromillones'>3. Fracción</h5>
                            <input
                                type='text'
                                style='background-color: {% if datosAdmon.css.num_fraction_bg_color %}{{datosAdmon.css.num_fraction_bg_color}}{% else %}{{game_rules.num_fraction_bg_color}}{% endif %};
                                    color: {% if datosAdmon.css.num_fraction_fg_color %}{{datosAdmon.css.num_fraction_fg_color}}{% else %}{{game_rules.num_fraction_fg_color}}{% endif %};'
                                class='input_numero_loteria_nacional width_serie'
                                id='fraction' />
                        </div>
                        <div class='col-lg-5 offset-lg-1 col-10 offset-1'>
                            <h5 class='pb-2 text_tabla_euromillones'>4. Apuesta</h5>
                            <input
                                type='text'
                                style='background-color: {% if datosAdmon.css.number_raffle_bg_color %}{{datosAdmon.css.number_raffle_bg_color}}{% else %}{{game_rules.number_bg_color}}{% endif %};
                                    color: {% if datosAdmon.css.number_raffle_fg_color %}{{datosAdmon.css.number_raffle_fg_color}}{% else %}{{game_rules.number_fg_color}}{% endif %}'
                                class='input_numero_loteria_nacional width_apuesta'
                                id='amount' />
                            <span class='euro_label'>€</span>
                        </div>
                    </div>
                    <div class='row' style='height: 30px'></div>
                    <div class='row div_comprobar_loteria_nacional'>
                        <button onclick='checkResults()' class='btn button_comprobar_euromillones_comprobar_apuesta'>Comprobar</button>
                    </div>
                </div>
                <div class='col-lg-4 order-lg-2 order-1'>
                    <div class='row' style='justify-content: center; margin-top: 15px;'>
                        <input onchange='changeDraw()' id='date' value='{% if config.detect.isMobile() %}{{fechaMobil}}{% else %}{{fechaLarga}}{% endif %}' type='{% if config.detect.isMobile() %}date{% else %}text{% endif %}' class='center selector_fecha_comprobador' />{% if !config.detect.isMobile() %}<i onclick='triggerCalendar()' style='cursor:pointer;' class='fa fa-caret-down'></i>{% endif %}
                    </div>
                    <div class='row section_comprobador_loteria_naciona_cupon' style='background-color: {{game_rules.bg_color}}; color: {{game_rules.fg_color}}'>
                        <div class='col-6'>
                            <p class='premio_label_comprobar_loteria_nacional'>1º PREMIO</p>
                            <p id='p1' class='premio_label_comprobar_loteria_nacional_numero'>{{sorteo['bet']['P1']}}</p>
                        </div>
                        <div class='col-6'>
                            <p class='premio_label_comprobar_loteria_nacional'>2º PREMIO</p>
                            <p id='p2' class='premio_label_comprobar_loteria_nacional_numero'>{{sorteo['bet']['P2']}}</p>
                        </div>
                        <div class='col-12' style='margin-top: 10px;'>
                            <div class='row' style='justify-content: center'>
                                <div class='reintegro_label_comprobar_loteria_nacional'>
                                    <span class='premio_label_comprobar_loteria_nacional'>R</span>
                                    <span id='num_refund1' class='premio_label_comprobar_loteria_nacional_numero'>{% if sorteo['other']['num_refund'] is defined and sorteo['other']['num_refund'][0] is defined %}{{sorteo['other']['num_refund'][0]}}{% endif %}</span>
                                </div>
                                <div class='reintegro_label_comprobar_loteria_nacional'>
                                    <span class='premio_label_comprobar_loteria_nacional'>R</span>
                                    <span id='num_refund2' class='premio_label_comprobar_loteria_nacional_numero'>{% if sorteo['other']['num_refund'] is defined and sorteo['other']['num_refund'][1] is defined %}{{sorteo['other']['num_refund'][1]}}{% endif %}</span>
                                </div>
                                {% if sorteo['other']['num_refund'][2] is defined %}
                                    <div class='reintegro_label_comprobar_loteria_nacional'>
                                        <span class='premio_label_comprobar_loteria_nacional'>R</span>
                                        <span id='num_refund3' class='premio_label_comprobar_loteria_nacional_numero'>{{sorteo['other']['num_refund'][2]}}</span>
                                    </div>
                                {% endif %}
                            </div>
                        </div>
                    </div>
                    <p class='text-center comprar_euromillones_escoge_numeros' id='texto_escoge_o_premio' style='margin-top: 35px;'>Combinación ganadora</p>
                    <p class='text-center comprar_euromillones_escoge_numeros' id='texto_escrutinio_porcentaje' style='margin-top: 35px;'></p>
                    <div class='row div_ver_premios_bonoloto'>
                        <button onclick='seePrizes()' id='button_see_prizes' class='btn button_comprobar_euromillones_ver_premios'>Escrutinio</button>
                    </div>
                </div>
            </div>
        </div>

        <div class='col-12 col-md-12' style='margin-top: 10px;'>
            <div class='row accordion' style='margin-top: 25px;' id='accordionExample'>
                <div class='col-md-12' style='text-align: left'>
                    <span class='label_resultados_euromillones'>Resultados de {{game_rules.name}}</span>
                </div>
                {% for s in sorteos %}
                    <a id='anchor{{s['date']|date_format('d-m-Y')}}' style='margin-bottom: 20px'></a>
                    <div class='col-md-12' style='padding: 10px; margin-top: 30px; background-color: {% if loop.index is even %}#fcfcfc{% else %}#f8f8f8{% endif %}'>
                        <div class='row' style='align-items: center;' id='heading{{s['date']|date_format('d-m-Y')}}'>
                            <div class='col-lg-5' style='text-align: center;'>
                                <span class='span_resultados_euromillones' data-toggle='collapse' data-target='#collapse{{s['date']|date_format('d-m-Y')}}' aria-expanded='true' aria-controls='collapse{{s['date']|date_format('d-m-Y')}}'>Resultado del {{s['date']|date_format('d-m-Y')}} <i class='fa fa-angle-down'></i></span>
                            </div>
                            <div class='col-lg-7 d-none d-lg-flex' style='display: flex; justify-content: center; align-items: center'>
                                <span class='label_resultados_sm'>1º PREMIO</span> <span class='label_resultados_premio'>{{s['bet']['P1']}}</span>
                                <span class='label_resultados_sm'>2º PREMIO</span> <span class='label_resultados_premio'>{{s['bet']['P2']}}</span>
                                <span style='margin-left: 10px;'></span>
                                <span class='label_resultados_sm'>R</span> <span class='label_resultados_premio'>{% if s['other']['num_refund'] is defined and s['other']['num_refund'][0] is defined %}{{s['other']['num_refund'][0]}}{% endif %} </span>
                                <span class='label_resultados_sm'>R</span> <span class='label_resultados_premio'>{% if s['other']['num_refund'] is defined and s['other']['num_refund'][0] is defined %}{{s['other']['num_refund'][1]}}{% endif %} </span>
                                {% if s['other']['num_refund'][2] is defined %}
                                    <span class='label_resultados_sm'>R</span> <span class='label_resultados_premio'>{{s['other']['num_refund'][2]}} </span>
                                {% endif %}
                            </div>
                        </div>
                        <div id='collapse{{s['date']|date_format('d-m-Y')}}' class='row collapse{% if loop.first %} show{% endif %}' data-parent='#accordionExample' aria-labelledby='heading{{s['date']|date_format('d-m-Y')}}' style='justify-content: center; margin-top: 35px;'>
                            <div class='col-md-10'>
                                <div class='d-lg-none'>
                                    <div class='row' style='justify-content: center; margin-top: 20px;' id='row_numbers_euromillon_sorteo'>
                                        <span class='label_resultados_sm'>1º PREMIO</span> <span class='label_resultados_premio'>{{s['bet']['P1']}}</span>
                                        <span class='label_resultados_sm'>2º PREMIO</span> <span class='label_resultados_premio'>{{s['bet']['P2']}}</span>
                                    </div>
                                    <div class='row' style='justify-content: center; margin-top: 20px;'>
                                        <span class='label_resultados_sm'>R</span> <span class='label_resultados_premio'>{{s['other']['num_refund'][0]}} </span>
                                        <span class='label_resultados_sm'>R</span> <span class='label_resultados_premio'>{{s['other']['num_refund'][1]}} </span>
                                        {% if s['other']['num_refund'][2] is defined %}
                                            <span class='label_resultados_sm'>R</span> <span class='label_resultados_premio'>{{s['other']['num_refund'][2]}} </span>
                                        {% endif %}
                                    </div>
                                </div>
                                <div class='col_der_resultados_bonoloto table-responsive-sm margin_top_responsive'>
                                    <!--ini col der resultados juego-->
                                    <table class='resultados_tabla table table-sm table-striped'>
                                        <tbody>
                                            <tr class='resultados_tabla_titulo' height='27'>
                                                <td>CATEGORIA</td>
                                                <td align='right'>APUESTAS</td>
                                                <td style='min-width: 110px;' align='right'>PREMIOS</td>
                                            </tr>
                                            {% for row in s['winnings'] %}
                                                <tr>
                                                <td class='f1i'>{{row['name']}}</td>
                                                <td class='f1d' align='right'>{{row['winners']|default(0)|number_int}}</td>
                                                <td class='f1d' align='right'>{{row['prize']|number_float}}</td>
                                                </tr>
                                            {% endfor %}
                                        </tbody>
                                    </table>
                                    <div class='clear'></div>
                                    {% if s['other']['documents'] is defined %}
                                    {% set url_lista = '' %}
                                    {% for document in s['other']['documents'] %}
                                        {% if (document['url'] is defined and 'lista' in (document['url']|lower)) %}
                                            {% set url_lista = document['url'] %}
                                            {% break %}
                                        {% endif %}
                                    {% endfor %}
                                    {% if url_lista is empty %}
                                        {% set url_lista = s['other']['documents'][0]['url'] %}
                                    {% endif %}

                                    {% if url_lista is not empty %}
                                        <a target='_blank' href='{{url_lista}}' class='d-block w-50 btn btn-small btn-success mx-auto small pb-2 '>Ver lista oficial</a>
                                    {% endif %}
                                    {% endif %}
                                </div>
                            </div>
                        </div>
                    </div>
                {% endfor %}
            </div>
        </div>

        {% if web_seo_onpage['txt_down'] is not empty %}
            <div class='col-12 text-center text-justify'>
                <div>{{web_seo_onpage['txt_down']}}</div>
            </div>
        {% endif %}
    </div>
</div>
<script type='text/javascript'>
    document.addEventListener("DOMContentLoaded", function(event) {
        if ($('#date').attr('type') == 'text') {
            $('#date').datepicker({
                dayNamesMin: ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa'],
                monthNames: monthNames,
                firstDay: 1,
                dateFormat: 'dd-mm-yy',
                gotoCurrent: true,
                defaultDate: new Date('{{sorteos[0]['date']}}'),
                maxDate: new Date('{{sorteos[0]['date']}}'),
                minDate: new Date('{{sorteos[(sorteos|length)-1]['date']}}'),
                beforeShowDay: enabledDay
            });
        }
    });

    function changeDraw() {
        /*$('#button_see_prizes').data('key', $('#date').find(':selected').data('key'));*/

        $.ajax({
            type: 'POST',
            url: 'get-draw-results',
            data: {
                'id_game': {{game_rules.id|default(0)}},
                'date': $('#date').val(),
                'id_draw': $('#id_draw').data('id_draw')
            },
            success: function(res) {
                $('#p1').html(res['bet']['P1']);
                $('#p2').html(res['bet']['P2']);
                $('#num_refund1').html(res.num_refund[0]);
                $('#num_refund2').html(res.num_refund[1]);
                $('#num_refund3').html(res.num_refund[2]);

                $('#text_has_ganado_euromillones').html('');
                $('#id_draw').data('id_draw', res.id_draw);

                checkResults();
            }
        });
    }

    function checkResults() {
        var number   = $('#number').val();
        var serie    = $('#serie').val();
        var fraction = $('#fraction').val();
        var amount   = $('#amount').val();
        var id_draw  = $('#id_draw').data('id_draw');

        if (number == '') {
            //customAlert('Debes rellenar un numero');
            return;
        }

        $.ajax({
            type: 'POST',
            url: 'check-results',
            data: {
                'id_game': {{game_rules.id|default(0)}},
                'number': number,
                'serie': serie,
                'fraction': fraction,
                'amount': amount,
                'id_draw': id_draw,
                'date': $('#date').val()
            },
            success: function(resData) {
                var html_has_ganado = '';
                var is_confirmed = 1;

                if (resData.total != '0,00') {
                    html_has_ganado += 'Ha sido premiada con ' + resData.total + ' €';
                } else {
                    if (resData['other_info']['is_confirmed'] !== 'undefined' && resData['other_info']['is_confirmed'] != null && resData['other_info']['is_confirmed'] == 0) {
                        is_confirmed = 0;
                        html_has_ganado += 'La apuesta aún no ha sido premiada.';
                    } else {
                        html_has_ganado += 'La apuesta no ha sido premiada.';
                    }
                }

                $('#texto_escoge_o_premio').html(html_has_ganado);

                if (is_confirmed != 0) {
                    $('#texto_escrutinio_porcentaje').addClass('no_display');
                } else if (resData['other_info']['perc_complete']) {
                    $('#texto_escrutinio_porcentaje').removeClass('no_display');
                }

                if (resData['other_info']['perc_complete'] !== 'undefined' && resData['other_info']['perc_complete'] && is_confirmed != 0) {
                    $('#texto_escrutinio_porcentaje').html('Escrutado: ' + resData['other_info']['perc_complete'] + '%');
                }
            }
        });
    }
</script>
