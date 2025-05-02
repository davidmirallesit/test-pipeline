<?php
namespace Infolot\Phalcon\Mvc\View\Engine;

use \Phalcon\Mvc\View\Engine\Volt\Compiler;

#[\AllowDynamicProperties]
class Volt extends \Phalcon\Mvc\View\Engine\Volt
{
    /**
     * Returns the Volt's compiler
     *
     * @return Compiler
     */
    public function getCompiler(): Compiler {
        $di     = \Phalcon\Di\Di::getDefault();
        $config = $di->getShared("config");
        $dir    = $this->view->getViewsDir();

        // si no se está buscando plantilla custom o no hay se carga la default
        if (strpos($dir, $config->application->templatesDir) === false || !property_exists($config->datosadmon->data, 'template') || $config->datosadmon->data->template == $config->application->defaultTemplate) {
            return parent::getCompiler();
        }

        // si es una plantilla se usa el compiler customizado para modificar la ruta de los archivos
        $compiler = new \Infolot\Phalcon\Mvc\View\Engine\Volt\Compiler($this->view);
        $compiler->setOption('path', function ($templatePath) use ($config) {
            $basePath = $config->application->templatesDir;
    
            $templatePath = trim(substr($templatePath, strlen($basePath)), '\\/');
            // se quita el uuid para usarlo como carpeta
            $templatePath = str_replace($config->datosadmon->data->template . DIRECTORY_SEPARATOR, '', $templatePath);
            // Vamos a dejar .volt para que se genera .volt.php (para poder excluir más facilmente en el linter que no los revise)
            $filename = basename(str_replace(['\\', '/'], '_', $templatePath), '.volt') . '.php';
            $filename = basename(str_replace(['\\', '/'], '_', $templatePath)) . '.php';
    
            $cacheDir = realpath($config->application->cacheDir);

            if (!$cacheDir) {
                $cacheDir = sys_get_temp_dir();
            }
    
            $cacheDir .= DIRECTORY_SEPARATOR . 'volt';
    
            if (!is_dir($cacheDir)) {
                @mkdir($cacheDir, 0755, true);
            }
    
            $cacheDir .= DIRECTORY_SEPARATOR . $config->datosadmon->data->template;
    
            if (!is_dir($cacheDir)) {
                @mkdir($cacheDir, 0755, true);
            }
    
            $compiledPath = $cacheDir . DIRECTORY_SEPARATOR . $filename;
            return $compiledPath;
        });
        $this->compiler = $compiler;
        return parent::getCompiler();
    }
}
