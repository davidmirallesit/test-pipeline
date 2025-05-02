<?php

use Infolot\Utilities;

class ScriptsController extends ControllerBase
{
    public function cleanAllCacheAction()
    {
        var_dump($_SERVER['REMOTE_ADDR']);

        Utilities::clean_all_cache(true);
    }

    public function pingAction()
    {
        $mem  = memory_get_usage(true);
        $time = microtime(true);

        $this->show_json([
            'status'        => 'OK',
            'date_commited' => date('d/m/Y H:i:s', filemtime(BASE_PATH.'/public/commands/command.lck')),
            'time'          => sprintf('%.8f sec.', $time - INI_TIME),
            'consumed_mem'  => sprintf('+%.2f MB (%.2f MB)', ($mem - INI_MEM) / 1048576, $mem / 1048576)
        ]);
    }
}
