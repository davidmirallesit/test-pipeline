{#</section> <!-- Se cierra el section class container que se crea en sections phtml -->
{#<div class="row" style="margin:0 !important;">#}
    <div class="container-fluid">
        {% include 'layouts/boxs/box_community_header.volt' %}
    </div>
{#</div>#}

{% if community_info %}
    <div class="container">
        <div class="row mt-4 mb-4">
            <div class="col columna-logo-empresa">
                <img class="logo-empresa-venta-participaciones" src="{{community_info.url_image}}">
                {# <!--Tamaño fijo imagen (Ajustaremos a medidas zeplin)--> #}
            </div>
        </div>
    </div>

    {% if community_info.name is defined %}
    <div class="col-12 d-flex justify-content-center bg-azul">
        <h1 class="mb-0 pt-2 pb-2 text-center text-header" style="font-size: 36px; line-height: 1.22">{{community_info.name}}</h1>
    </div>
    {% endif %}

    <div class="row bigParticipaciones" style="background-image: url('{{community_info.background}}'); width: 100%; margin:0 !important;">
        {% if !community_info.background and community_info.subtitle %}
            <div class="row d-flex justify-content-center bg-azul">
                <div class="col mt-3">
                    <h2 class="text-center text-header" style="font-size: 36px; line-height: 1.22; font-weight: normal;">{{community_info.subtitle}}</h2>
                </div>
            </div>
        {% endif %}
        {% if is_active %}
            <div class="container">
                {% if community_info.subtitle and community_info.background %}
                    <div class="row d-flex justify-content-center">
                        <div class="col mt-5">
                            <h2 class="text-center text-header" style="font-size:36px; color: white; line-height: 1.22; font-weight: normal;">{{community_info.subtitle}}</h2>
                        </div>
                    </div>
                {% endif %}
                <div class="row mt-4 mb-4" style="background-color: #3c5076; box-shadow: 0 0 20px 0 #0000000d; border-radius: 6px">
                    <div class="col mb-4 d-flex justify-content-center">
                        <div class="row">
                            <div class="col-12 d-flex justify-content-center mt-5 mb-4">
                                <select id="select_participaciones" name="fecha" class="" style="width:100%; height: 50px; border-radius: 6px; margin:0 !important" onchange="changedPlay(this)" autocomplete="off">
                                    {# <!--<option class="" selected value="">Sorteo extraordinario de navidad</option>--> #}
                                    {% for i, play_info in community_plays %}
                                        <option value="{{play_info.uuid}}" {% if i == selected_community_index %}selected="selected"{% endif %}>{{play_info.name}}</option>
                                    {% endfor %}
                                </select>

                                {# //var assignation #}
                                {% if community_plays[selected_community_index].products[array_keys(community_plays[selected_community_index].products)[0]]["numbers"] %}
                                {% set numbers = [] %}
                                {% for k, number in community_plays[selected_community_index].products[array_keys(community_plays[selected_community_index].products)[0]]["numbers"] %}
                                    {% set numbers[numbers | length] = array_keys(number)[0] %}
                                {% endfor %}
                                {{void_output(sort(numbers))}}
                                {% set numOpciones = count(numbers) %}
                                {% endif %}
                            </div>
                            <div class="col-12 d-flex justify-content-center" id="play_img_container_big">
                                {% if community_plays[selected_community_index].url_image is defined %}
                                    <img class="custom-img-responsive" src="{{community_plays[selected_community_index].url_image}}">
                                {% elseif (community_plays[selected_community_index].products[array_keys(community_plays[selected_community_index].products)[0]]["draw"] is defined and community_plays[selected_community_index].products[array_keys(community_plays[selected_community_index].products)[0]]["draw"][array_keys(community_plays[selected_community_index].products[array_keys(community_plays[selected_community_index].products)[0]]["draw"])[0]]["ticket_img"] is defined) %}
                                    <img class="custom-img-responsive" src="{{community_plays[selected_community_index].products[array_keys(community_plays[selected_community_index].products)[0]]["draw"][array_keys(community_plays[selected_community_index].products[array_keys(community_plays[selected_community_index].products)[0]]["draw"])[0]]["ticket_img"]["lg"]}}">
                                    {% if numOpciones > 0 %}
                                        <div class="inputParticipaciones d-flex justify-content-center" style="position: absolute;width: 45%;height: 15%;margin-top: 8%;margin-left: 12%;border-radius: 6px;background-color: transparent;">
                                            <button onclick="mostrarNum(-1)" class="button-prev" style="outline: none; background-color: transparent; border:hidden; width: 100%;"><span class="span_prev no_display">&lt;</span></button>
                                            <div style="align-items: center;outline: none;border: hidden;font-size: min(7vw,50px);display: flex;" class="text-center font-numlae" id="num_loteria_mostrado">{{numbers[0]}}</div>
                                            <button onclick="mostrarNum(1)" class="button-next" style="outline: none; background-color: transparent; border:hidden; width: 100%" {% if numOpciones < 2 %} disabled{% endif %}><span class="span_next{% if numOpciones < 2 %} no_display{% endif %}">&gt;</span></button>
                                        </div>
                                    {% endif %}
                                {% endif %}
                            </div>
                            <div class="col-12 d-flex justify-content-center align-items-center flex-column mt-3 mb-1" id="info_restantes_big">
                                {% if participaciones_individuales and (participaciones_individuales|length) > 1 and community_plays[selected_community_index].is_individual == 1 %}
                                    {% if strtotime(selected_participaciones_individuales[array_keys(selected_participaciones_individuales)[0]]["draw_date_formated"]) < strtotime('now') %}
                                        <p class="mb-0" style="color: white;">Sorteo realizado el <b>{{selected_participaciones_individuales[array_keys(selected_participaciones_individuales)[0]]["draw_date"]}}</b></p>
                                    {% elseif strtotime(community_plays[selected_community_index].date_end) < strtotime('now') %}
                                        <p class="mb-0" style="color: white;">Periodo de venta cerrado el <b>{{community_plays[selected_community_index].date_end|date_format('d/m/Y')}}</b></p>
                                    {% else %}
                                        {% for individual_restantes in selected_participaciones_individuales %}
                                        <div class="row w-100 justify-content-center align-items-center flex-column">
                                            <p class="mb-0" style="color: white;">Hay <b><span>{{individual_restantes["quantity"]}}</span></b>&nbsp;<span>{% if community_plays[selected_community_index].is_fractional %}Participaciones{% else %}Décimos{% endif %}</span>&nbsp;disponibles del nº: {{individual_restantes["number"]}}.</p>
                                            {% if drawsOnPlay[individual_restantes['uuid']] > 1 %}
                                                <div>
                                                    <p style="color: white;">{{individual_restantes["draw_name"]}}&nbsp;-&nbsp;{{individual_restantes['draw_date']}}</p>
                                                </div>
                                            {% endif %}
                                        </div>
                                        {% endfor %}
                                    {% endif %}
                                {% else %}
                                    <p class="mb-0" style="color: white;">
                                    {% if strtotime(community_plays[selected_community_index].date_end) < strtotime('now') %}
                                        Periodo de venta cerrado el <b>{{community_plays[selected_community_index].date_end|date_format('d/m/Y')}}</b>
                                    {% else %}
                                        Quedan <b><span>{% if community_plays[selected_community_index] %}{{floor((community_plays[selected_community_index].total_price_play - community_plays[selected_community_index].buyed.total) / community_plays[selected_community_index].price_play)}}{% else %}0{% endif %}</span></b>
                                        <span>{% if community_plays[selected_community_index].is_fractional %}Participaciones{% else %}Décimos{% endif %}</span>.
                                    {% endif %}
                                    </p>
                                {% endif %}

                                {% if community_plays[selected_community_index].min_import_by_user or community_plays[selected_community_index].max_import_by_user %}
                                    <p class="mb-0" style="color: white;">
                                        {% if community_plays[selected_community_index].min_import_by_user %}
                                            Importe mínimo <b><span id="min_import_big">{{community_plays[selected_community_index].min_import_by_user}}</span> €</b>
                                        {% endif %}
                                        {% if community_plays[selected_community_index].max_import_by_user %}
                                            Importe máximo <b><span id="max_import_big">{{community_plays[selected_community_index].max_import_by_user}}</span> €</b>
                                        {% endif %}
                                        {% if !community_plays[selected_community_index].price_donation %}
                                            sin donativo
                                        {% endif %}
                                    </p>
                                {% endif %}
                            </div>

                        <div class="col-12 d-flex justify-content-center mb-4">
                            <p style="color: white; font-size: 16px">
                                {% if community_plays[selected_community_index].price_play %}
                                Juegas <span id="spanPricePlayBig">{{community_plays[selected_community_index].price_play|number_float}}</span>€
                                {% endif %}
                                {% if community_plays[selected_community_index].price_donation %}
                                &nbsp;<img src="/img/manoVentaParticipaciones.svg"> &nbsp;Donativo:
                                <span id="spanDonationPlayBig">{{community_plays[selected_community_index].price_donation|number_float}}</span>€
                                {% endif %}
                            </p>
                        </div>
                    </div>
                </div>
                <div class="col-1 d-flex justify-content-center">
                    <div class="vertical-hr" style="border: solid 1px white;"></div>
                </div>
                <div class="col">
                    <div class="row">
                        <div class="col-12 d-flex justify-content-center mt-5 mb-2">
                            <p style="color: white; font-size: 24px;" id="texto_tipoJugada_big">{% if community_plays[selected_community_index].is_fractional %}Participaciones{% else %}Décimos{% endif %}</p>
                        </div>
                        <div class="col-12 d-flex justify-content-center mb-4" id="inputParticipacionesContainer">
                            {% if numOpciones is defined and numOpciones > 1 and community_plays[selected_community_index].is_individual %}
                                <div class="row w-100 justify-content-center">
                                    {% for i in 0..numOpciones %}
                                        <div class="d-flex justify-content-center w-100 mb-2" style="color:white; font-size: 24px; font-weight:600;">{{numbers[i]}}</div>
                                        <div class="inputParticipaciones d-flex justify-content-center mb-3" style="height: 50px; border-radius: 6px; background-color: white">
                                            <button onclick="resta({{i}})" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;"><i class="fa fa-minus-circle fa-3x" style="color: #D3D3D3"></i></button>
                                            <input autocomplete="off" value=0 type="text" style="outline: none; border: hidden; font-size: 24px; font-weight: 600;" class="text-center" id="numParticipaciones_{{i}}" name="numParticipaciones" data-play="{{community_plays[selected_community_index].uuid}}" data-number="{{numbers[i]}}">
                                            <button onclick="suma({{i}})" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;"><i class="fa fa-plus-circle fa-3x" style="color: #D3D3D3"></i></button>
                                        </div>
                                    {% endfor %}
                                </div>
                            {% else %}
                                {% set numOpciones = 1 %}
                                <div class="inputParticipaciones d-flex justify-content-center" style="height: 50px; border-radius: 6px; background-color: white">
                                    <button onclick="resta(0)" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;"><i class="fa fa-minus-circle fa-3x" style="color: #D3D3D3"></i></button>
                                    <input autocomplete="off" value=0 type="text" style="outline: none; border: hidden; font-size: 24px; font-weight: 600;" class="text-center" id="numParticipaciones_0" name="numParticipaciones" data-play="{{community_plays[selected_community_index].uuid}}">
                                    <button onclick="suma(0)" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;"><i class="fa fa-plus-circle fa-3x" style="color: #D3D3D3"></i></button>
                                </div>
                            {% endif %}
                        </div>
                        <div class="col-12 d-flex justify-content-center">
                            <p style="color: white; font-size: 24px"> Importe total</p>
                        </div>
                        <div class="col-12 mb-3">
                            <hr class="special-hr">
                        </div>
                        <div class="col-12 d-flex justify-content-center mb-5">
                            <p style="color:white; font-size: 50px" id="total_price_big">0,00 €</p>
                        </div>
                        <div class="col-12 mb-4 d-flex justify-content-center">
                            <button onclick="guardarEnCarrito()" class="text-center" id="button_compra_big" style="color:white; background-color: #7e7e7e; border-radius: 34px;
                                        width: 255px; height: 65px; border:none; font-size: 30px">Comprar</button>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row" id="rowTime">
                <div class="col-12 mb-2 d-flex justify-content-center no_display">
                    <p class="mt-2 " style="color: white; font-size: 32px"><img src="/img/reloj.svg"> &nbsp;&nbsp; <b>01</b>D &nbsp;<b>11</b>H &nbsp;<b>33</b>M &nbsp;<b>22</b>S</p>
                </div>
            </div>
            </div>
        {% endif %}
    </div>

    <div class="row smallParticipaciones" style="background-image: url('{{community_info.background}}');  width: 100%; margin:0 !important;">
        {% if !community_info.background and community_info.subtitle %}
            <div class="row d-flex justify-content-center bg-azul">
                <div class="col mt-3">
                    <h2 class="text-center text-header" style="font-size: 20px; line-height: 1.22; font-weight: normal;">{{community_info.subtitle}}</h2>
                </div>
            </div>
        {% endif %}
        {% if is_active %}
            <div class="container">
                {% if community_info.subtitle and community_info.background %}
                    <div class="row d-flex justify-content-center">
                        <h2 class="text-center mt-5 text-header" style="font-size:20px; color: white; line-height: 1.22; font-weight: normal;">{{community_info.subtitle}}</h2>
                    </div>
                {% endif %}
                <div class="d-flex justify-content-center">
                    <div class="row mt-4 mb-4" style="background-color: #3c5076; box-shadow:  0 0 20px 0 #0000000d; border-radius: 6px" id="panelSmallParticipaciones">
                        <div class="col-12 mt-3 mb-3 d-flex justify-content-center" id="smallSelectSorteo">
                            <select id="select_participaciones_small" name="fecha" class="" style=" height: 60px; border-radius: 6px; margin:0 !important" onchange="changedPlay(this)" autocomplete="off">
                                {% for play_info in community_plays %}
                                <option value="{{play_info.uuid}}"{% if ahora > play_info.date_end %} disabled{% endif %}>{{play_info.name}}</option>
                                {% endfor %}
                            </select>
                        </div>
                        <div class="col-12 mb-3 d-flex justify-content-center" id="play_img_container_small">
                            {% if community_plays[selected_community_index].url_image %}
                                <img class="custom-img-responsive" src="{{community_plays[selected_community_index].url_image}}">
                            {% elseif community_plays[selected_community_index].products[array_keys(community_plays[selected_community_index].products)[0]]["draw"] and community_plays[selected_community_index].products[array_keys(community_plays[selected_community_index].products)[0]]["draw"][array_keys(community_plays[selected_community_index].products[array_keys(community_plays[selected_community_index].products)[0]]["draw"])[0]]["ticket_img"] %}
                                <img class="custom-img-responsive" src="{{community_plays[selected_community_index].products[array_keys(community_plays[selected_community_index].products)[0]]["draw"][array_keys(community_plays[selected_community_index].products[array_keys(community_plays[selected_community_index].products)[0]]["draw"])[0]]["ticket_img"]["lg"]}}">
                                {% if numOpciones %}
                                    <div class="inputParticipaciones d-flex justify-content-center" style="position: absolute;width: 45%;height: 15%;margin-top: 8%;margin-left: 12%;border-radius: 6px;background-color: transparent;">
                                        <button onclick="mostrarNum(-1)" class="button-prev" style="outline: none; background-color: transparent; border:hidden; width: 100%;">
                                            <span class="span_prev no_display">&lt;</span>
                                        </button>
                                        <div style="align-items: center;outline: none;border: hidden;font-size: min(7vw,50px);display: flex;" class="text-center font-numlae" id="num_loteria_mostrado_small">{{numbers[0]}}</div>
                                        <button onclick="mostrarNum(1)" class="button-next" style="outline: none; background-color: transparent; border:hidden; width: 100%" {% if numOpciones < 2 %} disabled{% endif %}><span class="span_next{% if numOpciones < 2 %} no_display{% endif %}">&gt;</span></button>
                                    </div>
                                {% endif %}
                            {% endif %}
                        </div>
                        <div class="col-12 d-flex justify-content-center align-items-center flex-column" id="info_restantes_small">
                            {% if participaciones_individuales and (participaciones_individuales|length) > 1 and community_plays[selected_community_index].is_individual == 1 %}
                                {% if strtotime(selected_participaciones_individuales[array_keys(selected_participaciones_individuales)[0]]["draw_date_formated"]) < strtotime('now') %}
                                    <p class="mb-0" style="color: white;">Sorteo realizado el <b>{{selected_participaciones_individuales[array_keys(selected_participaciones_individuales)[0]]["draw_date"]}}</b></p>
                                {% elseif strtotime(community_plays[selected_community_index].date_end) < strtotime('now') %}
                                    <p class="mb-0" style="color: white;">Periodo de venta cerrado el <b>{{community_plays[selected_community_index].date_end|date_format('d/m/Y')}}</b></p>
                                {% else %}
                                    {% for individual_restantes in selected_participaciones_individuales %}
                                    <div class="row w-100 justify-content-center align-items-center flex-column">
                                        <p class="mb-0" style="color: white;">Hay <b><span>{{individual_restantes["quantity"]}}</span></b>&nbsp;<span>{% if community_plays[selected_community_index].is_fractional %}Participaciones{% else %}Décimos{% endif %}</span>&nbsp;disponibles del nº: {{individual_restantes["number"]}}.</p>
                                        {% if drawsOnPlay[individual_restantes['uuid']] > 1 %}
                                            <div>
                                                <p style="color: white;">{{individual_restantes["draw_name"]}}&nbsp;-&nbsp;{{individual_restantes['draw_date']}}</p>
                                            </div>
                                        {% endif %}
                                    </div>
                                    {% endfor %}
                                {% endif %}
                            {% else %}
                                <p class="mb-0" style="color: white;">
                                {% if strtotime(community_plays[selected_community_index].date_end) < strtotime('now') %}
                                    Período de venta cerrado el <b>{{community_plays[selected_community_index].date_end|date_format('d/m/Y')}}</b>
                                {% else %}
                                    Quedan <b><span>{% if community_plays[selected_community_index] %}{{floor((community_plays[selected_community_index].total_price_play - community_plays[selected_community_index].buyed.total) / community_plays[selected_community_index].price_play)}}{% else %}0{% endif %}</span></b>
                                    <span>{% if community_plays[selected_community_index].is_fractional %}Participaciones{% else %}Décimos{% endif %}</span>.
                                {% endif %}
                                </p>
                            {% endif %}

                            {% if community_plays[selected_community_index].min_import_by_user or community_plays[selected_community_index].max_import_by_user %}
                                <p class="mb-0" style="color: white;">
                                    {% if community_plays[selected_community_index].min_import_by_user %}
                                        Importe mínimo <b><span id="min_import_big">{{community_plays[selected_community_index].min_import_by_user}}</span> €</b>
                                    {% endif %}
                                    {% if community_plays[selected_community_index].max_import_by_user %}
                                        Importe máximo <b><span id="max_import_big">{{community_plays[selected_community_index].max_import_by_user}}</span> €</b>
                                    {% endif %}
                                    {% if !community_plays[selected_community_index].price_donation %}
                                        sin donativo
                                    {% endif %}
                                </p>
                            {% endif %}
                        </div>

                    <div class="col-12 d-flex justify-content-center">
                        <p id="pDonativoResponsive" style="color: white; font-size: 16px">
                            {% if community_plays[selected_community_index].price_play %}
                            Juegas <span id="spanPricePlaySmall">{{community_plays[selected_community_index].price_play|number_float}}</span>€
                            {% endif %}
                            {% if community_plays[selected_community_index].price_donation %}
                            <img src="/img/manoVentaParticipaciones.svg"> &nbsp;Donativo: <span id="spanDonationPlaySmall">{{community_plays[selected_community_index].price_donation|number_float}}</span>€
                            {% endif %}
                        </p>
                    </div>

                    <div class="col-12 d-flex justify-content-center mb-4">
                        <div class="vertical-hr" style="border: solid 1px white; width: 100%"></div>
                    </div>
                    <div class="col-12">
                        <div class="row">
                            <div class="col-6 d-flex justify-content-center">
                                <p style="color:white; font-size: 24px" id="texto_tipoJugada_small">{% if community_plays[selected_community_index].is_fractional %}Participaciones{% else %}Décimos{% endif %}></p>
                            </div>
                            <div class="col-6 d-flex justify-content-center">
                                <p style="color:white; font-size: 24px">Importe</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-12 mb-4">
                        <div class="row d-flex align-items-center">
                            <div class="col-6 d-flex justify-content-center" id="inputParticipacionesContainer_small">
                                {% if numbers and (numbers|length) > 1 and community_plays[selected_community_index].is_individual %}
                                    <div class="row w-100 justify-content-center">
                                        {% for i in 0..numOpciones %}
                                            <div class="d-flex justify-content-center w-100 mb-2" style="color:white; font-size: 24px; font-weight:600;">{{numbers[i]}}</div>
                                            <div class="inputParticipaciones d-flex justify-content-center" style="width:166px; height: 50px; border-radius: 6px; background-color: white">
                                                <button onclick="resta({{i}})" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;"><i class="fa fa-minus-circle fa-3x" style="color: #D3D3D3"></i></button>
                                                <input autocomplete="off" value=0 type="text" style="outline: none; border: hidden; font-size: 24px; font-weight: 600;" class="text-center smallNumParticipaciones" id="smallNumParticipaciones_{{i}}" name="numParticipaciones" data-play="{{community_plays[selected_community_index].uuid}}" data-number="{{numbers[i]}}">
                                                <button onclick="suma({{i}})" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;"><i class="fa fa-plus-circle fa-3x" style="color: #D3D3D3"></i></button>
                                            </div>
                                        {% endfor %}
                                    </div>
                                {% else %}
                                    <div class="inputParticipaciones d-flex justify-content-center" style="width:166px; height: 50px; border-radius: 6px; background-color: white">
                                        <button onclick="resta(0)" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;"><i class="fa fa-minus-circle fa-3x" style="color: #D3D3D3"></i></button>
                                        <input autocomplete="off" value=0 type="text" style="outline: none; border: hidden; font-size: 24px; font-weight: 600;" class="text-center smallNumParticipaciones" id="smallNumParticipaciones_0" name="numParticipaciones" data-play="{{community_plays[selected_community_index].uuid}}">
                                        <button onclick="suma(0)" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;"><i class="fa fa-plus-circle fa-3x" style="color: #D3D3D3"></i></button>
                                    </div>
                                {% endif %}
                            </div>
                            <div class="col-6 d-flex justify-content-center">
                                <p style="color:white" id="total_price_small">0,00€</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-12 mb-4 d-flex justify-content-center">
                        <button onclick="guardarEnCarrito()" class="text-center" id="button_compra_small" style="color:white; background-color: #7e7e7e; border-radius: 34px;
                                            width: 255px; height: 65px; border:none; font-size: 30px">Comprar</button>
                    </div>
                </div>
            </div>
            <div class="row mb-5" id="rowTime">
                <div class="col-12 d-flex justify-content-center no_display">
                    <p style="color: white; font-size: 24px"><img src="/img/reloj.svg"> &nbsp;&nbsp; <b>01</b>D &nbsp;<b>11</b>H &nbsp;<b>33</b>M &nbsp;<b>22</b>S</p>
                </div>
            </div>
            </div>
        {% endif %}
    </div>

    <section class="container">
        {# <!-- Se vuelve a abrir el section class container  que cerrará el que viene de sections --> #}
        <div class="col mt-5 mb-5">
            <div class="row">
                {% for feature in community_info.features %}
                    <div class="col-12 col-sm-12 col-md-12 col-lg-6 col-xl-6 mb-4">
                        <div class="media">
                            <img style="width: 64px; height: 64px" src="{{feature["img"]}}" class="align-self-center mr-3" alt="...">
                            <div class="media-body">
                                <h6 class="mt-0">{{feature["title"]}}</h6>
                                <p>{{feature["text"]}}</p>
                            </div>
                        </div>
                    </div>
                {% endfor %}
            </div>
        </div>
    </section>

    <section class="container">
        {{community_info.content}}
    </section>
{% else %}
    <div class="container">
        <div class="row mt-4 mb-4">
            <div class="col">
                No se ha encontrado la entidad.
            </div>
        </div>
    </div>
{% endif %}

<script>
    var plays                        = {{json_encode(community_plays)}};
    let participaciones_individuales = {{json_encode(participaciones_individuales)}};
    let drawsOnPlay                  = {{json_encode(drawsOnPlay)}};
    var firstAvailablePlay           = {{selected_community_index}};
    var selectedPlay                 = "{{community_plays[selected_community_index].uuid}}";
    var community_uuid               = "{{community_info.uuid}}";
    var numParticipaciones           = 0;
    var numMostrado                  = 0;
    var maxParticipaciones           = plays[firstAvailablePlay] ? (plays[firstAvailablePlay]["num_parts"] ? Number(plays[firstAvailablePlay]["num_parts"]) : 0) : 0;
    var totalPrice                   = 0.00;
    var play_price                   = plays[firstAvailablePlay] ? (plays[firstAvailablePlay]["price_play"] ? parseFloat(plays[firstAvailablePlay]["price_play"]) : 0.00) : 0.00;
    var play_donation                = plays[firstAvailablePlay] ? (plays[firstAvailablePlay]["price_donation"] ? parseFloat(plays[firstAvailablePlay]["price_donation"]) : 0.00) : 0.00;
    var numOpciones                  = {{numOpciones|default(1)}};
    var id_game                      = "{{idLn|default(0)}}";

document.addEventListener("DOMContentLoaded", function(event) {
    $(window).on('load', refreshForm);
    $(document).on('input', '[id*="umParticipaciones_"]', function(event) {
        let moreParticipaciones = isNaN(parseInt(event.target.value)) ? 0 : parseInt(event.target.value)
        let uuidPlay = $(event.target).data('play')
        let numberPlay = $(event.target).data('number')
        let selectedPlay = plays.find(e => e.uuid == uuidPlay)
        let selectedPlayNumber

        if (numberPlay) {
            selectedPlayNumber = participaciones_individuales.find(e => e.number == numberPlay && e.uuid == uuidPlay)
        } else {
            selectedPlayNumber = participaciones_individuales.find(e => e.uuid == uuidPlay)
        }

        // si el sorteo ya ha pasado no dejar comprar más
        if (new Date(selectedPlayNumber.draw_date_formated) < new Date()) {
            event.preventDefault()
            $('[id*="umParticipaciones_' + event.target.id.split('_')[1] + '"]').val(0).trigger("change");
            return
        }

        // si ha terminado el periodo de venta de la jugada no dejar comprar más
        if (new Date(selectedPlay.date_end) < new Date()) {
            event.preventDefault()
            $('[id*="umParticipaciones_' + event.target.id.split('_')[1] + '"]').val(0).trigger("change");
            return
        }

        if (moreParticipaciones > selectedPlayNumber.quantity) {
            moreParticipaciones = selectedPlayNumber.quantity
        }

        // se cambia el precio al input movil/desktop
        $('[id*="umParticipaciones_' + event.target.id.split('_')[1] + '"]').val(moreParticipaciones).trigger("change");
        updateTotalPrice()
        updateBuyButton()
    })

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
});

    function refreshForm() {
        $('#select_participaciones').val($('#select_participaciones').find("option:not([disabled])").first().val()).trigger("change")
        $('[id*="umParticipaciones_"]').val(0).trigger("change")
        updateTotalPrice()
        updateBuyButton()
    }

    function changedPlay(selected) {
        selectedPlay        = selected.value;
        play_info           = getPlayByUUID(selectedPlay);
        play_price          = play_info["price_play"] ? parseFloat(play_info["price_play"]) : 0.00;
        play_donation       = play_info["price_donation"] ? parseFloat(play_info["price_donation"]) : 0.00;
        maxParticipaciones  = play_info["num_parts"] ? Number(play_info["num_parts"]) : 0;
        is_fractional       = play_info["is_fractional"];
        is_individual       = play_info["is_individual"];
        min_import          = play_info['min_import_by_user']
        max_import          = play_info['max_import_by_user']

        $('#select_participaciones, #select_participaciones_small').not('#' + selected.id).val(selected.value)

        maxParticipaciones = Math.floor((parseFloat(play_info["total_price_play"]) - parseFloat(play_info["buyed"]["total"])) / play_price);

        var divInfoRestantesContent = "";
        selectedParticipacionesIndividuales = participaciones_individuales.filter(e => e.uuid == selectedPlay)
        if (selectedParticipacionesIndividuales.length > 1 && is_individual) {
            if (new Date(selectedParticipacionesIndividuales[0].draw_date_formated) < new Date()) {
                divInfoRestantesContent += `<div class="row w-100 justify-content-center align-items-center flex-column">
                    <p class="mb-0" style="color: white;">
                        Sorteo realizado el <b>${selectedParticipacionesIndividuales[0].draw_date}</b>
                    </p></div>`
            } else if (new Date(play_info["date_end"]) < new Date()) {
                divInfoRestantesContent += `<div class="row w-100 justify-content-center align-items-center flex-column">
                    <p class="mb-0" style="color: white;">
                        Periodo de venta cerrado el <b>${new Date(play_info["date_end"]).toLocaleDateString('es-ES', {"dateStyle": "short"})}</b>
                    </p></div>`
            } else {
                selectedParticipacionesIndividuales.forEach(individual_restantes => {
                    divInfoRestantesContent += `<div class="row w-100 justify-content-center align-items-center flex-column">
                    <p class="mb-0" style="color: white;">
                        Hay <b><span>${individual_restantes["quantity"]}</span></b>
                        <span>${is_fractional ? 'Participaciones' : 'Décimos'}</span>
                        disponibles del nº: ${individual_restantes["number"]}.
                    </p>`;

                    if (drawsOnPlay[individual_restantes["uuid"]]) {
                        if (drawsOnPlay[individual_restantes["uuid"]].length > 1) {
                            divInfoRestantesContent += `<div><p style="color: white;">${individual_restantes['draw_name']}&nbsp;-&nbsp;${individual_restantes['draw_date']}</p></div>`;
                        }
                    }
                    divInfoRestantesContent += '</div>';
                });
            }
        } else {
            // no va a haber un is_individual con un producto
            // if (is_individual) {
            //     divInfoRestantesContent += `<p class="mb-0" style="color: white;">Hay <b><span>${maxParticipaciones}</span></b>&nbsp;<span>${is_fractional ? 'Participaciones' : 'Décimos'}</span>&nbsp;disponibles.</p>`;
            // } else {
            //     divInfoRestantesContent += `<p class="mb-0" style="color: white;">Quedan <b><span>${maxParticipaciones}</span></b>&nbsp;<span>${is_fractional ? 'Participaciones' : 'Décimos'}</span>.</p>`;
            // }
            if (new Date(selectedParticipacionesIndividuales[0].draw_date_formated) < new Date()) {
                divInfoRestantesContent += `<p class="mb-0" style="color: white;">Sorteo realizado el <b>${selectedParticipacionesIndividuales[0].draw_date}<b></p>`;
            } else if (new Date(play_info["date_end"]) < new Date()) {
                divInfoRestantesContent += `<p class="mb-0" style="color: white;">Periodo de venta cerrado el <b>${new Date(play_info["date_end"]).toLocaleDateString('es-ES', {"dateStyle": "short"})}<b></p>`;
            } else {
                divInfoRestantesContent += `<p class="mb-0" style="color: white;">Quedan <b><span>${maxParticipaciones}</span></b>&nbsp;<span>${is_fractional ? 'Participaciones' : 'Décimos'}</span>.</p>`;
            }
        }

        if (Number(min_import) && Number(max_import)) {
            divInfoRestantesContent += `<p class="mb-0" style="color: white;"">Importe mínimo <b><span id="min_import">${min_import}</span> €</b> Importe máximo <b><span id="max_import">${max_import}</span> €</b>${play_donation ? ' sin donativo' : ''}</p>`;
        } else if (Number(min_import)) {
            divInfoRestantesContent += `<p class="mb-0" style="color: white;"">Importe mínimo <b><span id="min_import">${min_import}</span> €</b>${play_donation ? ' sin donativo' : ''}</p>`;
        } else if (Number(max_import)) {
            divInfoRestantesContent += `<p class="mb-0" style="color: white;"">Importe máximo <b><span id="max_import">${max_import}</span> €</b>${play_donation ? ' sin donativo' : ''}</p>`;
        }

        $('#numParticipaciones').val(0);
        $('#smallNumParticipaciones').val(0);
        $("#total_price_big").html(formatNumber(0, 2, true));
        $("#total_price_small").html(formatNumber(0, 2, true));
        //$("#spanParticipacionesBig").html(maxParticipaciones);
        //$("#spanParticipacionesSmall").html(maxParticipaciones);
        $("#info_restantes_big").html(divInfoRestantesContent);
        $("#info_restantes_small").html(divInfoRestantesContent);
        $("#spanPricePlayBig").html(formatNumber(play_price, 2));
        $("#spanPricePlaySmall").html(formatNumber(play_price, 2));
        $("#spanDonationPlayBig").html(formatNumber(play_donation, 2));
        $("#spanDonationPlaySmall").html(formatNumber(play_donation, 2));

        if (is_fractional) {
            $("#texto_tipoJugada_big").html("Participaciones");
            $("#texto_tipoJugada_small").html("Participaciones");
            $("#spanTipoJugadaBig").html("Participaciones");
            $("#spanTipoJugadaSmall").html("Participaciones");
        } else {
            $("#texto_tipoJugada_big").html("Décimos");
            $("#texto_tipoJugada_small").html("Décimos");
            $("#spanTipoJugadaBig").html("Décimos");
            $("#spanTipoJugadaSmall").html("Décimos");
        }

        var firstProduct = null;
        if (play_info["products"] && Object.keys(play_info["products"])[0]) {
            firstProduct = play_info["products"][Object.keys(play_info["products"])[0]];
            id_game = Object.keys(play_info["products"])[0];
        } else {
            id_game == "0";
        }

        var imgHTML = "";

        if (play_info["url_image"]) {
            imgHTML += '<img class="custom-img-responsive" src="' + play_info["url_image"] + '">';
        } else if (firstProduct && firstProduct["draw"] && firstProduct["draw"][Object.keys(firstProduct["draw"])[0]]["ticket_img"]) {
            imgHTML += '<img class="custom-img-responsive" src="' + firstProduct["draw"][Object.keys(firstProduct["draw"])[0]]["ticket_img"]["lg"] + '">';
        }

        var numbers = [];
        var plays = null;
        if (firstProduct && firstProduct["numbers"]) {
            plays = Object.keys(firstProduct["numbers"]);
            if (plays) {
                plays.sort(function(a, b) {
                    return a - b
                });
                for (var i = 0; i < plays.length; i++) {
                    var listOfNumbers = Object.keys(firstProduct["numbers"][plays[i]])
                    listOfNumbers.sort(function(a, b) {
                        return a - b
                    });
                    for (var j = 0; j < listOfNumbers.length; j++) {
                        numbers.push(listOfNumbers[j]);
                    }
                }
            }
        }
        if (!play_info["url_image"] && numbers) {
            imgHTML += '<div class="inputParticipaciones d-flex justify-content-center" style="position: absolute;width: 45%;height: 15%;margin-top: 8%;margin-left: 12%;border-radius: 6px;background-color: transparent;">';
            imgHTML += '<button onclick="mostrarNum(-1)" class="button-prev" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;"><span class="span_prev no_display"><</span></button>';
            imgHTML += '<div style="align-items: center;outline: none;border: hidden;font-size: min(7vw,50px);display: flex;" class="text-center font-numlae" id="num_loteria_mostrado">' + numbers[0] + '</div>';
            imgHTML += '<button onclick="mostrarNum(1)" class="button-next"style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;" ' + (numbers.length < 2 ? "disabled" : "") + '><span class="span_next ' + (numbers.length < 2 ? "no_display" : "") + '">></span></button>';
            imgHTML += '</div>';
        }

        var participacionesHTML = "";
        var participacionesSmallHTML = "";
        if (numbers && numbers.length > 1 && play_info["is_individual"]) {
            numOpciones = numbers.length;
            participacionesHTML += '<div class="row w-100 justify-content-center">';
            participacionesSmallHTML += '<div class="row w-100 justify-content-center">';
            for (var i = 0; i < numbers.length; i++) {
                participacionesHTML +=
                    `<div class="d-flex justify-content-center w-100 mb-2" style="color:white; font-size: 24px; font-weight:600;">
                ${numbers[i]}
            </div>
            <div class="inputParticipaciones d-flex justify-content-center mb-3" style="height: 75px; border-radius: 6px; background-color: white">
                <button onclick="resta(${i})" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;" >
                    <i class="fa fa-minus-circle fa-3x" style="color: #D3D3D3"></i>
                </button>
                <input value=0 type="text" style="outline: none; border: hidden; font-size: 24px; font-weight: 600;" class="text-center" id="numParticipaciones_${i}" name="numParticipaciones" data-play="${selectedPlay}" data-number="${numbers[i]}">
                <button onclick ="suma(${i})" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;">
                    <i class="fa fa-plus-circle fa-3x" style="color: #D3D3D3"></i>
                </button>
            </div>`;


                participacionesSmallHTML +=
                    `<div class="d-flex justify-content-center w-100 mb-2" style="color:white; font-size: 24px; font-weight:600;">
                ${numbers[i]}
            </div>
            <div class="inputParticipaciones d-flex justify-content-center" style="width:166px; height: 75px; border-radius: 6px; background-color: white">
                <button onclick="resta(${i})" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;" >
                    <i class="fa fa-minus-circle fa-3x" style="color: #D3D3D3"></i>
                </button>
                <input value=0 type="text" style="outline: none; border: hidden; font-size: 24px; font-weight: 600;" class="text-center smallNumParticipaciones" id="smallNumParticipaciones_${i}" name="numParticipaciones" data-play="${selectedPlay}" data-number="${numbers[i]}">
                <button onclick="suma(${i})" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;" >
                    <i class="fa fa-plus-circle fa-3x" style="color: #D3D3D3"></i>
                </button>
            </div>`
            }
            participacionesHTML += '</div>';
            participacionesSmallHTML += '</div>';
        } else {
            numOpciones = 1;
            participacionesHTML +=
                `<div class="inputParticipaciones d-flex justify-content-center" style="height: 75px; border-radius: 6px; background-color: white">
            <button onclick="resta(0)" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;" >
                <i class="fa fa-minus-circle fa-3x" style="color: #D3D3D3"></i>
            </button>
            <input value=0 type="text" style="outline: none; border: hidden; font-size: 24px; font-weight: 600;" class="text-center" id="numParticipaciones_0" name="numParticipaciones" data-play="${selectedPlay}">
            <button onclick ="suma(0)" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;" >
                <i class="fa fa-plus-circle fa-3x" style="color: #D3D3D3"></i>
            </button>
        </div>`

            participacionesSmallHTML +=
                `<div class="inputParticipaciones d-flex justify-content-center" style="width:166px; height: 75px; border-radius: 6px; background-color: white">
            <button onclick="resta(0)" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;" >
                <i class="fa fa-minus-circle fa-3x" style="color: #D3D3D3"></i>
            </button>
            <input value=0 type="text" style="outline: none; border: hidden; font-size: 24px; font-weight: 600;" class="text-center smallNumParticipaciones" id="smallNumParticipaciones_0" name="numParticipaciones" data-play="${selectedPlay}">
            <button onclick="suma(0)" style="outline: none; background-color: transparent; border:hidden; width: 100%; cursor: pointer;" >
                <i class="fa fa-plus-circle fa-3x" style="color: #D3D3D3"></i>
            </button>
        </div>`
        }
        $("#inputParticipacionesContainer").html(participacionesHTML);
        $("#inputParticipacionesContainer_small").html(participacionesSmallHTML)


        $("#play_img_container_big").html(imgHTML);
        $("#play_img_container_small").html(imgHTML.replace("num_loteria_mostrado", "num_loteria_mostrado_small"));
    }

    function formatDate(date_string) {
        var date = new Date(date_string);

        var year = date.getFullYear();
        var month = date.getMonth() + 1;
        var day = date.getDate();

        if (day < 10) {
            day = '0' + day;
        }
        if (month < 10) {
            month = '0' + month;
        }

        var formattedDate = day + '/' + month + '/' + year;
        return formattedDate;
    }

    function mostrarNum(option) {
        play_info = getPlayByUUID(selectedPlay);
        var firstProduct = play_info["products"][Object.keys(play_info["products"])[0]];
        if (firstProduct["numbers"]) {
            var numbers = [];
            var plays = null;
            if (firstProduct && firstProduct["numbers"]) {
                plays = Object.keys(firstProduct["numbers"]);
                plays.sort(function(a, b) {
                    return a - b
                });
                if (plays) {
                    for (var i = 0; i < plays.length; i++) {
                        var listOfNumbers = Object.keys(firstProduct["numbers"][plays[i]])
                        listOfNumbers.sort(function(a, b) {
                            return a - b
                        });
                        for (var j = 0; j < listOfNumbers.length; j++) {
                            numbers.push(listOfNumbers[j]);
                        }
                    }
                }
            }
            var mostrar = numMostrado + option;
            numMostrado = mostrar;
            if (numbers && numbers[mostrar]) {
                if (mostrar > 0) {
                    if ($(".span_prev").hasClass("no_display")) {
                        $(".span_prev").removeClass("no_display");
                    }
                } else {
                    if (!$(".span_prev").hasClass("no_display")) {
                        $(".span_prev").addClass("no_display");
                    }
                }
                if (mostrar >= (numbers.length - 1)) {
                    if (!$(".span_next").hasClass("no_display")) {
                        $(".span_next").addClass("no_display");
                    }
                } else {
                    if ($(".span_next").hasClass("no_display")) {
                        $(".span_next").removeClass("no_display");
                    }
                }
                $("#num_loteria_mostrado").html(numbers[mostrar]);
                $("#num_loteria_mostrado_small").html(numbers[mostrar]);
            }
        }
    }

    function suma(number = 0) {
        let moreParticipaciones = parseInt($('#numParticipaciones_' + number).val()) + 1;

        let uuidPlay = $('#numParticipaciones_' + number).data('play')
        let numberPlay = $('#numParticipaciones_' + number).data('number')
        let selectedPlay = plays.find(e => e.uuid == uuidPlay)
        let selectedPlayNumber, quantity, dateDraw

        if (numberPlay) {
            selectedPlayNumber = participaciones_individuales.find(e => e.number == numberPlay && e.uuid == uuidPlay)
            quantity = selectedPlayNumber.quantity
            dateDraw = selectedPlayNumber.draw_date_formated
        } else {
            // no individual
            quantity = Math.floor((parseFloat(play_info["total_price_play"]) - parseFloat(play_info["buyed"]["total"])) / play_price)
            dateDraw = selectedPlay.date_end
        }

        // si se intentan sumar más números de los que hay disponibles no deja
        if (moreParticipaciones > quantity) {
            return
        }

        // si se comprar más de lo que hay definido en el máximo no deja
        if (((numParticipaciones + 1) * play_price) > Number($('[id^="max_import"').first().text()) && $('[id^="max_import"').length) {
            customAlert("El importe máximo son " + $('[id^="max_import"').first().text() + " €" + (play_donation ? " sin contar el donativo" : ''));
            return
        }

        // si el sorteo ya ha pasado no dejar comprar más
        if (new Date(dateDraw) < new Date()) {
            return
        }

        // si ha terminado el periodo de venta de la jugada no dejar comprar más
        if (new Date(selectedPlay.date_end) < new Date()) {
            return
        }

        $('#numParticipaciones_' + number).val(moreParticipaciones)
        $('#smallNumParticipaciones_' + number).val(moreParticipaciones)
        updateTotalPrice()
        updateBuyButton()
    }

    function resta(number = 0) {
        let lessParticipaciones = parseInt($('#numParticipaciones_' + number).val()) - 1
        if (lessParticipaciones >= 0) {
            $('#smallNumParticipaciones_' + number).val(lessParticipaciones);
            $('#numParticipaciones_' + number).val(lessParticipaciones);
            updateTotalPrice()
            updateBuyButton()
        }
    }

    function getPlayByUUID(uuid) {
        var wanted_play = plays.find(element => element["uuid"] == uuid);
        return wanted_play;
    }

    function updateBuyButton() {
        if ($('[id^="min_import"').length) {
            if ((totalPrice - (play_donation * numParticipaciones)) >= Number($('[id^="min_import"').first().text())) {
                $("#button_compra_big").css("background-color", "#18a44b");
                $("#button_compra_small").css("background-color", "#18a44b"); // verde
            } else {
                $("#button_compra_big").css("background-color", "#7e7e7e"); // gris
                $("#button_compra_small").css("background-color", "#7e7e7e");
            }
        } else if ($('[id^="max_import"').length) {
            if (totalPrice > 0 && (totalPrice - (play_donation * numParticipaciones)) <= Number($('[id^="max_import"').first().text())) {
                $("#button_compra_big").css("background-color", "#18a44b");
                $("#button_compra_small").css("background-color", "#18a44b");
            } else {
                $("#button_compra_big").css("background-color", "#7e7e7e");
                $("#button_compra_small").css("background-color", "#7e7e7e");
            }
        } else {
            if (totalPrice > 0) {
                $("#button_compra_big").css("background-color", "#18a44b");
                $("#button_compra_small").css("background-color", "#18a44b");
            } else {
                $("#button_compra_big").css("background-color", "#7e7e7e");
                $("#button_compra_small").css("background-color", "#7e7e7e");
            }
        }
    }

    function updateTotalPrice() {
        updateNumParticipaciones()
        totalPrice = numParticipaciones * (play_price + play_donation);
        $("#total_price_big").html(formatNumber(totalPrice, 2) + " €");
        $("#total_price_small").html(formatNumber(totalPrice, 2) + " €");
    }

    function updateNumParticipaciones() {
        let participaciones = 0
        $('[id^="numParticipaciones_').each((i, e) => participaciones += parseInt(e.value))
        numParticipaciones = participaciones;
    }

    function guardarEnCarrito() {

        if (totalPrice <= 0) {
            return;
        }

        if ($('[id^="min_import"').length) {
            if ((totalPrice - (play_donation * numParticipaciones)) < Number($('[id^="min_import"').first().text())) {
                customAlert("El importe mínimo son " + $('[id^="min_import"').first().text() + " €" + (play_donation ? ' sin contar el donativo' : ''));
                return;
            }
        }

        if ($('[id^="max_import"').length) {
            if ((totalPrice - (play_donation * numParticipaciones)) > Number($('[id^="max_import"').first().text())) {
                customAlert("El importe máximo son " + $('[id^="max_import"').first().text() + " €" + (play_donation ? ' sin contar el donativo' : ''));
                return;
            }
        }

        var arrayParticipaciones = [];
        var lineasPedido = null;

        play_info = getPlayByUUID(selectedPlay);

        if (new Date(play_info.date_end) < new Date()) {
            customAlert("Ya se ha terminado el periodo de venta");
            return;
        }

        for (var i = 0; i < numOpciones; i++) {
            arrayParticipaciones.push(parseInt($('#numParticipaciones_' + i).val()));
            if (play_info["products"] && Object.keys(play_info["products"])[0]) {
                var firstProduct = play_info["products"][Object.keys(play_info["products"])[0]];
            }
        }

        if (play_info["is_individual"]) {
            lineasPedido = [];
            var firstProduct = play_info["products"][Object.keys(play_info["products"])[0]];
            if (firstProduct && firstProduct["numbers"]) {
                var numbers = [];
                var drawIds = [];
                var plays = null;
                if (firstProduct && firstProduct["numbers"]) {
                    plays = Object.keys(firstProduct["numbers"]);
                    plays.sort(function(a, b) {
                        return a - b
                    });
                    if (plays) {
                        for (var i = 0; i < plays.length; i++) {
                            var listOfNumbers = Object.keys(firstProduct["numbers"][plays[i]]);
                            listOfNumbers.sort(function(a, b) {
                                return a - b
                            });
                            for (var j = 0; j < listOfNumbers.length; j++) {
                                numbers.push(listOfNumbers[j]);
                                var drawId = firstProduct["draw"][plays[i]]["id_draw"];
                                drawIds.push(drawId);
                            }
                        }
                    }
                }
                for (var j = 0; j < numbers.length; j++) {
                    if (arrayParticipaciones[j] !== null && arrayParticipaciones[j] !== undefined) {
                        if (parseInt(arrayParticipaciones[j]) > 0) {
                            lineasPedido.push({
                                "quantity": arrayParticipaciones[j],
                                "number": numbers[j].toString(),
                                "id_draw": drawIds[j].toString()
                            });
                        }
                    } else {
                        console.log("revisar, no se encuentran 'numbers'");
                    }
                }
            } else {
                console.log("revisar, no se encuentran 'numbers'");
                lineasPedido.push({
                    "quantity": arrayParticipaciones[0]
                });
            }
        } else {
            lineasPedido = {
                "quantity": arrayParticipaciones[0]
            };
        }

        // el segundo uuid es de la campaña
        let objectCarrito = {
            "community_uuid": community_uuid,
            "uuid": selectedPlay,
            "lineasPedido": lineasPedido
        };

        $.ajax({
            type: "POST",
            url: "/guardarCarritoParticipaciones",
            data: objectCarrito,

            success: function(resData) {
                console.log(resData);
                location.href = "/carrito-comunidad";
            },
            error: function(e) {
                customAlert("Error al guardar la jugada");
            }
        });
    }
</script>
