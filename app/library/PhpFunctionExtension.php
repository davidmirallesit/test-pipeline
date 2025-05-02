<?php

namespace Infolot;

/**
 * Clase usada para ampliar la funcionalidad de Volt, permitiendo entonces
 * usar desde Volt cualquier función de PHP
 */
class PhpFunctionExtension
{
    /**
     * Este metodo es llamado ante cualquier intento de compilar una función llamada
     */
    public function compileFunction($name, $arguments)
    {
        if ($name != '_' && function_exists($name)) {
            return $name . '('. $arguments . ')';
        }
    }
}