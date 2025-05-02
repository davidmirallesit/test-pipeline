<div class="widget widget-popular-posts">
    <h5 class="widget-title">Botes</h5>
    <ul class="posts-list">
        {% for game in games %}
        {% set game_id = game['id'] %}
        {% set game_code = game['code'] %}
        <li class="responsive-li-tablet-view">
            <div class="row" style="margin-left: 0px; padding-top: 10px;">
                <div class="col-xs-12 col-sm-12 col-md-8 col-xl-8">
                    <img src="{{game["logo"]}}" class="custom-logo-mobile" alt="" />
                    <h2 class="game_title_home">{{game["name"]}}</h2>
                </div>
                <div class="col-xs-12 col-sm-12 col-md-4 col-xl-4">
                    <div class="row inner-bote-time" style="justify-content: flex-start;">
                        <div class="span_cuenta_atras_comprobador_home" id="countdown_{{game_id}}"></div>
                    </div>
                </div>
            </div>
            <div class="row" style="margin-left: 0px; padding-top: 7px; text-align: center">
                <div class="col-sm-12 col-md-4 col-lg-4">
                    {% if jackpots[game_id]["jackpot"] is defined %}
                    <p class="precio_bote_2 inner-bote text-dark">{% if jackpots[game_id]["jackpot"] > 0 %}{{jackpots[game_id]["jackpot"]|number_int}}€{% else %}-{% endif %}</p>
                    {% endif %}
                </div>
                <div class="col-sm-12 col-md-8 col-lg-8 responsive_sidebar_ipad">
                    {% if game["active"] and datosAdmon.games.buy_online == 1 %}
                        {% if datosAdmon.games.club_amigo_online == 1 %}
                            <a target="_blank" class="button_jugar_menu_games_home pull-right" href="{{sprintf(selae_url_with_game, game_code)}}">
                                <span class="button_jugar_menu_games_home_text_secondary">Comprar</span>
                            </a>
                        {% else %}
                            <a class="button_jugar_menu_games_home pull-right" href="{{buy_urls[game_code]}}">
                                <span class="button_jugar_menu_games_home_text_secondary">Comprar</span>
                            </a>
                        {% endif %}
                    {% endif %}

                    {% if datosAdmon.games.buy_online == 0 %}
                        <div class="d-flex justify-content-center" style="width: 100%">
                            <a class="button_jugar_menu_games_home_comprobar" href="{{result_urls[game_code]}}">
                                <span class="button_jugar_menu_games_home_text">Comprobar</span>
                            </a>
                        </div>
                    {% else %}
                        <a class="button_jugar_menu_games_home_comprobar pull-right" href="{{result_urls[game_code]}}">
                            <span class="button_jugar_menu_games_home_text">Comprobar</span>
                        </a>
                    {% endif %}
                </div>
            </div>
        </li>
        {% endfor %}
    </ul>
</div>
