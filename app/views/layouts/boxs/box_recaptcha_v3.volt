<script id="{{target}}-recaptcha-script" src="https://www.google.com/recaptcha/api.js?render={{datosAdmon.google.recaptcha_v3_web_key}}" async defer></script>
<script>
    var recaptcha_is_verified = false;

    function recaptcha_check(form, event = null) {
        if (!recaptcha_is_verified) {
            if (event && event.type == 'submit'){
                event.preventDefault();
                event.stopPropagation();
            }

            grecaptcha.ready(function() {
                grecaptcha.execute("{{datosAdmon.google.recaptcha_v3_web_key}}", {action: 'submit'}).then(function(token) {
                    recaptcha_is_verified = true;
                    if (form.find('[name="g-recaptcha-response"]').length) {
                        form.find('[name="g-recaptcha-response"]')[0].value = token
                        form.find('[name="g-recaptcha-response"]').val(token)
                    } else {
                        form.append(`<input type="hidden" name="g-recaptcha-response" value="${token}">`)
                    }
                    form.trigger('submit');
                });
            });
        } else {
            form.trigger('submit');
        }
    }
</script>
