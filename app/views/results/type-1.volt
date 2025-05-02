{% include 'layouts/boxs/box_css_game' with ['game': game_rules, 'pv': datosAdmon] %}
{% set num_section = 1 %}
<div class="col-12 my-4">
    <div class="row mb-3">
        <div class="col-lg-6 col-md-12 col-sm-12 d-md-block">
            <img class="float-left mx-3" src="{{game_rules.logo}}" height="60">
            <h1 class="span_comprobar_title">{{web_seo_onpage['h1']}}</h1>
        </div>
        <div class="col-lg-6 col-md-6 text-right m-auto">
            {% if datosAdmon.games.club_amigo_online == 1 %}
                <h2 onclick="location.href='https://juegos.loteriasyapuestas.es/CF/loginFromRetailer.do?retailerId={{ constant('RECEPTOR_ID') }}&gameId={{game_rules.lae.code}}'" class="span_comprobar_comprar">
                    Comprar {{game_rules.name}} &nbsp;&nbsp;<i class="fa fa-angle-right"></i>
                </h2>
            {% elseif datosAdmon.games.buy_online == 1 and game_rules.lae.code in datosAdmon.games.active %}
                <h2 onclick="location.href='{{buy_urls[game_rules.lae.code]}}'" class="span_comprobar_comprar">
                    Comprar {{game_rules.name}} &nbsp;&nbsp;<i class="fa fa-angle-right"></i>
                </h2>
            {% endif %}
        </div>
        {% if web_seo_onpage['txt_up'] is not empty %}
            <div class="col-12 text-center text-justify">
                <div>{{web_seo_onpage['txt_up']}}</div>
            </div>
        {% endif %}
    </div>
    <div class="row">
        <div class="col-md-12 div_comprobador">
            <div class="row">
                <div class="col-lg-8 order-lg-1 order-1 center_cols margin_top_responsive separator_sections">
                    <div class="row">
                        <div class="col-lg-7">
                            <h5 class="pt-4 pb-2 text_label">1. Escoge {% if game_rules.is_multiple and game_rules.num_number_per_bet != default_max_number_per_bet %}entre {{game_rules.num_number_per_bet}} y {{default_max_number_per_bet}}{% else %}{{game_rules.num_number_per_bet}}{% endif %} {{game_rules.number_name|default('números')}}</h5>
                            <div class="number_container selectable">
                            {% if game_rules.is_custom_values_per_number %}
                                {% set custom_values = json_decode(game_rules.is_custom_values_per_number, true) %}
                                {% for num in custom_values %}
                                    <div class="number_box fa-stack fa-lg">
                                        <i class="fa-stack-2x item_figure {{ get_item_css('number', 'figure', game_rules, datosAdmon) }}"></i>
                                        <span class="fa-stack-1x item_text">
                                        {{num}}
                                        </span>
                                    </div>
                                {% endfor %}
                            {% else %}
                                {% for num in game_rules.min_value_per_number..game_rules.max_value_per_number %}
                                    <div class="number_box fa-stack fa-lg">
                                        <i class="fa-stack-2x item_figure {{ get_item_css('number', 'figure', game_rules, datosAdmon) }}"></i>
                                        <span class="fa-stack-1x item_text">
                                        {{str_pad(num, (game_rules.max_value_per_number|length), '0', constant('STR_PAD_LEFT'))}}
                                        </span>
                                    </div>
                                {% endfor %}
                            {% endif %}
                            </div>
                        </div>
                        {% if game_rules.num_extra_per_bet > 0 %}
                        {% set num_section = num_section + 1 %}
                        <div class="col-lg-5">
                            <h5 class="p-0 pt-4 pb-2 text_label">{{num_section}}. Escoge {% if game_rules.is_multiple and game_rules.num_extra_per_bet != default_max_extra_per_bet %}entre {{game_rules.num_extra_per_bet}} y {{default_max_extra_per_bet}}{% else %}{{game_rules.num_extra_per_bet}}{% endif %} {{game_rules.extra_name|default('extras')}}</h5>
                            <div class="extra_container selectable">
                                {% if game_rules.is_custom_values_per_extra %}
                                {% set custom_values = json_decode(game_rules.custom_values_per_extra, true) %}
                                {% for num in custom_values %}
                                    <div class="extra_box fa-stack fa-lg">
                                        <i class="fa-stack-2x item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }}"></i>
                                        <span class="fa-stack-1x item_text">
                                        {{num}}
                                        </span>
                                    </div>
                                {% endfor %}
                                {% else %}
                                {% for num in game_rules.min_value_per_extra..game_rules.max_value_per_extra %}
                                    <div class="extra_box fa-stack fa-2x">
                                        <i class="item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }} fa-stack-2x"></i>
                                        <span class="item_text fa-stack-1x">
                                        {{str_pad(num, (game_rules.max_value_per_extra|length), '0', constant('STR_PAD_LEFT'))}}
                                        </span>
                                    </div>
                                {% endfor %}
                                {% endif %}
                            </div>
                        </div>
                        {% endif %}

                        {% if game_rules.is_num_refund and !game_rules.is_link_num_refund_extra %}
                        {% set num_section = num_section + 1 %}
                        <div class="{% if game_rules.num_extra_per_bet > 0 %}col-12{% else %} col-lg-5{% endif %}">
                            <h5 class="p-0 pt-4 pb-2 text_label">{{num_section}}. Escoge el reintegro</h5>
                            <div class="refund_container selectable">
                                {% for num in 0..9 %}
                                    <div class="refund_box fa-stack fa-2x">
                                        <i class="item_figure {{ get_item_css('refund', 'figure', game_rules, datosAdmon) }} fa-stack-2x"></i>
                                        <span class="item_text fa-stack-1x">
                                        {{num}}
                                        </span>
                                    </div>
                                {% endfor %}
                            </div>
                        </div>
                        {% endif %}
                    </div>
                </div>
                <div class="col-lg-4 order-lg-2 order-1 draw_results">
                    <div class="row" style="justify-content: center; margin-top: 15px; align-items: center">
                        <input onchange='changeDraw()' id='date' value='{% if config.detect.isMobile() %}{{fechaMobil}}{% else %}{{fechaLarga}}{% endif %}' type='{% if config.detect.isMobile() %}date{% else %}text{% endif %}' class='center selector_fecha_comprobador' />{% if !config.detect.isMobile() %}<i onclick='triggerCalendar()' style='cursor:pointer;' class='fa fa-caret-down'></i>{% endif %}
                    </div>
                    <p class="text-center txt-premio" id="texto_escoge_o_premio" style="margin-top: 15px;">Combinación ganadora</p>
                    <div class="row" style="justify-content: center" id="row_numbers_draw">
                        {% for num in sorteo['bet'] %}
                            <div class="number_box fa-stack fa-2x selected">
                                <i class="fa-stack-2x item_figure {{ get_item_css('number', 'figure', game_rules, datosAdmon) }}"></i>
                                <span class="fa-stack-1x item_text">
                                {% if game_rules.is_custom_values_per_number %}
                                {{num}}
                                {% else %}
                                {{str_pad(num, (game_rules.max_value_per_number|length), '0', constant('STR_PAD_LEFT'))}}
                                {% endif %}
                                </span>
                            </div>
                        {% endfor %}
                    </div>
                    <div class="d-flex justify-content-center align-items-center mt-2">
                    {% if game_rules.num_extra_per_bet > 0 %}
                        <div id="row_extras_draw">
                        {% for num in sorteo['extra'] %}
                            <div class="extra_box fa-stack fa-2x selected">
                                <i class="fa-stack-2x item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }}"></i>
                                <span class="fa-stack-1x item_text">
                                {% if game_rules.is_custom_values_per_extra %}
                                {{num}}
                                {% else %}
                                {{str_pad(num, (game_rules.max_value_per_number|length), '0', constant('STR_PAD_LEFT'))}}
                                {% endif %}
                                </span>
                            </div>
                        {% endfor %}
                        </div>
                    {% endif %}
                    {% if game_rules.is_num_complementary %}
                        <div class="label_resultados ml-3">C</div>
                        <div id="row_complementary_draw">
                            <div class="complementary_box fa-stack fa-2x selected">
                                <i class="fa-stack-2x item_figure {{ get_item_css('complementary', 'figure', game_rules, datosAdmon) }}"></i>
                                <span class="fa-stack-1x item_text">
                                {% if sorteo['other']['complementary'] is iterable %}
                                    {{implode(',', sorteo['other']['complementary'])}}
                                {% else %}
                                    {{sorteo['other']['complementary']}}
                                {% endif %}
                                </span>
                            </div>
                        </div>
                    {% endif %}
                    {% if game_rules.is_num_refund and !game_rules.is_link_num_refund_extra  %}
                        <div class="label_resultados ml-3">R</div>
                        <div id="row_refund_draw">
                            <div class="refund_box fa-stack fa-2x selected">
                                <i class="fa-stack-2x item_figure {{ get_item_css('refund', 'figure', game_rules, datosAdmon) }}"></i>
                                <span class="fa-stack-1x item_text">
                                {{sorteo['other']['refund']}}
                                </span>
                            </div>
                        </div>
                    {% endif %}
                    </div>
                    {% if game_rules.is_code_a > 0 and sorteo['other']['code_a'] is defined %}
                    <div class="row" style="justify-content: center; margin-top: 15px;">
                        <span id="row_code_a_draw" class="code_a_box">
                            {{game_rules.code_a_name|default('Código A')}}:
                            {% if sorteo['other']['code_a'] is iterable %}
                                {{implode(',', sorteo['other']['code_a'])}}
                            {% else %}
                                {{sorteo['other']['code_a']}}
                            {% endif %}
                        </span>
                    </div>
                    {% endif %}
                    {% if game_rules.is_code_b > 0 and sorteo['other']['code_b'] is defined %}
                    <div class="row" style="justify-content: center; margin-top: 15px;">
                        <span id="row_code_b_draw" class="code_b_box">
                            {{game_rules.code_b_name|default('Código B')}}:
                            {% if sorteo['other']['code_b'] is iterable %}
                                {{implode(',', sorteo['other']['code_b'])}}
                            {% else %}
                                {{sorteo['other']['code_b']}}
                            {% endif %}
                        </span>
                    </div>
                    {% endif %}
                    <div class="row" style="justify-content: center; margin-top: 10px">
                        <span id="text_has_ganado"></span>
                    </div>
                    <div class="row d-flex d-lg-none" style="justify-content: center; margin-top: 10px">
                        <button onclick="seePrizes()" id="button_see_prizes" class="btn btn-see-prizes">Escrutinio</button>
                    </div>

                </div>
                <div class="col-12 col-lg-8 separator_sections center-cols order-4">
                    <div class="row" style="justify-content: center; margin-top: 10px">
                        <button onclick="checkResults()" class="btn btn-check-result">Comprobar</button>
                    </div>
                </div>
                <div class="col-lg-4 d-none d-lg-flex center-cols order-5" style="justify-content: center; margin-top: 10px">
                    <div class="row">
                        <button onclick="seePrizes()" id="button_see_prizes" class="btn btn-see-prizes">Escrutinio</button>
                    </div>
                </div>
            </div>
        </div>

        {% include 'layouts/boxs/box_results' with ['sorteos': sorteos, 'game': game_rules, 'pv': datosAdmon] %}
    </div>

    {% if web_seo_onpage['txt_down'] is not empty %}
        <div class="col-12 text-center text-justify">
            <div>{{web_seo_onpage['txt_down']}}</div>
        </div>
    {% endif %}
</div>
<script type="text/javascript">
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

        $(".selectable .number_box").click(function(event) {
            event.preventDefault();
            if ($(this).hasClass('selected')) {
                $(this).removeClass('selected');
                num_numbers--;
            } else {
                $(this).addClass('selected');
                num_numbers++;
            }
        });

        $(".selectable .extra_box").click(function(event) {
            event.preventDefault();
            if ($(this).hasClass('selected')) {
                $(this).removeClass('selected');
                num_extras--;
            } else {
                $(this).addClass('selected');
                num_extras++;
            }
        });

        $(".selectable .refund_box").click(function(event) {
            event.preventDefault();

            if ($(this).hasClass('selected')) {
                $(this).removeClass('selected');
                num_refund--;
            } else {
                $(".selectable .refund_box.selected").removeClass('selected');
                $(this).addClass('selected');
                num_refund++;
            }
        });
    });

    var row_numbers_draw       = document.getElementById('row_numbers_draw');
    var row_extras_draw        = document.getElementById('row_extras_draw');
    var row_refund_draw        = document.getElementById('row_refund_draw');
    var row_complementary_draw = document.getElementById('row_complementary_draw');
    var row_code_a_draw        = document.getElementById('row_code_a_draw');
    var row_code_b_draw        = document.getElementById('row_code_b_draw');
    var text_has_ganado        = document.getElementById('text_has_ganado');
    var texto_escoge_o_premio  = document.getElementById('texto_escoge_o_premio');

    var num_numbers            = 0;
    var num_extras             = 0;
    var num_refund             = 0;
    var min_numbers            = {{game_rules.num_number_per_bet|default(0)}};
    var min_extras             = {{game_rules.num_extra_per_bet|default(0)}};
    var min_refund             = {% if game_rules.is_num_refund and !game_rules.is_link_num_refund_extra %}1{% else %}0{% endif %};

    function changeDraw() {
        //$('#button_see_prizes').data('key', $('#date').val());

        $.ajax({
            type: "POST",
            url: "get-draw-results",
            data: {
                'id_game': {{game_rules.id|default(0)}},
                'date': $('#date').val()
            },

            success: function(res) {

                let html_numbers = "";
                let html_extras = "";
                let html_code_a = "";
                let html_code_b = "";
                let html_has_ganado = "";

                if (row_numbers_draw && res.bet) {
                    $.each(res.bet, function(key, value) {
                        html_numbers += '<div class="number_box fa-stack fa-2x selected"><i class="fa-stack-2x item_figure {{ get_item_css('number', 'figure', game_rules, datosAdmon) }}"></i><span class="fa-stack-1x item_text">' + value + '</span></div>';
                    });

                    row_numbers_draw.innerHTML = html_numbers;
                }

                if (row_extras_draw && res.extra) {
                    $.each(res.extra, function(key, value) {
                        html_extras += '<div class="extra_box fa-stack fa-2x selected"><i class="fa-stack-2x item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }}"></i><span class="fa-stack-1x item_text">' + value + '</span></div>';
                    });

                    row_extras_draw.innerHTML = html_extras;
                }

                if (row_complementary_draw && res.complementary) {
                    row_complementary_draw.innerHTML = '<div class="complementary_box fa-stack fa-2x selected"><i class="fa-stack-2x item_figure {{ get_item_css('complementary', 'figure', game_rules, datosAdmon) }}"></i><span class="fa-stack-1x item_text">' + res.complementary + '</span></div>';
                }

                if (row_refund_draw && res.refund) {
                    row_refund_draw.innerHTML = '<div class="refund_box fa-stack fa-2x selected"><i class="fa-stack-2x item_figure {{ get_item_css('refund', 'figure', game_rules, datosAdmon) }}"></i><span class="fa-stack-1x item_text">' + res.refund + '</span></div>';
                }

                if (row_code_a_draw && res.code_a) {
                    html_code_a = "{{game_rules.code_a_name|default('Código A')}}: ";
                    if (res.code_a.length) {
                        html_code_a += res.code_a.join(', ');
                    }

                    row_code_a_draw.innerHTML = html_code_a;
                }

                if (row_code_b_draw && res.code_b) {
                    html_code_b = "{{game_rules.code_b_name|default('Código B')}}: ";
                    if (res.code_b.length) {
                        html_code_b += res.code_b.join(', ');
                    }

                    row_code_b_draw.innerHTML = html_code_b;
                }

                text_has_ganado.innerHTML = "";

                checkResults();
            },
            error: function(e) {

            }
        });
    }

    function checkResults() {
        let numbers = new Array();
        let extras = new Array();
        let num_refund;

        $(".selectable .number_box.selected .item_text").each(function(index) {
            numbers.push($.trim($(this).text()));
        });
        $(".selectable .extra_box.selected .item_text").each(function(index) {
            extras.push($.trim($(this).text()));
        });

        if (min_refund) {
            num_refund = $.trim($(".selectable .refund_box.selected .item_text").text());
        }

        if (numbers.length == 0 && extras.length == 0) {
            return;
        }

        if (min_numbers > 0 && num_numbers < min_numbers) {
            customAlert("Debes seleccionar al menos "+min_numbers+" {{game_rules.number_name|default('números')}}");
            return;
        }
        if (min_extras > 0 && num_extras < min_extras) {
            customAlert("Debes seleccionar al menos "+min_extras+" {{game_rules.extra_name|default('extras')}}");
            return;
        }
        if (min_refund > 0 && num_refund.length == 0) {
            customAlert("Debes seleccionar al menos "+min_refund+" reintegro");
            return;
        }

        $.ajax({
            type: "POST",
            url: "check-results",
            data: {
                'id_game': {{game_rules.id|default(0)}},
                "date": $("#date").val(),
                "numbers": numbers,
                "extras": extras,
                "num_refund": num_refund
            },

            success: function(res) {
                var html_has_ganado = "";

                if (row_numbers_draw) {
                    var items = row_numbers_draw.querySelectorAll('.number_box');
                    if (items.length) {
                        items.forEach(function(elem, index) {
                            elem.classList.remove('selected')
                            if (numbers.indexOf(elem.innerText) > -1) {
                                elem.classList.add('selected');
                            }
                        });
                    }

                    if (row_complementary_draw) {
                        var items = row_complementary_draw.querySelectorAll('.complementary_box');
                        if (items.length) {
                            items.forEach(function(elem, index) {
                                elem.classList.remove('selected')
                                if (numbers.indexOf(elem.innerText) > -1) {
                                    elem.classList.add('selected');
                                }
                            });
                        }
                    }
                }

                if (row_extras_draw) {
                    var items = row_extras_draw.querySelectorAll('.extra_box');
                    if (items.length) {
                        items.forEach(function(elem, index) {
                            elem.classList.remove('selected')
                            if (extras.indexOf(elem.innerText) > -1) {
                                elem.classList.add('selected');
                            }
                        });
                    }
                }

                if (row_refund_draw) {
                    var items = row_refund_draw.querySelectorAll('.refund_box');
                    if (items.length) {
                        items.forEach(function(elem, index) {
                            elem.classList.remove('selected')
                            if (num_refund == elem.innerText) {
                                elem.classList.add('selected');
                            }
                        });
                    }
                }

                if (res.total != "0,00") {
                    html_has_ganado += "Ha sido premiada con " + res.total + " €";
                } else {
                    html_has_ganado += "La apuesta no ha sido premiada.";
                }

                texto_escoge_o_premio.innerHTML = html_has_ganado;

            },
            error: function(e) {

            }
        });
    }
</script>
