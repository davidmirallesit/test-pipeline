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
        <div class="col-12 col-md-12">
            <input type="hidden" id="numbers_in_cart" value="{{implode(',', numbersInCart)}}">
            {% if (numbers|length) == 0 %}
                <div class="buscador_numeros">
                    <div class="row">
                        <div class="col-12 d-flex align-items-center justify-content-center py-4">
                            {% if ((numbers|length) == 0 and (randomNumbers|length) == 0) %}
                                <h5 class="text-buscador-numeros m-0">Actualmente no hay stock dispobible para este sorteo</h5>
                            {% else %}
                                <h5 class="text-buscador-numeros m-0">No hay números disponibles terminados en {{number}}</h5>
                            {% endif %}
                        </div>
                    </div>
                </div>
                {% if (randomNumbers|length) %}
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
            {% else %}
                <div class="row justify-content-center">
                    {% for value in numbers %}
                        {% include 'partial/search/tail_number' with ["class": 'col-10 col-sm-6 col-md-4 px-4 mb-3', "img": draw["ticket_img"]["lg"], "number": value.number, "stock": value.available] %}
                    {% endfor %}
                </div>
            {% endif %}
        </div>

    </div>
    <div class="row">
        <div class="col-12 mt-3 mb-3">
            <div class="col-12">
                <h2>Números por terminación</h2>
            </div>
            {% if (number|length) == 1 %}
                {% include 'partial/search/tail_number_links' with ["TAIL_NUMBER": number] %}
                <hr>
            {% elseif (number|length) > 2 %}
                <div class="row mt-3 justify-content-around">
                    {% for i in -2..(-1 * (number|length)) %}
                        <a href="{{draw_url ~ search_url ~ config.search_urls.tailNumber ~ substr(number, i)}}" class="btn primary_color_background text_color_ws p-2 px-4 border col-auto">Terminados en {{substr(number, i)}}</a>
                    {% endfor %}
                </div>
                <hr>
            {% endif %}
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
