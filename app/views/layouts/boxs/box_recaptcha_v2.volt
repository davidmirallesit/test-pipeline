<script id="{{target}}-recaptcha-script" src="https://www.google.com/recaptcha/api.js?render=explicit" async defer></script>
<script>
    var recaptcha_is_verified = false;

    var {{target}}RecaptchaScript = document.querySelector('#{{target}}-recaptcha-script');
    {{target}}RecaptchaScript.addEventListener('load', function () {
        grecaptcha.ready(loadCaptcha)
    });

    function loadCaptcha() {
        let recaptcha_container = document.querySelector('.{{target}}-recaptcha_container');
    
        if (recaptcha_container) {
            if (recaptcha_container.innerHTML.length) {
                grecaptcha.reset();
            } else {
                grecaptcha.render(recaptcha_container, {
                    'sitekey': "{{ datosAdmon.google.recaptcha_web_key }}"
                });
            }
        }
    }

    function recaptcha_check(form, event = null) {
        let response = grecaptcha.getResponse()
        if (event && event.type == 'submit'){
            event.preventDefault();
            event.stopPropagation();
        }
        if (response) {
            recaptcha_is_verified = true;
            if (form.find('[name="g-recaptcha-response"]').length) {
                form.find('[name="g-recaptcha-response"]')[0].value = response
                form.find('[name="g-recaptcha-response"]').val(response)
            } else {
                form.append(`<input type="hidden" name="g-recaptcha-response" value="${response}">`)
            }
            form.submit()
        } else {
            if (recaptcha_is_verified) {
                recaptcha_is_verified = false
                grecaptcha.reset()
            }
            customAlert("Complete el reCAPTCHA")
        }
    }
</script>
