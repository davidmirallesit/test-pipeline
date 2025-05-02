<div class="col-12 text-center">
    <h1 class="text-center">{{ web_seo_onpage['h1'] }}</h1>
</div>

{% if web_seo_onpage['txt_up'] is not empty %}
    <div class="col-12 text-center text-justify">
        <div>{{ web_seo_onpage['txt_up'] }}</div>
    </div>
{% endif %}

<div class="container">
    <div class="col-12 col-md-12">
        <!-- nuevo contenido -->
        {% if info_sorteo is defined %}
            {% if searcher_url is defined and hasSearcher %}
                {% include 'partial/search/advanced_search_widget.volt' %}
            {% else %}
                {% include 'partial/search/default_search_widget' with ['action': '/' ~ keyword] %}
            {% endif %}
        {% endif %}

        <!-- new responsive -->
        <!-- Contenido cambiado para mejor responsive -->
        <div class="blog-post">
            <div class="post-content text-center bloque_azulClaro">
                <div class="{% if info_sorteo is defined %}bloque_numeros_boletos {% endif %}p-3">
                    {% if info_sorteo is not defined %}
                    <div>Aún no hay información disponible sobre el próximo sorteo de {{header_title}}</div>
                    {% else %}
                    <h1 class="my-3 text-nums-disponibles">Comprar lotería</h1>
                    <span class="text-uppercase text-nums-disponibles">
                        {{ info_sorteo['name_pretty'] }} - {{ info_sorteo['date_draw'] | date_format('d/m') }}
                    </span>
                    <div class="row">
                        <div class="info_decimo_ln col-lg-4 col-md-12">
                            {% if proximos_sorteos_10 is defined and proximos_sorteos_10 is iterable %}
                            <form name="fbuscar" action="/{{keyword}}" method="get" class="float_right dropdowns-form-sorteos-ln dropdowns-form-img-ln">
                                <select size="1" name="idsorteo" class="select_buscador isorteo dropdown-sorteos-ln dropdown-sorteos-ln-left" onchange="this.form.submit()">
                                    {% for sorteo in proximos_sorteos_10 %}
                                    <option {% if sorteo['id_draw'] == sorteo_id %}selected{% endif %} value="{{sorteo['id_draw']}}">{{ sorteo['name'] }} {{ sorteo['date_draw'] | date_format('d/m/Y') }}</option>";
                                    {% endfor %}
                                </select>
                            </form>
                            {% endif %}

                            <img alt="Comprar {{header_title}}" class="decimo" src="{{ info_sorteo['ticket_img']['lg'] }}" />
                            <div clas="row row_margin_total">
                                <a href="{{ url(keyword ~ '?aleatorio=S&idsorteo=' ~ sorteo_id) }}" class="btn button_seleccionar_numero_aleatorio">Seleccionar un numero aleatorio</a>
                            </div>
                            <div class="row position-absolute txt_importe_row w-100 justify-content-center">
                                <p class="txt_importe_lot position-relative position_importes_txt importe-info-decimo m-0">TOTAL:&nbsp;<span id="price">0.00</span> €</p>
                            </div>
                            <div class="clear"></div>
                        </div>
                        <div class="col-md-12 col-lg-8 selector_decimo">

                            {% if _GET["numero"] is defined %}
                            <div class="row d-flex justify-content-center align-items-center mb-2">
                                <b>Filtrado por terminación:&nbsp;"{{ _GET["numero"] }}"&nbsp;&nbsp;</b>
                                <a class="btn button_seleccionar_numero_aleatorio mt-0" href="/{{keyword}}?idsorteo={{ sorteo_id}}">
                                    <i class="fa fa-close"></i>
                                </a>
                            </div>
                            {% endif %}

                            <form action="/{{keyword}}" id="formLoteriaNacional" method="get">
                                <input type="hidden" name="idsorteo" value="{{ info_sorteo['id_draw'] }}" />
                                <input type="hidden" name="datedraw" value="{{ info_sorteo['date_draw'] }}" />
                                <input type="hidden" name="pricedraw" value="{{ info_sorteo['price_ticket'] }}" />
                                <input type="hidden" name="iddraw" value="{{ info_sorteo['id'] }}" />
                                <p class="text-center col-12 pb-0 mb-0">
                                    Selecciona la cantidad deseada y añade a la cesta
                                </p>
                                <div class="row mt-0" id="boletos-container">
                                    {% if numeros_sorteo | length and numeros_sorteo is iterable %}
                                    {% for x in 0..((numeros_sorteo | length - 1) | max_value(9)) %}
                                    <div class="col-12 col-sm-6 mx-auto item_loteria_nacional">
                                        <div class="row container_loteria_nacional">
                                            <div class="pull-left image_box_loteria_nacional" style="max-width: 26%;">
                                                <div class="image_loteria_nacional">
                                                    <img src="{{ game_rules.logo }}" style="width: 52%;">
                                                </div>
                                            </div>
                                            <div class="pull-right-boleto numbers_box_loteria_nacional">
                                                <div class="pull-left number_box_loteria_nacional">
                                                    <span class="span_loteria_nacional">Lotería Nacional</span>
                                                    <span class="span_number_loterial_nacional">{{ numeros_sorteo[x].number }}</span>
                                                </div>
                                                <div class="pull-right-boleto number_box_loteria_nacional">
                                                    <span class="span_cantidad_loteria_nacional">Cantidad</span>
                                                    <div class="input-group float-right position_width_initial margin_div_cantidad_loteria_nacional">
                                                        <span class="input-group-btn">
                                                            <button type="button" class="btn p-0 my-1 btn-number button_transparent" disabled="disabled" data-type="minus" data-field="{{ numeros_sorteo[x].number }}"><i class="fa fa-minus-circle fa-2x" style="color: #D3D3D3"></i></button>
                                                        </span>
                                                        <input onchange="lotteryChangedSelectedQuantity()" oninput="checkQuantityLottery(event)" type="text" name="{{ numeros_sorteo[x].number }}" class="form-control input-number cantidad_cupones cantidad_loteria_nacional" value="0" min="0" max="{{ numeros_sorteo[x].available }}" size="2">
                                                        <span class="input-group-btn">
                                                            <button type="button" class="btn p-0 my-1 btn-number button_transparent" data-type="plus" data-field="{{ numeros_sorteo[x].number }}"><i class="fa fa-plus-circle fa-2x" style="color: #D3D3D3"></i></button>
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                            {% if datosAdmon.show_availability | abs %}
                                                {% if (datosAdmon.show_min_availability | abs) %}
                                                    {% if (datosAdmon.show_min_availability | abs) > numeros_sorteo[x].available %}
                                                        <span class="badge rounded-pill bg-danger pill_availability_box_loteria_nacional">Queda{% if numeros_sorteo[x].available > 1 %}n{% endif %}: {{ numeros_sorteo[x].available }}</span>                                                        
                                                    {% endif %}
                                                {% else %}
                                                    <span class="badge rounded-pill bg-primary pill_availability_box_loteria_nacional">Queda{% if numeros_sorteo[x].available > 1 %}n{% endif %}: {{ numeros_sorteo[x].available }}</span>
                                                {% endif %}
                                            {% endif %}
                                        </div>
                                    </div>
                                    {% endfor %}
                                    {% else %}
                                    <div class='m-auto'><p class='text-danger bold'>No hay números disponibles para este sorteo</p></div>
                                    {% endif %}
                                </div>

                                {% if cantidad_total > 0 %}
                                <div id="paginator" class=" nums_paginador">
                                    <a><i class="fa fa-chevron-circle-left" id="paginador-pagina-anterior"></i></a>
                                    {# Paginator #}
                                    <a><i class="fa fa-chevron-circle-right" id="paginador-pagina-siguiente"></i></a>
                                </div>
                                {% endif %}

                                {% if numeros_sorteo | length %}
                                <button class="rounded-50 btn-verde-claro btn add-cart-ln" type="button" onclick="submitNacional()" disabled id="button_anyadir_cesta">Añadir a la cesta</button>
                                {% endif %}
                                </div>
                            </form>
                        </div>
                    </div>
                    {% endif %}
                </div>
            </div>
        </div>
        <div class="col-12 py-3">
            <p class="small">
                <!--Última actualización: 25/03/2019 a las 12:44. -->(*) Cuando haga un
                pedido de Lotería Nacional usted está adquieriendo décimos oficiales (en formato pre-impreso o resguardo) cobrables en cualquier administración de
                loterías.
            </p>
        </div>



        <!-- registrese para juegos activos -->
        {% if datosAdmon.games.buy_online == 1 and datosAdmon.games.club_amigo_online == 1 %}
        <div class="blog-post">
            <div class="post-content text-center bg-azul">
                <div class="row px-4 pt-4">
                    <div class="col-12 col-md-7 text-left text_color_ws">
                        <h6>REGÍSTRESE PARA JUGAR A JUEGOS ACTIVOS</h6>
                        <p class="bg-azul text-left">Es preciso registrarse para jugar On-Line a los juegos
                            activos.
                            Si todavía no está registrado, regístrese y juegue ya!</p>
                    </div>
                    <div class="col-12 col-md-5">
                        <a target="_blank" class="btn-dark btn rounded-0 text-uppercase col-12 mx-0 my-1 mb-3 text-white white_space_normal" href="{{ selae_url_registration }}">
                            Registrarse en <br />Loterias del Estado
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <!-- registrese para juegos activos -->
        {% endif %}


    </div>

    {% if web_seo_onpage['txt_down'] is not empty %}
        <div class="col-12 text-center text-justify">
            <div>{{ web_seo_onpage['txt_down'] }}</div>
        </div>
    {% endif %}
</div>
{% if info_sorteo is defined %}
<script>
document.addEventListener("DOMContentLoaded", function(event) {
    pageLoad(0);

    $(document).on("click", ".btn-number", function(e) {

        var fieldName = $(this).attr('data-field');
        var type = $(this).attr('data-type');
        var input = $("input[name='" + fieldName + "']");
        var reverseInput = $("button[data-field='" + fieldName + "'][data-type!='" + type + "']");
        var currentVal = parseInt(input.val());

        if (!isNaN(currentVal)) {
            if (type == 'minus') {
                $(reverseInput).attr('disabled', false);
                var minValue = parseInt(input.attr('min'));
                if (!minValue) minValue = 0;
                if (currentVal > minValue) {
                    //input.val(currentVal - 1).change();
                }
                if (parseInt(input.val()) == minValue) {
                    $(this).attr('disabled', true);
                }
            } else if (type == 'plus') {
                $(reverseInput).attr('disabled', false);
                var maxValue = parseInt(input.attr('max'));
                if (!maxValue) maxValue = 9999999999999;
                if (currentVal < maxValue) {
                    //input.val(currentVal + 1).change();
                }
                if (parseInt(input.val()) == maxValue) {
                    $(this).attr('disabled', true);
                }
            }
        } else {
            input.val(0);
        }
    });
});
    var numTerminacion = "{% if number is defined %}{{number}}{% else %}-1{% endif %}";
    var showAvailability= Number("{% if datosAdmon.show_availability is defined %}{{datosAdmon.show_availability}}{% else %}0{% endif %}");
    var showMinAvailability = Number("{% if datosAdmon.show_min_availability is defined %}{{datosAdmon.show_min_availability}}{% else %}0{% endif %}");

    function pageLoad(pagina) {

        $.ajax({
            type: "POST",
            url: "paginate-boletos",
            data: {
                pagina: pagina,
                idsorteo: "{{ sorteo_id }}",
                numero: numTerminacion
            },
            success: function(results) {
                var cantidadPaginas = "{{ cantidad_total }}";
                if (cantidadPaginas > 0) {
                    document.getElementById('paginator').innerHTML = results.output;
                    removeOldTickets();
                    printResults(results.items_pagina_actual);
                    setActivePage(pagina);
                    setSiguienteAnterior(pagina - 1, pagina + 1);
                }
            }
        });

    }

    function submitNacional() {
        var formData = $('#formLoteriaNacional').serialize();
        var splittedFormData = formData.split("&");
        /* La primera posición de decimos empieza en el 4*/
        var arrayNumeros = new Object();
        for (var i = 4; i < splittedFormData.length; i++) {
            var splittedNumber = splittedFormData[i].split("=");
            arrayNumeros[splittedNumber[0]] = splittedNumber[1];
        }

        var objetoCarrito = {
            "id_game": splittedFormData[0].split("=")[1],
            "date_draw_ini": splittedFormData[1].split("=")[1].split("%")[0],
            "price_ticket": splittedFormData[2].split("=")[1],
            //"id_draw": splittedFormData[3].split("=")[1],
            "id_draw": "{{ sorteo_id }}",
            "tickets": arrayNumeros
        };

        $.ajax({
            type: "POST",
            url: "guardarCarritoLoteriaNacional",
            data: objetoCarrito,

            success: function(data) {
                $('#continueBuyingModal').modal({
                    backdrop: 'static',
                    keyboard: false
                });
                console.log(data.id_draw);
            },
            error: function(e) {
                customAlert("Error al guardar comprar la loteria");
            }
        });
    }

    function setSiguienteAnterior(anterior, siguiente) {
        if (anterior >= 0) {
            document.getElementById('paginador-pagina-anterior').setAttribute('onclick', 'pageLoad(' + anterior + ',{{cantidad_total}})');
        }
        if (siguiente < "{{ cantidad_total }}") {
            document.getElementById('paginador-pagina-siguiente').setAttribute('onclick', 'pageLoad(' + siguiente + ',{{cantidad_total}})');
        }
    }
</script>
{% endif %}
