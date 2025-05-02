
$(function () {
    /* ==========================================================================
       boton de subir inicio pagina
       ========================================================================== */
    var offset = 200;
    var duration = 500;
    $(window).scroll(function () {
        if ($(this).scrollTop() > offset) {
            //$('.back-to-top').fadeIn(400);
        } else {
            //$('.back-to-top').fadeOut(400);
        }
    });
    
    $('.back-to-top').click(function (event) {
        event.preventDefault();
        $('html, body').animate({
            scrollTop: 0
        }, 600);
        return false;
    })
    
    /* ==========================================================================
       banner inicio pagina
       ========================================================================== */
    $('.carousel').carousel({
        interval: 5000
    })
    
    /* ==========================================================================
       box_featured_ln.volt
       ========================================================================== */
    $('#mini_searcher_inputs button').on("click", event => {
        event.preventDefault()
        let tailNumber = $('#mini_searcher_inputs button').data("tail-number");
        let fullNumber = $('#mini_searcher_inputs button').data("full-number");
        let route = $('#mini_searcher_inputs button').data("to");
        let input = $('#mini_searcher_inputs input').val()
        if (input) {
            if (input.length == 5) {
                route += fullNumber + input;
            } else {
                route += tailNumber + input;
            }
        }
        location = route;
    });

    /* ==========================================================================
        plugin bootstrap minus and plus
        http://jsfiddle.net/laelitenetwork/puJ6G/
       ========================================================================== */
    $(document.body).on("click", '.btn-number', function (e) {
        e.preventDefault();
    
        let fieldName = $(this).attr('data-field');
        let type = $(this).attr('data-type');
        var input = $("input[name='" + fieldName + "']");
        var currentVal = parseInt(input.val());

        if (!isNaN(currentVal)) {
            if (type == 'minus') {
                if (currentVal > input.attr('min')) {
                    input.val(currentVal - 1).change();
                }
                if (parseInt(input.val()) == input.attr('min')) {
                    $(this).attr('disabled', true);
                }

                /* Francis: Solucionamos BUG que solo miraba el botón pulsado,
                  pero no si debía cambiar el estado del otro */
                let other_btn = $(input).parent().find('[data-type="plus"]');
                if (other_btn && parseInt(input.val()) < input.attr('max')) {
                    $(other_btn).attr('disabled', false);
                }
    
            } else if (type == 'plus') {
    
                if (currentVal < input.attr('max')) {
                    input.val(currentVal + 1).change();
                    $(input).trigger("change");
                }
                if (parseInt(input.val()) == input.attr('max')) {
                    $(this).attr('disabled', true);
                }

                /* Francis: Solucionamos BUG que solo miraba el botón pulsado,
                  pero no si debía cambiar el estado del otro */
                let other_btn = $(input).parent().find('[data-type="minus"]');
                if (other_btn && parseInt(input.val()) > input.attr('min')) {
                    $(other_btn).attr('disabled', false);
                }
            }
        } else {
            input.val(0);
        }
    });

    $('.tabs-login-register-big').ready(function() {
        if ($('.tabs-login-register-big').first().hasClass('active')) {
            $('.tabs-login-register-big').last().removeClass('bg-azul').addClass('bg-alternative-border').css("border", "1px solid").children().addClass('text-alternative').removeClass('text_color_ws');
        }

    });

    $('.tabs-login-register-big').click(function(event) {
        var nodeName = event.target.nodeName;
        var elementId = '';
        if (nodeName == 'LI') {
            elementId = event.target.id;
        } else if (nodeName == 'A') {
            elementId = event.target.parentElement.id;
        }
        if (!$('#' + elementId).first().hasClass('active')) {
            $('#' + elementId).first().addClass('bg-azul').removeClass('bg-alternative-border active').css("border", "0px").children().addClass('text_color_ws_modals').removeClass('text-alternative');
            if (nodeName == 'LI') {
                $('#' + elementId).first().children().click();
            }
            $('#' + elementId).siblings().removeClass('bg-azul active').addClass('bg-alternative-border').css("border", "1px solid").children().addClass('text-alternative').removeClass('text_color_ws_modals');
        }
    });

    $('.tabs-login-register-small').ready(function() {
        if ($('.tabs-login-register-small').first().hasClass('active')) {
            $('.tabs-login-register-small').last().removeClass('bg-azul').addClass('bg-alternative-border').css("border", "1px solid").children().addClass('text-alternative').removeClass('text_color_ws');
        }
    });

    $('.tabs-login-register-small').click(function(event) {
        var nodeName = event.target.nodeName;
        var elementId = '';
        if (nodeName == 'LI') {
            elementId = event.target.id;
        } else if (nodeName == 'A') {
            elementId = event.target.parentElement.id;
        }
        if (!$('#' + elementId).first().hasClass('active')) {
            $('#' + elementId).first().addClass('bg-azul active').removeClass('bg-alternative-border').css("border", "0px").children().addClass('text_color_ws_modals').removeClass('text-alternative');
            if (nodeName == 'LI') {
                $('#' + elementId).first().children().click();
            }
            $('#' + elementId).siblings().removeClass('bg-azul active').addClass('bg-alternative-border').css("border", "1px solid").children().addClass('text-alternative').removeClass('text_color_ws_modals');
        }
    });

    $('#pass_login, #email_login').keyup(function() {
        checkFormLogin();
    });

    $('#pass_small_login, #email_small_login').keyup(function() {
        checkFormSmallLogin();
    });

    $('#pass_register, #pass2_register ,#email_register').keyup(function() {
        checkFormRegister();
    });

    $("#registro_checkEdad, #registro_checkTerms, #registro_checkConditions").click(function() {
        checkFormRegister();
    });

    $('#pass_small_register, #pass2_small_register ,#email_small_register').keyup(function() {
        checkFormSmallRegister();
    });

    $("#registro_small_checkEdad, #registro_small_checkTerms, #registro_small_checkConditions").click(function() {
        checkFormSmallRegister();
    });

    function loginRegister(event) {
        event.preventDefault()
        let elementId = $(event.target).attr('id')
        let spinnerId = '[id*=spinner_procesando]'
        let action = $(this).attr('action');
        let params = {
            'uuid': config_baseconfig_uuid,
            'email': $(this).find('[name="email"]').val(),
            'pass': $(this).find('[name="pass"]').val()
        };

        switch (true) {
            case elementId.includes('login'):
                spinnerId = '#spinner_procesando'
                break;
            case elementId.includes('register'):
                spinnerId = '#spinner_procesando2'
                params.pass_confirm = $(this).find('[name="pass_confirm"]').val()
                break;
        }

        // muestra el spinner
        $(spinnerId).removeClass('carrito_span_procesando')

        $.ajax({
            type: 'POST',
            crossDomain: true,
            dataType: 'json',
            headers: {
                'Accept': 'application/json; charset=utf-8',
                'Origin': window.location.origin
            },
            xhrFields: {
                withCredentials: true
            },
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify(params),
            url: action,
            success: function(userdata) {
                if (userdata.error) {
                    customAlert(userdata.error);
                    $(spinnerId).addClass('carrito_span_procesando')
                } else {
                    $.ajax({
                        type: "POST",
                        url: "/setSessionUser",
                        data: userdata,
                        success: function(resData) {
                            location.reload();
                            $(spinnerId).addClass('carrito_span_procesando')
                        },
                        error: function(e) {
                            customAlert("Error");
                            $(spinnerId).addClass('carrito_span_procesando')
                        }
                    });
                }
            }
        });

    }

    $('#frm-loginRoof').on('submit', loginRegister)
    $('#frm-registerRoof').on('submit', loginRegister)
    $('#frm-loginRoofSmall').on('submit', loginRegister)
    $('#frm-registerRoofSmall').on('submit', loginRegister)
})

function customAlert(msg, callback = null) {
    // Comprobar y tratar el texto para mostrarlo como string
    if (!msg) {
        console.warn('Non empty value given to customAlert', msg)
        return
    }
    const originalMsg = msg
    switch (typeof msg) {
        case typeof []:
        case typeof {}:
            if (Array.isArray(msg)) {
                msg = msg.join(',')
            } else {
                msg = JSON.stringify(msg, null, 2)
                if (msg.replace('{', '').replace('}', '') == '') {
                    msg = ''
                } else {
                    msg = '<pre>'+msg+'</pre>'
                }
            }
            break;
        default:
            msg = String(msg)
            break;
    }
    if (msg.trim() == '') {
        console.warn('Empty value given to customAlert', originalMsg)
        return
    }

    let box = document.createElement('div')
    const buttonText = 'Aceptar'
    // si ya hay un alert en pantalla no se oscurece el fondo
    if (!document.querySelector('.custom-alert-background')) {
        box.classList.add("custom-alert-background")
    }

    if (callback) {
        if (typeof callback !== 'function') {
            callback = null
        } else if (callback.toString().includes('"')) {
            callback = callback.toString().replaceAll('"', '&quot;')
        }
    }

    box.innerHTML = `
        <div class="custom-alert-textbox" role="alertdialog" aria-describedby="alertText">
            <p id="alertText" class="custom-alert-text">${msg}</p>
            <hr>
            <button onclick="dismissCustomAlert(this, ${callback})" data-has_callback="${(callback) ? 1 : 0}" class="btn btn-primary custom-alert-button">${buttonText}</button>
        </div>
    `
    document.body.append(box)
    $('.custom-alert-button').last().focus()
}

function dismissCustomAlert(element = null, callback = null) {
    // si no se llama desde el boton se borran todos
    if (!Boolean(element)) {
        Array.from(document.querySelectorAll('.custom-alert-button')).forEach(e => {
            if (Number(e.dataset['has_callback'])) {
                e.click()
            } else {
                e.parentElement.remove()
            }
        })
    } else {
        if (element.parentElement.classList.contains('custom-alert-textbox')) {
            element.parentElement.parentElement.remove()
            // si despues de borrarlo quedan mas alerts sin el background se le pone uno al primero
            if (!document.querySelector('.custom-alert-background') && Boolean(document.querySelector('.custom-alert-textbox'))) {
                document.querySelector('.custom-alert-textbox').parentElement.classList.add("custom-alert-background")
            }
        } else {
            // si el elemento que se ha pasado no corresponde a un alert se borran todos
            Array.from(document.querySelectorAll('.custom-alert-button')).forEach(e => {
                if (Number(e.dataset['has_callback'])) {
                    e.click()
                } else {
                    e.parentElement.remove()
                }
            })    
        }
    }

    if (callback !== null) {
        if (typeof callback === 'function') {
            callback()
        } else {
            console.error('Non callable function given to dismissCustomAlert', callback)
        }
    }
}

function showRemaining(endTime, domId, countSeconds = false, timerId = null, start = false) {
    if (start) {
        if (document.getElementById(domId)) {
            if (!endTime.getTime) {
                endTime = new Date(endTime)
            }
            if (endTime.getTime()) {
                timerId = setInterval(() => {
                    showRemaining(endTime, domId, countSeconds, timerId)
                }, 1000);    
            }
        }
    } else {
        let now = new Date()
        let timeLeft = endTime - now
        if (timeLeft < 0 || (!countSeconds && (Math.floor(endTime / 1000) - Math.floor(now / 1000 )) < 60)) {
            // ya ha pasado la fecha
            document.getElementById(domId).innerHTML = '';
            clearInterval(timerId);
        } else {
            // timeLeft está en milisegundos por lo que 1000 es 1 segundo
            let second  = 1000;
            let minute  = second * 60;
            let hour    = minute * 60;
            let day     = hour * 24;

            let daysLeft    = Math.floor(timeLeft / day);
            let hoursLeft   = Math.floor((timeLeft % day) / hour);
            let minutesLeft = Math.floor((timeLeft % hour) / minute);

            document.getElementById(domId).innerHTML = `${daysLeft}D ${hoursLeft}H ${minutesLeft}M`;

            if (countSeconds) {
                let secondsLeft = Math.floor((timeLeft % minute) / second);
                document.getElementById(domId).innerHTML += ` ${secondsLeft}S`;
            }
        }
    }
}

function factorial(n) {
    if (!n || n < 0) {
        return 1;
    }

    if (n == 0) {
        return 1;
    }
    
    return n * factorial(n - 1);
}

function ucfirst(string) {
    if (typeof string !== "string") {
        string = string.toString()
    }

    if (string === "") {
        return ""
    }

    return (string.charAt(0).toLocaleUpperCase() + string.slice(1))
}

Date.prototype.getWeek = function () {
    var target  = new Date(this.valueOf());
    var dayNr   = (this.getDay() + 6) % 7;
    target.setDate(target.getDate() - dayNr + 3);
    var firstThursday = target.valueOf();
    target.setMonth(0, 1);
    if (target.getDay() != 4) {
        target.setMonth(0, 1 + ((4 - target.getDay()) + 7) % 7);
    }
    return 1 + Math.ceil((firstThursday - target) / 604800000);
}

function zerofill(string, length) {
    if (typeof string !== "string") {
        string = string.toString()
    }

    if ((length - string.length) <= 0) {
        return string
    }
    
    return ("0".repeat(length - string.length) + string)
}

function arraysEqual(a1, a2) {
    return JSON.stringify(a1) == JSON.stringify(a2)
}

function dateToYMD(date) {
    let day = date.getDate()
    let month = date.getMonth() + 1 //Month from 0 to 11
    let year = date.getFullYear()
    return `${year}-${zerofill(month, 2)}-${zerofill(day, 2)}`
}

function randomPick(array) {
    if (!Array.isArray(array)) {
        return
    }
    return array[Math.floor(Math.random() * array.length)]
}

function factorial(n) {
    if (n > 2) {
        return n * factorial(n - 1)
    }

    return n
}

function empty(element) {
    let result = true
    switch (typeof element) {
        case "object":
            if (Array.isArray(element)) {
                if (element.length) {
                    result = false
                } else {
                    if (Boolean(element.toString())) {
                        result = false
                    } else {
                        // arrays asociativos element["a"] = 1
                        let hasNoKeys = true
                        for (const i in element) {
                            hasNoKeys = false
                            break
                        }
                        result = hasNoKeys
                    }
                }
            } else {
                result = !Boolean(JSON.stringify(element).replace(/^\{/, '').replace(/\}$/, ''))
            }
            break
        case "boolean":
            result = false
            break
        case "function":
            element = element.toString()
                .replace(/function\s?\(.*\)\s?/, '')
                .replaceAll('\n', '')
                .replaceAll(' ', '')
                .replace(/^\{/, '')
                .replace(/\}$/, '')
            result = !Boolean(element)
            break
        case "number":
            result = false
            break
        case "undefined":
            result = true
            break
        case "string":
        default:
            result = !Boolean(element)
    }
    return result
}

function formatNumber(number, decimals = false, currency = false) {
    if (number === '') {
        return
    }

    let options = {}
    let isLeft = false
    let locale = navigator.userLanguage || navigator.language || 'es-ES'
    if (decimals) {
        if (typeof decimals == 'number') {
            decimals = Math.floor(decimals)
            if (decimals < 0) {
                decimals = 0
            }
            if (decimals > 20) {
                decimals = 20
            }
        } else {
            decimals = 2
        }

        options.minimumFractionDigits = decimals
        options.maximumFractionDigits = decimals
    }

    if (currency) {
        options.style = 'currency'
        options.currency = 'EUR'
        if (Object(currency) === currency) {
            if (typeof currency.currency === 'string') {
                if (currency.currency.match(/[A-Z]{3}/)) {
                    options.currency = currency.currency
                }
            }
            if (currency.isLeft) {
                isLeft = true
            }
        }
    }

    let result = new Intl.NumberFormat(locale, options).format(number)
    if (result.toString().split(',')[0].length > 3 && !result.toString().split(',')[0].includes(".") && locale == 'es-ES') {
        result = new Intl.NumberFormat('de-DE', options).format(number)
        if (!result.toString().includes(".")) {
            let decimals
            result = result.toString()
            if (result.includes(",")) {
                decimals = result.split(',')[1]
                result = result.split(',')[0]
            }
            let splitNumber = result.split('').reverse()
            let splitReusult = []
            for (let i = 0; i < splitNumber.length; i++) {
                if (i % 3 == 0 && i != 0) {
                    splitReusult.push('.')
                }
                splitReusult.push(splitNumber[i])
            }
            result = decimals ? splitReusult.reverse().join("") + ',' + decimals : splitReusult.reverse().join("")
        }
    }
    if (isLeft) {
        // String.fromCharCode(160) es el separador que usa Intl.numberformat
        let splitCurrency = result.split(String.fromCharCode(160))
        if (splitCurrency[0].match(/\d/)) {
            result = splitCurrency[1] + splitCurrency[0]
        }
    }
    return result
}

function deFormatNumber(number) {
    if (number === '') {
        return
    }

    if (typeof number != 'string') {
        if (number.toString) {
            number = number.toString()
        } else {
            return
        }
    }

    number = number.replace(/[^\d\.\,]/g, '')
    
    let result
    let actualSeparators = number.replace(/\d/g, '').split('')
    if (actualSeparators.length == 1) {
        // si solo hay 1 separador puede ser decimales o millares
        let parts = number.split(actualSeparators[0])
        if (parts[1].length != 3) {
            // si detras del separador no hay 3 cifras entonces decimales ej. 201.01
            result = parseFloat(number.replace(actualSeparators[0],'.'))
        } else {
            // si hay 3 cifras puede ser millar o decimal ej. 201.101
            // se usa un numero que tendrá 2 separadores de millares y un decimal para parsear el original
            let testNumber = formatNumber(1000000.1)
            let decimalSeparator = testNumber.replace(/\d/g, '').split('').pop()
            let thouSeparator = testNumber.replace(/\d/g, '').split('')[1]
            let thouRegex = new RegExp('\\'+thouSeparator, 'g')
            result = parseFloat(number.replace(thouRegex,'').replace(decimalSeparator,'.'))
        }
    } else {
        if (actualSeparators.length == 0) {
            // si no hay separadores se pasa tal cual ej. 200
            result = parseFloat(number)
        } else if (actualSeparators.every(e => e == actualSeparators[0])) {
            // si todos los separadores son iguales entoces es millares ej. 201.000.001
            result = parseFloat(number.replaceAll(actualSeparators[0], ''))
        } else {
            // el último es el de decimales y el resto millares ej. 201,000,001.025
            let decimalSeparator = actualSeparators.pop()
            let thouSeparator = actualSeparators[0]
            let thouRegex = new RegExp('\\'+thouSeparator, 'g')
            result = parseFloat(number.replace(thouRegex,'').replace(decimalSeparator,'.'))
        }
    }

    return result
}

/**
 * Usada en loteria nacional, navidad y niño y en el modulo del home de comprar loteria
 * para calcular el total
 */
function lotteryChangedSelectedQuantity() {
    let precio = parseFloat(DRAW_PRICE_TICKET)
    let hay_cantidad = false
    let total = 0

    $(".cantidad_cupones").each((i, e) => {
        if (parseFloat($(e).val()) > 0) {
            hay_cantidad = true
            total += parseFloat($(e).val())
        }
    })

    price = precio * total

    $("#price").html(formatNumber(price, 2))

    if (hay_cantidad) {
        $("#button_anyadir_cesta").prop("disabled", false)
    } else {
        $("#button_anyadir_cesta").prop("disabled", true)
    }
}

function checkQuantityLottery(event) {
    let numbersRegex  = new RegExp(/\d/, 'g')
    let quantity      = event.target.value.toString().match(numbersRegex)
    quantity          = (quantity === null) ? NaN : quantity.join('')
    let validQuantity = isNaN(parseInt(quantity)) ? '' : parseInt(quantity)
    let max           = Number($(event.target).attr("max"))
    let minusButton   = $(event.target).parent().find('[data-type="minus"]')
    let plusButton    = $(event.target).parent().find('[data-type="plus"]')

    if (validQuantity == '') {
        validQuantity = 0
    }

    if (validQuantity > max) {
        validQuantity = max
        plusButton.attr('disabled', true);
        minusButton.removeAttr('disabled');
    } else if (validQuantity == 0) {
        minusButton.attr('disabled', true);
        plusButton.removeAttr('disabled');
    } else {
        plusButton.removeAttr('disabled');
        minusButton.removeAttr('disabled');
    }

    $(event.target).val(validQuantity).trigger("change")
}

function removeAccents(word) {
    let mappings = {
        'a': String.fromCharCode(97, 224, 225, 226, 227, 228, 229, 259),
        'A': String.fromCharCode(65, 192, 193, 194, 195, 196, 258),
        'e': String.fromCharCode(101, 232, 233, 234, 235),
        'E': String.fromCharCode(69, 200, 201, 202, 203),
        'i': String.fromCharCode(105, 236, 237, 238, 239),
        'I': String.fromCharCode(73, 204, 205, 206, 207),
        'o': String.fromCharCode(111, 242, 243, 244, 245, 246),
        'O': String.fromCharCode(79, 210, 211, 212, 213, 214),
        'u': String.fromCharCode(117, 249, 250, 251, 252),
        'U': String.fromCharCode(85, 217, 218, 219, 220),
    };

    let anyChar = {}
    Object.entries(mappings).forEach(row => {
        key = row[0]
        value = row[1]
        anyChar[key] = value.split('').join('|')
    })

    let a = new RegExp(anyChar.a)
    let e = new RegExp(anyChar.e)
    let i = new RegExp(anyChar.i)
    let o = new RegExp(anyChar.o)
    let u = new RegExp(anyChar.u)
    let A = new RegExp(anyChar.A)
    let E = new RegExp(anyChar.E)
    let I = new RegExp(anyChar.I)
    let O = new RegExp(anyChar.O)
    let U = new RegExp(anyChar.U)

    return word.replace(a, 'a')
                .replace(e, 'e')
                .replace(i, 'i')
                .replace(o, 'o')
                .replace(u, 'u')
                .replace(A, 'A')
                .replace(E, 'E')
                .replace(I, 'I')
                .replace(O, 'O')
                .replace(U, 'U')
}

function getParentElementFromIcon(node) {
    if (window.jQuery) {
        node = $(node)
        if (node[0].nodeName === 'I') {
            return node[0].parentElement
        } else {
            return node[0]
        }
    } else {
        if (node.nodeName === 'I') {
            return node.parentElement
        } else {
            return node
        }
    }
}

function inputNumber (event, defaultReturn = '') {
    let numbersRegex  = new RegExp(/\d/, 'g')
    let number        = event.target.value.toString().match(numbersRegex)
    number            = (number === null) ? defaultReturn : number.join('')

    $(event.target).val(number).trigger("change");
}

var errorCaptchaLogin = false;
var errorCaptchaRegister = false;
var errorCaptchaSmallLogin = false;
var errorCaptchaSmallRegister = false;

function recaptchaErrorCallback() {
    errorCaptchaLogin = true;
    $('#captcha_login').remove();

    errorCaptchaRegister = true;
    $('#captcha_register').remove();

    checkFormLogin();
    checkFormRegister();
}

function recaptchaSmallErrorCallback() {
    errorCaptchaSmallLogin = true;
    $('#captcha_small_login').remove();

    errorCaptchaSmallRegister = true;
    $('#captcha_small_register').remove();

    checkFormSmallLogin();
    checkFormSmallRegister();
}

var captchaLogin = false;

function recaptchaCallbackLogin() {
    captchaLogin = true;
    checkFormLogin();
};

function checkFormLogin() {
    if (errorCaptchaLogin === true) {
        /* En el caso de que el captcha de error lo validaremos como si fuese correcto*/
        captchaLogin = true;
    }

    if ($('#pass_login').val() !== "" && $('#email_login').val() !== "" && captchaLogin === true) {
        $('#btn-login').prop('disabled', false);
    } else {
        $('#btn-login').prop('disabled', true);
    }
}

var captchaSmallLogin = false;

function recaptchaCallbackSmallLogin() {
    captchaSmallLogin = true;
    checkFormSmallLogin();
};

function checkFormSmallLogin() {
    if (errorCaptchaSmallLogin === true) {
        captchaSmallLogin = true;
    }
    if ($('#pass_small_login').val() !== "" && $('#email_small_login').val() !== "" && captchaSmallLogin === true) {
        $('#btn-small-login').prop('disabled', false);
    } else {
        $('#btn-small-login').prop('disabled', true);
    }
}

var captchaRegister = false;

function recaptchaCallbackRegister() {
    captchaRegister = true;
    checkFormRegister();
};

function checkFormRegister() {
    if (errorCaptchaRegister === true) {
        captchaRegister = true;
    }

    if ($('#pass_register').val() !== "" && $('#pass2_register').val() !== "" && $('#email_register').val() !== "" &&
        captchaRegister === true && $('#registro_checkEdad').is(':checked') && $('#registro_checkTerms').is(':checked') &&
        $('#registro_checkConditions').is(':checked')) {
        $('#btn-register').prop('disabled', false);
    } else {
        $('#btn-register').prop('disabled', true);
    }
}

var captchaSmallRegister = false;

function recaptchaCallbackSmallRegister() {
    captchaSmallRegister = true;
    checkFormSmallRegister();
};

function checkFormSmallRegister() {
    if (errorCaptchaSmallRegister === true) {
        captchaSmallRegister = true;
    }

    if ($('#pass_small_register').val() !== "" && $('#pass2_small_register').val() !== "" && $('#email_small_register').val() !== "" &&
        captchaSmallRegister === true && $('#registro_small_checkEdad').is(':checked') && $('#registro_small_checkTerms').is(':checked') &&
        $('#registro_small_checkConditions').is(':checked')) {
        $('#btn-small-register').prop('disabled', false);
    } else {
        $('#btn-small-register').prop('disabled', true);
    }
}

function onReady(yourMethod) {
  if (document.readyState === 'complete') { // Or also compare to 'interactive'
    setTimeout(yourMethod, 1); // Schedule to run immediately
  }
  else {
    readyStateCheckInterval = setInterval(function() {
      if (document.readyState === 'complete') { // Or also compare to 'interactive'
        clearInterval(readyStateCheckInterval);
        yourMethod();
      }
    }, 10);
  }
}
