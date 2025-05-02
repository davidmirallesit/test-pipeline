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
                {##########################################################
                 # COMPROBAR RESULTADOS (Números Seleccionables)
                 ##########################################################}
                <div class="col-lg-6 order-lg-1 order-2 pl-5 separator_sections align-items-center">
                    <h5 class="pt-4 pb-2 text_label mb-5">1. Marca los {{game_rules.number_name|default('números')}}</h5>
                    {% for num_number in 1..game_rules.num_number_per_bet %}
                    {% set match = sorteo['other']['matches'][num_number-1] %}
                    <div class="row">
                        <div class="col-3">
                            <span class="match_name" id="name_match_{{match['position']}}_team_1">{{match['team_1_name']}}</span>
                        </div>
                        <div class="col-1 p-0 text-center">
                            -
                        </div>
                        <div class="col-3">
                            <span class="match_name" id="name_match_{{match['position']}}_team_2">{{match['team_2_name']}}</span>
                        </div>
                        <div class="col-5 number_container selectable" data-index="{{num_number - 1}}">
{% if game_rules.is_custom_values_per_number %}
{% set custom_values = json_decode(game_rules.custom_values_per_number, true) %}
                            {% for num in custom_values %}
                                <div class="number_box fa-stack fa-lg" data-match="{{match['position']}}_{{num}}">
                                    <i class="fa-stack-2x item_figure {{ get_item_css('number', 'figure', game_rules, datosAdmon) }}"></i>
                                    <span class="fa-stack-1x item_text">
                                    {{num}}
                                    </span>
                                </div>
                            {% endfor %}
{% else %}
                            {% for num in game_rules.min_value_per_number..game_rules.max_value_per_number %}
                                <div class="number_box fa-stack fa-lg" data-match="{{match['position']}}_{{num}}">
                                    <i class="fa-stack-2x item_figure {{ get_item_css('number', 'figure', game_rules, datosAdmon) }}"></i>
                                    <span class="fa-stack-1x item_text">
                                    {{str_pad(num, (game_rules.max_value_per_number|length), '0', constant('STR_PAD_LEFT'))}}
                                    </span>
                                </div>
                            {% endfor %}
{% endif %}
                        </div>
                    </div>
                    {% endfor %}

                    {% if game_rules.num_extra_per_bet > 0 %}
                    <div class="section_featured">
                        <h5 class="p-0 pb-2 text_label">{{game_rules.extra_name|default('Extras')}}</h5>
                        {# CASO 1) SI hay suficientes partidos para todos los extras #}
                        {% if sorteo['other']['matches'][game_rules.num_number_per_bet+game_rules.num_extra_per_bet-1] is defined %}
                        {% for num_number in (game_rules.num_number_per_bet+1)..(game_rules.num_number_per_bet+game_rules.num_extra_per_bet) %}
                        {% set match = sorteo['other']['matches'][num_number-1] %}
                        <div class="row">
                            <div class="col-3">
                                <span class="match_name" id="name_match_{{match['position']}}_team_1">{{match['team_1_name']}}</span>
                            </div>
                            <div class="col-1 p-0 text-center">
                                -
                            </div>
                            <div class="col-3">
                                <span class="match_name" id="name_match_{{match['position']}}_team_2">{{match['team_2_name']}}</span>
                            </div>
                            <div class="col-5 extra_container selectable" data-index="{{num_number - game_rules.num_number_per_bet - 1}}">
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
                                    <div class="extra_box fa-stack fa-lg">
                                        <i class="item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }} fa-stack-2x"></i>
                                        <span class="item_text fa-stack-1x">
                                        {{str_pad(num, (game_rules.max_value_per_extra|length), '0', constant('STR_PAD_LEFT'))}}
                                        </span>
                                    </div>
                                {% endfor %}
                                {% endif %}
                            </div>
                        </div>
                        {% endfor %}
                        {# CASO 2) NO hay suficientes partidos para todos los extras, desdoblamos #}
                        {% else %}
                        {% for num_number in (game_rules.num_number_per_bet+1)..(game_rules.num_number_per_bet+game_rules.num_extra_per_bet) %}
                        {% if sorteo['other']['matches'][num_number-1] is defined %}
                        {% set match = sorteo['other']['matches'][num_number-1] %}
                        <div class="row">
                            <div class="col-6">
                                <span class="match_name" id="name_match_{{match['position']}}_team_1">{{match['team_1_name']}}</span>
                            </div>
                            <div class="col-6 extra_container selectable" data-index="{{num_number - game_rules.num_number_per_bet - 1}}">
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
                                    <div class="extra_box fa-stack fa-lg">
                                        <i class="item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }} fa-stack-2x"></i>
                                        <span class="item_text fa-stack-1x">
                                        {{str_pad(num, (game_rules.max_value_per_extra|length), '0', constant('STR_PAD_LEFT'))}}
                                        </span>
                                    </div>
                                {% endfor %}
                                {% endif %}
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-6">
                                <span class="match_name" id="name_match_{{match['position']}}_team_2">{{match['team_2_name']}}</span>
                            </div>
                            <div class="col-6 extra_container selectable" data-index="{{num_number - game_rules.num_number_per_bet}}">
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
                                    <div class="extra_box fa-stack fa-lg">
                                        <i class="item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }} fa-stack-2x"></i>
                                        <span class="item_text fa-stack-1x">
                                        {{str_pad(num, (game_rules.max_value_per_extra|length), '0', constant('STR_PAD_LEFT'))}}
                                        </span>
                                    </div>
                                {% endfor %}
                                {% endif %}
                            </div>
                        </div>
                        {% set num_number = num_number + 1 %}
                        {% endif %}
                        {% endfor %}
                        {% endif %}
                    </div>
                    {% endif %}

                </div>
                {##########################################################
                 # COMBINACION GANADORA (Resultados sorteo seleccionado)
                 ##########################################################}
                <div class="col-lg-6 order-lg-2 order-1 draw_results">
                    <div class="row" style="justify-content: center; margin-top: 15px; align-items: center">
                        <input onchange='changeDraw()' id='date' value='{% if config.detect.isMobile() %}{{fechaMobil}}{% else %}{{fechaLarga}}{% endif %}' type='{% if config.detect.isMobile() %}date{% else %}text{% endif %}' class='center selector_fecha_comprobador' />{% if !config.detect.isMobile() %}<i onclick='triggerCalendar()' style='cursor:pointer;' class='fa fa-caret-down'></i>{% endif %}
                    </div>
                    <p class="text-center txt-premio" id="texto_escoge_o_premio" style="margin-top: 15px;">Combinación ganadora</p>

                    {% for num_number in 1..game_rules.num_number_per_bet %}
                    {% set match = sorteo['other']['matches'][num_number-1] %}
                    <div class="row">
                        <div class="col-3">
                            <span class="match_name" data-position="{{match['position']}}" data-team="1">{{match['team_1_name']}}</span>
                        </div>
                        <div class="col-1 p-0 text-center">
                            -
                        </div>
                        <div class="col-3">
                            <span class="match_name" data-position="{{match['position']}}" data-team="2">{{match['team_2_name']}}</span>
                        </div>
                        <div class="col-5 px-4 number_container" data-index="{{num_number - 1}}">
{% if game_rules.is_custom_values_per_number %}
{% set custom_values = json_decode(game_rules.custom_values_per_number, true) %}
                            {% for num in custom_values %}
                                <div class="number_box fa-stack fa-lg{% if num == sorteo['bet'][num_number-1] %} selected{% endif %}">
                                    <i class="fa-stack-2x item_figure {{ get_item_css('number', 'figure', game_rules, datosAdmon) }}"></i>
                                    <span class="fa-stack-1x item_text">
                                    {{num}}
                                    </span>
                                </div>
                            {% endfor %}
{% else %}
                            {% for num in game_rules.min_value_per_number..game_rules.max_value_per_number %}
                                <div class="number_box fa-stack fa-lg{% if num == sorteo['bet'][num_number-1] %} selected{% endif %}">
                                    <i class="fa-stack-2x item_figure {{ get_item_css('number', 'figure', game_rules, datosAdmon) }}"></i>
                                    <span class="fa-stack-1x item_text">
                                    {{str_pad(num, (game_rules.max_value_per_number|length), '0', constant('STR_PAD_LEFT'))}}
                                    </span>
                                </div>
                            {% endfor %}
{% endif %}
                        </div>
                    </div>
                    {% endfor %}

                    {% if game_rules.num_extra_per_bet > 0 %}
                    <div class="section_featured">
                        <h5 class="p-0 pb-2 text_label">{{game_rules.extra_name|default('Extras')}}</h5>
                        {# CASO 1) SI hay suficientes partidos para todos los extras #}
                        {% if sorteo['other']['matches'][game_rules.num_number_per_bet+game_rules.num_extra_per_bet-1] is defined %}
                        {% for num_number in (game_rules.num_number_per_bet+1)..(game_rules.num_number_per_bet+game_rules.num_extra_per_bet) %}
                        {% set match = sorteo['other']['matches'][num_number-1] %}
                        <div class="row">
                            <div class="col-3">
                                <span class="match_name" data-position="{{match['position']}}" data-team="1">{{match['team_1_name']}}</span>
                            </div>
                            <div class="col-1 p-0 text-center">
                                -
                            </div>
                            <div class="col-3">
                                <span class="match_name" data-position="{{match['position']}}" data-team="2">{{match['team_2_name']}}</span>
                            </div>
                            <div class="col-5 px-4 extra_container" data-index="{{num_number - game_rules.num_number_per_bet - 1}}">
                                {% if game_rules.is_custom_values_per_extra %}
                                {% set custom_values = json_decode(game_rules.custom_values_per_extra, true) %}
                                {% for num in custom_values %}
                                    <div class="extra_box fa-stack fa-lg{% if num == sorteo['extra'][num_number - game_rules.num_number_per_bet - 1] %} selected{% endif %}">
                                        <i class="fa-stack-2x item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }}"></i>
                                        <span class="fa-stack-1x item_text">
                                        {{num}}
                                        </span>
                                    </div>
                                {% endfor %}
                                {% else %}
                                {% for num in game_rules.min_value_per_extra..game_rules.max_value_per_extra %}
                                    <div class="extra_box fa-stack fa-lg{% if num == sorteo['extra'][num_number - game_rules.num_number_per_bet - 1] %} selected{% endif %}">
                                        <i class="item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }} fa-stack-2x"></i>
                                        <span class="item_text fa-stack-1x">
                                        {{str_pad(num, (game_rules.max_value_per_extra|length), '0', constant('STR_PAD_LEFT'))}}
                                        </span>
                                    </div>
                                {% endfor %}
                                {% endif %}
                            </div>
                        </div>
                        {% endfor %}
                        {# CASO 2) NO hay suficientes partidos para todos los extras, desdoblamos #}
                        {% else %}
                        {% for num_number in (game_rules.num_number_per_bet+1)..(game_rules.num_number_per_bet+game_rules.num_extra_per_bet) %}
                        {% if sorteo['other']['matches'][num_number-1] is defined %}
                        {% set match = sorteo['other']['matches'][num_number-1] %}
                        <div class="row">
                            <div class="col-6">
                                <span class="match_name" data-position="{{match['position']}}" data-team="1">{{match['team_1_name']}}</span>
                            </div>
                            <div class="col-6 extra_container" data-index="{{num_number - game_rules.num_number_per_bet - 1}}">
                                {% if game_rules.is_custom_values_per_extra %}
                                {% set custom_values = json_decode(game_rules.custom_values_per_extra, true) %}
                                {% for num in custom_values %}
                                    <div class="extra_box fa-stack fa-lg{% if num == sorteo['extra'][num_number - game_rules.num_number_per_bet - 1] %} selected{% endif %}">
                                        <i class="fa-stack-2x item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }}"></i>
                                        <span class="fa-stack-1x item_text">
                                        {{num}}
                                        </span>
                                    </div>
                                {% endfor %}
                                {% else %}
                                {% for num in game_rules.min_value_per_extra..game_rules.max_value_per_extra %}
                                    <div class="extra_box fa-stack fa-lg{% if num == sorteo['extra'][num_number - game_rules.num_number_per_bet - 1] %} selected{% endif %}">
                                        <i class="item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }} fa-stack-2x"></i>
                                        <span class="item_text fa-stack-1x">
                                        {{str_pad(num, (game_rules.max_value_per_extra|length), '0', constant('STR_PAD_LEFT'))}}
                                        </span>
                                    </div>
                                {% endfor %}
                                {% endif %}
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-6">
                                <span class="match_name" data-position="{{match['position']}}" data-team="2">{{match['team_2_name']}}</span>
                            </div>
                            <div class="col-6 extra_container" data-index="{{num_number - game_rules.num_number_per_bet}}">
                                {% if game_rules.is_custom_values_per_extra %}
                                {% set custom_values = json_decode(game_rules.custom_values_per_extra, true) %}
                                {% for num in custom_values %}
                                    <div class="extra_box fa-stack fa-lg{% if num == sorteo['extra'][num_number - game_rules.num_number_per_bet] %} selected{% endif %}">
                                        <i class="fa-stack-2x item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }}"></i>
                                        <span class="fa-stack-1x item_text">
                                        {{num}}
                                        </span>
                                    </div>
                                {% endfor %}
                                {% else %}
                                {% for num in game_rules.min_value_per_extra..game_rules.max_value_per_extra %}
                                    <div class="extra_box fa-stack fa-lg{% if num == sorteo['extra'][num_number - game_rules.num_number_per_bet] %} selected{% endif %}">
                                        <i class="item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }} fa-stack-2x"></i>
                                        <span class="item_text fa-stack-1x">
                                        {{str_pad(num, (game_rules.max_value_per_extra|length), '0', constant('STR_PAD_LEFT'))}}
                                        </span>
                                    </div>
                                {% endfor %}
                                {% endif %}
                            </div>
                        </div>
                        {% set num_number = num_number + 1 %}
                        {% endif %}
                        {% endfor %}
                        {% endif %}
                    </div>
                        {% endif %}

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
                <div class="col-12 col-lg-6 separator_sections center-cols order-4">
                    <div class="row justify-content-center mt-4">
                        <button onclick="checkResults()" class="btn btn-check-result">Comprobar</button>
                    </div>
                </div>
                <div class="col-lg-6 d-none d-lg-flex center-cols order-5 justify-content-center mt-4">
                    <div class="row">
                        <button onclick="seePrizes()" id="button_see_prizes" class="btn btn-see-prizes">Escrutinio</button>
                    </div>
                </div>
            </div>
        </div>

        {% include box_results with ['sorteos': sorteos, 'game': game_rules, 'pv': datosAdmon] %}
    </div>

    {% if web_seo_onpage['txt_down'] is not empty %}
        <div class="col-12 text-center text-justify">
            <div>{{web_seo_onpage['txt_down']}}</div>
        </div>
    {% endif %}
</div>
<script type="text/javascript">
    var draw_positions = document.querySelectorAll('.draw_results [data-position][data-team]');
    var draw_numbers = document.querySelectorAll('.draw_results .number_container[data-index]');
    var draw_extras = document.querySelectorAll('.draw_results .extra_container[data-index]');

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

        $('.selectable .number_box').click(function(event) {
            event.preventDefault();
            if ($(this).hasClass('selected')) {
                $(this).removeClass('selected');
                num_numbers--;
            } else {
                $(this).addClass('selected');
                num_numbers++;
            }
        });

        $('.selectable .extra_box').click(function(event) {
            event.preventDefault();
            if ($(this).hasClass('selected')) {
                $(this).removeClass('selected');
                num_extras--;
            } else {
                $(this).addClass('selected');
                num_extras++;
            }
        });
    });

    var row_code_a_draw        = document.getElementById('row_code_a_draw');
    var row_code_b_draw        = document.getElementById('row_code_b_draw');
    var text_has_ganado        = document.getElementById('text_has_ganado');
    var texto_escoge_o_premio  = document.getElementById('texto_escoge_o_premio');

    var num_numbers            = 0;
    var num_extras             = 0;
    var min_numbers            = {{game_rules.num_number_per_bet|default(0)}};
    var min_extras             = {{game_rules.num_extra_per_bet|default(0)}};

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

                let html_code_a = "";
                let html_code_b = "";
                let html_has_ganado = "";

                if (res.bet) {
                    for (i in res.bet) {
                        var objs = draw_numbers[i].querySelectorAll('.number_box');
                        if (objs) {
                            objs.forEach(function(elem, index) {
                                elem.classList.remove('selected');

                                if (elem.innerText == res.bet[i]) {
                                    elem.classList.add('selected');
                                }
                            });
                        }
                    };
                }

                if (res.extra) {
                    for (i in res.extra) {
                        var objs = draw_extras[i].querySelectorAll('.extra_box');
                        if (objs) {
                            objs.forEach(function(elem, index) {
                                elem.classList.remove('selected');

                                if (elem.innerText == res.extra[i]) {
                                    elem.classList.add('selected');
                                }
                            });
                        }
                    };
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

        $(".selectable .number_box.selected .item_text").each(function(index) {
            let parent_index = $(this).parent().parent().attr('data-index');
            if (!numbers[parent_index]) {
                numbers[parent_index] = new Array();
            }
            numbers[parent_index].push($.trim($(this).text()));
        });
        $(".selectable .extra_box.selected .item_text").each(function(index) {
            let parent_index = $(this).parent().parent().attr('data-index');
            if (!extras[parent_index]) {
                extras[parent_index] = new Array();
            }
            extras[parent_index].push($.trim($(this).text()));
        });

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

        $.ajax({
            type: "POST",
            url: "check-results",
            data: {
                'id_game': {{game_rules.id|default(0)}},
                "date": $("#date").val(),
                "numbers": numbers,
                "extras": extras
            },

            success: function(res) {
                var html_has_ganado = "";

                if (draw_numbers) {
                    draw_numbers.forEach(function(elem, index) {
                        let selected = elem.querySelector('.selected');
                        if (selected.classList.contains('selected')) {
                            selected.classList.remove('failed');

                            if (numbers[index].indexOf(selected.innerText) == -1) {
                                selected.classList.add('failed');
                            }
                        }
                    });
                }

                if (draw_extras) {
                    draw_extras.forEach(function(elem, index) {
                        let selected = elem.querySelector('.selected');
                        if (selected.classList.contains('selected')) {
                            selected.classList.remove('failed');

                            if (extras[index].indexOf(selected.innerText) == -1) {
                                selected.classList.add('failed');
                            }
                        }
                    });
                }

                if (res.total > 0) {
                    html_has_ganado += "Ha sido premiada con " + res.total + " €";
                } else if (res.other_info && res.other_info.bets && res.other_info.bets.detail && res.other_info.bets.detail.length) {
                    html_has_ganado += "Tiene un premio de categoría: " + res.other_info.bets.detail[0].name;
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
