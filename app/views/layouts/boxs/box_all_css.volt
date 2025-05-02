{##############################################################################
 #
 # Fichero a incluir en footer/header, con el CSS común para toda la web
 #
 # Usado en:
 #    - views/index.volt
 #    - views/partial/header.volt
 #
 ##############################################################################}
     {# Cacheamos ciertas URLs externas #}
    <link rel="preconnect" href="https://ssl.google-analytics.com" crossorigin="anonymous">
    <link rel="preconnect" href="https://www.google.com" crossorigin="anonymous">
    <link rel="preconnect" href="https://fonts.googleapis.com" crossorigin="anonymous">
    <link rel="preconnect" href="https://www.googletagmanager.com" crossorigin="anonymous">
    <link rel="preload" href="https://fonts.googleapis.com/css?family=Open+Sans:300,300i,400,400i,600,600i,700,700i,800,800i&display=swap" as="style" crossorigin="anonymous">
    <link rel="preload" href="https://fonts.googleapis.com/css?family=Open+Sans:400,700|Roboto:400,500,700" as="style" crossorigin="anonymous">
    <link rel="preload" href="{{ static_url('css/all.min.css?v' ~ config.version) }}" as="style">
    <link rel="preload" href="{{ static_url('js/all.min.js?v' ~ config.version) }}" as="script">

    <link rel="stylesheet" type="text/css" href="{{ static_url('css/all.min.css?v' ~ config.version) }}" />
    <link rel="stylesheet" type="text/css" href="{{ static_url('css/styles.css?v' ~ config.version) }}" />
