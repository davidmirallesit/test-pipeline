<div class="container">
    <div class="row">
        <div class="col-12 col-md-12 mb-4">
            {% include 'partial/search/advanced_search_widget.volt' %}
        </div>
    </div>

    <div class="row">
        <div class="col-12 text-center">
            <h1 class="text-center">{{web_seo_onpage['h1']}}</h1>
        </div>

        {% if web_seo_onpage['txt_up'] is not empty %}
            <div class="col-12 text-center text-justify">
                <div>{{web_seo_onpage['txt_up']}}</div>
            </div>
        {% endif %}
    </div>

    <div class="row">
        <input type="hidden" id="number" value="{{number}}">
        <div class="col-12 col-md-12">
            {% if (stock == 0 and (randomNumbers|length) == 0) %}
                <div class="row buscador_numeros">
                    <div class="col-12 d-flex align-items-center justify-content-center py-4">
                        <h5 class="text-buscador-numeros m-0">Actualmente no hay stock dispobible para este sorteo</h5>
                    </div>
                </div>
            {% endif %}
            <div class="row buscador_numeros py-4">
                <div class="col-12 col-md-6 d-flex justify-content-center" id="play_img_container_big">
                    <img class="decimo" src="{{draw["ticket_img"]["lg"]}}">
                    {% if number %}
                        <div class="inputParticipaciones d-flex justify-content-center full-number-text">
                            <div class="text-center font-numlae full-number-text-size" id="num_loteria_mostrado">{{number}}</div>
                        </div>
                    {% endif %}
                    {% if show_availability | abs %}
                        {% if (show_min_availability | abs) %}
                            {% if (show_min_availability | abs) > stock %}
                                <span class="badge rounded-pill bg-danger pill_availability_box_searcher_full_number">Queda{% if stock > 1 %}n{% endif %}: {{ stock }}</span>                                                        
                            {% endif %}
                        {% else %}
                            <span class="badge rounded-pill bg-primary pill_availability_box_searcher_full_number">Queda{% if stock > 1 %}n{% endif %}: {{ stock }}</span>
                        {% endif %}
                    {% endif %}
                </div>

                <div class="col-12 col-md-6 text-center">
                    {% if stock > 0 %}
                        <div class="row justify-content-center mt-4">
                            <span class="span_cantidad_loteria_nacional">Cantidad</span>
                        </div>
                        <div class="row justify-content-center">
                            <div class="col-12 col-sm-6 col-lg-4">
                                <div class="input-group position_width_initial">
                                    <span class="input-group-btn">
                                        <button id="restar" type="button" class="btn p-0 my-1 btn-number button_transparent" disabled="disabled" data-type="minus"><i class="fa fa-minus-circle fa-2x" style="color: #D3D3D3"></i></button>
                                    </span>
                                    <input 
                                        id="quantity"
                                        type="text"
                                        name="{{number}}"
                                        class="form-control input-number cantidad_cupones cantidad_loteria_nacional mx-2"
                                        value="0"
                                        min="0"
                                        max="{% if !array_key_exists(number, stockInCart) %}{{stock}}{% else %}{{(stock - stockInCart[number])}}{% endif %}"
                                        size="2"
                                        autocomplete="off"
                                    >
                                    <span class="input-group-btn">
                                        <button id="sumar" type="button" class="btn p-0 my-1 btn-number button_transparent" data-type="plus"><i class="fa fa-plus-circle fa-2x" style="color: #D3D3D3"></i></button>
                                    </span>
                                </div>
                            </div>
                        </div>
                        <div class="row justify-content-center">
                            <button class="rounded-50 btn-verde-claro btn add-cart-ln" type="button" disabled id="button_add_cart">Añadir a la cesta</button>
                        </div>
                    {% else %}
                        <div class="row">
                            <div class="col-12">
                                Este número no está disponible
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12">
                                <form id="search-form" action="{{_SERVER["REQUEST_URI"]}}" method="POST" class="form-numero">
                                    <div class="row mt-3 d-flex justify-content-center">
                                        <div class="col-sm-6 col-md-4 col-6 col-lg-4 col-xl-4">
                                            <input oninput="inputNumber(event)" class="campo_numero py-3" maxlength="5" id="numero" name="numero" type="text" placeholder="Terminación" required="">
                                        </div>
                                        <div class="col-sm-12  col-md-12 col-lg-4 col-12 col-xl-4 justify-content-lg-start justify-content-end">
                                            <input class="rounded-50 btn-verde-claro btn" type="submit" value="BUSCAR NÚMERO">
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    {% endif %}
                </div>
            </div>
        </div>
    </div>

    {% if (stock == 0 and (randomNumbers|length) > 0) %}
        <div class="row mt-3">
            <div class="col-12">
                <h2>Otros números</h2>
            </div>
        </div>

        <div class="row justify-content-center">
            {% for value in randomNumbers %}
                {% include 'partial/search/tail_number' with ["class": 'col-10 col-sm-6 col-md-4 px-4 mb-3', "img": draw["ticket_img"]["lg"], "number": value.number, "stock": value.available] %}
            {% endfor %}
        </div>
    {% endif %}

    <div class="row">
        <div class="col-12 mt-3 mb-3">
            <div>
                <h2>Números por terminación</h2>
            </div>
            <div class="row ml-1 mt-3 justify-content-around">
                {% for i in -2..-5 %}
                    <a href="{{draw_url ~ search_url ~ config.search_urls.tailNumber ~ substr(number, i) }}" class="btn primary_color_background text_color_ws p-2 px-4 border col-auto">Terminados en {{substr(number, i)}}</a>
                {% endfor %}
            </div>
            <hr>
            {% include 'partial/search/tail_number_links.volt' %}
        </div>
    </div>

    {% if web_seo_onpage['txt_down'] is not empty %}
        <div class="row">
            <div class="col-12 text-center text-justify">
                <div>{{web_seo_onpage['txt_down']}}</div>
            </div>
        </div>
    {% endif %}
</div>

{% include 'partial/modals/continue_buying_or_cart.volt' %}
