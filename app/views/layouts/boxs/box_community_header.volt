<div class="row mb-2 d-none d-sm-flex">
    <div class="col d-flex align-items-center pt-2">
        <a href="{{ url() }}" class="navbar-brand py-0 logo-navbar"><img src="{{config.datosadmon.data.media.logo}}" alt="" style="width:auto; max-height:75px;" class="logo-navbar"></a>
    </div>
    <div class="col d-flex justify-content-end">
        <div class="d-flex justify-content-center align-items-center navbar-icon-participaciones pt-2 px-1 div-navbar-svg">
            {% if session.has('user') %}
                <a class="text-center pt-1 px-1" href="{{config.baseconfig.url_panel}}/backend/users/profile" target="_blank">
                    {# <!-- Esto es icon-user.svg--> #}
                    <svg class="text-azul" xmlns="http://www.w3.org/2000/svg" id="Grupo_389" width="36.012" height="36.012" viewBox="0 0 36.012 36.012">
                        <path fill="currentColor" id="Trazado_225" d="M18.006 0a18.006 18.006 0 1 0 18.006 18.006A18 18 0 0 0 18.006 0zM6.148 28.591a15.892 15.892 0 0 1 23.715 0 15.881 15.881 0 0 1-23.715 0zM4.832 26.9a15.9 15.9 0 1 1 26.347 0 18 18 0 0 0-26.347 0z" />
                        <path fill="currentColor" id="Trazado_226" d="M172.33 61a6.337 6.337 0 0 0-6.33 6.33v2.11a6.33 6.33 0 1 0 12.66 0v-2.11a6.337 6.337 0 0 0-6.33-6.33zm4.22 8.44a4.22 4.22 0 1 1-8.44 0v-2.11a4.22 4.22 0 1 1 8.44 0z" transform="translate(-154.324 -56.71)" />
                    </svg>
                    <span class="text-azul text-center navbarTextResponsive d-none d-sm-block" style="display: block">Mi cuenta</span>
                </a>
            {% else %}
                <a class="text-center pt-1 px-1" data-toggle="modal" data-target="#loginModalRoof">
                    <svg class="text-azul" xmlns="http://www.w3.org/2000/svg" id="Grupo_389" width="36.012" height="36.012" viewBox="0 0 36.012 36.012">
                        <path fill="currentColor" id="Trazado_225" d="M18.006 0a18.006 18.006 0 1 0 18.006 18.006A18 18 0 0 0 18.006 0zM6.148 28.591a15.892 15.892 0 0 1 23.715 0 15.881 15.881 0 0 1-23.715 0zM4.832 26.9a15.9 15.9 0 1 1 26.347 0 18 18 0 0 0-26.347 0z" />
                        <path fill="currentColor" id="Trazado_226" d="M172.33 61a6.337 6.337 0 0 0-6.33 6.33v2.11a6.33 6.33 0 1 0 12.66 0v-2.11a6.337 6.337 0 0 0-6.33-6.33zm4.22 8.44a4.22 4.22 0 1 1-8.44 0v-2.11a4.22 4.22 0 1 1 8.44 0z" transform="translate(-154.324 -56.71)" />
                    </svg>
                    <span class="text-azul text-center navbarTextResponsive d-none d-sm-block" style="display: block">Acceder</span>
                </a>
                {% include 'layouts/boxs/box_modal_login' with ['target': 'loginModalRoof'] %}
            {% endif %}
        </div>
        <div class="d-flex justify-content-center align-items-center navbar-icon-participaciones pt-2 px-1 ml-2 div-navbar-svg">
            <a class="text-center pt-1 px-1" href="/carrito-comunidad">
                <svg class="text-azul" xmlns="http://www.w3.org/2000/svg" id="Grupo_390" width="35.855" height="35.855" viewBox="0 0 35.855 35.855">
                    <path fill="currentColor" id="Trazado_231" d="M17.928 0a17.928 17.928 0 1 0 17.927 17.928A17.918 17.918 0 0 0 17.928 0zm10.9 29.406l-.068.063-.214.2c-.072.067-.132.117-.2.175l-.08.07q-.132.115-.267.226a15.811 15.811 0 0 1-20.407-.232l-.063-.055-.215-.19c-.071-.064-.12-.11-.179-.166l-.1-.1q-.468-.445-.9-.927l-.007-.008a15.885 15.885 0 0 1-1.31-1.68v-.007l-.017-.025q-.091-.136-.18-.273l-.04-.063q-.082-.128-.161-.257l-.028-.046q-.193-.318-.37-.644-.087-.16-.17-.322l-.013-.025q-.255-.5-.473-1.012l-.018-.043q-.068-.161-.132-.324l-.016-.014q-.069-.175-.133-.351l-.01-.028q-.055-.151-.107-.3l-.029-.086q-.045-.134-.087-.268l-.025-.078q-.051-.165-.1-.332l-.025-.091q-.034-.122-.066-.245l-.033-.13-.054-.222-.029-.124q-.036-.159-.069-.319l-.026-.132-.041-.213-.027-.15-.036-.215-.021-.133q-.024-.162-.046-.325l-.016-.131q-.014-.114-.026-.229l-.014-.138q-.013-.132-.023-.264c0-.03-.005-.06-.008-.091-.009-.116-.016-.233-.022-.349 0-.036 0-.072-.005-.108l-.01-.268v-.11-.365a15.827 15.827 0 0 1 31.653 0v.475q0 .134-.01.268c0 .036 0 .072-.005.108-.006.117-.013.233-.022.349 0 .03-.005.06-.008.091l-.023.264-.014.138q-.012.115-.026.229l-.016.131q-.021.163-.046.325l-.021.133c-.011.072-.023.143-.036.215l-.027.15-.041.213-.026.132q-.033.16-.069.319l-.029.124-.054.222-.033.13q-.032.123-.066.245l-.025.091q-.047.166-.1.332l-.025.078q-.042.134-.087.268l-.029.086q-.052.152-.107.3l-.01.028q-.065.176-.133.351l-.006.015q-.064.163-.132.324l-.018.043q-.218.514-.473 1.012l-.013.025q-.083.162-.17.322-.177.326-.37.644l-.028.046q-.079.129-.161.257l-.04.063q-.088.137-.18.273l-.017.025v.007a15.905 15.905 0 0 1-2.245 2.623z" />
                    <g id="Grupo_393" transform="translate(6.497 7.653)">
                        <g id="Grupo_392">
                            <g id="Grupo_391">
                                <path fill="currentColor" id="Trazado_232" d="M170.687 348.24a2.827 2.827 0 1 0 2.827 2.827 2.83 2.83 0 0 0-2.827-2.827zm0 3.957a1.131 1.131 0 1 1 1.131-1.131 1.132 1.132 0 0 1-1.131 1.134z" transform="translate(-162.602 -331.505)" />
                                <path fill="currentColor" id="Trazado_233" d="M290.166 348.24a2.827 2.827 0 1 0 2.827 2.827 2.83 2.83 0 0 0-2.827-2.827zm0 3.957a1.131 1.131 0 1 1 1.131-1.131 1.132 1.132 0 0 1-1.131 1.134z" transform="translate(-273.714 -331.505)" />
                                <path fill="currentColor" id="Trazado_234" d="M114.134 114.8a.848.848 0 0 0-.664-.32H98.621l-.771-3.9a.848.848 0 0 0-.679-.669l-3.392-.622a.848.848 0 1 0-.306 1.668l2.825.518 2.489 12.579a.848.848 0 0 0 .832.683h11.872a.848.848 0 0 0 .826-.657l1.979-8.565a.847.847 0 0 0-.162-.715zm-3.317 8.245h-10.5l-1.359-6.869H112.4z" transform="translate(-92.778 -109.276)" />
                            </g>
                        </g>
                    </g>
                </svg>
                <span class="text-azul text-center navbarTextResponsive d-none d-sm-block" style="display: block">Mi cesta</span>
            </a>
        </div>
    </div>
</div>
{#<!-- para el menú pequeño-->#}
<div class="row mb-2 d-flex d-sm-none">
    <div class="col-12">
        <div class="row">
            <div class="col d-flex d-sm-none justify-content-center">
                <div class="d-flex justify-content-center align-items-center navbar-icon-participaciones pt-2 px-1">
                    <a class="text-center pt-1 bg-azul" href="{{config.baseconfig.url_panel}}/backend/users/profile" target="_blank">
                        {#<!-- Esto es icon-user.svg-->#}
                        <svg class="text-header m-1" xmlns="http://www.w3.org/2000/svg" id="Grupo_389" width="36.012" height="36.012" viewBox="0 0 36.012 36.012">
                            <path fill="currentColor" id="Trazado_225" d="M18.006 0a18.006 18.006 0 1 0 18.006 18.006A18 18 0 0 0 18.006 0zM6.148 28.591a15.892 15.892 0 0 1 23.715 0 15.881 15.881 0 0 1-23.715 0zM4.832 26.9a15.9 15.9 0 1 1 26.347 0 18 18 0 0 0-26.347 0z" />
                            <path fill="currentColor" id="Trazado_226" d="M172.33 61a6.337 6.337 0 0 0-6.33 6.33v2.11a6.33 6.33 0 1 0 12.66 0v-2.11a6.337 6.337 0 0 0-6.33-6.33zm4.22 8.44a4.22 4.22 0 1 1-8.44 0v-2.11a4.22 4.22 0 1 1 8.44 0z" transform="translate(-154.324 -56.71)" />
                        </svg>
                    </a>
                </div>
            </div>
            <div class="col-6 d-flex justify-content-center align-items-center pt-2">
                <a href="{{ url() }}" class="navbar-brand py-0 logo-navbar"><img src="{{config.datosadmon.data.media.logo}}" alt="" style="width:auto; max-height:75px;" class="logo-navbar"></a>
            </div>
            <div class="col d-flex d-sm-none justify-content-center">
                <div class="d-flex justify-content-center align-items-center navbar-icon-participaciones pt-2">
                    <a class="text-center pt-1 bg-azul" href="/carrito-comunidad">
                        <svg class="text-header m-1" xmlns="http://www.w3.org/2000/svg" id="Grupo_390" width="35.855" height="35.855" viewBox="0 0 35.855 35.855">
                            <path fill="currentColor" id="Trazado_231" d="M17.928 0a17.928 17.928 0 1 0 17.927 17.928A17.918 17.918 0 0 0 17.928 0zm10.9 29.406l-.068.063-.214.2c-.072.067-.132.117-.2.175l-.08.07q-.132.115-.267.226a15.811 15.811 0 0 1-20.407-.232l-.063-.055-.215-.19c-.071-.064-.12-.11-.179-.166l-.1-.1q-.468-.445-.9-.927l-.007-.008a15.885 15.885 0 0 1-1.31-1.68v-.007l-.017-.025q-.091-.136-.18-.273l-.04-.063q-.082-.128-.161-.257l-.028-.046q-.193-.318-.37-.644-.087-.16-.17-.322l-.013-.025q-.255-.5-.473-1.012l-.018-.043q-.068-.161-.132-.324l-.016-.014q-.069-.175-.133-.351l-.01-.028q-.055-.151-.107-.3l-.029-.086q-.045-.134-.087-.268l-.025-.078q-.051-.165-.1-.332l-.025-.091q-.034-.122-.066-.245l-.033-.13-.054-.222-.029-.124q-.036-.159-.069-.319l-.026-.132-.041-.213-.027-.15-.036-.215-.021-.133q-.024-.162-.046-.325l-.016-.131q-.014-.114-.026-.229l-.014-.138q-.013-.132-.023-.264c0-.03-.005-.06-.008-.091-.009-.116-.016-.233-.022-.349 0-.036 0-.072-.005-.108l-.01-.268v-.11-.365a15.827 15.827 0 0 1 31.653 0v.475q0 .134-.01.268c0 .036 0 .072-.005.108-.006.117-.013.233-.022.349 0 .03-.005.06-.008.091l-.023.264-.014.138q-.012.115-.026.229l-.016.131q-.021.163-.046.325l-.021.133c-.011.072-.023.143-.036.215l-.027.15-.041.213-.026.132q-.033.16-.069.319l-.029.124-.054.222-.033.13q-.032.123-.066.245l-.025.091q-.047.166-.1.332l-.025.078q-.042.134-.087.268l-.029.086q-.052.152-.107.3l-.01.028q-.065.176-.133.351l-.006.015q-.064.163-.132.324l-.018.043q-.218.514-.473 1.012l-.013.025q-.083.162-.17.322-.177.326-.37.644l-.028.046q-.079.129-.161.257l-.04.063q-.088.137-.18.273l-.017.025v.007a15.905 15.905 0 0 1-2.245 2.623z" />
                            <g id="Grupo_393" transform="translate(6.497 7.653)">
                                <g id="Grupo_392">
                                    <g id="Grupo_391">
                                        <path fill="currentColor" id="Trazado_232" d="M170.687 348.24a2.827 2.827 0 1 0 2.827 2.827 2.83 2.83 0 0 0-2.827-2.827zm0 3.957a1.131 1.131 0 1 1 1.131-1.131 1.132 1.132 0 0 1-1.131 1.134z" transform="translate(-162.602 -331.505)" />
                                        <path fill="currentColor" id="Trazado_233" d="M290.166 348.24a2.827 2.827 0 1 0 2.827 2.827 2.83 2.83 0 0 0-2.827-2.827zm0 3.957a1.131 1.131 0 1 1 1.131-1.131 1.132 1.132 0 0 1-1.131 1.134z" transform="translate(-273.714 -331.505)" />
                                        <path fill="currentColor" id="Trazado_234" d="M114.134 114.8a.848.848 0 0 0-.664-.32H98.621l-.771-3.9a.848.848 0 0 0-.679-.669l-3.392-.622a.848.848 0 1 0-.306 1.668l2.825.518 2.489 12.579a.848.848 0 0 0 .832.683h11.872a.848.848 0 0 0 .826-.657l1.979-8.565a.847.847 0 0 0-.162-.715zm-3.317 8.245h-10.5l-1.359-6.869H112.4z" transform="translate(-92.778 -109.276)" />
                                    </g>
                                </g>
                            </g>
                        </svg>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>