<footer>
    <div class="container py-5">
        <div class="row">
            <div class="col-12{% if hasSearcher %} col-md-2 col-sm-2{% else %} col-md-3 col-sm-3{% endif %} col-xs-12">
                <h3><a href="/"><img style="width:100%; height:auto;" src="{{config.datosadmon.data.media.logo}}" alt=""></a></h3>
            </div>
            {% if datosAdmon.games.buy_online == 1 %}
                <div class="align_responsive_footer col-6 {% if hasSearcher %}col-md-2 col-sm-4{% else %}col-md-3 col-sm-3{% endif %} col-xs-12">
                    <h3>Comprar</h3>
                    {% if constant('RECEPTOR_ID') != 'ERROR' %}
                        <ul>
                            <li>
                                <a href="{{ url('loteria-nacional') }}">Lotería Nacional</a>
                            </li>
                            <li>
                                <a href="{{ url('loteria-navidad') }}">Lotería de Navidad</a>
                            </li>
                            <li>
                                <a href="{{ url('loteria-nino') }}">Lotería del Niño</a>
                            </li>

                            {% if datosAdmon.games.club_amigo_online == 1 %}
                                {% for gameCode in datosAdmon.games.active %}
                                    {% if gameCode != 'LNAC' %}
                                        <li>
                                            <a target="_blank" href="{{sprintf(selae_url_with_game, gameCode) }}">
                                                {{(datosAdmon.games.all|getAttribute(gameCode)).name }}
                                            </a>
                                        </li>
                                    {% endif %}
                                {% endfor %}
                            {% else %}
                                {% for gameCode in datosAdmon.games.active %}
                                    {% if gameCode != 'LNAC' %}
                                        <li>
                                            <a target="_blank" href="{{ url(buy_urls[gameCode]) }}">
                                                {{(datosAdmon.games.all|getAttribute(gameCode)).name }}
                                            </a>
                                        </li>
                                    {% endif %}
                                {% endfor %}
                            {% endif %}
                        </ul>
                    {% endif %}

                </div>
            {% endif %}
            <div class="align_responsive_footer col-6 col-md-2 col-sm-3 col-xs-12">
                <h3>Comprobar</h3>
                <ul>
                    {% for gameCode, keyword in result_urls %}
                        <li>
                            <a href="{{ url(keyword) }}">{{(datosAdmon.games.all|getAttribute(gameCode)).name }}</a>
                        </li>
                    {% endfor %}
                </ul>
            </div>
            <div class="align_responsive_footer col-6 col-md-2 col-sm-3 col-xs-12">
                <h3>Acceso</h3>
                <ul>
                    <li>
                        <a href="{{ url('botes') }}">Botes</a>
                    </li>
                    <li>
                        <a href="{{ url('condiciones-generales') }}">Condiciones Generales</a>
                    </li>
                </ul>
                {% if hasSearcher %}
                    {% include 'layouts/boxs/box_footer_extra_urls.volt' %}
                {% endif %}
            </div>
            {% if hasSearcher %}
                <div class="align_responsive_footer col-6 col-md-4 col-sm-4 offset-sm-2 offset-md-0 col-xs-12">
                    <h3>Buscador de números</h3>
                    <ul>
                        {% for name_seo, search_url in searchUrlByNameSeo %}
                            <li>
                                <a href="{{ url(name_seo ~ '/' ~ search_url) }}">{{drawsByNameSeo[name_seo]["name_short"]}}</a>
                            </li>
                        {% endfor %}
                    </ul>
                </div>
            {% else %}
                <div class="align_responsive_footer col-6 col-md-2 {% if !hasSearcher %}col-sm-9 offset-sm-3 offset-md-0{% else %}col-sm-2{% endif %} col-xs-12">
                    {% include 'layouts/boxs/box_footer_extra_urls.volt' %}
                </div>
            {% endif %}
        </div>
    </div>
</footer>
{% if !onlyHeader %}
{% include 'layouts/boxs/box_all_js.volt' %}
{% endif %}
