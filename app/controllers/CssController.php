<?php

class CssController extends ControllerBase
{
    public function webpremiumAction()
    {
        $this->view->disable();

        header("Content-type: text/css; charset: UTF-8");

        $datosAdmon = $this->config->get('datosadmon')->data;

        $primary_color = $datosAdmon->css->color_tema;
        $text_color = $datosAdmon->css->color_texto;
        $secondary_color = isset($datosAdmon->css->secondary_color_tema) ? $datosAdmon->css->secondary_color_tema : '#6cd660';
        $secondary_text_color = isset($datosAdmon->css->secondary_color_texto) ? $datosAdmon->css->secondary_color_texto : '#FFFFFF';
        $page_header = $datosAdmon->media->header;
        $page_footer = $datosAdmon->media->footer;
        $footer_bg = $datosAdmon->css->footer_bg_color;
        $footer_fg = $datosAdmon->css->footer_fg_color;
        $icon_bg_color = $datosAdmon->css->footer_icon_color;

        //echo file_get_contents('css/style.css');?>

        .btn-verde-claro,
        .button_buscar_numero,
        .carrito_button_finalizar,
        .resume_order_button_continuar,
        .button_anyadir_a_la_cesta_row_multi {
            background-color: <?php echo $primary_color; ?>;
            color: <?php echo $text_color; ?>;
        }

        .bg-alternative-border{
            background-color: <?php echo $text_color; ?>;
            border-color: <?php echo $primary_color; ?> !important;
        }

        .text-alternative{
            color: <?php echo $primary_color; ?> !important;
        }

        .text_color_ws_modals{
            color: <?php echo $text_color; ?> !important;
        }

        .selected_day{
            color: white !important;
            background-color: <?php echo $primary_color; ?>;
        }

        .text_color_ws{
            color: <?php echo $text_color; ?>;
        }

        .color_white{
            color: white;
        }

        body {
        font-size: 15px;
        font-family: 'Open Sans', sans-serif ;
        font-weight: 400;
        /*color: <?php echo $text_color; ?>;*/
        margin: 0;
        line-height: 25px;
        background: #fff;
        -webkit-box-sizing: box-sizing;
        -moz-box-sizing: box-sizing;
        box-sizing: box-sizing;
        }


        h1,
        h2,
        h3,
        h4,
        h5,
        h6 {
        font-family: 'Open Sans', sans-serif;
        /*color: <?php echo $text_color; ?>;*/
        font-weight: 700;
        }

        p {
        /*color: <?php echo $text_color; ?>;*/
        font-size: 14px;
        font-weight: 400;
        }


        a {
        /*color: <?php echo $primary_color; ?>;*/
        -webkit-transition: all 0.2s linear;
        -moz-transition: all 0.2s linear;
        -o-transition: all 0.2s linear;
        transition: all 0.2s linear;
        }

        .page-header{
            background-image: url('<?php echo $page_header; ?>');
        }

        #event{
            background-image: url('<?php echo $page_footer; ?>');
        }

        #copyright{
            background: <?php echo $footer_bg; ?>;
        }

        #cards{
            background: <?php echo $footer_bg; ?>;
        }

        footer{
            background: <?php echo $footer_bg; ?>;
            color: <?php echo $footer_fg; ?>;
        }

        footer ul li a {
            font-size: 13px;
            font-weight: 400;
            color: <?php echo $footer_fg; ?>;
        }

        #copyright .copyright-text{
            color: <?php echo $footer_fg; ?>;
        }

        .btn_login_style{
            background-color: <?php echo $text_color; ?>;
            color: <?php echo $primary_color; ?> !important;
            border-radius: 25px;
            margin-right: 15px;
        }

        .btn_goToCart{
            color: <?php echo $text_color; ?>;
            background-color: <?php echo $primary_color; ?> !important;
            border-radius: 25px;
            margin-right: 15px;
        }
        
        .btn_continueBuying{
            background-color: <?php echo $text_color; ?>;
            color: <?php echo $primary_color; ?> !important;
            border: 1px solid <?php echo $primary_color; ?>;
            border-radius: 25px;
            margin-right: 15px;
        }

        .text-azul{color: <?php echo $primary_color; ?>}
        .bg-azul{ background-color: <?php echo $primary_color ?>; }
        .btn-azul{ background-color: <?php echo $primary_color; ?>; color: #fff }
        .btn-header{ background-color: <?php echo $primary_color; ?>}
        .text-header{color: <?php echo $text_color ?>}
        header nav ul li a:hover{ color: <?php echo $primary_color; ?> !important }

        header nav ul li.active a{background: <?php echo $primary_color; ?> !important; color: #fff !important;border-radius: 50px; }

        header nav ul li .dropdown-menu{margin-top: 26px;  border-color: <?php echo $primary_color; ?>;border-style: solid;  border-width: 2px 0 0 0; text-transform: initial;}

        .button_login {
            background: <?php echo $primary_color; ?> !important; color: #fff !important;border-radius: 50px; 
            font-weight: lighter;
            border-color: unset;
            padding: .5rem 1.1rem !important;
        }

        .button_register {
            background: <?php echo $primary_color; ?> !important; color: #fff !important;border-radius: 50px;
            font-weight: lighter;
            border-color:unset;
            padding: .5rem 1.1rem !important;
        }

        .button_jugar_menu_games_home_comprobar{
        border-radius: 34px;
        background-color: <?php echo $primary_color; ?>;
        display: inline-block !important;
        justify-content: center;
        align-items: center;
        text-align: center;
        margin-right: 5px;
        }

        .button_jugar_menu_games_home{
            background-color: <?php echo $secondary_color; ?>;
        }

        .button_jugar_menu_games_home_text{
            color: <?php echo $text_color; ?>;
        }

        .button_jugar_menu_games_home_text_secondary {
            color: <?php echo $secondary_text_color; ?>;
        }

        .page-header .breadcrumb li {
        line-height: 25px;
        color: <?php echo $primary_color; ?>;
        }

        #sidebar .menu-left li a.cesta:hover{background-color:<?php echo $primary_color; ?>; color: #fff}

        .widget-buscador a.terminacion:hover{background-color: <?php echo $primary_color; ?>;}

        .back-to-top i {
        display: block;
        width: 40px;
        font-size: 20px;
        height: 40px;
        background: <?php echo $primary_color; ?>;
        color: <?php echo $text_color; ?>;
        text-align: center;
        box-shadow: 0px 6px 13px rgba(0, 0, 0, 0.08);
        line-height: 40px;
        border-radius: 50%;
        }

        .container_button_comprobar{
        background-color:<?php echo $primary_color; ?>;
        padding: 10px;
        text-align: center;
        cursor: pointer;
        width:190px;
        }

        .button_boleto_sencillo{
        width: 49%;
        height: 50px;
        background-color: <?php echo $primary_color; ?>;
        color:white;
        }

        .button_boleto_proximos_sorteos{
        width:100%;
        height: 50px;
        background-color: <?php echo $primary_color; ?>;
        color:white;
        }

        .button_boleto_multiple{
        width: 49%;
        height: 50px;
        background-color: <?php echo $primary_color; ?>;
        color:white;
        opacity: 0.3;
        }

        .button_comprar_añadir_al_carrito {
            background-color: <?php echo $primary_color; ?>;
            color: <?php echo $text_color; ?>;
        }

        .button_comprobar_euromillones_comprobar_apuesta{
        border-radius: 34px;
        background-color: <?php echo $primary_color; ?>;
        height: 59px;
        color: <?php echo $text_color; ?>;
        font-size: 20px;
        font-weight: 300;
        width: 228px;
        }

        .primary_color_background{
            background-color: <?php echo $primary_color; ?>;
        }

        .primary_color{
        color: <?php echo $primary_color; ?>;
        }


        <?php


        $this->response->setHeader('Content-Type', 'text/css');
        $this->response->setStatusCode(200, "");
        $this->response->send();
        return;
    }
}
?>
