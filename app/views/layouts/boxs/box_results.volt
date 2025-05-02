{% if sorteos is defined and sorteos is iterable %}
<div class="col-12 col-md-12 mt-2 box_results">
    <div class="row accordion mt-3" id="accordionExample">
        <div class="col-md-12 text-left">
            <span class="label_resultados">Resultados de {{game.name}}</span>
        </div>
        {% for key, s in sorteos %}
            <a id="anchor{{s['date']|date_format('d-m-Y')}}" style="margin-bottom: 20px"></a>
            <div class="col-md-12 p-1 mt-3" style="background-color: {% if loop.index is even %}#fcfcfc{% else %}#f8f8f8{% endif %}">
                <div class="row align-items-center" id="heading{{s['date']|date_format('d-m-Y')}}">
                    <div class="col-lg-5 text-center">
                        <span class="span_resultados" data-toggle="collapse" data-target="#collapse{{s['date']|date_format('d-m-Y')}}" aria-expanded="true" aria-controls="collapse{{s['date']|date_format('d-m-Y')}}">Resultados del {{s['date']|date_format('d-m-Y')}} <i class="fa fa-angle-down"></i></span>
                    </div>
                    <div class="col-lg-7 d-none d-flex justify-content-center align-items-center">
                        {% for num in s['bet'] %}
                            <div class="number_box fa-stack{% if game.id_type != constant('T_GAME_APUESTAS') %} fa-2x{% endif %} selected">
                                <i class="fa-stack-2x item_figure {{ get_item_css('number', 'figure', game, pv) }}"></i>
                                <span class="fa-stack-1x item_text">
                                {% if game_rules.is_custom_values_per_number %}
                                {{num}}
                                {% else %}
                                {{str_pad(num, (game.max_value_per_number|length), '0', constant('STR_PAD_LEFT'))}}
                                {% endif %}
                                </span>
                            </div>
                        {% endfor %}
                        {% if game.num_extra_per_bet > 0 %}
                        {% for num in s['extra'] %}
                            <div class="extra_box fa-stack{% if game.id_type != constant('T_GAME_APUESTAS') %} fa-2x{% endif %} selected">
                                <i class="fa-stack-2x item_figure {{ get_item_css('extra', 'figure', game, pv) }}"></i>
                                <span class="fa-stack-1x item_text">
                                {% if game_rules.is_custom_values_per_extra %}
                                {{num}}
                                {% else %}
                                {{str_pad(num, (game.max_value_per_number|length), '0', constant('STR_PAD_LEFT'))}}
                                {% endif %}
                                </span>
                            </div>
                        {% endfor %}
                        {% endif %}
                        {% if game.is_num_complementary %}
                            <div class="span_resultados ml-3">C</div>
                            <div class="complementary_box fa-stack{% if game.id_type != constant('T_GAME_APUESTAS') %} fa-2x{% endif %} selected">
                                <i class="fa-stack-2x item_figure {{ get_item_css('complementary', 'figure', game, pv) }}"></i>
                                <span class="fa-stack-1x item_text">
                                {% if s['other']['complementary'] is iterable %}
                                    {{implode(',', s['other']['complementary'])}}
                                {% else %}
                                    {{s['other']['complementary']}}
                                {% endif %}
                                </span>
                            </div>
                        {% endif %}
                        {% if game.is_num_refund and !game.is_link_num_refund_extra %}
                            <div class="span_resultados ml-3">R</div>
                            <div class="refund_box fa-stack{% if game.id_type != constant('T_GAME_APUESTAS') %} fa-2x{% endif %} selected">
                                <i class="fa-stack-2x item_figure {{ get_item_css('refund', 'figure', game, pv) }}"></i>
                                <span class="fa-stack-1x item_text">
                                {{s['other']['refund']}}
                                </span>
                            </div>
                        {% endif %}
                    </div>
                </div>
                <div id="collapse{{s['date']|date_format('d-m-Y')}}" class="row collapse{% if loop.first %} show{% endif %}" data-parent="#accordionExample" aria-labelledby="heading{{s['date']|date_format('d-m-Y')}}" style="justify-content: center; margin-top: 35px;">
                    <div class="col-md-10">
                        <div class="d-lg-none">
                            <div class="row" style="justify-content: center;">
                                {% for num in s['bet'] %}
                                <div class="number_box fa-stack{% if game.id_type != constant('T_GAME_APUESTAS') %} fa-2x{% endif %} selected">
                                    <i class="fa-stack-2x item_figure {{ get_item_css('number', 'figure', game, pv) }}"></i>
                                    <span class="fa-stack-1x item_text">
                                    {% if game_rules.is_custom_values_per_number %}
                                    {{num}}
                                    {% else %}
                                    {{str_pad(num, (game.max_value_per_number|length), '0', constant('STR_PAD_LEFT'))}}
                                    {% endif %}
                                    </span>
                                </div>
                                {% endfor %}
                                <span style="margin-left: 10px;"></span>
                            </div>
                            {% if game.num_extra_per_bet > 0 %}
                            <div class="row" style="justify-content: center;">
                                {% for num in s['extra'] %}
                                <div class="extra_box fa-stack{% if game.id_type != constant('T_GAME_APUESTAS') %} fa-2x{% endif %} selected">
                                    <i class="fa-stack-2x item_figure {{ get_item_css('extra', 'figure', game, pv) }}"></i>
                                    <span class="fa-stack-1x item_text">
                                    {% if game_rules.is_custom_values_per_extra %}
                                    {{num}}
                                    {% else %}
                                    {{str_pad(num, (game.max_value_per_number|length), '0', constant('STR_PAD_LEFT'))}}
                                    {% endif %}
                                    </span>
                                </div>
                            {% endfor %}
                            </div>
                            {% endif %}
                        </div>

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
{% endif %}
