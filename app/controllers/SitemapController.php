<?php

use Infolot\Utilities;
use \Phalcon\Mvc\View;

// 1º las primeras 50k urls, 2º las siguinetes 50k y 3º las terminaciones
const SITEMAPS_PER_SEARCHER = 3;

class SitemapController extends ControllerBase
{
    public function indexAction()
    {
        $this->view->setRenderLevel(View::LEVEL_LAYOUT);
        $di = \Phalcon\Di\Di::getDefault();
        $di->getRouter();
        // el 0 es inclusive y hace referenca a las urls de la web no del buscador de numeros
        $sitemapsNeeded = 0;
        $lastModDates = [date('Y-m-d')];
        if ($this->config->datosadmon->data->is_search_numbers) {
            $searcherUrls = Utilities::getSitemapSearchUrlByNameSeo();
            $urls = [];
            if (!is_null($searcherUrls)) {
                foreach ($searcherUrls as $key => $value) {
                    for ($i=0; $i < SITEMAPS_PER_SEARCHER; $i++) {
                        $lastModDates[] = Utilities::getLastModByNameSeo($key);
                    }
                    $urls[] = "/$key/$value";
                }
            }
            unset($searcherUrls);
            $sitemapsNeeded += SITEMAPS_PER_SEARCHER * count($urls);
        }

        $this->view->setVars([
            "url" => $this->config->datosadmon->data->url->main,
            "sitemapsNeeded" => $sitemapsNeeded,
            "lastModDates" => $lastModDates,
        ]);

        $this->response->setContentType('application/xml', 'UTF-8');
    }

    public function robotsAction()
    {
        $this->view->disable();
        header('Content-type: text/plain; charset=utf-8');
        //puede ser un sitemap index
        $sitemapUrl = rtrim($this->config->datosadmon->data->url->main, '/') . '/sitemap_index.xml.gz';

        if ($this->config->datosadmon->data->cod_admon == '300260003') {
            echo <<<EOT
            User-agent: *

            # Bloqueo de las terminaciones menos navidad
            Disallow: /*/buscador-numeros/*

            # Permitir terminaciones navidad
            Allow: /loteria-navidad/buscador-numeros/*

            # Bloqueo de las URL dinamicas
            Disallow: /*?

            Disallow: /*.ini
            Disallow: /*.log
            Disallow: /*.sql
            Disallow: /*.json

            Sitemap: $sitemapUrl

            EOT;
            return;
        }

        //si no se habilita el Googlebot no puede pillar el sitemap y no sirve de nada
        echo <<<EOT
        User-agent: *
        Disallow: /

        User-agent: Googlebot
        Allow: /
        Disallow: /*.ini
        Disallow: /*.log
        Disallow: /*.sql
        Disallow: /*.json

        Sitemap: $sitemapUrl

        EOT;
    }

    public function sitemapAction($number = null)
    {
        ini_set('memory_limit', '512M');
        $fileIndex = intval($number);
        if ($number > 0) {
            $urlIndex = 0;
            while ($fileIndex > SITEMAPS_PER_SEARCHER) {
                $urlIndex++;
                $fileIndex -= SITEMAPS_PER_SEARCHER;
            }

            $tmp = Utilities::getSitemapSearchUrlByNameSeo();
            foreach ($tmp as $key => $value) {
                $urls[] = "/$key/$value";
                $nameSeos[] = $key;
            }
            unset($tmp);

            if (!array_key_exists($urlIndex, $urls)) {
                //TODO unificar este codigo y el del validatecontroller
                $di         = \Phalcon\Di\Di::getDefault();
                $dispatcher = $di->getShared('dispatcher');
        
                return $dispatcher->forward([
                    'namespace'  => $dispatcher->getNamespaceName(),
                    'module'     => $dispatcher->getModuleName(),
                    'controller' => 'error',
                    'action'     => 'show404',
                    'params'     => []
                ]);
            }

            $finalUrl = $this->config->datosadmon->data->url->main . $urls[$urlIndex];

            switch ($fileIndex) {
                case 1:
                    // primera mitad de los 100k numeros
                    $this->view->pick('sitemap/search_numbers_first_half');
                    $finalUrl .= $this->config["search_urls"]["fullNumber"];
                    break;
                case 2:
                    // segunda mitad de los 100k numeros
                    $this->view->pick('sitemap/search_numbers_second_half');
                    $finalUrl .= $this->config["search_urls"]["fullNumber"];
                    break;
                case 3:
                    // terminaciones
                    $this->view->pick('sitemap/search_tail_numbers');
                    $finalUrl .= $this->config["search_urls"]["tailNumber"];
                    break;
            }
            $this->view->setVars([
                "url" => $finalUrl,
                "last_mod" => Utilities::getLastModByNameSeo($nameSeos[$urlIndex])
            ]);
            $this->view->setRenderLevel(View::LEVEL_LAYOUT);
        } else {
            $urls = Utilities::getSitemap($number);
            $this->view->pick('sitemap/web');

            $this->view->setVars([
                "urls" => $urls,
                "webUrl" => $this->config->datosadmon->data->url->main,
                "last_mod" => date('Y-m-d')
            ]);
        }
        $this->view->setRenderLevel(View::LEVEL_LAYOUT);
        $this->response->setContentType('application/xml', 'UTF-8');
    }
}
