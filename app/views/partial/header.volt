{% if !onlyHeader %}
    <head>
    <meta charset="utf-8">
    {% include 'layouts/boxs/box_all_css.volt' %}
    </head>
{% endif %}

<header class="header sticky-top" id="myHeader">
{% if !config.maintenance_enabled %}
    {% include 'partial/easyxdm.volt' %}
{% endif %}
{% if showMenu %}
    {% if (constant('RECEPTOR_ID') != "ERROR") %}
    <div id="roof" class="bg-azul px-md-2 px-lg-4 px-xl-5 d-none d-lg-block">
        <div class="row py-2">
            <div class="col-md-4 text-white">{{datosAdmon.msg_cabecera}}</div>
            <div class="col-md-8 text-right text-white">
                <div class="row">
                    <div class="col-12">
                        <div class="row justify-content-end">
                            <div class="col-auto p-0 ml-md-auto">
                                {% if datosAdmon.social is defined and datosAdmon.social is iterable %}
                                {% for red in datosAdmon.social %}
                                        <a class="mr-3 {{red.name}}" target="_blank" href="{{red.url}}"><i class="fa {{red.icon}}"></i></a>
                                {% endfor %}
                                {% endif %}
                            </div>
                            <div class="col-auto p-0">
                                <a href="tel:{{datosAdmon.phone}}"><i class="fa fa-phone"></i> {{datosAdmon.phone}}</a>
                            </div>
                            <div class="col-auto p-0">
                                <a class="pl-3 mr-3" href="mailto:{{datosAdmon.email}}"><i class="fa fa-envelope"></i> {{datosAdmon.email}}</a>
                            </div>
                            {% if !config.maintenance_enabled %}
                                <div class="col-auto p-0 ml-md-auto ml-lg-0">
                                    {% if session.has('user') %}
                                        <a class="btn btn_login_style btn-logout m-0" href="{{config.baseconfig.url_panel}}/backend/pay" target="_blank">
                                            <svg style="width:1em;" class="svg-inline--fa fa-coins fa-w-16" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="coins" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" data-fa-i2svg="">
                                                <path fill="currentColor" d="M0 405.3V448c0 35.3 86 64 192 64s192-28.7 192-64v-42.7C342.7 434.4 267.2 448 192 448S41.3 434.4 0 405.3zM320 128c106 0 192-28.7 192-64S426 0 320 0 128 28.7 128 64s86 64 192 64zM0 300.4V352c0 35.3 86 64 192 64s192-28.7 192-64v-51.6c-41.3 34-116.9 51.6-192 51.6S41.3 334.4 0 300.4zm416 11c57.3-11.1 96-31.7 96-55.4v-42.7c-23.2 16.4-57.3 27.6-96 34.5v63.6zM192 160C86 160 0 195.8 0 240s86 80 192 80 192-35.8 192-80-86-80-192-80zm219.3 56.3c60-10.8 100.7-32 100.7-56.3v-42.7c-35.5 25.1-96.5 38.6-160.7 41.8 29.5 14.3 51.2 33.5 60 57.2z"></path>
                                            </svg>
                                            {{userBalance_quantity|number_float}} €</a>

                                        <div class="dropdown float-right ml-1">
                                            <a class="btn dropdown-toggle btn_login_style" href="#" role="button" id="dropdownMenuLinkBig" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                                [{{ session.get('user')['name'] }}]
                                            </a>

                                            <div class="dropdown-menu" aria-labelledby="dropdownMenuLinkBig">
                                                {% for item in user_dropdown %}
                                                    <a class="text-dark dropdown-item{% if preg_match('/\/logout$/', item['url']) %} btn-logout{% endif %}" href="{{item['url']}}">
                                                        <div class="row">
                                                            <div class="col-1 text-right p-0">
                                                                {{item['icon']}}
                                                            </div>
                                                            <div class="col-11 text-left pl-1">
                                                                {{item['text']}}
                                                            </div>
                                                        </div>
                                                    </a>
                                                {% endfor %}
                                            </div>
                                        </div>
                                    {% else %}
                                        <a class="btn btn-login btn_login_style" data-toggle="modal" data-target="#loginModalRoof">Acceso Usuarios</a>
                                    {% endif %}
                                </div>
                            {% endif %}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    {% endif %}
    <nav class="container navbar navbar-expand-lg navbar-light">
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <a href="/" class="navbar-brand py-0 logo-empresa-navbar"><img src="{{config.datosadmon.data.media.logo}}" alt="" style="width:auto; max-height:75px;" class="small-img-icon"></a>
        <a href="{{ url('carrito') }}" class="font_size_15 navbar-toggler border-0 text-dark bg-azulclaro p-2"><i class="fa fa-shopping-cart" aria-hidden="true" style="font-size: 3em; vertical-align: middle; color: #656565;"></i> <span class="ml-2 mt-1" style="font-size: 1.25rem; color: rgba(0,0,0,.5);">({{ count(carrito_ws)|default(0) }})</span></a>

        <div class="collapse navbar-collapse" id="navbarNav">
            <div class="row ml-lg-auto">
                <div class="col-12">
                    <ul class="navbar-nav">

                        <li class="nav-item{% if active_menu == "inicio" %} active{% endif %}">
                            <a href="{{ url() }}" class="nav-link">Inicio <span class="sr-only">(current)</span></a>
                        </li>

                        <li class="nav-item dropdown{% if active_menu == "juegos" %} active{% endif %}">
                            <a class="nav-link dropdown-toggle" href="#" id="dropdown04" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Comprar</a>
                            <div class="dropdown-menu rounded-0" aria-labelledby="dropdown04">
                                <a href="{{ url('loteria-nacional') }}" class="dropdown-item">Lotería Nacional</a>
                                <a href="{{ url('loteria-navidad') }}" class="dropdown-item">Lotería de Navidad</a>
                                <a href="{{ url('loteria-nino') }}" class="dropdown-item">Lotería del Niño</a>

                                {% if datosAdmon.games.buy_online == 1 %}
                                    {% if datosAdmon.games.club_amigo_online == 1 %}
                                        {% for gameCode in datosAdmon.games.active %}
                                            {% if gameCode != 'LNAC' %}
                                                <a href="{{ sprintf(selae_url_with_game, gameCode) }}" class="dropdown-item">{{(datosAdmon.games.all|getAttribute(gameCode)).name }}</a>
                                            {% endif %}
                                        {% endfor %}
                                    {% else %}
                                        {% for gameCode in datosAdmon.games.active %}
                                            {% if gameCode != 'LNAC' %}
                                                <a href="{{ url(buy_urls[gameCode]) }}" class="dropdown-item">{{(datosAdmon.games.all|getAttribute(gameCode)).name }}</a>
                                            {% endif %}
                                        {% endfor %}
                                    {% endif %}
                                {% endif %}
                            </div>
                        </li>
                        <li class="nav-item{% if active_menu == "botes" %} active{% endif %}">
                            <a href="{{ url('botes') }}" class="nav-link">Botes</a>
                        </li>
                        <li class="nav-item dropdown{% if active_menu == "resultados" %} active{% endif %}">
                            <a class="nav-link dropdown-toggle" href="#" id="dropdown05" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Resultados</a>
                            <div class="dropdown-menu rounded-0" aria-labelledby="dropdown05">
                                {% for gameCode, keyword in result_urls %}
                                    <a href="{{ url(keyword) }}" class="dropdown-item">{{(datosAdmon.games.all|getAttribute(gameCode)).name }}</a>
                                {% endfor %}
                            </div>
                        </li>
                        {% if datosAdmon.is_blog %}
                            <li class="nav-item">
                                <a href="{{ datosAdmon.url.blog}}" target="_blank" class="nav-link" aria-haspopup="true" aria-expanded="false">Blog</a>
                            </li>
                        {% endif %}

                        <li class="d-none d-lg-block nav-item cesta{% if active_menu == "carrito" %} active{% endif %}">
                            <a href="{{ url('carrito') }}" class="nav-link"><i class="fa-shopping-cart fa"></i> Cesta ({{count(carrito_ws)|default(0)}})</a>
                        </li>

                        {% if session.has('user') %}
                            <li class="nav-item d-block d-lg-none">
                                <a class="nav-link bg-azulclaro" href="{{config.baseconfig.url_panel}}/backend/pay" target="_blank">
                                        <svg style="width:1em;" class="svg-inline--fa fa-coins fa-w-16" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="coins" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" data-fa-i2svg="">
                                            <path fill="currentColor" d="M0 405.3V448c0 35.3 86 64 192 64s192-28.7 192-64v-42.7C342.7 434.4 267.2 448 192 448S41.3 434.4 0 405.3zM320 128c106 0 192-28.7 192-64S426 0 320 0 128 28.7 128 64s86 64 192 64zM0 300.4V352c0 35.3 86 64 192 64s192-28.7 192-64v-51.6c-41.3 34-116.9 51.6-192 51.6S41.3 334.4 0 300.4zm416 11c57.3-11.1 96-31.7 96-55.4v-42.7c-23.2 16.4-57.3 27.6-96 34.5v63.6zM192 160C86 160 0 195.8 0 240s86 80 192 80 192-35.8 192-80-86-80-192-80zm219.3 56.3c60-10.8 100.7-32 100.7-56.3v-42.7c-35.5 25.1-96.5 38.6-160.7 41.8 29.5 14.3 51.2 33.5 60 57.2z"></path>
                                        </svg>
                                        {{userBalance_quantity|number_float}} €
                                </a>
                            </li>
                            <li class="nav-item dropdown d-block d-lg-none">
                                <a class="nav-link dropdown-toggle" href="#" id="dropdownMenuLinkBig" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">[{{session.get('user')['name']}}]</a>
                                <div class="dropdown-menu rounded-0" aria-labelledby="dropdownMenuLinkBig">
                                    {% for item in user_dropdown %}
                                        <a class="text-dark dropdown-item{% if preg_match('/\/logout$/', item['url']) %} btn-logout{% endif %}" href="{{item['url']}}>">
                                            <div class="row">
                                                <div class="col-1 text-right p-0">
                                                    {{item['icon']}}
                                                </div>
                                                <div class="col-11 text-left pl-1">
                                                    {{item['text']}}
                                                </div>
                                            </div>
                                        </a>
                                    {% endfor %}
                                </div>
                            </li>
                        {% else %}
                            <li class="nav-item d-block d-lg-none">
                                <a data-toggle="modal" data-target="#loginModalRoof">Acceso Usuarios</a>
                            </li>
                        {% endif %}
                    </ul>
                </div>
            </div>
        </div>
    </nav>

    {% include 'layouts/boxs/box_modal_login' with ['target': 'loginModalRoof'] %}
{% endif %}
</header>
{{flash.output() }}
<script>
    window.addEventListener("load", () => {
        $('.dropdown-toggle').hover(dropMenu, dropMenuOut)
    });

    function dropMenu(event) {
        let target = event.target
        if ($(target).attr('aria-expanded') == 'true') {
            return
        }

        $(target).dropdown("toggle")
    }

    function dropMenuOut(event) {
        let target = event.target
        if ($(target).attr('aria-expanded') != 'true') {
            return
        }

        let idInterval = setInterval(() => {
            if ($(target).parents(".dropdown").is($(":hover").last().parents(".dropdown"))) {
                return
            }

            if ($(target).attr('aria-expanded') == 'true') {
                $(target).dropdown("toggle")
            }

            clearInterval(idInterval)
        }, 1000);
    }
</script>