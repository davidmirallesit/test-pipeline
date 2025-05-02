<?php

use Phalcon\Mvc\Router;
use Infolot\Utilities;

$di->setShared('router', function () use ($config, $di) {
    $cache  = $di->getShared('cache');
    $router = new Router();

    // Para quitar barras extra automáticamente
    $router->removeExtraSlashes(true);

    // $router->add('/:params', [
    //     'controller' => 'index',
    //     'action' => 'index',
    //     'params' => 1
    // ]);

    // $router->add('/:controller/:action', [
    //     'controller' => 1,
    //     'action' => 2,
    //     // 'params' => 2
    // ]);

    // $router->add('/:controller/:action/:params', [
    //     'controller' => 1,
    //     'action' => 2,
    //     'params' => 3
    // ]);

    $communityIndexCacheKey = $config->cache->base_config_key . rtrim(Utilities::getServerName(), '/') . '_communities';
    $communityKeys = $cache->get($communityIndexCacheKey);

    if ($communityKeys) {
        foreach ($communityKeys as $cacheKey) {
            if ($cache->has($cacheKey)) {
                $keyword = $cache->get($cacheKey)["data"]["keyword"];
                if (isset($keyword)) {
                    $router->add(
                        '/' . $keyword,
                        [
                            'controller' => 'sections',
                            'action'     => 'ventaParticipacionesWithKeyword',
                        ]
                    )->setName($keyword);
                }
            }
        }
    }
    
    // if (is_dir($config->application->admonsDir . $_SERVER['SERVER_NAME'] . '/communities')) {
    //     foreach (scandir($config->application->admonsDir . $_SERVER['SERVER_NAME'] . '/communities') as $community) {
    //         if (preg_match('/.+\.ini$/', $community)) {
    //             $router->add(
    //                 '/' . rtrim($community, '.ini'),
    //                 [
    //                     'controller' => 'sections',
    //                     'action'     => 'ventaParticipacionesWithKeyword',
    //                 ]
    //             )->setName(rtrim($community, '.ini'));
    //         }
    //     }
    // }
    if ($config->datosadmon && $config->datosadmon->data->is_search_numbers) {
        $searchUrls = Utilities::getSearchUrlByNameSeo();
        if (!is_null($searchUrls)) {
            foreach ($searchUrls as $name_seo => $search_url) {
                $router->add(
                    "/$name_seo/$search_url",
                    [
                        'controller' => 'search',
                        'action'     => 'index',
                    ]
                )->setName('search-number');
        
                $router->add(
                    "/$name_seo/$search_url" . $config["search_urls"]["tailNumber"] . "([0-9]{1,4})",
                    [
                        'controller' => 'search',
                        'action'     => 'tailNumber',
                        'number'     => 1,
                    ]
                )->setName('search-tail-number');
        
                $router->add(
                    "/$name_seo/$search_url" . $config["search_urls"]["tailNumber"] . "([0-9]{5})",
                    [
                        'controller' => 'search',
                        'action'     => 'redirectToFullNumber',
                        'number'     => 1,
                    ]
                );
        
                $router->add(
                    "/$name_seo/$search_url" . $config["search_urls"]["fullNumber"] . "([0-9]{5})",
                    [
                        'controller' => 'search',
                        'action'     => 'fullNumber',
                        'number'     => 1,
                    ]
                )->setName('search-full-number');
            }
        }
        unset($searchUrls);
    }

    $router->add(
        '/',
        [
            'controller' => 'index',
            'action'     => 'index',
        ]
    );

    // StoryBook define routes
    $router->add(
        '/storybook',
        [
            'controller' => 'storyBook',
            'action'     => 'index',
        ]
    );

    $router->addGet(
        '/storybook/{file:.+}',
        [
            'controller' => 'storyBook',
            'action'     => 'static',
            "file"       => 1,
        ]
    );
    // End of StoryBook

    $router->add(
        '/robots.txt',
        [
            'controller' => 'sitemap',
            'action'     => 'robots',
        ]
    );

    $router->add(
        '/sitemap_index.xml.gz',
        [
            'controller' => 'sitemap',
            'action'     => 'index',
        ]
    );

    $router->add(
        '/test/show_php_info',
        [
            'controller' => 'test',
            'action'     => 'showPhpInfo',
        ]
    );

    $router->add(
        '/sitemap([0-9]+).xml.gz',
        [
            'controller' => 'sitemap',
            'action'     => 'sitemap',
            'number'     => 1,
        ]
    );

    $router->add(
        '/paginate-boletos',
        [
            'controller' => 'ajax',
            'action'     => 'paginateBoletos',
        ]
    );

    $router->add(
        '/save-cart-type-lotto',
        [
            'controller' => 'ajax',
            'action'     => 'saveCartTypeLotto',
        ]
    );

    $router->add(
        '/save-cart-type-apuestas',
        [
            'controller' => 'ajax',
            'action'     => 'saveCartTypeApuestas',
        ]
    );
    
    // // Define a route
    // $router->add(
    //     '/guardarCarritoEuromillones',
    //     [
    //         'controller' => 'ajax',
    //         'action'     => 'guardarCarritoEuromillones',
    //     ]
    // );

    // // Define a route
    // $router->add(
    //     '/guardarCarritoBonoloto',
    //     [
    //         'controller' => 'ajax',
    //         'action'     => 'guardarCarritoBonoloto',
    //     ]
    // );

    // // Define a route
    // $router->add(
    //     '/guardarCarritoPrimitiva',
    //     [
    //         'controller' => 'ajax',
    //         'action'     => 'guardarCarritoPrimitiva',
    //     ]
    // );

    // // Define a route
    // $router->add(
    //     '/guardarCarritoGordo',
    //     [
    //         'controller' => 'ajax',
    //         'action'     => 'guardarCarritoGordo',
    //     ]
    // );
    
    // Define a route
    $router->add(
        '/guardarCarritoLoteriaNacional',
        [
            'controller' => 'ajax',
            'action'     => 'guardarCarritoLoteriaNacional',
        ]
    );
    
    // Define a route
    // $router->add(
    //     '/guardarCarritoQuiniela',
    //     [
    //         'controller' => 'ajax',
    //         'action'     => 'guardarCarritoQuiniela',
    //     ]
    // );
    
    // Define a route
    $router->add(
        '/guardarCarritoQuinigol',
        [
            'controller' => 'ajax',
            'action'     => 'guardarCarritoQuinigol',
        ]
    );
    
    // // Define a route
    // $router->add(
    //     '/guardarCarritoLototurf',
    //     [
    //         'controller' => 'ajax',
    //         'action'     => 'guardarCarritoLototurf',
    //     ]
    // );
    
    // Define a route
    $router->add(
        '/setSessionUser',
        [
            'controller' => 'ajax',
            'action'     => 'setSessionUser',
        ]
    );
    
    // Define a route
    $router->add(
        '/guardarCarritoWs',
        [
            'controller' => 'ajax',
            'action'     => 'guardarCarritoWs',
        ]
    );
    
    // Define a route
    $router->add(
        '/saveUserDataWS',
        [
            'controller' => 'ajax',
            'action'     => 'saveUserDataWS',
        ]
    );
    
    // Define a route
    $router->add(
        '/createOrderWs',
        [
            'controller' => 'ajax',
            'action'     => 'createOrderWs',
        ]
    );
    
    // Define a route
    $router->add(
        '/createCommunityOrderWs',
        [
            'controller' => 'ajax',
            'action'     => 'createCommunityOrderWs',
        ]
    );
    
    // Define a route
    $router->add(
        '/saveNewAddressWS',
        [
            'controller' => 'ajax',
            'action'     => 'saveNewAddressWS',
        ]
    );
    
    // Define a route
    $router->add(
        '/getUserAdressesWS',
        [
            'controller' => 'ajax',
            'action'     => 'getUserAdressesWS',
        ]
    );

    // Define a route
    $router->add(
        '/check-results',
        [
            'controller' => 'ajax',
            'action'     => 'checkResults'
        ]
    );
    // Define a route
    $router->add(
        '/get-draw-results',
        [
            'controller' => 'ajax',
            'action'     => 'getDrawResults',
        ]
    );

    // Define a route
    $router->add(
        '/botes',
        [
            'controller' => 'sections',
            'action'     => 'botes',
        ]
    );
    
    // Define a route
    $router->add(
        '/carrito',
        [
            'controller' => 'carrito',
            'action'     => 'carrito',
        ]
    );
    
    $router->add(
        '/resume-order/{id}',
        [
            'controller' => 'order',
            'action' => 'resumeOrder'
        ]
    )->setName('resume-order');

    $router->add(
        '/cart/{id_cart}',
        [
            'controller' => 'voiceServer',
            'action' => 'cart'
        ]
    )->setName('cart');
    
    // Define a route
    $router->add(
        '/aviso-legal',
        [
            'controller' => 'legal',
            'action'     => 'avisoLegal',
        ]
    );
    
    // Define a route
    $router->add(
        '/politica-de-cookies',
        [
            'controller' => 'legal',
            'action'     => 'politicaCookies',
        ]
    );
    
    
    // Define a route
    $router->add(
        '/politica-privacidad',
        [
            'controller' => 'legal',
            'action'     => 'politicaPrivacidad',
        ]
    );
    
    
    // Define a route
    $router->add(
        '/condiciones-generales',
        [
            'controller' => 'about',
            'action'     => 'condicionesGenerales',
        ]
    );
    
    // Define a route
    $router->add(
        '/contacto',
        [
            'controller' => 'contacto',
            'action'     => 'index',
        ]
    );
    
    // Define a route
    $router->add(
        '/quienes-somos',
        [
            'controller' => 'about',
            'action'     => 'quienesSomos',
        ]
    );
    
    $router->add(
        '/carrito-comunidad',
        [
            'controller' => 'carrito',
            'action'     => 'carritoComunidad',
        ]
    );
    
    $router->add(
        '/venta-participaciones/{keyword}',
        [
            'controller' => 'sections',
            'action' => 'ventaParticipacionesWithKeyword'
        ]
    )->setName('venta-participaciones-keyword');
    
    
    $router->add(
        '/guardarCarritoParticipaciones',
        [
            'controller' => 'ajax',
            'action'     => 'guardarCarritoParticipaciones',
        ]
    );
    
    // Define a route
    $router->add(
        '/email-contacto',
        [
            'controller' => 'contacto',
            'action'     => 'emailContacto',
        ]
    );

    $router->add(
        '/get-header',
        [
            'controller' => 'sections',
            'action'     => 'getHeader',
        ]
    );

    $router->add(
        '/get-footer',
        [
            'controller' => 'sections',
            'action'     => 'getFooter',
        ]
    );

    // Define a route
    $router->add(
        '/css/styles.css',
        [
            'controller' => 'css',
            'action'     => 'webpremium',
        ]
    );

    $router->add('/validate', [
        'controller' => 'validate',
        'action'     => 'index',
    ]);

    /*
     * Rutas Api
    */
    $router->addPost(
        '/api/webhooks',
        'Api::webhooks'
    );

    $router->addPost(
        '/api/update-game-results',
        'Api::updateGameResults'
    );

    $router->addPost(
        '/api/update-next-draws',
        'Api::updateNextDraws'
    );

    $router->addPost(
        '/api/update-jackpots',
        'Api::updateJackpots'
    );

    $router->addPost(
        '/api/update-locations',
        'Api::updateLocations'
    );

    $router->addPost(
        '/api/community',
        'Api::community'
    );

    $router->addPost(
        '/api/admon',
        'Api::callApiAdmon'
    );

    $router->addPost(
        '/api/users',
        'Api::callApiAdmon'
    );

    $router->addPost(
        '/api/config',
        'Api::callApiAdmon'
    );

    $router->add(
        '/api/ping',
        'Api::ping'
    );

    $games = $di->getShared('getgames');
    if (!empty($games)) {
        foreach ($games as $game) {
            if ($game->id_operator != $config->games->id_operator_selae) {
                continue;
            }

            // Ruta Resultados
            $router->add('/resultados-'.$game->keyword, [
                'controller' => 'results',
                'action'     => 'genericResultados',
                'id_game'    => $game->id,
                'id_type'    => $game->id_type,
                'code'       => $game->lae->code,
                'name'       => $game->name
            ]);

            // Ruta Comprar
            if ($game->is_link_draw) {
                $router->add('/'.$game->keyword, [
                    'controller' => 'buy',
                    'action'     => 'getDatosLoteria',
                    'id_game'    => $game->id,
                    'id_type'    => $game->id_type,
                    'code'       => $game->lae->code,
                    'name'       => $game->name
                ]);

                if (array_key_exists($game->id, $config->games->draws_t->toArray())) {
                    foreach ($config->games->draws_t[$game->id] as $keyword => $type) {
                        $router->add('/'.$keyword, [
                            'controller' => 'buy',
                            'action'     => 'getDatosLoteria',
                            'id_game'    => $game->id,
                            'id_type'    => $game->id_type,
                            'code'       => $game->lae->code,
                            'name'       => $type['name'],
                            'id_draw_t'  => $type['id'],
                            'keyword'    => $keyword
                        ]);
                    }
                }
            } else {
                $router->add('/comprar-'.$game->keyword, [
                    'controller' => 'buy',
                    'action'     => 'genericCompra',
                    'id_game'    => $game->id,
                    'id_type'    => $game->id_type,
                    'code'       => $game->lae->code,
                    'name'       => $game->name
                ]);
            }
        }
    }

    $router->add(
        '/scripts/clean-all-cache',
        'Scripts::cleanAllCache'
    );

    if ($config->maintenance_enabled) {
        $router->add(
            '/mantenimiento',
            [
                'controller' => 'maintenance',
                'action' => 'index',
            ]
        );
    }

    return $router;
});

$router = $di->getRouter();

$router->handle($_SERVER['REQUEST_URI']);
