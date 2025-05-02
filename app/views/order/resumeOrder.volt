<section class="container my-4">
    <div class="row m-0 p-0 w-100">
        <div class="col-12 p-0 text-left">
            <h1 class="resumen-pedido-titulo">{{web_seo_onpage['h1']}}</h1>
        </div>

        {% if web_seo_onpage['txt_up'] is not empty %}
            <div class="col-12 text-center text-justify">
                <div>{{web_seo_onpage['txt_up']}}</div>
            </div>
        {% endif %}

        <hr class="mt-2 mb-3 w-100">
        <div class="col-12 p-0">
            {% if order_info.data.data %}
                <div class="row mb-3">
                    <div class="col-12 col-lg-4">
                        <span class="resumen-pedido-info-cabecera">Pedido: </span>
                        <span class="resumen-pedido-info-cabecera resumen-pedido-info-cabecera-value">#{{order_info.data.data.num_order}}</span>
                    </div>
                    <div class="col-12 col-lg-4">
                        <span class="resumen-pedido-info-cabecera">Nº de referencia: </span>
                        <span class="resumen-pedido-info-cabecera resumen-pedido-info-cabecera-value">{{order_info.data.data.locator}}</span>
                    </div>
                    <div class="col-12 col-lg-4">
                        <span class="resumen-pedido-info-cabecera">Estado: </span>
                        <span class="resumen-pedido-info-cabecera resumen-pedido-info-cabecera-value resume-order-state-{% switch order_info.data.data.state %}{% case 'pendent' %}{% case 'cancelled' %}{% case 'payed' %}{{order_info.data.data.state}}{% break %}{% default %}default{% endswitch %}">
                            {% switch order_info.data.data.state %}
                                {% case "pendent" %}
                                    Pendiente
                                    {% break %}
                                {% case "cancelled" %}
                                    Cancelado
                                    {% break %}
                                {% case "payed" %}
                                    Pagado
                                    {% break %}
                                {% default %}
                                    {{order_info.data.data.state}}
                                    {% break %}
                            {% endswitch %}
                        </span>
                    </div>
                    <div class="col-12">
                        <span class="resumen-pedido-info-cabecera">Creado el: </span>
                        <span class="resumen-pedido-info-cabecera resumen-pedido-info-cabecera-value">{{order_info.data.data.date_created}}</span>
                    </div>
                </div>
                <div class="row px-0 py-3 mb-4 carrito_section">
                    {% for i in 0..(order_info.data.lines | length - 1) %}
                        <!-- <div class="row m-0 mb-3 pt-2 pb-2 carrito_section w-100"> -->
                            <div class="col-12 col-lg-7 resumen-pedido-line-header">
                                <span>{{order_info.data.lines[i].name_item}}</span>
                            </div>
                            <div class="col-12 col-lg-5 text-left text-lg-right">
                                <span class="resumen-pedido-line-info">Fecha:&nbsp;</span>
                                <span class="resumen-pedido-line-info resumen-pedido-line-info-value">
                                    {{order_info.data.lines[i].date_draw_ini}}
                                    {% if order_info.data.lines[i].date_draw_end and order_info.data.lines[i].date_draw_ini != order_info.data.lines[i].date_draw_end %}
                                     - {{order_info.data.lines[i].date_draw_end}}
                                    {% endif %}
                                </span>
                            </div>

                            <hr class="mt-2 mb-3 mr-2 ml-2 w-100">

                            {# Loteria nacional #}
                            {% if order_info.data.lines[i].number is defined %}
                                <div class="col-12 col-lg-5 text-center text-lg-left">
                                    <span class="resumen-pedido-line-header d-inline">Nº: </span>
                                    <span class="resumen-pedido-line-header d-inline">{{order_info.data.lines[i].number}}</span>
                                </div>
                                <div class="col-6 text-left">
                                    <span class="resumen-pedido-line-info d-inline">Cantidad: </span>
                                    <span class="resumen-pedido-line-info resumen-pedido-line-info-value d-inline">{{order_info.data.lines[i].quantity}}</span>
                                </div>

                            {# otros #}
                            {% elseif order_info.data.lines[i].numbers is defined %}
                                {% set numbersCollection = order_info.data.lines[i].numbers %}
                                {% if property_exists(order_info.data.lines[i], 'code_a') %}
                                    {% set code_a = order_info.data.lines[i].code_a %}
                                {% else %}
                                    {% set code_a = null %}
                                {% endif %}
                                {% set code_a_checked = false %}
                                {% for numbers_line in numbersCollection %}
                                        <div class="col-2 col-md-1 px-1 text-right resumen-pedido-line-info">#{{loop.index}}</div>
                                        <div class="col-10 col-md-11 resumen-pedido-line-header">
                                            {% if numbers_line is iterable %}
                                                {% if order_info.data.lines[i].id_game != 25 and order_info.data.lines[i].id_game != 26 %}
                                                    {{implode(" - ", numbers_line)}}
                                                {% else %}
                                                    {# //quiniela y quinigol, llega un array de arrays #}
                                                    <div class="text-monospace d-inline-block">{% for n in numbers_line %}{% if code_a and !code_a_checked and array_search(strval(loop.index), code_a) !== false %}<div class="d-inline-block border px-1 bg-white"><span class='elige8-text'>{{implode(',', n)}}</span></div>{% else %}<div class="d-inline-block border px-1 bg-white">{{implode(',', n)}}</div>{% endif %}{% endfor %}</div>
                                                    {% set code_a_checked = true %}
                                                {% endif %}
                                            {% else %}
                                                {{numbers_line}}
                                            {% endif %}
                                            {% if order_info.data.lines[i].extras is not null and order_info.data.lines[i].extras[loop.index0] is not null %}
                                                {% if order_info.data.lines[i].id_game != 25 and order_info.data.lines[i].id_game != 26 %}
                                                    &nbsp;&nbsp;/&nbsp;&nbsp;
                                                    {% if order_info.data.lines[i].extras[loop.index0] is defined %}
                                                        {% if order_info.data.lines[i].extras[loop.index0][0] is defined and order_info.data.lines[i].extras[loop.index0][0] is iterable %}
                                                            {% for extra in 0..(order_info.data.lines[i].extras[loop.index0]|length) %}
                                                                {% if extra > 0 %} - {% endif %}
                                                                {{implode(' , ', order_info.data.lines[i].extras[loop.index0][extra])}}
                                                            {% endfor %}
                                                        {% else %}
                                                            {{implode(' - ', order_info.data.lines[i].extras[loop.index0])}}
                                                        {% endif %}
                                                    {% else %}
                                                        {{order_info.data.lines[i].extras[loop.index0]}}
                                                    {% endif %}
                                                {% else %}
                                                    <span>&nbsp;&nbsp;-&nbsp;&nbsp;</span>
                                                    <div class="text-monospace d-inline-block">{% for k in 0..(order_info.data.lines[i] | length) %}<span>{% if order_info.data.lines[i].extras[k] is iterable %}{% if order_info.data.lines[i].extras[k][0] is iterable %}{% for extra in order_info.data.lines[i].extras[k] %}<div class="d-inline-block border px-1 bg-white">{{ implode(',', extra) }}</div>{% endfor %}{% else %}<div class="d-inline-block border px-1 bg-white">{{ implode(',', order_info.data.lines[i].extras[k]) }}</div>{% endif %}{% else %}<div class="d-inline-block border px-1 bg-white">{{ order_info.data.lines[i].extras[k] }}</div>{% endif %}</span>{% endfor %}</div>
                                                {% endif %}
                                            {% endif %}
                                        </div>
                                {% endfor %}

                                {# reintegro #}
                                {% if order_info.data.lines[i].num_refund is defined and order_info.data.lines[i].num_refund is not iterable %}
                                    <div class="col-2 col-md-1 px-1 text-right resumen-pedido-line-info">R</div>
                                    <div class="col-10 col-md-11 resumen-pedido-line-header">
                                        {{order_info.data.lines[i].num_refund}}
                                    </div>
                                {% endif %}

                                {# code_a #}
                                {% if code_a is not null %}
                                    <div class="col-2 col-md-1 px-1 text-right resumen-pedido-line-info">
                                        {# sacamos aquí el nombre del juego extra code_a (joker, elige8....) #}
                                        {% set code_a_name = "" %}
                                        {% for game_info in games_info %}
                                            {% if game_info.id == order_info.data.lines[i].id_game %}
                                                {% set code_a_name = ucfirst(game_info.code_a_name) %}
                                            {% endif %}
                                        {% endfor %}
                                        <span>{{ucfirst(code_a_name)}}</span>
                                    </div>
                                    <div class="col-10 col-md-11 resumen-pedido-line-header">
                                        {% if code_a is iterable %}
                                            {{implode(' - ', code_a)}}
                                        {% else %}
                                            {{code_a}}
                                        {% endif %}
                                    </div>
                                {% endif %}
                            {% endif %}

                            <div class="col-12 text-right">
                                <span class="resumen-pedido-line-info">
                                    Importe:
                                </span>
                                <span class="resumen-pedido-line-info resumen-pedido-line-info-value">
                                    {{order_info.data.lines[i].price_item|number_float}} €
                                </span>

                                {% if order_info.data.lines[i] is defined and property_exists(order_info.data.lines[i], 'price_donation') %}
                                    <span class="resumen-pedido-line-info">
                                        Donativo:
                                    </span>
                                    <span class="resumen-pedido-line-info resumen-pedido-line-info-value">
                                        {{order_info.data.lines[i].price_donation|number_float}} €
                                    </span>
                                {% endif %}
                            </div>
                        <!-- </div> -->
                    {% endfor %}
                </div>
                {% if (property_exists(order_info.data, 'shipping_not_shippable') and order_info.data.shipping_not_shippable is not null) or property_exists(order_info.data, 'shipping_shippable') %}
                    <div class="row px-0 py-3 mb-4 carrito_section">
                        <div class="col-12 resumen-pedido-info-cabecera">
                            <span class="resumen-pedido-line-header">Tipo de envío:&nbsp;</span>
                            {% if property_exists(order_info.data, 'shipping_not_shippable') and order_info.data.shipping_not_shippable is not null %}
                                <span>
                                    Productos no enviables: {{order_info.data.shipping_not_shippable.name}}
                                </span>
                                {% if order_info.data.shipping_not_shippable.comments is defined and order_info.data.shipping_not_shippable.comments is not empty %}
                                    <span class="ml-4">
                                        {{order_info.data.shipping_not_shippable.comments}}
                                    </span>
                                {% endif %}
                                <br />
                            {% endif %}
                            {% if property_exists(order_info.data, 'shipping_shippable') and order_info.data.shipping_shippable is not null %}
                                <span>
                                    Productos enviables: {{order_info.data.shipping_shippable.name}}
                                </span>
                                {% if order_info.data.shipping_shippable.comments is defined and order_info.data.shipping_shippable.comments is not empty %}
                                    <span class="ml-4">
                                        {{order_info.data.shipping_shippable.comments}}
                                    </span>
                                {% endif %}
                                <br />
                            {% endif %}
                        </div>
                        <div class="col-12 text-right">
                            <span class="resumen-pedido-line-info">
                                Importe:
                            </span>
                            <span class="resumen-pedido-line-info resumen-pedido-line-info-value">
                                {{order_info.data.data.total_shipping|number_float}} €
                            </span>
                        </div>
                    </div>
                {% endif %}
                {% if order_info.data.payment %}
                    {% for payment in order_info.data.payment %}
                        <div class="row px-0 py-3 mb-4 carrito_section align-items-end">
                            <div class="col-12 resumen-pedido-info-cabecera">
                                <span class="resumen-pedido-line-header">Método de pago:&nbsp;</span>
                                <span>{{payment.type}}</span>
                                {# Mostrar posibles comentarios del método de pago buscándolos en pv-info #}
                                {% set iban = false %}
                                {% if property_exists(payment, 'id_payment') and payment.id_payment is not null %}
                                    {% set found = false %}
                                    {% set paymentUsed = null %}
                                    {% if datosAdmon.payments.ibans is defined and datosAdmon.payments.ibans is iterable %}
                                        {% for checkPayment in datosAdmon.payments.ibans %}
                                            {% if checkPayment.id == payment.id_payment %}
                                                {% set found = true %}
                                                {% set iban = true %}
                                                {% set paymentUsed = checkPayment %}
                                            {% endif %}
                                        {% endfor %}
                                    {% endif %}
                                    {% if !found and datosAdmon.payments.tpvs is defined and datosAdmon.payments.tpvs is iterable %}
                                        {% for checkPayment in datosAdmon.payments.tpvs %}
                                            {% if checkPayment.id == payment.id_payment %}
                                                {% set found = true %}
                                                {% set paymentUsed = checkPayment %}
                                            {% endif %}
                                        {% endfor %}
                                    {% endif %}
                                    {% if found and paymentUsed.comments is defined %}
                                        <span>&nbsp;-&nbsp;{{paymentUsed.comments}}</span>
                                    {% endif %}
                                {% endif %}
                            </div>
                            {% if iban and payment.state == 'PENDIENTE DE PAGO' %}
                                <div class="col-12 mt-4 resumen-pedido-info-cabecera">
                                    <p class="text-danger bold">Debe realizar una transferencia bancaria o ingreso en efectivo usando los siguientes datos:</p>
                                    <span class="resumen-pedido-line-header">IBAN:&nbsp;</span>
                                    <span>{{paymentUsed.iban}}</span>
                                    <br />
                                    <span class="resumen-pedido-line-header">Banco:&nbsp;</span>
                                    <span>{{paymentUsed.name}}</span>
                                    <br />
                                    <span class="resumen-pedido-line-header">Concepto:&nbsp;</span>
                                    <span>{{payment.ref}}</span>
                                </div>
                            {% endif %}
                            <div class="col-6 mt-3 resumen-pedido-info-cabecera">
                                <span class="resumen-pedido-line-header">Estado:&nbsp;</span>
                                <span>{{payment.state}}</span>
                            </div>
                            <div class="col-6 mt-3 text-right">
                                <span class="resumen-pedido-line-info">
                                    Pago:
                                </span>
                                <span class="resumen-pedido-line-info resumen-pedido-line-info-value">
                                    {{payment.amount|number_float}} €
                                </span>
                            </div>
                        </div>
                    {% endfor %}
                    {% if order_info.data.payment | length > 1 %}
                        <div class="row px-0 py-3 mb-4 carrito_section align-items-end">
                            <div class="col-12 text-right">
                                <span class="resumen-pedido-line-info">
                                    Total pagado:
                                </span>
                                <span class="resumen-pedido-line-info resumen-pedido-line-info-value">
                                    {{order_info.data.data.total_payed|number_float}} €
                                </span>
                            </div>
                        </div>
                    {% endif %}
                {% endif %}
                <hr class="mt-4 mb-4">
                <div class="row mb-4">
                    <div class="col-12 d-flex justify-content-end">
                        <span class="resumen-pedido-importe-total">Importe total:&nbsp;</span>
                        <span class="resumen-pedido-importe-total resumen-pedido-importe-total-value">{{order_info.data.data.total_price|number_float}} €</span>
                    </div>
                </div>
                <div class="row d-flex justify-content-center">
                    <button class="btn btn-block resume_order_button_continuar" onclick="volverACompra()" type="button">
                        <span style="display: inline;">Seguir comprando</span>
                    </button>
                </div>
                <script type="text/javascript">
                    function volverACompra() {
                        location.href = "/";
                    }
                </script>
            {% else %}
                {% if order_info.error %}
                    <div class="col-12">
                        <span class="resumen-pedido-info-cabecera">Error: </span>
                        <span class="resumen-pedido-info-cabecera resumen-pedido-info-cabecera-value">{{order_info.error}}</span>
                    </div>
                {% endif %}
            {% endif %}
        </div>

        {% if web_seo_onpage['txt_down'] is not empty %}
            <div class="col-12 text-center text-justify">
                <div>{{web_seo_onpage['txt_down']}}</div>
            </div>
        {% endif %}
    </div>
</section>
