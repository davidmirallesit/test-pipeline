<?php
namespace Infolot\Phalcon\Mvc\View\Engine\Volt;

use Closure;
use Infolot\Utilities;

#[\AllowDynamicProperties]
class Compiler extends \Phalcon\Mvc\View\Engine\Volt\Compiler
{
    public function __construct(\Phalcon\Mvc\ViewBaseInterface $view) {
        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getShared("config");
        $this->baseDir = $config->application->viewsDir;
        parent::__construct($view);
        Utilities::completeCompiler($this);
    }

    /**
     * Compiles a template into a file forcing the destination path
     *
     *```php
     * $compiler->compileFile(
     *     "views/layouts/main.volt",
     *     "views/layouts/main.volt.php"
     * );
     *```
     *
     * @param string path
     * @param string compiledPath
     * @param bool extendsMode
     *
     * @throws \Phalcon\Mvc\View\Engine\Volt\Exception
     * @return string|array
     */
    public function compileFile(string $path, string $compiledPath, bool $extendsMode = false) 
    {
        // var viewCode, compilation, finalCompilation;

        if ($path == $compiledPath) {
            throw new \Phalcon\Mvc\View\Engine\Volt\Exception(
                "Template path and compilation template path cannot be the same"
            );
        }

        /**
         * Check if the template does exist
         */
        if (!file_exists($path)) {
            throw new \Phalcon\Mvc\View\Engine\Volt\Exception("Template file " . $path . " does not exist");
        }

        /**
         * Always use file_get_contents instead of read the file directly, this
         * respect the open_basedir directive
         */
        $viewCode = file_get_contents($path);

        if ($viewCode === false) {
            throw new \Phalcon\Mvc\View\Engine\Volt\Exception(
                "Template file " . $path . " could not be opened"
            );
        }

        $this->currentPath = $path;

        $compilation = $this->compileSource($viewCode, $extendsMode);

        /**
         * We store the file serialized if it's an array of blocks
         */
        if (gettype($compilation) == "array") {
            $finalCompilation = serialize($compilation);
        } else {
            $finalCompilation = $compilation;
        }

        $di = \Phalcon\Di\Di::getDefault();
        $config = $di->getShared("config");
        $basePath = $config->application->templatesDir;
        $templatePath = trim(substr($path, strlen($basePath)), '\\/');
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

        /**
         * Always use file_put_contents to write files instead of write the file
         * directly, this respect the open_basedir directive
         */
        if (file_put_contents($compiledPath, $finalCompilation) === false) {
            throw new \Phalcon\Mvc\View\Engine\Volt\Exception("Volt directory can't be written");
        }

        return $compilation;
    }

    /**
     * Gets the final path with VIEW
     */
    protected function getFinalPath(string $path)
    {
        $view = $this->view;

        if (gettype($view) == "object") {
            $viewsDirs = $view->getViewsDir();

            if (gettype($viewsDirs) == "array") {
                foreach ($viewsDirs as $viewsDir) {
                    if (file_exists($viewsDir . $path)) {
                        return $viewsDir . $path;
                    }
                }

                // Otherwise, take the last viewsDir
                return $this->baseDir . $path;
            } else {
                if (file_exists($viewsDirs . $path)) {
                    return $viewsDirs . $path;
                }
                return $this->baseDir . $path;
            }
        }

        return $path;
    }

    /**
     * Compiles a template into a file applying the compiler options
     * This method does not return the compiled path if the template was not compiled
     *
     *```php
     * $compiler->compile("views/layouts/main.volt");
     *
     * require $compiler->getCompiledTemplatePath();
     *```
     *
     * @param string templatePath
     * @param bool extendsMode
     *
     * @throws \Phalcon\Mvc\View\Engine\Volt\Exception
     * @return mixed
     */
    public function compile(string $templatePath, bool $extendsMode = false)
    {
        /**
         * Re-initialize some properties already initialized when the object is
         * cloned
         */
        $this->extended = false;
        $this->extendedBlocks = false;
        $this->blocks = null;
        $this->level = 0;
        $this->foreachLevel = 0;
        $this->blockLevel = 0;
        $this->exprLevel = 0;

        $compilation = null;

        $options = $this->options;

        /**
         * This makes that templates will be compiled always
         */
        if (!$compileAlways = $options["always"]) {
            if ($compileAlways = $options["compileAlways"]) {
                trigger_error(
                    "The 'compileAlways' option is deprecated. Use 'always' instead.",
                    E_USER_DEPRECATED
                );
            } else {
                $compileAlways = false;
            }
        }

        if (gettype($compileAlways) != "boolean") {
            throw new \Phalcon\Mvc\View\Engine\Volt\Exception("'always' must be a bool value");
        }

        /**
         * Prefix is prepended to the template name
         */
        if (!$prefix = $options["prefix"]) {
            $prefix = "";
        }

        if (gettype($prefix) != "string") {
            throw new \Phalcon\Mvc\View\Engine\Volt\Exception("'prefix' must be a string");
        }

        /**
         * Compiled path is a directory where the compiled templates will be
         * located
         */
        if (!$compiledPath = $options["path"]) {
            if ($compiledPath = $options["compiledPath"]) {
                trigger_error(
                    "The 'compiledPath' option is deprecated. Use 'path' instead.",
                    E_USER_DEPRECATED
                );
            } else {
                $compiledPath = "";
            }
        }

        /**
         * There is no compiled separator by default
         */
        if (!$compiledSeparator = $options["separator"]) {
            if ($compiledSeparator = $options["compiledSeparator"]) {
                trigger_error(
                    "The 'compiledSeparator' option is deprecated. Use 'separator' instead.",
                    E_USER_DEPRECATED
                );
            } else {
                $compiledSeparator = "%%";
            }
        }

        if (gettype($compiledSeparator) != "string") {
            throw new \Phalcon\Mvc\View\Engine\Volt\Exception("'separator' must be a string");
        }

        /**
         * By default the compile extension is .php
         */
        if (!$compiledExtension = $options["extension"]) {
            if ($compiledExtension = $options["compiledExtension"]) {
                trigger_error(
                    "The 'compiledExtension' option is deprecated. Use 'extension' instead.",
                    E_USER_DEPRECATED
                );
            } else {
                $compiledExtension = ".php";
            }
        }

        if (gettype($compiledExtension) != "string") {
            throw new \Phalcon\Mvc\View\Engine\Volt\Exception("'extension' must be a string");
        }

        /**
         * Stat option assumes the compilation of the file
         */
        if (!$stat = $options["stat"]) {
            $stat = true;
        }

        /**
         * Check if there is a compiled path
         */

        if (gettype($compiledPath) == "string") {
            /**
             * Calculate the template realpath's
             */
            if (!empty($compiledPath)) {
                /**
                 * Create the virtual path replacing the directory separator by
                 * the compiled separator
                 */
                $templateSepPath = $this->custom_prepare_virtual_path(
                    realpath($templatePath),
                    $compiledSeparator
                );
            } else {
                $templateSepPath = $templatePath;
            }

            /**
             * In extends mode we add an additional 'e' suffix to the file
             */
            if ($extendsMode) {
                $compiledTemplatePath = $compiledPath . $prefix . $templateSepPath . $compiledSeparator . "e" . $compiledSeparator . $compiledExtension;
            } else {
                $compiledTemplatePath = $compiledPath . $prefix . $templateSepPath . $compiledExtension;
            }
        } elseif (gettype($compiledPath) == "object" && $compiledPath instanceof Closure) {
            /**
             * A closure can dynamically compile the path
             */
            $compiledTemplatePath = call_user_func_array(
                $compiledPath,
                [$templatePath, $options, $extendsMode]
            );

            /**
             * The closure must return a valid path
             */
            if (gettype($compiledTemplatePath) != "string") {
                throw new \Phalcon\Mvc\View\Engine\Volt\Exception(
                    "'path' closure didn't return a valid string"
                );
            }
        } else {
            throw new \Phalcon\Mvc\View\Engine\Volt\Exception(
                "'path' must be a string or a closure"
            );
        }

        /**
         * Compile always must be used only in the development stage
         */
        if (!file_exists($compiledTemplatePath) || $compileAlways) {
            /**
             * The file needs to be compiled because it either doesn't exist or
             * needs to compiled every time
             */
            $compilation = $this->compileFile(
                $templatePath,
                $compiledTemplatePath,
                $extendsMode
            );
        } else {
            if ($stat === true) {
                /**
                 * Compare modification timestamps to check if the file
                 * needs to be recompiled
                 */
                if (filemtime($templatePath) < filemtime($compiledTemplatePath)) {
                    $compilation = $this->compileFile(
                        $templatePath,
                        $compiledTemplatePath,
                        $extendsMode
                    );
                } else {
                    if ($extendsMode) {
                        /**
                         * In extends mode we read the file that must
                         * contains a serialized array of blocks
                         */
                        $blocksCode = file_get_contents($compiledTemplatePath);

                        if ($blocksCode === false) {
                            throw new \Phalcon\Mvc\View\Engine\Volt\Exception(
                                "Extends compilation file " . $compiledTemplatePath . " could not be opened"
                            );
                        }

                        /**
                         * Unserialize the array blocks code
                         */
                        if ($blocksCode) {
                            $compilation = unserialize($blocksCode);
                        } else {
                            $compilation = [];
                        }
                    }
                }
            }
        }

        $this->compiledTemplatePath = $compiledTemplatePath;

        return $compilation;
    }

    private function custom_prepare_virtual_path($path, $virtual_separator) {
        $virtual_str = '';
    
        if (gettype($pat) != 'string' || gettype($virtual_separator) != 'string') {
            if (gettype($path) == 'string') {
                return $path;
            }
            return '';
        }

        for ($i = 0; $i < strlen($path); $i++) {
            $ch = $path[$i];
            if ($ch == '\0') {
                continue;
            }
            if ($ch == '/' || $ch == '\\' || $ch == ':') {
                $virtual_str .= $virtual_separator;
            }
            else {
                $virtual_str .= $ch;
            }
        }

        if ($virtual_str) {
            return $virtual_str;
        }
        return '';
    }
}