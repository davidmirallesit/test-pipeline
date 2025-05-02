{##############################################################################
 #
 # Fichero a incluir en footer/header, con el javascript común para toda la web
 #
 # Usado en:
 #    - views/index.volt
 #    - views/partial/footer.volt
 #
 ##############################################################################}
<script type="text/javascript">
    const mapit_params = {
        lat: {{ str_replace(',', '.', datosAdmon.address.lat) }},
        lng: {{ str_replace(',', '.', datosAdmon.address.lng) }},
        key: '{{ datosAdmon.google.maps }}',
        ref: '{{ date('d-m-Y') }}'
    };
    const DRAW_PRICE_TICKET = {{info_sorteo['price_ticket']|default(0)}};
    const config_baseconfig_uuid = '{{config.baseconfig.uuid}}';
</script>
<script type="text/javascript" src="{{ static_url('js/all.min.js?v' ~ config.version) }}"></script>
{# <!-- Global site tag (gtag.js) - Google Analytics -->#}
<script async src="https://www.googletagmanager.com/gtag/js?id={{datosAdmon.google.analytics}}"></script>
<script type="text/javascript">
    window.dataLayer = window.dataLayer || [];

    function gtag() {
        dataLayer.push(arguments);
    }
    gtag('js', new Date());
    gtag('config', '{{datosAdmon.google.analytics}}');
</script>
{% include 'layouts/boxs/box_js_section.volt' %}
{# <script type="text/javascript" src="//www.privacypolicies.com/public/cookie-consent/3.0.0/cookie-consent.js"></script> #}
<noscript><a href="https://www.PrivacyPolicies.com/cookie-consent/"></a></noscript>
{# <!-- End Cookie Consent --> #}
{% if datosAdmon.footer_javascript is defined %}
<script>{{datosAdmon.footer_javascript}}</script>
{% endif %}
