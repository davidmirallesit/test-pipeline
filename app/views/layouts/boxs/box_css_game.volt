{#
    Para forzar nº columnas concreto usando FLEX:

    .parent {
        display: flex;
        flex-direction: row;
        flex-wrap: wrap;
        align-content: center;
        gap: 2px;
    }

    .child {
        flex: 1;
        flex-basis: 20%;
        aspect-ratio: 1; // Forma Cuadrada
    }
#}
<style>
    .selected > .item_figure {
        opacity: 1 !important;
    }

    .failed > .item_figure {
        opacity: 0.5 !important;
    }

    .label_resultados {
        align-self: center !important;
        font-size: 2rem;
        font-weight: 300;
        color: #656565;
    }

    .label_resultados_sm {
        font-size: 0.8rem;
        color: #656565;
        margin-right: 5px;
    }
    .label_resultados_premio {
        font-size: 1.6rem;
        font-weight: bold;
        color: #656565;
        margin-right: 22px;
    }

    .span_resultados {
        font-size: 1.2rem;
        font-weight: 600;
        color: #656565;
        margin-right: 5px;
        cursor: pointer;
    }

    .match_name {
        font-size: 14px;
        color: #656565;
        white-space: nowrap;
    }

    .section_featured {
        margin-top: 15px;
        margin-right: 50px;
        align-items: center;
        background-color: #f2f2f2;
        padding-top: 10px;
        padding-left: 30px;
        padding-right: 30px;
        padding-bottom: 5px;
    }

    .section_featured .text_label {
        font-size: 16px;
        font-weight: 600;
        color: #656565;
    }

    .btn-check-result {
        border-radius: 34px;
        background-color: {{ get_item_css('primary', 'bg', game, pv) }};
        height: 59px;
        color: {{ get_item_css('primary', 'fg', game, pv) }};
        font-size: 20px;
        font-weight: 300;
        width: 228px;
    }


{#######################################################################
 # NUMEROS PRINCIPALES
 #######################################################################}
    .number_container {
        position: relative;
        display: flex;
        flex-flow: row wrap;
        justify-content: left;
        align-items: center;
    }

    .number_box {
        box-sizing: border-box;
        /*flex: 1;
        flex-basis: 10%;*/
        min-height: 40px;
        margin-bottom: 2px;
    }
    .selectable .number_box:hover,
    .section-buy .number_box:hover {
        cursor:pointer;
    }

    .number_box .item_figure {
        opacity: 0.2;
        color: {{ get_item_css('number', 'bg', game, pv) }};
    }

    .section-buy .type-2 .item_figure_code_a_selected {
        color: {{ get_item_css('code_a', 'fg', game, pv) }} !important;
    }

    .number_box .item_text {
        font-size: 16px;
        font-weight: normal;
        color: {{ get_item_css('number', 'fg', game, pv) }};
    }

    .draw_results .number_box .item_text,
    .box_results .number_box .item_text {
        font-size: 1.5rem;
    }

    .game-type-2 .draw_results .number_box .item_text,
    .game-type-2 .box_results .number_box .item_text {
        font-size: 1.2rem;
    }

    /* SECCION DE COMPRAR */
    .section-buy .number_box .item_figure {
        color: {{ get_item_css('number', 'fg', game, pv) }};
    }

    .section-buy .number_box .item_text {
        color: {{ get_item_css('number', 'bg', game, pv) }};
    }

    /* invertir los colores al seleccionar los numeros */
    .section-buy .number_box.selected > .item_figure {
        color: {{ get_item_css('number', 'bg', game, pv) }};
    }

    .section-buy .number_box.selected > .item_text {
        color: {{ get_item_css('number', 'fg', game, pv) }};
    }

    .section-buy .number_box .item_figure {
        opacity: 0.2;
    }

    .section-buy .number_box .item_text {
        font-size: 14px;
    }

    .section-buy .number_box {
        min-height: unset;
    }

    .section-buy .number_container {
        justify-content: center;
    }

{#######################################################################
 # EXTRAS
 #######################################################################}
{% if game.num_extra_per_bet > 0 %}
    .extra_container {
        position: relative;
        display: flex;
        flex-flow: row wrap;
        justify-content: left;
        align-items: center;
    }

    .extra_box {
        box-sizing: border-box;
        min-height: 40px;
        margin-bottom: 2px;
    }
    .selectable .extra_box:hover,
    .section-buy .extra_box:hover {
        cursor:pointer;
    }

    .extra_box .item_figure {
        opacity: 0.2;
        color: {{ get_item_css('extra', 'bg', game, pv) }};
    }
    .extra_box .item_text {
        font-size: 16px;
        font-weight: normal;
        color: {{ get_item_css('extra', 'fg', game, pv) }};
    }

    .draw_results .extra_box .item_text,
    .box_results .number_box .item_text {
        font-size: 1.5rem;
    }

    .game-type-2 .draw_results .extra_box .item_text,
    .game-type-2 .box_results .number_box .item_text {
        font-size: 1.2rem;
    }

    /* SECCION DE COMPRAR */
    .section-buy .extra_box .item_text {
        font-size: 0.8em;
    }

    @media (max-width: 575px) {
        .section-buy .extra_container {
            justify-content: center;
        }
    }
{% endif %}

{#######################################################################
 # REINTEGRO
 #######################################################################}
{#% if game.is_num_refund > 0 and game.is_num_refund_selectable %#}
{% if game.is_num_refund > 0 %}
    .refund_container {
        position: relative;
        display: flex;
        flex-flow: row wrap;
        justify-content: center;
        align-items: center;
    }

    .refund_box {
        box-sizing: border-box;
        min-height: 40px;
        margin-bottom: 2px;
    }
    .selectable .refund_box:hover {
        cursor:pointer;
    }

    .refund_box .item_figure {
        opacity: 0.2;
        color: {{ get_item_css('refund', 'bg', game, pv) }};
    }

    .refund_box .item_text {
        font-size: 24px;
        font-weight: normal;
        color: {{ get_item_css('refund', 'fg', game, pv) }};
    }

    /* SECCION DE COMPRAR */
    .section-buy .refund_box .item_figure {
        color: {{ get_item_css('number', 'fg', game, pv) }};
    }

    .section-buy .refund_box .item_text {
        font-size: unset;
        color: {{ get_item_css('number', 'bg', game, pv) }};
    }

    /* invertir los colores al seleccionar el reintegro */
    .section-buy .refund_box.selected > .item_figure {
        color: {{ get_item_css('number', 'bg', game, pv) }};
    }

    .section-buy .refund_box.selected > .item_text {
        color: {{ get_item_css('number', 'fg', game, pv) }};
    }

    .section-buy .refund_box .item_figure {
        opacity: 0.2;
    }

    .section-buy .refund_box {
        min-height: unset;
    }
{% endif %}

{#######################################################################
 # COMPLEMENTARIO
 #######################################################################}
{% if game.is_num_complementary > 0 %}
    .complementary_container {
        position: relative;
        display: flex;
        flex-flow: row wrap;
        justify-content: center;
        align-items: center;
    }

    .complementary_box {
        box-sizing: border-box;
        min-height: 40px;
        margin-bottom: 2px;
    }
    .selectable .complementary_box:hover {
        cursor:pointer;
    }

    .complementary_box .item_figure {
        /*color: #ececec;*/
        opacity: 0.2;
        color: {{ get_item_css('complementary', 'bg', game, pv) }};
    }
    .complementary_box .item_text {
        font-size: 24px;
        font-weight: normal;
        color: {{ get_item_css('complementary', 'fg', game, pv) }};
    }
{% endif %}

{#######################################################################
 # Nº SERIE
 #######################################################################}
{% if game.is_num_serie > 0 %}
    .serie_box {
        box-sizing: border-box;
        min-height: 40px;
        margin-bottom: 2px;
        background-color: {{ get_item_css('serie', 'bg', game, pv) }};
        color: {{ get_item_css('serie', 'fg', game, pv) }};
    }
{% endif %}

{#######################################################################
 # Nº FRACCION
 #######################################################################}
{% if game.is_num_fraction > 0 %}
    .fraction_box {
        box-sizing: border-box;
        min-height: 40px;
        margin-bottom: 2px;
        background-color: {{ get_item_css('fraction', 'bg', game, pv) }};
        color: {{ get_item_css('fraction', 'fg', game, pv) }};
    }
{% endif %}

{#######################################################################
 # BOTE
 #######################################################################}
{% if game.is_jackpot > 0 %}
    .jackpot_box {
        box-sizing: border-box;
        min-height: 40px;
        margin-bottom: 2px;
        background-color: {{ get_item_css('jackpot', 'bg', game, pv) }};
        color: {{ get_item_css('jackpot', 'fg', game, pv) }};
    }
{% endif %}

{#######################################################################
 # CODIGO A
 #######################################################################}
{% if game.is_code_a > 0 %}
    .code_a_box {
        box-sizing: border-box;
        min-height: 40px;
        margin-bottom: 2px;
        font-size: 16px;
        font-weight: 300;
        color: {{ get_item_css('code_a', 'fg', game, pv) }};
        background-color: {{ get_item_css('code_a', 'bg', game, pv) }};
        color: {{ get_item_css('code_a', 'fg', game, pv) }};
    }

    .section-buy .code_a_box {
        min-height: 40px;
        margin-bottom: 2px;
    }

    .section-buy .type-2 .code_a_box {
        min-height: 45px;
    }

    .section-buy .type-1 .code_a_box {
        opacity: 0.2;
    }

    .section-buy .type-1 .code_a_box.selected {
        opacity: 1;
    }

    .section-buy .selectable .code_a_box:hover {
        cursor:pointer;
    }

    .section-buy .code_a_box .item_figure {
        opacity: 0.2;
        width: 10em;
    }

    .section-buy .type-2 .code_a_box .item_figure {
        opacity: 1;
        max-height: 40px;
    }

    .section-buy .code_a_box .item_text {
        font-size: 14px;
        font-weight: normal;
    }
{% endif %}

{#######################################################################
 # CODIGO B
 #######################################################################}
{% if game.is_code_b > 0 %}
    .code_b_box {
        box-sizing: border-box;
        min-height: 40px;
        margin-bottom: 2px;
        font-size: 16px;
        font-weight: 300;
        color: {{ get_item_css('code_b', 'fg', game, pv) }};
        background-color: {{ get_item_css('code_b', 'bg', game, pv) }};
        color: {{ get_item_css('code_b', 'fg', game, pv) }};
    }

    .section-buy .code_b_box {
        min-height: 40px;
        margin-bottom: 2px;
    }

    .section-buy .type-1 .code_b_box {
        opacity: 0.2;
    }

    .section-buy .type-1 .code_b_box.selected {
        opacity: 1;
    }

    .section-buy .selectable .code_b_box:hover {
        cursor:pointer;
    }

    .section-buy .code_b_box .item_figure {
        opacity: 0.4;
        width: 10em;
    }

    .section-buy .code_b_box .item_text {
        font-size: 14px;
        font-weight: normal;
    }

    .section-buy .code_b_box .item_figure {
        opacity: 0.2;
    }
{% endif %}


{#######################################################################
 # XXX ELIMINAR???
 #
 # Mirar si se pueden eliminar los estilos que se muestran a continuación
 #######################################################################}

    .ball_container {
        margin: 15px;
        font-weight: 300;
    }

    .ball_container_selector {
        font-weight: 300;
    }

    .ball_container_prizes {
        margin: 0px 8px 16px 8px;
        font-weight: 300;
    }

    .ball_off_number {
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.number_fg_color}}{% endif %};
        padding-top: 15px;
        padding-left: 8px;
    }

    .ball_off_background {
        color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.number_bg_color}}{% endif %};
        opacity: 0.4;
        font-size: 4em;
    }

    .ball_on_number {
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.number_fg_color}}{% endif %};
        padding-top: 15px;
        padding-left: 8px;
    }

    .ball_on_background {
        color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.number_bg_color}}{% endif %};
        font-size: 4em;
    }

    .ball_off_number_extra {
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.extra_fg_color}}{% endif %};
        padding-top: 16px;
        padding-left: 14px;
        font-size: 1.6em;
    }

    .ball_on_number_extra {
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.extra_fg_color}}{% endif %};
        padding-top: 16px;
        padding-left: 14px;
        font-size: 1.6em;
    }

    .ball_off_background_extra {
        color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.extra_bg_color}}{% endif %};
        opacity: 0.4;
        font-size: 4em;
    }

    .ball_on_background_extra:before {
        content:"\f005"
    }
    .ball_on_background_extra {
        color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.extra_bg_color}}{% endif %};
        font-size: 4em;
    }

    .ball_off_background_extra:before {
        content:"\f005"
    }
    .ball_off_background_extra {
        color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.extra_bg_color}}{% endif %};
        opacity: 0.4;
        font-size: 4em;
    }

    .ball_off_background_complementary {
        color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.num_complementary_bg_color}}{% endif %};
        opacity: 0.4;
        font-size: 4em;
    }

    .ball_on_background_complementary {
        color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.num_complementary_bg_color}}{% endif %};
        font-size: 4em;
    }

    .ball_off_number_complementary {
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.num_complementary_fg_color}}{% endif %};
        padding-top: 15px;
        padding-left: 8px;
    }

    .ball_on_number_complementary {
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.num_complementary_fg_color}}{% endif %};
        padding-top: 15px;
        padding-left: 8px;
    }

    .ball_off_background_refund {
        color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.num_refund_bg_color}}{% endif %};
        opacity: 0.4;
        font-size: 4em;
    }

    .ball_on_background_refund {
        color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.num_refund_bg_color}}{% endif %};
        font-size: 4em;
    }

    .ball_off_number_refund {
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.num_refund_fg_color}}{% endif %};
        padding-top: 15px;
        padding-left: 18px;
    }

    .ball_on_number_refund {
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.num_refund_fg_color}}{% endif %};
        padding-top: 15px;
        padding-left: 18px;
    }

    .ball_on {
        background-color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.number_bg_color}}{% endif %};
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.number_fg_color}}{% endif %};
    }

    .ball_off_refund {
        background-color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.num_refund_bg_color}}{% endif %};
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.num_refund_fg_color}}{% endif %};
        opacity: 0.4;
    }

    .ball_on_refund {
        background-color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.num_refund_bg_color}}{% endif %};
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.num_refund_fg_color}}{% endif %};
    }

    .ball_off_complementary {
        background-color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.num_complementary_bg_color}}{% endif %};
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.num_complementary_fg_color}}{% endif %};
        opacity: 0.4;
    }

    .ball_on_complementary {
        background-color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.num_complementary_bg_color}}{% endif %};
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.num_complementary_fg_color}}{% endif %};
    }

    .ball_on_number_prizes {
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.number_fg_color}}{% endif %};
        padding-top: 8px;
        padding-left: 6px;
        font-size: 1.5em;
    }

    .ball_on_background_prizes {
        color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.number_bg_color}}{% endif %};
        font-size: 3em;
    }

    .ball_on_number_extra_prizes {
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.extra_fg_color}}{% endif %};
        padding-top: 8px;
        padding-left: 10px;
        font-size: 1.3em;
    }

    .ball_on_background_extra_prizes {
        color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.extra_bg_color}}{% endif %};
        font-size: 3em;
    }

    .ball_on_background_complementary_prizes {
        color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.num_complementary_bg_color}}{% endif %};
        font-size: 3em;
    }

    .ball_on_number_complementary_prizes {
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.num_complementary_fg_color}}{% endif %};
        padding-top: 8px;
        padding-left: 6px;
        font-size: 1.5em;
    }

    .ball_on_background_refund_prizes {
        color: {% if pv.css.number_no_raffle_bg_color %}{{pv.css.number_no_raffle_bg_color}}{% else %}{{game.num_refund_bg_color}}{% endif %};
        font-size: 3em;
    }

    .ball_on_number_refund_prizes {
        color: {% if pv.css.number_no_raffle_fg_color %}{{pv.css.number_no_raffle_fg_color}}{% else %}{{game.num_refund_fg_color}}{% endif %};
        padding-top: 8px;
        padding-left: 6px;
        font-size: 1.5em;
    }
</style>
