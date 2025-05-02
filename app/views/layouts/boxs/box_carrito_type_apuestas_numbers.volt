<div class="text-monospace d-inline-block">
    {% for j, n in numeros["numbers"][i] %}{# si el code_a se puede elegir se pintan del color los numeros elegidos #}
        {% if numeros["code_a"] is defined and games_info[numeros['id_game']]["is_code_a_selectable"] %}
            {% if games_info[numeros['id_game']]["is_code_a_per_slip"] %}
                {% if array_search((j + 1), numeros["code_a"]["code"]) !== false and i == 0 %}
                    {% set code_a_color = 'elige8-text' %}
                {% endif %}
            {% elseif array_search((j + 1), numeros["code_a"][0]["code"]) !== false %}
                {% set code_a_color = 'elige8-text' %}
            {% endif %}
        {% endif %}
        {# el loop.first y last evita que aparezcan espacios en blanco entre los divs #}
        {% if !loop.first %}{{"-->"}}{% endif %}<div class="d-inline-block border px-1 bg-white {{code_a_color}}">
            {{ implode(',', n) }}
        </div>{% if !loop.last %}{{"<!--"}}{% endif %}
        {% set code_a_color = '' %}
    {% endfor %}
</div>
