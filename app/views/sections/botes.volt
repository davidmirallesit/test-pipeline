<div class="col-12 text-center">
    <h1 class="text-center title-games">{{web_seo_onpage['h1']}}</h1>
</div>
{% if web_seo_onpage['txt_up'] is not empty %}
<div class="col-12 text-center text-justify">
    <div>{{web_seo_onpage['txt_up']}}</div>
</div>
{% endif %}
{% if games is defined %}
<div class="row">
    {% for game in games %}
        {% if game.is_jackpot and game.lae is defined and game.lae.code != '' %}
        <div class="col-lg-6">
            <div class="blog-post">
                <div class="post-content text-center botes">
                    <div class="row h-100 p-2">
                        <div class="col-lg-2 col-sm-3 col-12 my-auto">
                            <img class="mb-3" src="{{game.logo}}" width="60" height="60" />
                        </div>
                        <div class="col-lg-6 col-sm-3 m-auto">
                            {% if datosAdmon.games.buy_online == 1 %}
                                <a target="_blank" class="btn-azul btn rounded-0 text-uppercase" href="{% if datosAdmon.games.club_amigo_online == 1 %}https://juegos.loteriasyapuestas.es/CF/loginFromRetailer.do?retailerId={{ constant('RECEPTOR_ID') }}&gameId={{game.lae.code}}{% else %}{{buy_urls[game.lae.code]}}{% endif %}">
                                    <h2 class="button-botes-bote">Jugar {{game.name}} </h2>
                                </a>                                
                            {% endif %}
                        </div>
                        <div class="col-lg-4 col-sm-6 col-12 pt-3 pr-3 text-center text-sm-right">
                            <p class="precio_bote text-dark">{% if jackpots[game.id].jackpot and jackpots[game.id].jackpot > 0 %}{{jackpots[game.id].jackpot|number_int}} €{% else %}-{% endif %}</p>
                            <p>{{jackpots[game.id].date_formatted}}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        {% endif %}
    {% endfor %}
</div>
{% endif %}
{% if web_seo_onpage['txt_down'] is not empty %}
    <div class="col-12 text-center text-justify">
        <div>{{web_seo_onpage['txt_down']}}</div>
    </div>
{% endif %}
