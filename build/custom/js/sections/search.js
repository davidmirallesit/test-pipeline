let ORIGINAL_CART_ITEMS
let ORIGINAL_CART_NUMBERS
$(window).on('load', () => {
    ORIGINAL_CART_ITEMS = Number($('a[href="/carrito"]').first().find('span').text().match(/\d+/)[0])
    ORIGINAL_CART_NUMBERS = $('#numbers_in_cart').length ? $('#numbers_in_cart').val().split(',') : []
    $("#sumar").on("click", event => addQuantity(1, event))
    $("#restar").on("click", event => addQuantity(-1, event))

    $("[id^=sumar-]").on("click", event => addQuantity(1, event))
    $("[id^=restar-]").on("click", event => addQuantity(-1, event))
    // $("[id^=button_add_cart-]").on("click", addToCart)
    $("#button_add_cart").on("click", addToCart)
    $("#quantity").on("input", checkNumber)
    $("[id^=quantity-]").on("input", checkNumber)

    $("#quantity").on("addtocartevent", addToCart)
    $("[id^=quantity-]").on("addtocartevent", addToCart)

    $("#search-form").on("submit", searchNumber)
    $("#numero").on("input", checkNumber)

    $('input[data-number]').filter((i, e) => e.value > 0).each((i, element) => {
        $('#restar-' + element.dataset.number).removeAttr("disabled")
    });
});

function searchNumber() {
    let number = $('#numero').val().toString()
    if (number.length == 5) {
        $("#search-form").attr("action", DRAW_URL + SEARCHER_URL + SEARCH_URLS.fullNumber + number)
    } else if (number.length < 5) {
        $("#search-form").attr("action", DRAW_URL + SEARCHER_URL + SEARCH_URLS.tailNumber + number)
    }
}

function addQuantity(amount, event) {
    event.preventDefault()
    event.stopPropagation()
    event.stopImmediatePropagation()
    let number          = getParentElementFromIcon(event.target).dataset.number
    let quantityId      = (number) ? '#quantity-' + number : '#quantity'
    let btnAddCartId    = '#button_add_cart'
    let sumarId         = (number) ? '#sumar-' + number : '#sumar'
    let restarId        = (number) ? '#restar-' + number : '#restar'
    let originalValue   = $(quantityId).val()
    let result          = Number(originalValue) + Number(amount)
    let max             = Number($(quantityId).attr("max"))

    if (result <= 0) {
        $(restarId).attr("disabled", "disabled")
    } else {
        $(restarId).removeAttr("disabled")
    }

    if (result >= max) {
        $(sumarId).attr("disabled", "disabled")
    } else {
        $(sumarId).removeAttr("disabled")
    }

    $(quantityId).val(result).trigger("change")
    if ($(btnAddCartId).length) {
        if (result > 0) {
            $(btnAddCartId).removeAttr("disabled")
        } else {
            $(btnAddCartId).attr("disabled", "disabled")
        }
    } else {
        $(quantityId).val(result).trigger("addtocartevent")
    }
}

function checkNumber(event) {
    event.preventDefault()
    event.stopPropagation()
    event.stopImmediatePropagation()
    let otherNumber   = getParentElementFromIcon(event.target).dataset.number
    let numbersRegex  = new RegExp(/\d/, 'g')
    let quantity      = event.target.value.toString().match(numbersRegex)
    quantity          = (quantity === null) ? NaN : quantity.join('')
    let validQuantity = isNaN(parseInt(quantity)) ? '' : parseInt(quantity)
    let quantityId    = (otherNumber) ? "#quantity-" + otherNumber : "#quantity"
    let sumarId       = (otherNumber) ? "#sumar-" + otherNumber : "#sumar"
    let restarId      = (otherNumber) ? "#restar-" + otherNumber : "#restar"
    let btnAddCartId  = '#button_add_cart'
    let max           = Number($(quantityId).attr("max"))

    if (validQuantity == '') {
        validQuantity = 0
    }

    if (validQuantity > max) {
        validQuantity = max
        $(sumarId).attr("disabled", "disabled")
    } else {
        $(sumarId).removeAttr("disabled")
    }

    if (validQuantity == 0) {
        $(restarId).attr("disabled", "disabled")
        $(btnAddCartId).attr("disabled", "disabled")
    } else {
        $(restarId).removeAttr("disabled")
        $(btnAddCartId).removeAttr("disabled")
    }

    $(quantityId).val(validQuantity).trigger("change")
    if (!$(btnAddCartId).length) {
        $(quantityId).val(validQuantity).trigger("addtocartevent");
    }
}

function addToCart(event) {
    event.preventDefault()
    event.stopPropagation()
    event.stopImmediatePropagation()
    let otherNumber   = getParentElementFromIcon(event.target).dataset.number
    let quantityId    = (otherNumber) ? "#quantity-" + otherNumber : "#quantity"
    let quantity = $(quantityId).val();
    let number = (otherNumber) ? otherNumber : $('#number').val();
    let tickets = {};
    let newItemsCart = ORIGINAL_CART_ITEMS
    tickets[number] = quantity

    var objetoCarrito = {
        "date_draw_ini": DATE_DRAW_INI,
        "price_ticket": PRICE_TICKET,
        "id_draw": ID_DRAW,
        "tickets": tickets
    };

    // numeros que no son de este sorteo/juego
    let fixedNumbers = ORIGINAL_CART_ITEMS - ORIGINAL_CART_NUMBERS.length

    // numeros de estes sorteo contando los que se hayan quitado
    let prevNumbers = ORIGINAL_CART_NUMBERS.length - $('input[data-number]').filter((i,e) => e.value == 0 && ORIGINAL_CART_NUMBERS.includes(e.dataset.number)).length

    // numeros añadidos nuevos
    let newNumbers = $('input[data-number]').filter((i,e) => e.value > 0 && !ORIGINAL_CART_NUMBERS.includes(e.dataset.number)).length


    if (otherNumber) {
        objetoCarrito.replace_quantity = true
        newItemsCart = fixedNumbers + prevNumbers + newNumbers
    }

    $.ajax({
        type: "POST",
        url: "/guardarCarritoLoteriaNacional",
        data: objetoCarrito,

        success: function(data) {
            if (otherNumber) {
                $('a[href="/carrito"]').each((i, e) => {
                    if ($(e).find("span").length) {
                        let itemsCart = Number($(e).text().match(/\d+/)[0])
                        $(e).find("span").html($(e).find("span").html().replace(itemsCart, newItemsCart))
                    } else {
                        let itemsCart = Number($(e).text().match(/\d+/)[0])
                        $(e).html($(e).html().replace(itemsCart, newItemsCart))
                    }
                })
                // $(quantityId).attr("max", ($(quantityId).attr("max") - quantity))
                // addQuantity((quantity * -1), {target: $(quantityId)[0]})
            } else {
                $('#continueBuyingModal').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }
        },
        error: function(e) {
            customAlert("Error al guardar comprar la loteria");
        }
    });
}