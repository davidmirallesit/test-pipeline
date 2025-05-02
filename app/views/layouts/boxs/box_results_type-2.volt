<div class="col-12 col-md-12 mt-2 box_results">
    <div class="row accordion mt-3" id="accordionExample">
        <div class="col-md-12 text-left">
            <span class="label_resultados">Resultados de {{game.name}}</span>
        </div>
        {% for key, s in sorteos %}
        <a id="anchor{{s['date']|date_format('d-m-Y')}}" style="margin-bottom: 20px"></a>
        <div class="col-md-12 p-1 mt-3" style="background-color: {% if loop.index is even %}#fcfcfc{% else %}#f8f8f8{% endif %}">
            <div class="row align-items-center" id="heading{{s['date']|date_format('d-m-Y')}}">
                <div class="col-lg-12 text-center">
                    <span class="span_resultados" data-toggle="collapse" data-target="#collapse{{s['date']|date_format('d-m-Y')}}" aria-expanded="true" aria-controls="collapse{{s['date']|date_format('d-m-Y')}}">Resultados del {{s['date']|date_format('d-m-Y')}} <i class="fa fa-angle-down"></i></span>
                </div>
            </div>
            <div id="collapse{{s['date']|date_format('d-m-Y')}}" class="row collapse{% if loop.first %} show{% endif %}" data-parent="#accordionExample" aria-labelledby="heading{{s['date']|date_format('d-m-Y')}}" style="justify-content: center; margin-top: 35px;">
                <div class="col-lg-6 pl-5 separator_sections">
                    {% for num_number in 1..game_rules.num_number_per_bet %}
                    {% set match = s['other']['matches'][num_number-1] %}
                    <div class="row">
                        <div class="col-3">
                            <span class="match_name">{{match['team_1_name']}}</span>
                        </div>
                        <div class="col-1 p-0 text-center">
                            -
                        </div>
                        <div class="col-3">
                            <span class="match_name">{{match['team_2_name']}}</span>
                        </div>
                        <div class="col-5 number_container">
{% if game_rules.is_custom_values_per_number %}
{% set custom_values = json_decode(game_rules.custom_values_per_number, true) %}
                            {% for num in custom_values %}
                                <div class="number_box fa-stack{% if num == s['bet'][num_number-1] %} selected{% endif %}">
                                    <i class="fa-stack-2x item_figure {{ get_item_css('number', 'figure', game_rules, datosAdmon) }}"></i>
                                    <span class="fa-stack-1x item_text">
                                    {{num}}
                                    </span>
                                </div>
                            {% endfor %}
{% else %}
                            {% for num in game_rules.min_value_per_number..game_rules.max_value_per_number %}
                                <div class="number_box fa-stack{% if num == s['bet'][num_number-1] %} selected{% endif %}">
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
                        {% if s['other']['matches'][game_rules.num_number_per_bet+game_rules.num_extra_per_bet-1] is defined %}
                        {% for num_number in (game_rules.num_number_per_bet+1)..(game_rules.num_number_per_bet+game_rules.num_extra_per_bet) %}
                        {% set match = s['other']['matches'][num_number-1] %}
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
                            <div class="col-5 extra_container">
                                {% if game_rules.is_custom_values_per_extra %}
                                {% set custom_values = json_decode(game_rules.custom_values_per_extra, true) %}
                                {% for num in custom_values %}
                                    <div class="extra_box fa-stack{% if num == s['extra'][num_number - game_rules.num_number_per_bet - 1] %} selected{% endif %}">
                                        <i class="fa-stack-2x item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }}"></i>
                                        <span class="fa-stack-1x item_text">
                                        {{num}}
                                        </span>
                                    </div>
                                {% endfor %}
                                {% else %}
                                {% for num in game_rules.min_value_per_extra..game_rules.max_value_per_extra %}
                                    <div class="extra_box fa-stack{% if num in s['extra'][num_number - game_rules.num_number_per_bet - 1] %} selected{% endif %}">
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
                        {% if s['other']['matches'][num_number-1] is defined %}
                        {% set match = s['other']['matches'][num_number-1] %}
                        <div class="row">
                            <div class="col-6">
                                <span class="match_name" id="name_match_{{match['position']}}_team_1">{{match['team_1_name']}}</span>
                            </div>
                            <div class="col-6 extra_container">
                                {% if game_rules.is_custom_values_per_extra %}
                                {% set custom_values = json_decode(game_rules.custom_values_per_extra, true) %}
                                {% for num in custom_values %}
                                    <div class="extra_box fa-stack{% if num in s['extra'][num_number - game_rules.num_number_per_bet - 1] %} selected{% endif %}">
                                        <i class="fa-stack-2x item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }}"></i>
                                        <span class="fa-stack-1x item_text">
                                        {{num}}
                                        </span>
                                    </div>
                                {% endfor %}
                                {% else %}
                                {% for num in game_rules.min_value_per_extra..game_rules.max_value_per_extra %}
                                    <div class="extra_box fa-stack{% if num in s['extra'][num_number - game_rules.num_number_per_bet - 1] %} selected{% endif %}">
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
                            <div class="col-6 extra_container">
                                {% if game_rules.is_custom_values_per_extra %}
                                {% set custom_values = json_decode(game_rules.custom_values_per_extra, true) %}
                                {% for num in custom_values %}
                                    <div class="extra_box fa-stack{% if num in s['extra'][num_number - game_rules.num_number_per_bet] %} selected{% endif %}">
                                        <i class="fa-stack-2x item_figure {{ get_item_css('extra', 'figure', game_rules, datosAdmon) }}"></i>
                                        <span class="fa-stack-1x item_text">
                                        {{num}}
                                        </span>
                                    </div>
                                {% endfor %}
                                {% else %}
                                {% for num in game_rules.min_value_per_extra..game_rules.max_value_per_extra %}
                                    <div class="extra_box fa-stack{% if num in s['extra'][num_number - game_rules.num_number_per_bet] %} selected{% endif %}">
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

                <div class="col-lg-6">
                    {% if s['winnings'] is iterable %}
                    <div class="col_der_resultados table-responsive-sm margin_top_responsive">
                        <!--ini col der resultados juego-->
                        <table class="resultados_tabla table table-sm table-striped">
                            <tbody>
                                <tr class="resultados_tabla_titulo" height="27">
                                    <td>CATEGORIA</td>
                                    <td align="right">APUESTAS</td>
                                    <td style="min-width: 110px;" align="right">PREMIOS</td>
                                    {% if s['winnings'][array_key_first(s['winnings'])]['winners-eu'] is defined %}
                                    <td style="min-width: 110px;" align="right">ACERTANTES EUROPA</td>
                                    {% endif %}
                                </tr>
                                {% for key, row in s['winnings'] %}
                                <tr>
                                    <td class='f1i'>{{row['name']}}</td>
                                    <td class='f1d' align='right'>{{row['winners']|number_int}}</td>
                                    <td class='f1d' align='right'>{{row['prize']|number_float}}</td>
                                    {% if row['winners-eu'] is defined %}
                                    <td class='f1d' align='right'>{{row['winners-eu']|number_int}}</td>
                                    {% endif %}
                                </tr>
                                {% endfor %}
                            </tbody>
                        </table>
                        <div class="clear"></div>
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
                            <a target='_blank' href='{{url_lista}}' class='d-block w-50 btn btn-small btn-success mx-auto small pb-2 '>Ver lista oficial {{game.name}}</a>
                        {% endif %}
                        {% endif %}
                    </div>
                    {% endif %}
                </div>
            </div>
        </div>
        {% endfor %}
    </div>
</div>
