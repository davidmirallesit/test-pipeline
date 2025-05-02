function setPeninsula(value) {
    peninsula = value;
    updateTotal();
    checkComplete();
}

function updateTotal() {
    shippable_price = 0.0;
    not_shippable_price = 0.0;
    if (peninsula) {
        ship_shippable = $('.radio-shippable:checked').data('price');
        ship_not_shippable = $('.radio-not-shippable:checked').data('price');
    } else {
        ship_shippable = $('.radio-shippable:checked').data('price_out');
        ship_not_shippable = $('.radio-not-shippable:checked').data('price_out');
    }

    if (typeof ship_shippable != "undefined" && ship_shippable != "") {
        shippable_price += parseFloat(ship_shippable);
    }
    if (typeof ship_not_shippable != "undefined" && ship_not_shippable != "") {
        not_shippable_price += parseFloat(ship_not_shippable);
    }

    shipping_price = shippable_price + not_shippable_price;

    shippable_porcentage = $('.radio-shippable:checked').data('porcentaje');
    not_shippable_porcentage = $('.radio-not-shippable:checked').data('porcentaje');

    var porcentaje = 0;
    if (typeof shippable_porcentage != "undefined" && shippable_porcentage != "") {
        porcentaje += parseFloat(shippable_porcentage);
    }
    if (typeof not_shippable_porcentage != "undefined" && not_shippable_porcentage != "") {
        porcentaje += parseFloat(not_shippable_porcentage);
    }

    if (porcentaje > 0) {
        total_porcentaje        = parseFloat(porcentaje) / 100;
        total_total_porcentaje  = parseFloat(subTotal) * total_porcentaje;
        total_total_porcentaje  = Math.round(total_total_porcentaje * 100) / 100;
        total_subtotal          = parseFloat(subTotal);
        total_envio             = parseFloat(shipping_price) + total_total_porcentaje;
        total_total             = total_envio + total_subtotal;
        total_total             = Math.round(total_total * 100) / 100;

        $("#total_subtotal").html(formatNumber(total_subtotal, 2));
        $("#total_envio").html(formatNumber(total_envio, 2));
        $("#total_total").html(formatNumber(total_total, 2));
    } else {
        total_subtotal  = parseFloat(subTotal);
        total_envio     = parseFloat(shipping_price);
        total_total     = total_envio + total_subtotal;

        $("#total_subtotal").html(formatNumber(total_subtotal, 2));
        $("#total_envio").html(formatNumber(total_envio, 2));
        $("#total_total").html(formatNumber(total_total, 2));
    }
}

function load_user_Addresses(addressToSelect = 0) {
    if (user_logged != 1) {
        return;
    }

    if (!userAddresses || userAddresses.length == 0) {
        userAddressDivContent = "";
        userAddressDivContent = "<span><b>No hay direcciones guardadas</b></span>"
        $('#addressContent').html(userAddressDivContent);
        $('#addressModalButton').addClass("d-none");
        return;
    }

    if ($('#addressModalButton').hasClass("d-none")) {
        $('#addressModalButton').removeClass("d-none");
    }

    modalDivContent = "";
    var i = 0;
    var addressToSelectIndex = 0;
    userAddresses.forEach(userAddress => {
        if (addressToSelect && userAddress["id"] == addressToSelect) {
            addressToSelectIndex = i;
        }

        modalDivContent += '<div class="list-group d-flex flex-row align-items-center justify-content-start">';
        if ((!addressToSelect && i == 0) || (addressToSelect && userAddress["id"] == addressToSelect)) {
            modalDivContent += '<input checked type="radio" name="RadioInputAddress" value="' + i + '" id="address' + i + '" />';
        } else {
            modalDivContent += '<input type="radio" name="RadioInputAddress" value="' + i + '" id="address' + i + '" />';
        }

        modalDivContent += '<label class="list-group-item w-100 ml-3" for="address' + i + '">';
        modalDivContent += '<span>' + userAddress["address"] + '</span>';
        modalDivContent += '<br >';
        modalDivContent += '<span>' + userAddress["city"] + ', ' + userAddress["province"] + ', ' + userAddress["cp"] + ', ' + userAddress["country"] + '</span>';
        modalDivContent += '</label></div>';

        i++;
    });

    $('#user_addresses_modal_body').html(modalDivContent);

    userAddressDivContent = "";
    userAddressDivContent += '<div><span>' + userAddresses[addressToSelectIndex]["address"] + '</span></div>';
    userAddressDivContent += '<div><span>' + userAddresses[addressToSelectIndex]["city"] + ', ' + userAddresses[addressToSelectIndex]["province"] + ', ' + userAddresses[addressToSelectIndex]["cp"] + ', ' + userAddresses[addressToSelectIndex]["country"] + '</span></div>';

    $('#addressContent').data("id", userAddresses[addressToSelectIndex]["id"]);
    $('#addressContent').html(userAddressDivContent);

    setPeninsula(!userAddresses[addressToSelectIndex]["province_out"])
}

function fetch_user_Addresses(addressToSelect = 0) {
    if (user_logged != 1) {
        return
    }

    $.ajax({
        type: "POST",
        url: "/getUserAdressesWS",
        data: {},
        success: function (resData) {
            if (resData.success == false) {
                console.log("Error: " + resData.error);
            } else {
                console.log("Direcciones obtenidas");
                console.log(resData);

                userAddresses = resData.addresses;
                console.log("addresses: " + userAddresses);

                needUserAddressesReload = false;
                if (addressToSelect) {
                    load_user_Addresses(addressToSelect);
                } else {
                    load_user_Addresses();
                }
            }
        },
        error: function (e) {
            customAlert("Error");
        }
    });
}

function changedNewAddressCountry(selected) {
    let selectedCountryId = selected.value;

    $('#address_id_province')
        .find('option')
        .remove()
        .end()
        .append('<option value=""></option>')
        .val('');

    let newOptionsSelect = '';
    for (let key in provinces) {
        if (provinces.hasOwnProperty(key)) {
            if (provinces[key]["id_country"] == selectedCountryId) {
                newOptionsSelect = newOptionsSelect + '<option value="' + provinces[key]["id"] + '">' + provinces[key]["name"] + '</option>';
            }
        }
    }

    $('#address_id_province').append(newOptionsSelect);
}

function changedNewAddressProvince(selected) {
    let selectedProvinceId = selected.value;

    $('#address_id_city')
        .find('option')
        .remove()
        .end()
        .append('<option value=""></option>')
        .val('');

    let newOptionsSelect = '';
    for (let key in cities) {
        if (cities.hasOwnProperty(key)) {
            if (cities[key]["id_province"] == selectedProvinceId) {
                newOptionsSelect = newOptionsSelect + '<option value="' + cities[key]["id"] + '">' + cities[key]["name"] + '</option>';
            }
        }
    }

    $('#address_id_city').append(newOptionsSelect);
}

//comprobamos si está todo seleccionado para activar / desactivar el botón de Finalizar pedido
function checkComplete() {
    isComplete = true;
    isAddressRequired = false;

    shipMethodComplete = true;
    addressComplete = true;

    if (user_logged != 1) {
        if ($("#pendingData_login").hasClass("no_display")) {
            $("#pendingData_login").removeClass("no_display");
        }
        isComplete = false;
    } else {
        if (!$("#pendingData_login").hasClass("no_display")) {
            $("#pendingData_login").addClass("no_display");
        }
    }

    if ($("#compra_checkTerms").prop('checked')) {
        if (!$("#pendingData_Condiciones").hasClass("no_display")) {
            $("#pendingData_Condiciones").addClass("no_display");
        }
    } else {
        if ($("#pendingData_Condiciones").hasClass("no_display")) {
            $("#pendingData_Condiciones").removeClass("no_display");
        }
        isComplete = false;
    }

    //comprobar si todos los juegos tienen su método de envío
    if (gameIds) {
        gameIds.forEach(gameId => {
            //hay seleccionado método de envío para este juego?
            if (!document.querySelector('input[name=shipMethod_' + gameId + ']:checked')) {
                isComplete = false;
                shipMethodComplete = false;
                if ($("#pendingData_envio").hasClass("no_display")) {
                    $("#pendingData_envio").removeClass("no_display");
                }
            } else {
                dataShippable = $(document.querySelector('input[name=shipMethod_' + gameId + ']:checked')).data('shippable');
                addressRequired = $(document.querySelector('input[name=shipMethod_' + gameId + ']:checked')).data('addressrequired');
                if (dataShippable == 1 && addressRequired == 1) {
                    isAddressRequired = true;
                }
            }
        });
    }

    if (shipMethodComplete) {
        if (!$("#pendingData_envio").hasClass("no_display")) {
            $("#pendingData_envio").addClass("no_display");
        }
    }

    //si no hay direcciones, no puede estar completo, si hay, siempre habrá una seleccionada
    if (isAddressRequired && (!userAddresses || userAddresses.length < 1)) {
        isComplete = false;
        addressComplete = false;
        if ($("#pendingData_direccion").hasClass("no_display")) {
            $("#pendingData_direccion").removeClass("no_display");
        }
    }
    if (addressComplete) {
        if (!$("#pendingData_direccion").hasClass("no_display")) {
            $("#pendingData_direccion").addClass("no_display");
        }
    }

    if (isComplete) {
        if (!$("#pendingData").hasClass("no_display")) {
            $("#pendingData").addClass("no_display");
        }
        $("#carrito_button_finalizar").prop("disabled", false);
    } else {
        if ($("#pendingData").hasClass("no_display")) {
            $("#pendingData").removeClass("no_display");
        }
        $("#carrito_button_finalizar").prop("disabled", true);
    }
}

function checkCondiciones(test) {
    checkComplete();
}