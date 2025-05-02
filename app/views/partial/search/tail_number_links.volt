{% if TAIL_NUMBER is defined %}
    <div class="row mt-3 justify-content-around">
        {% for i in 0..4 %}
            <a href="{{draw_url ~ search_url ~ config.search_urls.tailNumber ~ (i ~ TAIL_NUMBER)}}" class="btn primary_color_background text_color_ws p-2 px-4 border col-auto mb-1">Terminados en {{i ~ TAIL_NUMBER}}</a>
        {% endfor %}
    </div>
    <div class="row mt-3 justify-content-around">
        {% for i in 5..9 %}
            <a href="{{draw_url ~ search_url ~ config.search_urls.tailNumber ~ (i ~ TAIL_NUMBER)}}" class="btn primary_color_background text_color_ws p-2 px-4 border col-auto mb-1">Terminados en {{i ~ TAIL_NUMBER}}</a>
        {% endfor %}
    </div>
{% else %}
    <div class="row mt-3 justify-content-around">
        {% for i in 0..4 %}
            <a href="{{draw_url ~ search_url ~ config.search_urls.tailNumber ~ i}}" class="btn primary_color_background text_color_ws p-2 px-4 border col-auto">Terminados en {{i}}</a>
        {% endfor %}
    </div>
    <div class="row mt-3 justify-content-around">
        {% for i in 5..9 %}
            <a href="{{draw_url ~ search_url ~ config.search_urls.tailNumber ~ i}}" class="btn primary_color_background text_color_ws p-2 px-4 border col-auto">Terminados en {{i}}</a>
        {% endfor %}
    </div>
{% endif %}
