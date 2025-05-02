<?php
use \Phalcon\Autoload\Loader;

$loader = new Loader;

/**
 * Register Namespaces
 */
$loader->setNamespaces([
    'Infolot'         => $config->application->libraryDir,
    'Infolot\Plugins' => $config->application->pluginsDir
]);

/**
 * We're a registering a set of directories taken from the configuration file
 */
$loader->setDirectories([
    $config->application->controllersDir,
    //$config->application->modelsDir
]);

/**
 * Registramos composer
 */
$loader->setFiles([
    $config->application->vendorDir.'autoload.php'
]);

$loader->register();
