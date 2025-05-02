<div class="buscador_numeros">
    <div class="row">
        <div class="col-lg-4 col-sm-12 d-flex justify-content-lg-start justify-content-md-center justify-content-center">
            <h5 class="text-buscador-numeros">Buscador de números</h5>
        </div>
        {% if proximos_sorteos_10 is not null %}
            <div class="col-lg-8 col-12 p-0">
                <div class="row w-100 p-0 m-0 d-flex">
                    <div class="col-12 col-lg-5 col-xl-6 d-flex justify-content-center justify-content-lg-end mb-2 mb-lg-0 mb-xl-0">
                        <span class="span-selecciona-sorteo mr-0">Selecciona sorteo:</span>
                    </div>
                    <div class="col-12 col-lg-7 col-xl-6 d-flex justify-content-center mb-2 mb-lg-0 mb-xl-0">
                        <div class="widget-content d-flex justify-content-center w-100">
                            <form name="fbuscar" method="get" class="w-100 text-center dropdowns-form-sorteos-ln">
                                <select size="1" name="idsorteo" class="select_buscador dropdown-sorteos-ln" onchange="this.form.submit()">
                                    {% for sorteo in proximos_sorteos_10 %}
                                        <option{% if sorteo['id_draw'] == sorteo_id %} selected{% endif %} value="{{sorteo['id_draw']}}">{{sorteo['name']}} {{sorteo['date_draw']|date_format('d/m/Y')}}</option>
                                    {% endfor %}
                                </select>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        {% endif %}
    </div>
    <div class="row d-flex align-items-center">
        <div class="col-sm-12 col-lg-4 d-flex justify-content-sm-center justify-content-md-center justify-content-center justify-content-lg-end ml-0 ml-lg-5">
            <span>Selecciona terminación:</span>
        </div>
        <div class="col-sm-12 col-lg-8 col col d-flex justify-content-lg-start justify-content-md-center">
            {% for i in 0..9 %}
                <a class="terminacion separador_terminacion" href="/{{key(searcher_url)}}/{{searcher_url[key(searcher_url)]}}{{config.search_urls.tailNumber}}{{i}}">{{i}}</a>
            {% endfor %}
        </div>
    </div>
    <div class="row">
        <div class="col d-flex justify-content-center">
            <form id="search-form" method="POST" class="form-numero">
                <div class="row row-form-numero">
                    <div class="col-sm-6 col-md-6 col-lg-4 col-xl-4 col-6 d-flex justify-content-lg-end justify-content-end">
                        <span>Introduce número: </span>
                    </div>
                    <div class="col-sm-6 col-md-4 col-6 col-lg-4 col-xl-4">
                        <input oninput="inputNumber(event)" class="campo_numero py-3" maxlength="5" id="numero" name="numero" type="text" placeholder="Terminación" required="">
                    </div>
                    <div class="col-sm-12  col-md-12 col-lg-4 col-12 col-xl-4 justify-content-lg-start justify-content-end">
                        <input class="rounded-50 btn-verde-claro btn" type="submit" value="BUSCAR NÚMERO">
                    </div>
                </div>
                <input type="hidden" name="idsorteo" value="{{sorteo_id}}">
            </form>
        </div>
    </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function(event) {
    $("#search-form").on("submit", () => {
        let number = $('#numero').val().toString()
        if (number.length == 5) {
            $("#search-form").attr("action", "{{ key(searcher_url) ~ '/' ~ searcher_url[key(searcher_url)] ~ config.search_urls.fullNumber}}" + number)
        } else if (number.length < 5) {
            $("#search-form").attr("action", "{{ key(searcher_url) ~ '/' ~ searcher_url[key(searcher_url)] ~ config.search_urls.tailNumber}}" + number)
        }
    });
});
</script>
