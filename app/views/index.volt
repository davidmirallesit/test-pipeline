<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="{% if web_seo_onpage is defined and web_seo_onpage['meta_description'] is defined and web_seo_onpage['meta_description'] is not empty %}{{web_seo_onpage['meta_description']}}{% else %}{{datosAdmon.seo.meta_description}}{% endif %}">
    {% if datosAdmon is defined %}
    {{datosAdmon.google.tag_manager_head}}
    {% endif %}
    {#
    <meta name="keywords" content="Lotería &quot;Web Premium&quot;, Buscar Lotería Nacional del 2019, Comprar loteria de Navidad 2019, Buscar lotería, Comprar Lotería, Lotería, Lotería Nacional, Comprar loteria por Internet, Administración de lotería, admon lotería, suerte, buscar números,Bonoloto, Euromillones, Quiniela, Primitiva, ONCE, Muro del Alcoy">
    #}
    {% if datosAdmon is defined and datosAdmon.seo.meta_robots is defined %}
        <meta name="robots" content="{{datosAdmon.seo.meta_robots}}">
        <meta name="googlebot" content="{{datosAdmon.seo.meta_robots}}">
    {% else %}
        <meta name="robots" content="all">
        <meta name="googlebot" content="all">
    {% endif %}

    {% if datosAdmon is defined and datosAdmon.media.favicon is defined %}
    <link rel="shortcut icon" type="image/x-icon" href="{{datosAdmon.media.favicon}}" />
    {% endif %}
    <title>{% if web_seo_onpage is defined and web_seo_onpage['meta_title'] is defined and web_seo_onpage['meta_title'] is not empty %}{{web_seo_onpage['meta_title']}}{% else %}{{datosAdmon.seo.meta_title}}{% endif %}</title>

    {% include 'layouts/boxs/box_all_css.volt' %}
</head>
<body class="{% if class_css_controller is defined %}{{class_css_controller}}{% endif %}{% if css_subsection is defined %} {{css_subsection}}{% endif %}">

    {% include 'partial/header' with ['onlyHeader': true] %}

    {# TODO si hay un error manejarlo desde el controlador base o el index no aqui #}
    {% if constant('RECEPTOR_ID') == 'ERROR' %}
        <section class="container my-4">
            <div class="row">
                <div class="col-12">
                    Error accediendo a los datos de la administración. Por favor, contacta con un administrador
                </div>
            </div>
        </section>
    {% else %}
        {{datosAdmon.google.tag_manager_body}}
        {% include 'layouts/boxs/box_html_section.volt' %}
        <section class="{% if class_css_main is defined %}{{class_css_main}}{% else %}container{% endif %}">
            <div class="row">
                {{ content() }}
            </div>
        </section>
    {% endif %}

    {% if datosAdmon.media.footer is defined %}
        <section class="jumbotron jumbotron-fluid" id="event">
            <div class="container">
                <h1 class="display-4 text-center text-danger"></h1>
                <p class="lead text-center text-danger"></p>
            </div>
        </section>
    {% endif %}

    {% include 'partial/footer' with ['onlyHeader': true] %}

    <div class="social-links-footer bg-azul">
    {% if datosAdmon.social is defined and datosAdmon is iterable %}
    {% for red in datosAdmon.social %}
        <a style="margin-right: 15px" class="custom-icon-color {{red.name}}" target="_blank" href="{{red.url}}"><i class="fa {{red.icon}}"></i></a>
    {% endfor %}
    {% endif %}
    </div>

    <section id="cards" style="background-color: white !important;">
        <div class="container">
            {% if datosAdmon.logos.cards is defined or datosAdmon.logos.banks is defined %}
                <div class="row d-flex justify-content-center">
            {% endif %}
            {% if datosAdmon.logos.cards is defined %}
                {% for valor in json_decode(json_encode(datosAdmon.logos.cards), true) %}
                    <div style="margin-top: auto; margin-bottom: auto;">
                        <img src="{{valor['img']}}" class="icono-footer" />
                    </div>
                {% endfor %}
            {% endif %}

            {# Existe objetos bankos en este administración #}
            {% if datosAdmon.logos.banks is defined %}
                {% for valor in json_decode(json_encode(datosAdmon.logos.banks), true) %}
                    <div style="margin-top: auto; margin-bottom: auto;">
                        <img src="{{valor['img']}}" class="img-fluid icono-footer" />
                    </div>
                {% endfor %}
            {% endif %}
            {% if datosAdmon.logos.cards is defined or datosAdmon.logos.banks is defined %}
                </div>
            {% endif %}

            {% if datosAdmon.logos.others is defined %}
                <div class="row d-flex justify-content-center">
                {% for valor in json_decode(json_encode(datosAdmon.logos.others), true) %}
                    <div style="position: relative; margin-top: auto; margin-bottom: auto;">
                        <img src="{{valor['img']}}" class="icono-footer-custom" />
                        {% if valor['name'] == "Punto Oficial Selae" %}
                            <div class='selae-img'>{{ constant('RECEPTOR_ID') }}</div>
                        {% endif %}
                    </div>
                {% endfor %}
            {% endif %}
        </div>
    </section>

    <section id="copyright" style="background-color: white !important;">
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <p class="copyright-text text-center" style="color: black !important;">
                        © {{ date('Y') }} Diseño y desarrollo por
                        <a rel="nofollow" href="https://infolot.es">
                            <img class="infolot_logo_footer" style="width: 4.2em;" src="{{ static_url('img/icono_infolot_horizontal.svg') }}">
                        </a>
                    </p>
                </div>
            </div>
        </div>
    </section>

    <a href="#" class="back-to-top">
        <i class="fa fa-arrow-up"></i>
    </a>
    {##############################
     # JAVASCRIPT
     ##############################}
    {% include 'layouts/boxs/box_all_js.volt' %}
</body>
</html>
