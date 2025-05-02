<div class="col-12 text-center">
    <h1 class="text-center">{{web_seo_onpage['h1']}}</h1>
</div>

{% if web_seo_onpage['txt_up'] is not empty %}
    <div class="col-12 text-center text-justify">
        <div>{{web_seo_onpage['txt_up']}}</div>
    </div>
{% endif %}
<div class="container">
    <div class="col-12 col-md-12">
        {% if !hasStock %}
            <div class="buscador_numeros">
                <div class="row">
                    <div class="col-12 d-flex align-items-center justify-content-center py-4">
                        <h5 class="text-buscador-numeros m-0">Actualmente no hay stock dispobible para este sorteo</h5>
                    </div>
                </div>
            </div>
        {% endif %}
        <div class="buscador_numeros">
            <div class="row">
                <div class="col d-flex justify-content-center">
                    <form id="search-form" action="{{_SERVER["REQUEST_URI"]}}" method="POST" class="form-numero">
                        <div class="row">
                            <div class="d-none d-sm-block col-sm-12 col-md-6">
                                <img class="custom-img-responsive" src="{% if draw["ticket_img"]["lg"] is defined %}{{draw["ticket_img"]["lg"]}}{% endif %}" alt="imagen decimo lotería">
                            </div>
                            <div class="text-center col-12 col-md-6">
                                <div class="row">
                                    <div class="col-12">
                                        Buscar número del {{draw["name_pretty"]}} del {{draw["date_draw"]|date_format('d/m/Y')}}
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-12">
                                        <div class="row mt-3 d-flex justify-content-center">
                                            <div class="col-8 col-sm-6 col-lg-4">
                                                <input oninput="inputNumber(event)" class="campo_numero py-3" maxlength="5" id="numero" name="numero" type="text" placeholder="Terminación" required="">
                                            </div>
                                            <div class="col-12 col-lg-4 justify-content-lg-start justify-content-end">
                                                <input class="rounded-50 btn-verde-claro btn mt-sm-2 mt-lg-0" type="submit" value="BUSCAR NÚMERO">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div class="col-12 mt-3 mb-3">
        <div class="col-12">
            <h2>Números por terminación</h2>
        </div>
        {% include 'partial/search/tail_number_links.volt' %}
    </div>

    {% if web_seo_onpage['txt_down'] is not empty %}
        <div class="col-12 text-center text-justify">
            <div>{{web_seo_onpage['txt_down']}}</div>
        </div>
    {% endif %}
</div>
