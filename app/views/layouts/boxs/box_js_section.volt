{################################################################################
 # Fichero en el que colocar contenido Javascript según el controlador que se está
 # cargando que figura en la variable "controller"
 ################################################################################}

{################################################################################
 # INCLUIMOS CONTENIDO OPCIONAL (según sección)
 ################################################################################}
{% if controller is defined %}

{# Sección BUY #}
{% if controller == 'buy' %}
<script>
    // variables globales que se usan en el script de abajo
    // esto no debería ni existir
    const monthNames = {{json_encode(monthNames)}};
    const shortMonthNames = {{json_encode(shortMonthNames)}};
    const dayNames = {{json_encode(dayNames)}};


    {% set jsonValues = preg_replace('/\\\"/',     '"',    json_encode(game_rules)) %}
    {% set jsonStart  = preg_replace('/\:\"\{/',   ':{',   jsonValues) %}
    {% set jsonEnd    = preg_replace('/\}\"/',     '}',    jsonStart) %}
    {% set arrayStart = preg_replace('/\:\"\[/',   ':[',   jsonEnd) %}
    {% set arrayEnd   = preg_replace('/\]\"/',     ']',    arrayStart) %}
    {% set nullValues = preg_replace('/\"null\"/', 'null', arrayEnd) %}

    let gameRules = {{nullValues}};

    if (!gameRules.min_import_per_slip) {
        gameRules.min_import_per_slip = 0
    }

    let boletos = [];
    let actualBoleto = 0;
    let actualApuesta = 0;

    let apuestas = [];
    let contenedor_apuestas = [];

    {% switch (game_code) %}
        {% case 'LAQU' %}
        {% case 'QGOL' %}
            // totalDays = 1;
            let info_jornadas = {{json_encode(jornadas)}};
            let jornada_seleccionada = "{% if jornadas is defined and jornadas is iterable and (jornadas|length) > 0 %}{{ array_keys(jornadas)[0] }}{% endif %}";
            {% break %}
    {% endswitch %}

    let CLOSE_DATES = {% if (game_id is null or !property_exists(config.datosadmon.data.games.close_dates, game_id)) %}[]{% else %}{{config.datosadmon.data.games.close_dates|getAttribute(game_id)|json_encode}}{% endif %};
    //TODO donde se use el close date sustituirlo por este
    // let close_dates = "<?php echo $close_date; ?>";
    let PV_CALENDAR = {{json_encode(pvCalendar)}};

    let selectedWeek = -1;
    let numPreloadedBets = {{num_preloaded_bets}};

    if (gameRules.id_type != 3) {
        $(document).on('click', '.div_day', function(event) {
            event.preventDefault();
            if ($(this).hasClass('pointer_a') && !$(this).hasClass('no_draw') && !$(this).data("holyday")) {
                if (CLOSE_DATES[$(this).data("index") + 1] === undefined) {
                    customAlert("No se pueden comprar boletos solo ese día, deshabilitado por la administración")
                    return
                }

                quitarRestoDeDiasALaSemana();
                $(this).addClass('selected_day');
                $(this).removeClass('disabled_day');
                comprobarPrecio();
            }
        });
    }
</script>

{# Sección RESULTADOS #}
{% elseif controller == 'results' %}
    <script>
        let available_dates = {{available_dates | default('[]')}};
        const monthNames = {{json_encode(monthNames)}};
        const shortMonthNames = {{json_encode(shortMonthNames)}};
    </script>

{# Sección BUSCAR #}
{% elseif controller == 'search' %}
    <script>
        let SEARCH_URLS   = JSON.parse('{{json_encode(config['search_urls'])}}');
        let DRAW_URL      = "{{draw_url}}";
        let SEARCHER_URL  = "{{search_url}}";
        let NUMBER_URL    = "{{number_url}}";
        let DATE_DRAW_INI = "{{draw['date_draw']|date_format('Y-m-d')}}";
        let PRICE_TICKET  = parseFloat("{{draw['price_ticket']}}");
        let ID_DRAW       = "{{draw['id_draw']}}";
    </script>

{% endif %}
{% endif %}

{################################################################################
 # INCLUIMOS LAS FUNCIONES JAVASCRIPT (SI LAS HAY)
 ################################################################################}
{% if js_section is defined %}
<script src="{{ static_url(js_section) }}"></script>
{% endif %}
