{% if lot_nac_enabled and info_sorteo is not null %}
<div class="mt-0 blog-post">
    <div class="post-content text-center bloque_azulClaro">
        <div class="bloque_numeros p-3">
            <h1 class="numeros_disponibles">Comprar lotería</h1>
            <span class="numeros_disponibles numeros_disponibles_negrita">
                {{info_sorteo['name_pretty']}}
            </span>
            <div class="row mt-4">
                <div class="info_decimo col-md-7 no-right-padding">
                    <img alt="Comprar Lotería Nacional" class="decimo" src="{{info_sorteo['ticket_img']['lg']}}" />
                </div>
                <div class="col-md-5 pl-1 no-left-padding">
                    <div class="row w-100 mr-0 ml-2 mt-2">
                        <div class="pl-0 pr-1 col-4 col-sm-6 col-md-4 col-lg-3">
                            <p class="text-dark text-left text-info-ticket">Precio:</p>
                        </div>
                        <div class="px-0 col-8 col-sm-6 col-md-8 col-lg-9">
                            {#   <span>Aqui va el precio</span>   #}
                            <p class="text-right text-info-ticket-result"><b>{{info_sorteo['price_ticket']}}€</b></p>
                        </div>
                    </div>
                    <div class="row w-100 mr-0 ml-2">
                        <div class="pl-0 pr-1 col-4 col-sm-6 col-md-4 col-lg-3">
                            <p class="text-dark text-left text-info-ticket">Fecha:</p>
                        </div>
                        <div class="px-0 col-8 col-sm-6 col-md-8 col-lg-9">
                            <p class="text-right text-info-ticket-result"><b>{{info_sorteo['date_draw']|date_format('d-m-Y')}}</b></p>
                        </div>
                    </div>
                    <div class="row w-100 mr-0 ml-2">
                        <div class="pl-0 pr-1 col-4 col-sm-6 col-md-4 col-lg-3">
                            <p class="text-dark text-left text-info-ticket">Sorteo:</p>
                        </div>
                        <div class="px-0 col-8 col-sm-6 col-md-8 col-lg-9">
                            <p class="text-right text-info-ticket-result"><b>{{info_sorteo['name_short']}}</b></p>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col d-flex justify-content-center text-right">
                            {# Primera letra en mas #}
                            <button class="btn-azul btn rounded-0 col-12 mx-0 my-1 dropdown-sorteos" data-toggle="collapse" data-target="#masNumeros" aria-expanded="false" aria-controls="collapseExample">
                                Ver más sorteos <i class='fa fa-caret-down' aria-hidden='true'></i>
                            </button>
                        </div>
                        <div class="collapse rounded-0 div-mas-sorteos" id="masNumeros">
                            {% for sorteo in proximos_sorteos_5 %}
                                <a class="btn-verde-claro btn-verde-mas-sorteos style_white_space btn rounded-0 col-12 text-white mx-0 my-1" href="loteria-nacional?idsorteo={{sorteo['id_draw']}}">
                                    <span class="row">
                                        <span class="col-3">
                                            {{sorteo['date_draw']|date_format('d-m-Y')}}
                                        </span>
                                        <span class="col-6">
                                            {{sorteo['name']}}
                                        </span>
                                        <span class="col-3">
                                            {{preg_replace('|([0-9]{4})([0-9]{3})|', '\2/\1', sorteo['id_draw'])}}
                                        </span>
                                    </span>
                                </a>
                            {% endfor %}
                        </div>
                    </div>
                    <div class="row mt-4 d-flex justify-content-end">
                        <div class="col-4 col-sm-6 col-md-6 col-lg-4 ">
                            <span class="span_total_loteria_nacional ">TOTAL:</span>
                        </div>
                        <div class="col-8 col-sm-6 col-md-6 col-lg-8 text-right d-flex justify-content-sm-start justify-content-md-center justify-content-lg-center justify-content-center">
                            <span class="span_total_loteria_nacional" id="price">0.00</span><span class="span_total_loteria_nacional">€</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row mt-4">
                <div class="col-md-12 selector_decimo">
                    <form action="./loteria-{% if id_featured == 4 %}navidad{% elseif id_featured == 5 %}nino{% else %}nacional{% endif %}" method="post">
                        <input type="hidden" name="idsorteo" value="{{info_sorteo['id_draw']}}" />
                        <input type="hidden" name="iddraw" value="{{info_sorteo['id']}}" />
                        <input type="hidden" name="datedraw" value="{{info_sorteo['date_draw']}}" />
                        <input type="hidden" name="pricedraw" value="{{info_sorteo['price_ticket']}}" />
                        <div class="row mt-0">
                            {% if numeros_sorteo is empty %}
                                <p class="text-danger bold">No hay números disponibles para este sorteo</p>
                            {% else %}
                                <div class="col-12 col-md-6 col-lg-6">
                                    <p>Selecciona la cantidad deseada y añade a la cesta</p>
                                </div>
                                {#  si el sorteo elegido esta en el buscador mostrar ese buscador sino un boton que te lleva a comprar #}
                                {% if hasFeaturedSearcher %}
                                    <div class="col-12 col-md-6 col-lg-6">
                                        <div class="row align-items-center" id="mini_searcher_inputs">
                                            <div class="col-12 col-sm-6 col-md-5 col-xl-6">
                                                <input oninput="inputNumber(event)" class="text-center" maxlength="5" type="text" placeholder="Terminación" style="width: 100%;">
                                            </div>
                                            <div class="w-100 p-2 d-sm-none"></div>
                                            <div class="col-12 col-sm-6 col-md-7 col-xl-6">
                                                <button class="rounded-50 btn-verde-claro btn mt-0" data-full-number="{{this.config.search_urls.fullNumber}}" data-tail-number="{{this.config.search_urls.tailNumber}}" data-to="/{{key(featuredSearcherUrl)}}/{{featuredSearcherUrl[key(featuredSearcherUrl)]}}">BUSCAR NÚMERO</button>
                                            </div>
                                        </div>
                                    </div>
                                {% else %}
                                    <div class="col-12 col-md-6 col-lg-6">
                                        <button onclick="" id="button_buscar_numero" class="btn button_buscar_numero">BUSCAR NÚMERO</button>
                                    </div>
                                {% endif %}
                                {# <p class="text-center col-12 pb-0 mb-0">Selecciona la cantidad deseada y añade a la cesta</p> #}
                                {% for numero in numeros_sorteo %}
                                <div class="col-12 col-lg-6 col-md-6 item_loteria_nacional">
                                    <div class="row container_loteria_nacional">
                                        <div class="pull-left image_box_loteria_nacional">
                                            <div class="image_loteria_nacional">
                                                <img src="{{all_games[idLn].logo}}" style="width: 52%;">
                                            </div>
                                        </div>
                                        <div class="pull-right-boleto numbers_box_loteria_nacional">
                                            <div class="pull-left number_box_loteria_nacional">
                                                <span class="span_loteria_nacional">Lotería Nacional</span>
                                                <span class="span_number_loterial_nacional">{{numero.number}}</span>
                                            </div>
                                            <div class="pull-right-boleto number_box_loteria_nacional">
                                                <span class="span_cantidad_loteria_nacional">Cantidad</span>
                                                <div class="input-group float-right position_width_initial margin_div_cantidad_loteria_nacional">
                                                    <span class="input-group-btn">
                                                        <button type="button" class="btn p-0 my-1 btn-number button_transparent" disabled="disabled" data-type="minus" data-field="{{numero.number}}"><i class="fa fa-minus-circle fa-2x" style="color: #D3D3D3"></i></button>
                                                    </span>
                                                    <input onchange="lotteryChangedSelectedQuantity()" oninput="checkQuantityLottery(event)" type="text" name="{{numero.number}}" class="form-control input-number cantidad_cupones cantidad_loteria_nacional" value="0" min="0" max="{{numero.available}}" size="2">
                                                    <span class="input-group-btn">
                                                        <button type="button" class="btn p-0 my-1 btn-number button_transparent" data-type="plus" data-field="{{numero.number}}"><i class="fa fa-plus-circle fa-2x" style="color: #D3D3D3"></i></button>
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                {% endfor %}
                            {% endif %}
                        </div>

                        <div class="row align-items-start mt-3 row-seleccionar-mostrar-anyadir">
                            <div class="col-12 col-lg-5 col-md-6 col-sm-12">
                                <a href="loteria-{% if id_featured == 4 %}navidad{% elseif id_featured == 5 %}nino{% else %}nacional{% endif %}?aleatorio=S&idsorteo={{sorteo_id}}" class="btn button_seleccionar_numero_aleatorio_row_multi">Seleccionar un numero aleatorio</a>
                            </div>
                            <div class="col-12 col-lg-3 col-sm-12 col-md-3 align-self-start col-button-anyadir">
                                {% if numeros_sorteo is not empty %}
                                    <button onclick="this.form.submit()" id="button_anyadir_cesta" class="btn button_anyadir_a_la_cesta_row_multi">Añadir a la cesta</button>
                                {% endif %}
                            </div>
                            <div class="col-12 col-lg-4 col-sm-12 col-md-3 style_mostrar_mas_multi">
                                <a class="style_mostrar_mas_multi" href="./loteria-{% if id_featured == 4 %}navidad{% elseif id_featured == 5 %}nino{% else %}nacional{% endif %}?idsorteo={{sorteo_id}}&amp;todos=S"><i class="fa fa-plus-circle" style="color: #D3D3D3; font-size: 1.5em;"></i> Mostrar más</a>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="col-12 py-3">
                    <p class="small">
                        {# Última actualización: 25/03/2019 a las 12:44.  #}
                        (*) Cuando haga un pedido de Lotería Nacional usted está adquiriendo décimos oficiales
                        (en formato pre-impreso o resguardo) cobrables en cualquier administración de loterías.
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>
{% endif %}
