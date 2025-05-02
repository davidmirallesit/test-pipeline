<script type="text/javascript" src="{{config.baseconfig.url_panel}}/xdm/easyXDM.min.js"></script>
<script type="text/javascript">
    let a_login = document.createElement('a');
    a_login.setAttribute('href', '{{config.baseconfig.url_panel}}/login');

    let a_logout = document.createElement('a');
    a_logout.setAttribute('href', '{{config.baseconfig.url_panel}}/logout');

    var is_guest = {% if session.has('user') %}false{% else %}true{% endif %};
    var transport = new easyXDM.Socket( /** The configuration */ {
        remote: "{{config.baseconfig.url_panel}}/xdm/iframe-intermediate.html?url={{urlencode('/extranet/is_logged')}}",
        swf: '{{config.baseconfig.url_panel}}/xdm/easyxdm.swf',
        onMessage: function(message, origin) {
            if (message)  {
                var msg = JSON.parse(message);

                if (is_guest) {
                    if (msg.data) {
                        a_login.click();
                    }
                } else {
                    if (!msg.data) {
                        a_logout.click();
                    }
                }
            }
        }
    });
</script>
