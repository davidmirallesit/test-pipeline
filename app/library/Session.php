<?php

namespace Infolot;

use \Phalcon\Db;
use \Phalcon\Session\Adapter;
use \Phalcon\Session\AdapterInterface;
use \Phalcon\Session\Exception;
use \Phalcon\Db\Adapter\Pdo\Mysql as DbAdapter;
use \Phalcon\Db\Column;
use \Phalcon\Http\Request;

/**
 * Clase personalizada para la gestión de la sesión por
 * base de datos, en lugar de por archivos, para mejorar
 * la eficiencia y la seguridad
 */
class Session extends Adapter implements AdapterInterface
{
    /**
     * @var DbAdapter
     */
    protected $id_web;
    protected $connection;
    protected $maxlifetime;
    protected $options;

    /**
     * {@inheritdoc}
     *
     * @param  array $options
     * @throws Exception
     */
    public function __construct($options = null)
    {
        if (!isset($options['db']) || !$options['db'] instanceof DbAdapter) {
            throw new Exception(
                'Parameter "db" is required and it must be an instance of Phalcon\Db\AdapterInterface'
            );
        }

        $this->id_web = $options['id_web'];
        unset($options['id_web']);

        $this->connection = $options['db'];
        unset($options['db']);


        if (!isset($options['table']) || empty($options['table']) || !is_string($options['table'])) {
            throw new Exception("Parameter 'table' is required and it must be a non empty string");
        }

        $this->maxlifetime = isset($options['maxlifetime']) ? $options['maxlifetime'] : (int)ini_get('session.gc_maxlifetime');
        unset($options['maxlifetime']);

        $columns = ['session_id', 'id_user', 'id_web', 'date_created', 'date_updated', 'ip', 'user_agent', 'session_data', 'session_expire'];
        foreach ($columns as $column) {
            $oColumn = "column_$column";
            if (!isset($options[$oColumn]) || !is_string($options[$oColumn]) || empty($options[$oColumn])) {
                $options[$oColumn] = $column;
            }
        }

        $this->options = $options;

        //parent::__construct($options);
        session_set_save_handler(
            [$this, 'open'],
            [$this, 'close'],
            [$this, 'read'],
            [$this, 'write'],
            [$this, 'destroy'],
            [$this, 'gc']
        );
    }

    /**
     * {@inheritdoc}
     *
     * @return boolean
     */
    public function open()
    {
        $this->_started = true;
        return $this->isStarted();
    }

    /**
     * {@inheritdoc}
     *
     * @return boolean
     */
    public function close()
    {
        $this->_started = false;
        return $this->isStarted();
    }

    /**
     * {@inheritdoc}
     *
     * @return boolean
     */
    public function isStarted(): bool
    {
        return $this->_started;
    }

    /**
     * {@inheritdoc}
     *
     * @return array
     */
    public function getOptions(): array
    {
        return $this->options;
    }

    /**
     * {@inheritdoc}
     *
     * @param  string $sessionId
     * @return string
     */
    public function read($sessionId)
    {
        if (!$this->isStarted()) {
            return false;
        }

        $options = $this->getOptions();
        $row     = $this->connection->fetchOne(
            sprintf(
                'SELECT %s FROM %s WHERE %s = ? AND %s >= ?',
                $this->connection->escapeIdentifier($options['column_session_data']),
                $this->connection->escapeIdentifier($options['table']),
                $this->connection->escapeIdentifier($options['column_session_id']),
                $this->connection->escapeIdentifier($options['column_session_expire'])
            ),
            Db::FETCH_NUM,
            [$sessionId, time()],
            [Column::BIND_PARAM_STR, Column::BIND_PARAM_INT]
        );
        if (empty($row)) {
            $this->gc();

            return '';
        }
        return $row[0];
    }

    /**
     * {@inheritdoc}
     *
     * @param  string $sessionId
     * @param  string $data
     * @return boolean
     */
    public function write($sessionId, $data)
    {
        $options = $this->getOptions();
        $row = $this->connection->fetchOne(
            sprintf(
                'SELECT COUNT(*) FROM %s WHERE %s = ?',
                $this->connection->escapeIdentifier($options['table']),
                $this->connection->escapeIdentifier($options['column_session_id'])
            ),
            Db::FETCH_NUM,
            [$sessionId]
        );

        if ($row[0] > 0) {
            return $this->connection->execute(
                sprintf(
                    'UPDATE %s SET %s = ?, %s = ?, %s = ? WHERE %s = ?',
                    $this->connection->escapeIdentifier($options['table']),
                    $this->connection->escapeIdentifier($options['column_session_data']),
                    $this->connection->escapeIdentifier($options['column_id_user']),
                    $this->connection->escapeIdentifier($options['column_date_updated']),
                    $this->connection->escapeIdentifier($options['column_session_id'])
                ),
                [$data, isset($_SESSION['user']) ? (int)$_SESSION['user']['id'] : null, date('Y-m-d H:i:s'), $sessionId]
            );
        }

        if (!$this->isStarted()) {
            return false;
        }

        return $this->connection->execute(
            sprintf(
                'INSERT INTO %s (%s, %s, %s, %s, %s, %s, %s, %s, %s) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                $this->connection->escapeIdentifier($options['table']),
                $this->connection->escapeIdentifier($options['column_session_id']),
                $this->connection->escapeIdentifier($options['column_id_user']),
                $this->connection->escapeIdentifier($options['column_id_web']),
                $this->connection->escapeIdentifier($options['column_date_created']),
                $this->connection->escapeIdentifier($options['column_date_updated']),
                $this->connection->escapeIdentifier($options['column_ip']),
                $this->connection->escapeIdentifier($options['column_user_agent']),
                $this->connection->escapeIdentifier($options['column_session_data']),
                $this->connection->escapeIdentifier($options['column_session_expire'])
            ),
            [$sessionId, isset($_SESSION['user']) ? (int)$_SESSION['user']['id'] : null,  !@empty($this->id_web) ? $this->id_web : null, date('Y-m-d H:i:s'), null, self::getIp(), self::getUserAgent(), $data, time() + $this->maxlifetime]
        );
    }

    /**
     * {@inheritdoc}
     *
     * @return boolean
     */
    public function destroy($session_id = null)
    {
        if (!$this->isStarted()) {
            return true;
        }
        if (is_null($session_id)) {
            $session_id = $this->getId();
        }
        $this->_started = false;
        $options = $this->getOptions();

        /*if (isset($_SESSION['user']) && $id_user = (int)$_SESSION['user']['id']) {
            $result  = $this->connection->execute(
                sprintf(
                    'DELETE FROM %s WHERE %s = ?',
                    $this->connection->escapeIdentifier($options['table']),
                    $this->connection->escapeIdentifier($options['column_id_user'])
                ),
                [$id_user]
            );
        } else {*/
            $result  = $this->connection->execute(
                sprintf(
                    'DELETE FROM %s WHERE %s = ?',
                    $this->connection->escapeIdentifier($options['table']),
                    $this->connection->escapeIdentifier($options['column_session_id'])
                ),
                [$session_id]
            );
        //}

        return $result;
    }

    /**
     * {@inheritdoc}
     * @param  integer $maxlifetime
     *
     * @return boolean
     */
    public function gc($maxlifetime = null)
    {
        return true;
        /*
        $options = $this->getOptions();
        return $this->connection->execute(
            sprintf(
                'DELETE FROM %s WHERE %s < ?',
                $this->connection->escapeIdentifier($options['table']),
                $this->connection->escapeIdentifier($options['column_session_expire'])
            ),
            [time()]
        );
        */
    }

    /**
     *  Devuelve la IP teniendo en cuenta si se esta detras de un Proxy, etc.
     *
     *  @access public
     *  @return string      Devuelve la IP
     */
    public static function getIp()
    {
        //get useful vars:
        $client_ip       = @$_SERVER['HTTP_CLIENT_IP'];
        $x_forwarded_for = @$_SERVER['HTTP_X_FORWARDED_FOR'];
        $remote_addr     = @$_SERVER['REMOTE_ADDR'];

        // then the script itself
        if (!empty($client_ip)) {
            $ip_expl = explode('.', $client_ip);
            $referer = explode('.', $remote_addr);
            if ($referer[0] != $ip_expl[0]) {
                // $ip=array_reverse($ip_expl);
                $ip = $ip_expl;
                return implode('.', $ip);
            }
            return $client_ip;
        } elseif (!empty($x_forwarded_for) && !preg_match('#^192\.168\.0\.#i', $x_forwarded_for)) {
            if (strstr($x_forwarded_for, ',')) {
                $ip_expl = explode(',', $x_forwarded_for);
                return end($ip_expl);
            }
            return $x_forwarded_for;
        }
        return $remote_addr;
    }

    /**
     *  Devuelve el UserAgent del usuario
     *
     *  @access public
     *  @return string      Devuelve el user agent
     */
    public static function getUserAgent()
    {
        $request = new Request();

        return $request->getUserAgent();
        //return $_SERVER['HTTP_USER_AGENT'];
    }
}
