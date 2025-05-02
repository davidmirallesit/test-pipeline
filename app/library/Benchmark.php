<?php

namespace Infolot;

class Benchmark
{
    /**
     * Recoge una variable de tiempo y la añade a la pila de tiempos tomados
     *
     * @param     string    $name       Nombre de la variable
     * @param     float     $value      Valor de la variable
     * @param     int       $level      Nivel de jerarquía
     *
     * @return    void
     */
    public static function set_time(string $name, int $level = 1)
    {
        if (!defined('INI_TIME')) {
            die('Debe definir una constante INI_TIME al inicio de la aplicación: <pre>define(\'INI_TIME\', microtime(true));</pre>');
        }

        $GLOBALS['times'][] = [
            'name'  => $name,
            'time'  => microtime(true) - INI_TIME,
            'level' => $level
        ];
    }

    public static function get_times()
    {
        return $GLOBALS['times'] ?: [];
    }
}
