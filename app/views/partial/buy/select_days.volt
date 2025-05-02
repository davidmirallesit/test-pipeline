<div class="col-12 col-md-11 col-xl-9 offset-md-1" style="overflow: hidden">
    <div class="row margin_left_none">
        {% for i in 0..6 %}
        {% if i == 5 %}
            <div class="w-100 d-none d-md-block d-lg-none"></div>
        {% endif %}
        <div
            id="{{ daysEnabled[i]['normalizedDay'] }}"
            data-index="{{i}}"
            {% if daysEnabled[i]["holydayText"] is defined %}
                title="{{ daysEnabled[i]['holydayText'] }}"
                {% if daysEnabled[i]["isEnabled"] %}
                    data-holyday="{{ daysEnabled[i]['timestamp'] | date_format('Y-m-d', true) }}"
                    onclick="customAlert(`No se pueden comprar boletos solo ese día por festivo: {{ daysEnabled[i]['holydayText'] }}`)"
                {% endif %}
            {% endif %}
            class="
                text-center
                col-4
                col-sm-2
                col-md-2
                col-lg-1
                p-0
                noselect
                disabled_day
                div_day
                {% if daysEnabled[i]['isEnabled'] %}pointer_a{% else %}no_draw{% endif %}
            "
        >
            <span id="{{ daysEnabled[i]['normalizedDay'] }}_day_text" class="span_disabled_day">
                {{ mb_strtoupper(daysEnabled[i]['day']) }}
            </span>
            <br>
            <span id="{{ daysEnabled[i]['normalizedDay'] }}_day_number" class="span_disabled_day_number">
                {{ daysEnabled[i]["weekDay"] }}
            </span>
        </div>
        {% endfor %}
        <div id="semana" class="col-8 col-sm-12 col-md-4 col-lg-3 noselect disabled_day div_day_semana pointer_a text-center">
            TODA LA SEMANA
        </div>
    </div>
</div>