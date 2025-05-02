{################################################################################
 # Fichero en el que colocar contenido HTML según el controlador que se está
 # cargando que figura en la variable "controller", que se mostrará justo antes
 # de mostrar el contenido de la sección
 ################################################################################}

{################################################################################
 # INCLUIMOS CONTENIDO OPCIONAL (según sección)
 ################################################################################}
{% if controller is defined %}

{% if controller == 'index' %}
{% include 'layouts/boxs/box_carousel.volt' %}

{# Sección BUY #}
{% elseif controller == 'buy' %}
{% include 'partial/modals/continue_buying_or_cart.volt' %}

{# Sección SECTIONS #}
{% elseif controller == 'sections' %}
    {% if is_admon_header is defined and is_admon_header %}
    <div class="page-header d-none d-md-block">
        <div class="container">
            <div class="page-header-inner">
                {% if datosAdmon.media.header is defined %}
                    <ol class="breadcrumb wow fadeInDown" data-wow-delay="300ms">
                        <li><a href="/">Inicio <span class="pl-2">/</span></a></li>
                        <li class="page pl-2"> {{header_title}}</li>
                    </ol>
                {% endif %}

                <h1 class="page-title wow fadeInRight" {% if (header_title == "Loteria Nacional" or header_title == "Venta Empresas" or header_title == "Venta Participaciones") %}1{% endif %} data-wow-delay="300ms">
                    {{header_title}}
                </h1>
            </div>
        </div>
    </div>
    {% endif %}
{% endif %}
{% endif %}
