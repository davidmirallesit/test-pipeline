{% if datosAdmon.games.buy_online == 1 and datosAdmon.games.club_amigo_online == 1 %}
<div class="mt-0 blog-post">
    <div class="post-content text-center bg-azul">
        <div class="row px-4 pt-4">
            <div class="col-12 col-md-7 text-left text_color_ws">
                <h6>REGÍSTRESE PARA JUGAR A JUEGOS ACTIVOS</h6>
                <p class="bg-azul text-left">Es preciso registrarse para jugar On-Line a los juegos
                    activos.
                    Si todavía no está registrado, regístrese y juegue ya!</p>
            </div>
            <div class="col-12 col-md-5">
                <a target="_blank" class="btn-dark btn rounded-0 text-uppercase col-12 mx-0 my-1 mb-3 text-white white_space_normal" href="https://juegos.loteriasyapuestas.es/CF/registration/modifyRetailerInput.do?newRetailerId=<?= RECEPTOR_ID ?>">
                    Registrarse en <br />Loterias del Estado
                </a>
            </div>
        </div>
    </div>
</div>
{% endif %}
