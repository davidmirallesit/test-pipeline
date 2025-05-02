<div class="col-12" style="margin-top: 25px">

    <div class="blog-post">
        {% if config.baseconfig.media_domain is defined and datosAdmon.pages.header is defined %}
        <div class="feature-inner">
            <a class="lightbox"><img src="{{config.baseconfig.media_domain}}/{{datosAdmon.pages.header}}" alt=""></a>
        </div>
        {% endif %}
        {% if datosAdmon.pages.conocenos.text is defined %}
        <div class="post-content p-4 text-black">
            {{datosAdmon.pages.conocenos.text}}
        </div>
        {% endif %}
    </div>

    {#<!-- registrese para juegos activos -->#}
    {% if (datosAdmon.games.buy_online == 1 and datosAdmon.games.club_amigo_online == 1) %}
        <div class="blog-post">
            <div class="post-content text-center bg-azul">
                <div class="row px-4 pt-4">
                    <div class="col-12 col-md-7 text-left text_color_ws">
                        <h6>REGÍSTRESE PARA JUGAR A JUEGOS ACTIVOS</h6>
                        <p class="bg-azul text-left">Es preciso registrarse para jugar On-Line a los juegos
                            activos.
                            Si todavía no está registrado, regístrese y juegue ya!</p>
                    </div>
                    <div class="col-12 col-md-5">
                        <a target="_blank" class="btn-dark btn rounded-0 text-uppercase col-12 mx-0 my-1 mb-3 text-white white_space_normal" href="https://juegos.loteriasyapuestas.es/CF/registration/modifyRetailerInput.do?newRetailerId={{constant('RECEPTOR_ID')}}">
                            Registrarse en <br />Loterias del Estado
                        </a>
                    </div>
                </div>
            </div>
        </div>
        {#<!-- registrese para juegos activos -->#}
    {% endif %}
</div>
