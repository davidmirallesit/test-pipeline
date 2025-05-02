Infolot
========

## Información sobre las admon ##

- En la carpeta public existe un fichero llamado domains_list.json. En dicho fichero están en listado de administraciones junto con sus respectivos dominios y más información como los colores para el estilo de la web. 

- Este json se actualizará mediante un web service situado en la ruta -> /api/admon.

- Este web service recibirá los datos de la administración a insertar/modificar mediante POST

    - mode: la acción que se quiere hacer: add (añadir o modificar) o delete (eliminar)
    - domain: el dominio de la web de la administración
    - media_domain : el dominio donde se encuentran almacenadas las imagenes
    - local_password: la contraseña es ```#!x79`|=8&Qw.dR```
    - token: el token que se usará para las llamadas de la administración
    - password: la contraseña de la administación, encriptada
    
- Ejemplo de llamada: 

    - Ruta: ```http://webpremium.es/api/admon```
    - POST JSON: ```{"mode": "add", "domain" => "www.todoloterias.es/", "media_domain" => "media.todoloterias.es", "token" => "07e36f37-7ecd-4d75-9d51-54f31e55adf6", "local_password": "#!x79`|=8&Qw.dR", "password"  => "doDP+kS8fX3ACE15VDQqfTZpuiKKV5gKJYddaB9Ruolkvz3FyhORL+9+dzVL0b+0exdJMytY8qs="}```
    - Headers: ```Content-Type: application/json```
        
        
- INFO PARA EL DESARROLLADOR
    ```
    Los datos de la admoninstración están almacenados en public/admons/. En esta carpeta hay una carpeta por cada dominio 
    dado de alta con el método anterior. En esa carpeta verás dos archivos .ini, uno con la información enviada mediante 
    la api, y otro llamado datos_admon.ini, que se generará después de cada llamada a nuestro web service a partir. 
    
    Al llamar a nuestro web service, se llamará a la función datos-admon del web service de buscaloteria.com, de donde obtendremos l
    a información estática de la administración y se guardará en ese archivo .ini. Tanto esa información como la de los datos que 
    nos mandan por api los podrás encontrar en $this->config. En el archivo config.php podrás ver como se hace. 
    ```        
