<div class="col-xl-4 offset-md-1 col-md-5 pr-0">
    <div class="dropdown_date">
        <span>Semana Nº: </span>
        <div class="w-100 d-block d-sm-none"></div>
        <button class="btn dropbtn primary_color_background">
            <span id="semana_label" class="semana_button_text" data-year="{{ date('Y', weeks[0]['monday']) }}">{{ weeks[0]["week_number"] }}</span>
            <span id="semana_date_label" class="dias_button_text">
                {{ weeks[0]["week_text"] }}
                <i class="fa fa-caret-down"></i>
            </span>
        </button>
        <div id="dropdown_week" class="dropdown-content_date" style="width:100%;">
            {% for weekData in weeks %}
                <a class="pointer_a display_dropdown" onclick="changeWeek(`{{ weekData['week_number'] }}`, `{{ date('Y', weekData['monday']) }}`)" data-year="{{ date('Y', weekData['monday']) }}">
                    <span class="semana_button_text">
                        {{ weekData["week_number"] }}
                    </span>
                    <span class="dias_button_text">
                        {{ weekData["week_text"] }}
                    </span>
                </a>
            {% endfor %}
        </div>
    </div>
</div>
<input type="hidden" data-sems="1" id="abono_semanas_button">
{#
<!-- se deja comentado por si en un futuro se quiere introducir la posibilidad de que el usuario indique manualmente cuantas semanas quiere jugar -->
<div class="col-xl-3 offset-sm-1 offset-md-0 col-md-5">
    <div class="dropdown_date">
        <span class="margin-right-abono">Jugar: </span>
        <button data-sems="1" id="abono_semanas_button" class="btn dropbtn primary_color_background">
            <span id="abono_semanas" class="dias_button_text">
                Esta semana
                <i class="fa fa-caret-down"></i>
            </span>
        </button>
        <div id="dropdown_abono" class="dropdown-content_date" style="width:100%; margin-left: 10px;">
            <a class="pointer_a display_dropdown" onclick="changeNumWeek('1')">
                <span class="semana_button_text"></span>
                <span class="dias_button_text">
                    Esta semana
                </span>
            </a>
            {% if config.datosadmon.data.is_subscription and game_rules.is_subscribable %}
                <a class="pointer_a display_dropdown" onclick="changeNumWeek('X')">
                    <span class="semana_button_text"></span>
                    <span class="dias_button_text">
                        Abono
                    </span>
                </a>
            {% endif %}
        </div>
    </div>
</div>
#}
