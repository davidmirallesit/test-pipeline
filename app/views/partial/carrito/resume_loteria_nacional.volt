{% if array_search(numeros["id_draw"], sorteos_ln_cargados) === false %}
    {% set sorteos_ln_cargados[sorteos_ln_cargados | length] = numeros["id_draw"] %}
    <div class="col-12 d-block carrito_section p-3">
        <div class="row carrito_pedido_header">
            <div class="col-12 col-lg-4 col-xl-3 carrito_header_info_data">
                <img src="{{gameInfo['logo']}}" height="39" width="39">
                <span class="ml-2">{{gameInfo['name']}}</span>
            </div>
            <div class="col-12 col-sm-12 col-lg-5">
                <span class="carrito_header_info_title">Sorteo: </span><span class="carrito_line_main">{{numeros['date_draw_ini'] | date_format('d/m/Y')}} - ({{view_sorteo(numeros["id_draw"])}})</span>
            </div>
            <div class="d-none col-12 col-md-4">
                <!-- Entrega estimada: -->
            </div>
        </div>
        <hr class="m-0">
        <div class="row mt-1 d-flex d-sm-none carrito_header_info_data">
            <div class="col-5 text-center">Número</div>
            <div class="col-4">Cantidad</div>
            <div class="col-3">€</div>
        </div>
        {# agrupamiento del mismo sorteo visualmente #}
        {% for i in index..(carrito_ws|length - 1) %}
            {% if array_key_exists("id_draw", numeros) and array_key_exists("id_draw", carrito_ws[i]) and numeros["id_draw"] == carrito_ws[i]["id_draw"] %}
                <div class="row mt-1">
                    <div class="col-5 col-sm-3 carrito_header_info_data text-center">
                        <span class="d-none d-sm-inline">N: </span>
                        {{ carrito_ws[i]['number'] }}
                    </div>
                    <div class="col-4 col-sm-3 col-xl-2">
                        <span class="carrito_header_info_title d-none d-sm-inline">Cantidad: </span>
                        <span class="carrito_line_main"> {{ intval(carrito_ws[i]['quantity']) }}</span>
                    </div>
                    <div class="col-3 col-lg-4 col-xl-5">
                        <span class="d-none d-md-inline carrito_header_info_title d-none d-sm-inline">Importe:&nbsp;</span><span class="carrito_line_main">{{ intval(carrito_ws[i]['quantity']) * intval(carrito_ws[i]['price_ticket']) }}€</span>
                    </div>
                    <div class="col-12 col-sm-2 col-lg-1 carrito_delete_container d-flex justify-content-end justify-content-lg-start">
                        <a href="{{ url('carrito?delete=' ~ i) }}"><i class="fa fa-trash-o text-azul"></i></a>
                    </div>
                </div>
            {% endif %}
        {% endfor %}
    </div>
    <br>
{% endif %}
