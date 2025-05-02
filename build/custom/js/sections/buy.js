var SLIPS_INDEX = 0
var SLIPS = []

for (let i = 0; i < numPreloadedBets; i++) {
    boletos.push(nuevoBoleto());
}

var CODE_A, CODE_B
var ELIGE_8 = 8
if (gameRules.is_code_a && gameRules.is_code_a_selectable && gameRules.is_code_a_per_slip) {
    CODE_A = []
}

if (gameRules.is_code_b && gameRules.is_code_b_selectable && gameRules.is_code_b_per_slip) {
    CODE_B = []
}

function aleatorioBoleto(boleto) {
    boleto = Number(boleto)
    if ($("#apuesta_" + boleto).hasClass('disabled_tabla')) {
        customAlert("Debes rellenar primero el boleto anterior")
        return
    }
    let prev_code_a = $('#apuesta_' + boleto + '_code_a').hasClass("selected")
    let prev_code_b = $('#apuesta_' + boleto + '_code_b').hasClass("selected")
    limpiarBoleto(boleto)
    boletos[boleto] = nuevoBoleto()
    aleatorioEnBoleto(boleto)

    if (prev_code_a) {
        //FIXME code_a revisar cuando code_a es true y no un array en todos los sitios donde se use code_a
        boletos[boleto]["code_a"] = true
        $('#apuesta_' + boleto + '_code_a').addClass("selected")
    }

    if (prev_code_b) {
        boletos[boleto]["code_b"] = true
        $('#apuesta_' + boleto + '_code_b').addClass("selected")
    }
    //Si no es el último boleto, comprobar si hay que activar los siguientes (si estaban previamente rellenados)

    //habilitar el siguiente boleto
    if (boleto == boletos.length - 1) {
        crearDivApuesta()
    } else {
        habilitarBoleto(boleto + 1)
    }
}


function borrarBoleto(boleto) {
    boleto = Number(boleto)
    boletos.splice(boleto, 1)
    boletos.push(nuevoBoleto())
    changeBoleto(boleto)
    comprobarPrecio()

    //Si no es el último boleto, desactivar siguientes
    //nth-of-type empieza a contar por 1 y queremos el siguiente del que estamos borrando por eso el +2
    // $('.style_tabla_comprar_euromillones:nth-child(n+' + (boleto + 2) + ')').attr('style', 'opacity: 0.3').addClass('disabled_tabla')
    // if (boleto < boletos.length) {
    //     for (let i = (boleto + 1); i <= boletos.length; i++) {
    //         $("#apuesta_" + i).attr('style', 'opacity: 0.3')
    //         $("#apuesta_" + i).addClass('disabled_tabla')
    //     }
    // }
}

/**
 * quiniela 2 apuestas
 * [[["1","X"],["2"],["2"],["2"],["2"],["X"],["X"],["2"],["2"],["2"],["2"],["2"],["1"],["X"]]]
 * 
 * quinigol 4 apuestas
 * [[["1","0"],["M"]],[["1"],["M"]],[["1","2"],["M"]],[["1"],["M"]],[["1"],["M"]],[["1"],["M"]]]
 */

/**
 * 
 * @param {array} array array con las apuestas de tipo Apuestas Deportivas
 * @returns 
 */
function getNumSportBets(array) {
    let total = 1;
    
    array.forEach(bets => {
        if (Array.isArray(bets[0])) {
            total *= getNumSportBets(bets)
        } else {
            total *= bets.length
        }
    })

    return total
}

/**
 * 
 * @param {array} array array con los numeros, todos deben estar a la misma profundidad en el array
 * ej.
 * OK [["1"], ["1", "2"]]
 * NO [["1"], ["1", ["2", "1"]]]
 * @returns {number} numero de numeros en el array
 */
function getNumSportNumbers(array) {
    let total = 0
    
    array.forEach(bets => {
        if (Array.isArray(bets[0])) {
            total += getNumSportNumbers(bets)
        } else {
            total += bets.length
        }
    })

    return total
}

/**
 * 
 * @param {number|array} bets numero de numeros seleccionado o array con los numeros de tipo Lotto
 * @param {number} group grupo de numeros de los que se quiere combinaciones por defecto gameRules.num_number_per_bet
 * @returns {number} devuelve el numero de combinaciones de {group} cifras entre los numeros {bets}
 */
function getNumLottoBets(bets, group = null) {
    if (Array.isArray(bets)) {
        // se quitan repetidos
        bets = new Set(bets).size
    }

    if (!group) {
        group = gameRules.num_number_per_bet
    }

    if (bets == group) {
        return 1
    }

    return factorial(bets) / (factorial(group) * factorial(bets - group))
}

/**
 * 
 * @param {number} number cantidad de valores elegidos
 * @param {number} extra cantidad de extras elegidos
 * @param {array} fallback en caso de no haber multiples definidos en el juego se calculan con la cantidad de numeros
 * ej. fallback
 * simple
 * ['07', '10', '46', '11', '37']
 * 
 * con extras
 * [
 *  "numeros": ['07', '10', '46', '11', '37'],
 *  "extras": ['06', '11']
 * ]
 * @returns {number} numero de apuestas
 */
function getNumBets(number, extra = null, fallback = []) {
    let numBets = null
    if (gameRules.multiples) {
        if (extra) {
            multiple = gameRules.multiples.find(multiple => multiple.number == number && multiple.extra == extra)
        } else {
            multiple = gameRules.multiples.find(multiple => multiple.number == number)
        }

        if (multiple) {
            numBets = multiple.combinations
        }
    }

    if (numBets) {
        return numBets
    }

    let numeros
    let extras
    if (fallback["numeros"]) {
        numeros = fallback["numeros"]
    }

    if (fallback["extras"]) {
        extras = fallback["extras"]
    }

    //si no se han definido en el panel calcularlos a mano
    switch (gameRules.id_type) {
        case 1:
            //LOTTO (euromillon)
            if (!empty(extras)) {
                numBets = getNumLottoBets(numeros) * getNumLottoBets(extras.length, gameRules.num_extra_per_bet)
            } else {
                numBets = getNumLottoBets(numeros)
            }
            break;
        case 2:
            //APUESTA DEPORTIVA (quiniela)
            if (!empty(extras)) {
                numBets = getNumSportBets(numeros) * extra[0].length * extra[1].length
            } else {
                numBets = getNumSportBets(numeros)
            }
            break;
    }
    
    return numBets
}

/**
 * comprueba si las dos apuestas que se pasan pueden ir en el mismo boleto o no
 * 
 * si es multiple devuelve false
 * si el code_a es por boleto y son diferentes devuelve false
 * si el code_b es por boleto y son diferentes devuelve false
 * si el refund es por boleto y son diferentes devuelve false
 * @returns {boolean} si pueden ir en el mismo boleto o no
 */
function isBetOnSameSlip(bet1, bet2) {
    if (bet1 === undefined || bet2 === undefined) {
        // si solo se pasa 1 apuesta no se puede comparar por lo que la propio apuesta si está en el mismo boleto
        return true
    }

    if (bet1["tipo"] == "multiple" || bet2["tipo"] == "multiple") {
        return false
    }

    // se pueden elegir diferentes reintegros por boleto en cada apuesta, hay que comprobar que sean iguales para que entren en el mismo
    if (gameRules.is_num_refund && gameRules.is_num_refund_per_slip) {
        if (gameRules.is_link_num_refund_extra) {
            if (Array.isArray(bet1['extras'])) {
                if (!bet1["extras"].every((e, i) => e == bet2["extras"][i])) {
                    return false
                }
            } else {
                if (bet1['extras'] != bet2['extras']) {
                    return false;
                }
            }
        } else if (bet1["refund"] != bet2["refund"]) {
            return false
        }
    }

    // si hay un mismo extra para varias apuestas hay que tener en cuenta si los extras son iguales
    if (gameRules.num_max_bets_per_slip != gameRules.num_max_extras_per_slip) {
        if (Array.isArray(bet1['extras'])) {
            if (!bet1["extras"].every((e, i) => JSON.stringify(e) == JSON.stringify(bet2["extras"][i]))) {
                return false
            }
        } else {
            if (bet1['extras'] != bet2['extras']) {
                return false;
            }
        }
    }

    if (gameRules.is_code_a && gameRules.is_code_a_per_slip) {
        if (gameRules.is_code_a_selectable) {
            if (!bet1["code_a"].every((e, i) => e == bet2["code_a"][i])) {
                return false
            }
        } else if (JSON.stringify(bet1["code_a"]) != JSON.stringify(bet2["code_a"])) {
            return false
        }
    }

    if (gameRules.is_code_b && gameRules.is_code_b_per_slip) {
        if (gameRules.is_code_b_selectable) {
            if (!bet1["code_b"].every((e, i) => e == bet2["code_b"][i])) {
                return false
            }
        } else if (JSON.stringify(bet1["code_b"]) != JSON.stringify(bet2["code_b"])) {
            return false
        }
    }

    return true
}

// si no hay suficientes apuestas para rellenar el minimo por boleto se marca como false
var COMPLETED_SLIPS = true
/**
 * Devuelve los boletos en base a las apuestas que hay en el array de boletos, se tiene en cuenta, multiples, refund, code_a y code_b
 * los multiples van en una apuesta separada
 * las apuestas tienen que estar entre gameRules.num_min_bets_per_slip y gameRules.num_max_bets_per_slip en cada boleto 
 * si el min son 2 y el max son 8 si hay 7 en el boleto actual no caben 2 mas pero tampoco puedes tener 8-1, tiene que ser un boleto de 7 y otro de 2
 * 
 * el code_a puede ser por boleto y si hay diferentes hay que separarlos
 * el code_b puede ser por boleto y si hay diferentes hay que separarlos
 * el refund puede ser por boleto y si hay diferentes hay que separarlos
 * @returns {array} array de boletos con las apuestas agrupadas
 */
function getSlips() {
    let total = 0;
    let simples = []
    let groups = []
    let groupIndex = 0
    let num_min_bets_per_slip = gameRules.min_import_per_slip ? Math.round(((gameRules.min_import_per_slip / gameRules.price) + Number.EPSILON) * 100) / 100 : gameRules.num_min_bets_per_slip
    let selectedDays = $('.div_day.selected_day').length
    COMPLETED_SLIPS = true

    if (gameRules.id_type == 2) {
        selectedDays = 1
    }

    boletos.filter(f => f["completo"]).forEach(element => {
        if (element["tipo"] == "multiple") {
            groups[groupIndex] = []
            groups[groupIndex].push(element)
            groupIndex++
            total++
        } else {
            simples.push(element)
        }
    })

    // si no hay apuestas simples se devuelven las multiples y si no hay multiples groups = []
    if (!simples.length) {
        SLIPS = groups
        return groups
    }

    let left = simples.length
    let discard = []
    let leftovers = []

    // con esto se compara el reintegro con la siguiente apuesta no con todas [1, 1, 2, 1] -> [[1, 1], [2], [1]]
    simples.forEach((element, index) => {
        if (left == num_min_bets_per_slip) {
            if (groups[groupIndex] === undefined) {
                groups[groupIndex] = []
            }
            leftovers = simples.filter((e, i) => !discard.includes(i))
            if ((groups[groupIndex].length + left) <= gameRules.num_max_bets_per_slip) {
                // si todos los que quedan caben en el ultimo boleto se añade y se para el bucle
                leftovers.forEach(e => {
                    if (isBetOnSameSlip(e, groups[groupIndex][0])) {
                        groups[groupIndex].push(e)
                    } else {
                        groupIndex++
                        groups[groupIndex] = [e]
                    }
                })
                leftovers = []
                left = 0
            } else {
                // si no caben en el ultimo boleto se añade en uno nuevo y se para el bucle
                //TODO hacer aqui lo mismo de arriba de comprobar isBetOnSameSlip
                groupIndex++
                groups[groupIndex] = leftovers.slice()
                leftovers = []
                left = 0
            }

            // si los que quedan no son iguales se han añadido igualmente para el calculo de totales pero se marca como incompleto
            if (!leftovers.every(e => isBetOnSameSlip(e, groups[groupIndex][0]))) {
                COMPLETED_SLIPS = false
            }
        }

        if (left > 0) {
            if (groups[groupIndex] === undefined) {
                groups[groupIndex] = []
            }
            if (groups[groupIndex].length >= gameRules.num_max_bets_per_slip) {
                groupIndex++
                groups[groupIndex] = []
            }
    
            groups[groupIndex].push(element)
            discard.push(index)
            left--
    
            if (simples[index + 1] && !isBetOnSameSlip(element, simples[index + 1])) {
                groupIndex++
            }
        }
    })

    let completedSlip = true
    let infoRow = ''
    groups.forEach((e, i) => {
        // si despues de iterar simples algun grupo se queda con menos del min se marca incompleto
        if (e[0].tipo != 'multiple' && e.length * selectedDays < num_min_bets_per_slip) {
            COMPLETED_SLIPS = false
            completedSlip = false
        }

        infoRow += `<tr>
            <td scope="row">${i + 1}</td>
            <td>${e.map(slipBet => boletos.findIndex(globalBet => globalBet.index == slipBet.index) + 1).join(', ')}</td>
            <td>${completedSlip ? 'si' : 'no'}</td>
        </tr>`

        completedSlip = true
    })

    $('#num_slips').text(groups.length)
    $('#slips_info').html(infoRow)

    SLIPS = groups
    
    return groups

    // con esto se compara el reintegro de todas las apuestas [1, 1, 2, 1] -> [[1, 1, 1], [2]]
    // let base = null
    // while (left) {
    //     if (left == num_min_bets_per_slip) {
    //         if (groups[groupIndex] === undefined) {
    //             groups[groupIndex] = []
    //         }
    //         if ((groups[groupIndex].length + left) <= gameRules.num_max_bets_per_slip && simples.every(e => isBetOnSameSlip(e, groups[groupIndex][0]))) {
    //             //si todos los que quedan caben en el ultimo boleto y son iguales se añade y se para el bucle
    //             simples.forEach(e => groups[groupIndex].push(e))
    //             simples = []
    //             left = 0
    //         } else {
    //             //si todos los que quedan son iguales entre si se puede añadir a un boleto nuevo porque son el num_min_bets_per_slip
    //             groupIndex++
    //             groups[groupIndex] = simples.slice()
    //             simples = []
    //             left = 0
    //             if (!groups[groupIndex].every(e => isBetOnSameSlip(e, groups[groupIndex][0]))) {
    //                 //si los que quedan no son iguales se añaden igualmente para el calculo de totales pero se marca como incompleto
    //                 COMPLETED_SLIPS = false
    //             }
    //         }
    //     }

    //     simples.forEach((element, index) => {
    //         if (left != num_min_bets_per_slip) {
    //             if (groups[groupIndex] === undefined) {
    //                 groups[groupIndex] = []
    //             }
    //             if (groups[groupIndex].length >= gameRules.num_max_bets_per_slip) {
    //                 groupIndex++
    //                 groups[groupIndex] = []
    //                 base = null
    //             }
    //             if (!base) {
    //                 // se pilla el primer elemento para compararlo con el resto
    //                 base = element
    //                 groups[groupIndex].push(base)
    //                 left--
    //                 discard.push(index)
    //             } else {
    //                 if (isBetOnSameSlip(base, element)) {
    //                     groups[groupIndex].push(element)
    //                     left--
    //                     discard.push(index)
    //                 }
    //                 // si isBetOnSameSlip es false la apuesta no se filtra y se procesa en la siguiente tanda del while
    //             }
    //         }
    //     })

    //     // si despues de iterar simples el grupo se queda con menos del min se marca incompleto
    //     if (groups[groupIndex].length * $('.div_day.selected_day').length < num_min_bets_per_slip) {
    //         COMPLETED_SLIPS = false
    //     }

    //     // los elementos que ya se han agrupado se descartan
    //     simples = simples.filter((e, i) => !discard.includes(i))
    //     discard = []
    //     base = null
    //     if (left != num_min_bets_per_slip) {
    //         groupIndex++
    //     }
    // }

    // return groups
}

function comprobarPrecio() {
    //TODO comprobarPrecio se llama 32 veces cuando se borra una apuesta
    let bets = 0
    let currentBets = 0
    let price = null
    let days_selected = 0
    let weeks = 1
    let priceBets = 0
    let slips = getSlips()
    let addedPricePerSlip = 0;
    let addedPricePerBet = 0;
    let priceAOnBet = 0;
    let priceBOnBet = 0;
    let priceLQ = 0

    if (gameRules.is_code_a) {
        if (gameRules.is_code_a_per_slip) {
            if (gameRules.is_code_a_selectable) {
                // {# no hay ningun otro juego con code_a selectable y no esta definido que 8 sea completo #}
                if ((CODE_A.length && gameRules.code != 'LQ') || (CODE_A.length == ELIGE_8 && gameRules.code == 'LQ')) {
                    addedPricePerSlip += gameRules.code_a_price ? gameRules.code_a_price : 0;
                }
            } else {
                // si no se elige no se suma, es un checkbox
                if ($("#code_a").length && $("#code_a").hasClass("selected")) {
                    addedPricePerSlip += gameRules.code_a_price ? gameRules.code_a_price : 0;
                }
            }
        } else {
            // cada apuesta debe calcular su precio
            priceAOnBet = gameRules.code_a_price ? gameRules.code_a_price : 0
        }
    }

    if (gameRules.is_code_b_per_slip) {
        if (gameRules.is_code_b_selectable) {
            if (CODE_B.length) {
                addedPricePerSlip += gameRules.code_b_price ? gameRules.code_b_price : 0;
            }
        } else {
            if ($("#code_b").length && $("#code_b").hasClass("selected")) {
                addedPricePerSlip += gameRules.code_b_price ? gameRules.code_b_price : 0;
            }
        }
    } else {
        priceBOnBet = gameRules.code_b_price ? gameRules.code_b_price : 0
    }

    if ($("#abono_semanas_button").length) {
        weeks = $("#abono_semanas_button").data('sems')
    }

    if ($('.div_day.selected_day').length) {
        days_selected = $('.div_day.selected_day').length
    }

    if (gameRules.id_type == 2) {
        // con las jornadas no hay semanas ni dias solo se juega a 1
        weeks = 1
        days_selected = 1
    }

    let totalsPerSlip = []
    slips.forEach((slip, i) => totalsPerSlip[i] = {"numbers": slip.map(e => e["index"]), "total": 0})
    boletos.filter(e => e["completo"]).forEach(item => {
        if (gameRules.id_type == 2) {
            currentBets = getNumBets(getNumSportNumbers(item["numeros"]), item["extras"], item)
            bets += currentBets
            if (gameRules.code == 'LQ'){
                priceLQ = getQuinielaItemPrice(item)
            }
        } else {
            if (item["tipo"] == "simple") {
                currentBets = 1
                bets += currentBets
            } else {
                if (item["numeros"].length == gameRules.num_number_per_bet - 1) {
                    currentBets = gameRules.max_value_per_number - (gameRules.num_number_per_bet - 1) //opción elige 5 en vez de 6
                    bets += currentBets
                } else {
                    currentBets = 1
                    if (item["numeros"].length > gameRules.num_number_per_bet) {
                        //combinaciones de m cogidos de n en n donde m es la cantidad de números escogidos y n la cantidad de números por apuesta simple, de forma que numeroCombinaciones=m!/(n!*(m-n)!)
                        currentBets *= (factorial(item["numeros"].length) / (factorial(gameRules.num_number_per_bet) * factorial(item["numeros"].length - gameRules.num_number_per_bet)))
                    }
                    if (item["extras"] && item["extras"].length > gameRules.num_extra_per_bet) {
                        currentBets *= (factorial(item["extras"].length) / (factorial(gameRules.num_extra_per_bet) * factorial(item["extras"].length - gameRules.num_extra_per_bet)))
                    }
                    bets += currentBets
                }
            }
        }
    
        if (priceAOnBet) {
            if (!gameRules.is_code_a_optional) {
                addedPricePerBet += priceAOnBet;
            } else if (gameRules.is_code_a_selectable) {
                if ((CODE_A.length && gameRules.code != 'LQ') || (CODE_A.length == ELIGE_8 && gameRules.code == 'LQ')) {
                    addedPricePerBet += priceAOnBet;
                }
            } else {
                if ($("#code_a").length && $("#code_a").hasClass("selected")) {
                    addedPricePerBet += priceAOnBet;
                }
            }
        }

        if (priceBOnBet) {
            if (!gameRules.is_code_b_optional) {
                addedPricePerBet += priceBOnBet;
            } else if (gameRules.is_code_b_selectable) {
                if (CODE_B.length) {
                    addedPricePerBet += priceBOnBet;
                }
            } else {
                if ($("#code_b").length && $("#code_b").hasClass("selected")) {
                    addedPricePerBet += priceBOnBet;
                }
            }
        }

        if (priceLQ) {
            priceBets += priceLQ
            totalsPerSlip.find(slip => slip.numbers.find(index => index == item["index"]) !== undefined).total += priceLQ
        } else {
            priceBets += currentBets * (gameRules.price + addedPricePerBet)
            totalsPerSlip.find(slip => slip.numbers.find(index => index == item["index"]) !== undefined).total += currentBets * (gameRules.price + addedPricePerBet)
        }
        addedPricePerBet = 0
    });

    //check semanas
    let sorteosSems = 0
    if ($("#semana").length) {
        if (weeks > 1 && weeks != "X") {
            if ($("#semana").hasClass("selected_day")) {
                sorteosSems = (weeks - 1) * gameRules.id_days.length
            } else {
                // un dia concreto
                let selectedDay = new Date($('.div_day.selected_day').data("date"))
                // esta semana no se cuenta porque no se puede elegir
                selectedDay.setDate(selectedDay.getDate() + 7)
                let i = 1
                let holydays = 0
                while (i < Number(weeks)) {
                    console.log(dateToYMD(selectedDay))
                    if (PV_CALENDAR[dateToYMD(selectedDay)]) {
                        holydays++
                    }
                    selectedDay.setDate(selectedDay.getDate() + 7)
                    i++
                }
                sorteosSems = (weeks - 1) * days_selected - holydays
            }
        }
    } else if (weeks > 1 && weeks != "X") {
        sorteosSems = (weeks - 1) * gameRules.id_days.length
    }
    // days_selected pasa a ser el total de sorteos contando todas las semanas
    days_selected = days_selected + sorteosSems

    price = priceBets * days_selected
    // en la quiniela el precio ya viene calculado no hace falta añadirle el precio por boleto
    if (gameRules.code != 'LQ') {
        price += (addedPricePerSlip * slips.length * days_selected)
        totalsPerSlip.forEach(e => e.total *= days_selected)
    }

    // se mira si el boleto mas barato cumple el min_import_per_slip
    if (price > 0 && Math.min(...totalsPerSlip.map(item => item.total)) >= gameRules.min_import_per_slip && COMPLETED_SLIPS) {
        $("#button_validarApuesta").prop("disabled", false)
    } else {
        $("#button_validarApuesta").prop("disabled", true)
    }

    $("#total_price").html(formatNumber(price, 2))
    $("#num_apuestas").html(bets)
    if ($("#total_sorteos").length) {
        $("#total_sorteos").html(days_selected)
    }
}

function aleatorioEnBoleto(boleto) {
    if (gameRules.id_type == 2) {
        randomBetType2(boleto)
        return
    }

    let numeros = []

    //GET 5 NUM RANDOMS AND 2 STARS
    if (gameRules.custom_values_per_number) {
        while (numeros.length < gameRules.num_number_per_bet) {
            random = Math.floor(Math.random() * (gameRules.custom_values_per_number.length))
            numeros.push(gameRules.custom_values_per_number[random])
            $("#apuesta_" + boleto + "_numero_" + random).addClass('selected')
            boletos[boleto]["numeros"].push(random)
        }
    } else {
        while (numeros.length < gameRules.num_number_per_bet) {
            random = Math.floor(Math.random() * (gameRules.max_value_per_number - gameRules.min_value_per_number + 1) + gameRules.min_value_per_number)
            random = zerofill(random.toString(), 2)
            if (numeros.indexOf(random) < 0) {
                numeros.push(random)
                $("#apuesta_" + boleto + "_numero_" + random).addClass('selected')
                boletos[boleto]["numeros"].push(random)
            }
        }
    }

    if (gameRules.num_max_extras_per_slip) {
        if (gameRules.custom_values_per_extra) {
            while (boletos[boleto]["extras"].length < gameRules.num_extra_per_bet) {
                random = Math.floor(Math.random() * (gameRules.custom_values_per_number.length))
                boletos[boleto]["extras"].push(gameRules.custom_values_per_number[random])
                $("#apuesta_" + boleto + "_extra_" + random).addClass('selected')
            }
        } else {
            if (gameRules.is_link_num_refund_extra && boletos[boleto - 1] && boletos[boleto - 1]["extras"]) {
                $(`[id^="apuesta_${boleto}_extra_"].selected`).removeClass('selected')
                boletos[boleto]["extras"] = boletos[boleto - 1]["extras"].map(e => e)
                $("#apuesta_" + boleto + "_extra_" + boletos[boleto - 1]["extras"][0]).addClass('selected')
            } else {
                while (boletos[boleto]["extras"].length < gameRules.num_extra_per_bet) {
                    random = Math.floor(Math.random() * (gameRules.max_value_per_extra - gameRules.min_value_per_extra + 1) + gameRules.min_value_per_extra)
                    if (gameRules.max_value_per_extra >= 10) {
                        random = zerofill(random, 2)
                    }
                    if (boletos[boleto]["extras"].indexOf(random) < 0) {
                        boletos[boleto]["extras"].push(random)
                        $("#apuesta_" + boleto + "_extra_" + random).addClass('selected')
                    }
                }
            }
        }

        if ($("#container_boleto_" + boleto + "_extras").length) {
            $("#apuesta_" + boleto + "_extraInfo").html(`Escoge ${gameRules.num_extra_per_bet} ${gameRules.extra_name}`)
        }
    }

    if ($("#container_boleto_" + boleto + "_refund").length) {
        if (boletos[boleto - 1] && boletos[boleto - 1]["refund"]) {
            if(Array.isArray(boletos[boleto - 1]["refund"])) {
                boletos[boleto]["refund"] = boletos[boleto - 1]["refund"].map(e => e)
            } else {
                boletos[boleto]["refund"] = boletos[boleto - 1]["refund"]
            }
        } else {
            if (gameRules.is_link_num_refund_extra) {
                //el gordo no tiene configurados numeros de reintegro
                boletos[boleto]["refund"] = Math.floor(Math.random() * (gameRules.max_value_per_extra - gameRules.min_value_per_extra + 1) + gameRules.min_value_per_extra);
            } else {
                boletos[boleto]["refund"] = Math.floor(Math.random() * (gameRules.num_refund_max - gameRules.num_refund_min + 1) + gameRules.num_refund_min);
            }
        }
        $("#apuesta_" + boleto + "_refund_" + boletos[boleto]["refund"]).addClass('selected')    
    }

    if (gameRules.is_code_a && gameRules.is_code_a_per_slip) {
        if ($('.code_a_box.selected').length) {
            $("#apuesta_" + boleto + "_code_a").addClass("selected")
            boletos[boleto]["code_a"] = true
        }
    }

    if (gameRules.is_code_b && gameRules.is_code_b_per_slip) {
        if ($('.code_b_box.selected').length) {
            $("#apuesta_" + boleto + "_code_b").addClass("selected")
            boletos[boleto]["code_b"] = true
        }
    }

    boletos[boleto]["tipo"] = "simple"
    boletos[boleto]["completo"] = true
    //nextApuestaResponsive()
    $("#apuesta_" + boleto + "_title").html("Apuesta " + (boleto + 1))
    $("#apuesta_" + boleto + "_btn_cambiar_multiple").removeClass("button_es_multiple")
    $("#apuesta_" + boleto + "_btn_cambiar_multiple").html("Sencilla")
    $("#apuesta_" + boleto + "_numInfo").html(`Escoge ${gameRules.num_number_per_bet} ${gameRules.number_name}`)

    comprobarPrecio()
}

function randomBetType2(boleto) {
    if (gameRules.code == "QGOL") {
        aleatorioEnBoletoQuinigol(boleto)
        return
    }

    for (let i = 0; i < gameRules.num_number_per_bet; i++) {
        random = Math.floor(Math.random() * (gameRules.custom_values_per_number.length))
        $(`#apuesta_${boleto}_match_${i}_numero_${gameRules.custom_values_per_number[random]}`).addClass('selected')
        boletos[boleto]["numeros"][i].push(gameRules.custom_values_per_number[random])

        if (gameRules.is_code_a && $('#match_' + (i+1)).hasClass('partido_seleccionado_elige8') && boleto == 0) {
            $(`#apuesta_${boleto}_match_${i}_numero_${gameRules.custom_values_per_number[random]}`).find('.item_figure').addClass('item_figure_code_a_selected')
        }
    }

    let lastBet = boletos.find(e => e.tipo == 'simple' && e.completo)
    if (lastBet) {
        boletos[boleto]["extras"] = JSON.parse(JSON.stringify(lastBet["extras"]))
        for (let i = 0; i < gameRules.num_extra_per_bet; i++) {
            $(`#apuesta_${boleto}_team_${i}_extra_${boletos[boleto]["extras"][i][0]}`).addClass('selected')
        }
    } else {
        for (let i = 0; i < gameRules.num_extra_per_bet; i++) {
            random = Math.floor(Math.random() * (gameRules.custom_values_per_extra.length))
            $(`#apuesta_${boleto}_team_${i}_extra_${gameRules.custom_values_per_extra[random]}`).addClass('selected')
            boletos[boleto]["extras"][i] = [gameRules.custom_values_per_extra[random]]
        }
    }

    boletos[boleto]["tipo"] = "simple"
    boletos[boleto]["completo"] = true
    $("#apuesta_" + boleto + "_title").html("Apuesta " + (boleto + 1))
    $("#apuesta_" + boleto + "_btn_cambiar_multiple").removeClass("button_es_multiple")
    $("#apuesta_" + boleto + "_btn_cambiar_multiple").html("Sencilla")

    if (gameRules.is_code_a) {
        updateCodeAMatches()
    }

    comprobarPrecio()
}

function aleatorioEnBoletoQuinigol(boleto) {
    for (let i = 0; i < gameRules.num_number_per_bet; i++) {
        //se saca un valor para cada equipo
        for (let j = 0; j < gameRules.custom_values_per_number[0].split('-').length; j++) {
            random = Math.floor(Math.random() * (gameRules.unique_custom_values.length))
            // numeros.push(gameRules.unique_custom_values[random])
            $(`#apuesta_${boleto}_match_${i}_team_${j}_numero_${gameRules.unique_custom_values[random]}`).addClass('selected')

            boletos[boleto]["numeros"][i][j].push(gameRules.unique_custom_values[random])
        }
    }

    boletos[boleto]["tipo"] = "simple"
    boletos[boleto]["completo"] = true
    $("#apuesta_" + boleto + "_title").html("Apuesta " + (boleto + 1))
    $("#apuesta_" + boleto + "_btn_cambiar_multiple").removeClass("button_es_multiple")
    $("#apuesta_" + boleto + "_btn_cambiar_multiple").html("Sencilla")

    comprobarPrecio()
    return
}

function nuevoBoleto() {
    let boleto = []
    let numeros = [];
    boleto["numeros"] = numeros
    boleto["tipo"] = "simple"
    boleto["completo"] = false
    boleto["index"] = SLIPS_INDEX
    SLIPS_INDEX++
    
    if (gameRules.num_max_extras_per_slip) {
        boleto["extras"] = []
    }
    
    if (gameRules.id_type == 2) {
            for (let i = 0; i < gameRules.num_number_per_bet; i++) {
                numeros[i] = []
            }
            
            let extras = []
            for (let i = 0; i < gameRules.num_extra_per_bet; i++) {
                extras[i] = []
            }
        
            boleto["numeros"] = numeros
            boleto["extras"] = extras
    }

    switch (gameRules.code) {
        case "LQ":
            // for (let i = 1; i <= gameRules.num_number_per_bet; i++) {
            //     numeros[i] = []
            // }
            
            // let reintegros = []
            // for (let i = 1; i <= gameRules.num_extra_per_bet; i++) {
            //     reintegros[i] = ''
            // }
        
            // boleto["numeros"] = numeros
            // boleto["pleno"] = reintegros
            break
        case "QGOL":
            for (let i = 0; i < gameRules.num_number_per_bet; i++) {
                let equipos = []
                gameRules.custom_values_per_number[0].split('-').forEach((e, i) => {
                    //array por equipo
                    equipos.push([])
                })
                numeros[i] = equipos
            }
            boleto["numeros"] = numeros
            break
    }

    if (gameRules.is_num_refund && gameRules.is_num_refund_selectable) {
        boleto["refund"] = ""
    }

    if (gameRules.is_code_a) {
        if (gameRules.is_code_a_optional) {
            if (gameRules.is_code_a_selectable) {
                boleto["code_a"] = []
            } else {
                boleto["code_a"] = false
            }
        } else {
            boleto["code_a"] = true
        }
    }

    if (gameRules.is_code_b) {
        if (gameRules.is_code_b_optional) {
            if (gameRules.is_code_b_selectable) {
                boleto["code_b"] = []
            } else {
                boleto["code_b"] = false
            }
        } else {
            boleto["code_b"] = true
        }
    }

    return boleto
}

function crearDivApuesta() {
    if (gameRules.code == 'QGOL') {
        crearDivApuestaQuinigol()
        return
    }
    let divNuevaApuesta = document.createElement('div')
    let copy = $('#apuesta_0')[0]
    let nextId = $('#contenedorApuestas').children().length
    divNuevaApuesta.className = copy.className
    divNuevaApuesta.style = copy.style
    divNuevaApuesta.id = copy.id.replace('0', nextId)
    divNuevaApuesta.innerHTML = copy.innerHTML.replace(/_0_/g, '_' + nextId.toString() + '_').replace(/Boleto\('0'\)/g, "Boleto\('" + nextId.toString() + "'\)")

    document.getElementById('contenedorApuestas').appendChild(divNuevaApuesta)

    boletos.push(nuevoBoleto())
    $("#apuesta_" + nextId).addClass('hidden_responsive')
    $("#apuesta_" + nextId + '_title').text('Apuesta ' + (nextId + 1))
    limpiarBoleto(nextId)
    scrollApuestasToEnd()
}

function crearDivApuestaQuinigol() {

    let divNuevaApuesta = document.createElement('div')
    let copy = $('#apuesta_0')[0]
    let nextId = $('#contenedorApuestas').children().length
    divNuevaApuesta.className = copy.className
    divNuevaApuesta.style = copy.style
    divNuevaApuesta.id = copy.id.replace('0', nextId)
    divNuevaApuesta.innerHTML = copy.innerHTML.replace(/apuesta_0_/g, 'apuesta_' + nextId.toString() + '_').replace(/Boleto\('0'\)/g, "Boleto\('" + nextId.toString() + "'\)")

    document.getElementById('contenedorApuestas').appendChild(divNuevaApuesta)

    boletos.push(nuevoBoleto())
    $("#apuesta_" + nextId).addClass('hidden_responsive')
    $("#apuesta_" + nextId + '_title').text('Apuesta ' + (nextId + 1))
    $("#apuesta_" + nextId).find(".selected").removeClass("selected")
    limpiarBoleto(nextId)
    scrollApuestasToEnd()
    return
}

function habilitarBoleto(boleto) {
    let previouslyDisabled = $("#apuesta_" + boleto).hasClass('disabled_tabla')
    $("#apuesta_" + boleto).attr('style', 'visibility: visible')
    $("#apuesta_" + boleto).removeClass('disabled_tabla')
    if ($("#apuesta_" + boleto).hasClass('no_display')) {
        $("#apuesta_" + boleto).removeClass('no_display')
        scrollApuestasToEnd()
    }

    if (boleto < boletos.length) {
        let bol_completo = true
        for (let i = boleto; i <= boletos.length && bol_completo; i++) {
            if (boletos[i]["completo"] == true) {
                if (i == boletos.length - 1) {
                    crearDivApuesta()
                } else {
                    habilitarBoleto(i + 1)
                }
            } else {
                bol_completo = false
            }
        }
    }

    switch (gameRules.id_type) {
        case 2:
            //pintar los extras del boleto anterior en el siguiente
            $('#apuesta_' + boleto + ' .extra_container').removeClass("selected")
            for (let i = 0; i < gameRules.num_extra_per_bet; i++) {
                if (boletos[boleto]["extras"][i] == "") {
                    boletos[boleto]["extras"][i] = boletos[boleto - 1]["extras"][i].map(e => e)
                    $(`#apuesta_${boleto}_team_${i}_extra_${boletos[boleto - 1]["extras"][i]}`).addClass("selected")
                }
            }
            break
    }

    if ($("#container_boleto_" + boleto + "_refund").length) {
        //si no hay reintegro seleccionado en la siguiente apuesta se pone el del anterior            
        if (!$("#container_boleto_" + boleto + "_refund").find('.selected').length) {
            otherReintegro = boletos.filter(e => e["refund"])[0]
            reintegro = otherReintegro ? otherReintegro["refund"] : ''
            boletos[boleto]["refund"] = reintegro
            $("#apuesta_" + boleto + "_refund_" + reintegro).addClass('selected')
        }
    }

    if (gameRules.is_link_num_refund_extra && boletos[boleto - 1] && boletos[boleto - 1]["extras"] && previouslyDisabled) {
        $(`[id^="apuesta_${boleto}_extra_"].selected`).removeClass('selected')
        boletos[boleto]["extras"] = boletos[boleto - 1]["extras"].map(e => e)
        $("#apuesta_" + boleto + "_extra_" + boletos[boleto - 1]["extras"][0]).addClass('selected')
    }

    if (gameRules.is_code_a && gameRules.is_code_a_per_slip) {
        if ($('.code_a_box.selected').length) {
            $("#apuesta_" + boleto + "_code_a").addClass("selected")
            boletos[boleto]["code_a"] = true
        }
    }

    if (gameRules.is_code_b && gameRules.is_code_b_per_slip) {
        if ($('.code_b_box.selected').length) {
            $("#apuesta_" + boleto + "_code_b").addClass("selected")
            boletos[boleto]["code_b"] = true
        }
    }
}

function scrollApuestasToEnd() {
    $('#contenedorApuestas').scrollLeft($('#contenedorApuestas')[0].scrollWidth)
}

function getDateOfISOWeek(weekNo, year = "current") {
    let date = new Date()

    if (year !== "current" && !isNaN(Number(year)) && year) {
        date.setFullYear(Number(year))
        date.setHours(0, 0, 0)
    }

    // semana seleccionada
    date.setDate(date.getDate() + (7 * (weekNo - date.getWeek())))
    // lunes de esa semana
    // getDay empieza por 0 si es domingo y 6 el sabado asi que si es 0 se cambia a 7
    date.setDate(date.getDate() - ((date.getDay() || 7) - 1))

    return date
}

function getDateRangeOfWeek(weekNo, year = null) {
    weekNo = Number(weekNo)
    if (isNaN(weekNo)) {
        return
    }

    let date = getDateOfISOWeek(weekNo, year)

    let monday = date.getDate()
    let prevMonth = ucfirst(date.toLocaleString('default', { month: 'short' }))
    let prevYear = date.getFullYear()
    date.setDate(date.getDate() + 6)
    let saturday = date.getDate()

    if (saturday < monday) {
        return `${zerofill(monday, 2)} ${prevMonth}-${zerofill(saturday, 2)} ${ucfirst(date.toLocaleString('default', { month: 'short' }))} ${prevYear}`
    }

    return `${zerofill(monday, 2)}-${zerofill(saturday, 2)} ${ucfirst(date.toLocaleString('default', { month: 'short' }))} ${date.getFullYear()}`
}

function getDayOfWeek(weekNo, day) {
    return getDateFromWeek(weekNo, day).getDate()
}

function getDateFromWeek(weekNo, day, year = null) {
    weekNo = Number(weekNo)
    if (isNaN(weekNo)) {
        return
    }

    day = Number(day)
    if (isNaN(day)) {
        return
    }

    let date = getDateOfISOWeek(weekNo, year)
    // dia seleccionado
    date.setDate(date.getDate() + day)

    //si tenemos fecha de cierre para ese día, se pone para la posterior comprobación
    if (typeof CLOSE_DATES[day + 1] != "undefined" && CLOSE_DATES[day + 1] != "") {
        date.setHours(...CLOSE_DATES[day + 1].close_hour.split(":"))
    }

    return date
}

function getRealWeek(weekNo) {
    return getDateOfISOWeek(weekNo).getWeek()
}

function changeWeek(week, year = null) {
    let date = getDateFromWeek(week, 0, year)
    $("#semana_label").html(date.getWeek());
    $("#semana_label").data('year', date.getFullYear());
    $("#selected_fecha").html(date.getWeek());
    $("#semana_date_label").html(getDateRangeOfWeek(week, year) + " <i class=\"fa fa-caret-down\"></i>");
    selectedWeek = week;

    let d1 = new Date();
    // let weekNoToday = d1.getWeek();
    let hasPreviousDay = false
    let formattedDate
    $("#semana").addClass("selected_day")
    dayNames.forEach((day, i) => {
        day = removeAccents(day)
        formattedDate = date.getFullYear() + '-' + zerofill(date.getMonth() + 1, 2) + '-' + zerofill(date.getDate(), 2)
        $("#" + day + "_day_number").html(date.getDate());
        $("#" + day).data("date", formattedDate).attr("data-date", formattedDate);

        if (gameRules.id_days.indexOf((i + 1).toString()) >= 0) {
            disableDaySelection(day)

            if (getDateFromWeek(week, i) > d1 && (CLOSE_DATES[i + 1] !== undefined || hasPreviousDay)) {
                if (PV_CALENDAR[formattedDate]) {
                    if (hasPreviousDay) {
                        enableDaySelection(day)
                    }
                    addHolydayToDaySelection(day, PV_CALENDAR[formattedDate], formattedDate)
                } else {
                    enableDaySelection(day)
                }
            }

        }

        if (!hasPreviousDay) {
            hasPreviousDay = $("#" + day).hasClass('pointer_a');
        }

        date.setDate(date.getDate() + 1)
    })

    comprobarPrecio();

    document.getElementById("dropdown_week").style.pointerEvents = "none";

    setTimeout((function () {
        document.getElementById("dropdown_week").style.pointerEvents = "auto";
    }), 500);
}

function addHolydayToDaySelection(day, text, date)
{
    $("#" + day).attr('onclick', `customAlert('No se pueden comprar boletos solo ese día por festivo: ${text}')`);
    $("#" + day).attr('title', text);
    $("#" + day).data('holyday', date);
}

function enableDaySelection(day)
{
    $("#" + day).removeClass('no_draw');
    $("#" + day).addClass('pointer_a');
    $("#" + day).addClass('selected_day');
    $("#" + day).removeClass('disabled_day');
}

function disableDaySelection(day)
{
    $("#" + day).prop('onclick', null);
    $("#" + day).removeAttr('title');
    $("#" + day).removeData('holyday');
    $("#" + day).addClass('no_draw');
    $("#" + day).removeClass('pointer_a');
    $("#" + day).removeClass('selected_day');
    $("#" + day).addClass('disabled_day');
}

function changeNumWeek(week) {
    let sem = "";
    if (week == 1) {
        sem = "Esta semana";
    } else if(week == "X") {
        sem = "Abono";
    } else {
        sem = week + " semanas";
    }

    if ($("#is_randomable_box").length) {
        if (week != 'X') {
            $("#is_randomable_box").addClass('d-none')
        } else {
            $("#is_randomable_box").removeClass('d-none')
        }
    }

    $("#abono_semanas").html(sem + " <i class=\"fa fa-caret-down\"></i>");
    $("#selected_abono").html(sem);
    $("#abono_semanas_button").data('sems', week);

    comprobarPrecio();

    document.getElementById("dropdown_abono").style.pointerEvents = "none";

    setTimeout((function () {
        document.getElementById("dropdown_abono").style.pointerEvents = "auto";
    }), 500);
}

function quitarRestoDeDiasALaSemana() {
    $('.div_day_semana').addClass('selected_day');
    $(".div_day_semana").trigger("click");
}

function prevApuestaResponsive() {
    let fisrtBet = Number($('#contenedorApuestas').children().first().attr("id").split('_')[1])
    if (actualApuesta == fisrtBet) {
        return
    }

    $("#apuesta_" + (actualApuesta)).addClass('hidden_responsive');
    actualApuesta -= 1;
    $("#apuesta_" + (actualApuesta)).removeClass('hidden_responsive');
}

function nextApuestaResponsive() {
    let lastBet = Number($('#contenedorApuestas').children().last().attr("id").split('_')[1])
    if (actualApuesta == lastBet) {
        return
    }

    $("#apuesta_" + (actualApuesta)).addClass('hidden_responsive');
    actualApuesta += 1;
    $("#apuesta_" + (actualApuesta)).removeClass('hidden_responsive');
}

function changeBoleto(boleto) {
    let apuesta;
    let completo = true;

    for (let i = boleto; i <= boletos.length; i++) {
        limpiarBoleto(i);
        apuesta = boletos[i];

        if (!apuesta || !apuesta["numeros"].length && $("#apuesta_" + i).hasClass("disabled_tabla")) {
            break
        }

        if (apuesta != null) {
            pintarBoleto(i, apuesta);
        }

        if (i > 1) {
            $("#apuesta_" + i).attr('style', 'opacity: 0.3');
            $("#apuesta_" + i).addClass('disabled_tabla');
            //mientras no hayamos encontrado uno incompleto, seguimos comprobando
            if (completo) {
                //si el anterior es completo, se habilita el siguiente, si no, usamos el bool para no comprobar más
                if (boletos[i - 1]["completo"]) {
                    habilitarBoleto(i);
                } else {
                    completo = false;
                }
            }
        }
    }

    comprobarPrecio();
}

function ocultarSobrantes() {
    let apuesta_rect;
    let contenedor_rect = contenedor_apuestas[0].getBoundingClientRect();

    for (let i = 0; i < apuestas.length; i++) {
        apuesta_rect = apuestas[i].getBoundingClientRect();
        if (apuesta_rect.right > contenedor_rect.right) {
            apuestas[i].classList.add("no_display");
        } else {
            apuestas[i].classList.remove("no_display");
            //truco, quitamos display none para que se pueda calcular su tamaño, si no cabe, se oculta de nuevo
            apuesta_rect = apuestas[i].getBoundingClientRect();
            if (apuesta_rect.right > contenedor_rect.right) {
                apuestas[i].classList.add("no_display");
            }
        }
    }
}

function limpiarBoleto(boleto) {
    $("#container_boleto_" + boleto + "_numeros").find('.selected').removeClass('selected')

    if ($("#container_boleto_" + boleto + "_extras").length) {
        $("#container_boleto_" + boleto + "_extras").find(".selected").removeClass("selected")
    }

    if ($("#container_boleto_" + boleto + "_refund").length) {
        $("#container_boleto_" + boleto + "_refund").find('.selected').removeClass('selected')
    }

    if ($("#apuesta_" + boleto + "_code_a").length) {
        $("#apuesta_" + boleto + "_code_a").removeClass('selected')
    }

    if ($("#apuesta_" + boleto + "_code_b").length) {
        $("#apuesta_" + boleto + "_code_b").removeClass('selected')
    }

    if ($("#container_boleto_" + boleto + "_numeros").find('.item_figure_code_a_selected').length) {
        $("#container_boleto_" + boleto + "_numeros").find('.item_figure_code_a_selected').removeClass('item_figure_code_a_selected')
    }

    $("#apuesta_" + boleto + "_btn_cambiar_multiple").text('Sencilla')
    $("#apuesta_" + boleto + "_btn_cambiar_multiple").removeClass('button_es_multiple')

    comprobarPrecio();
}

function printResults(resultados){
    var content = '';
    for(var i = 0; i<resultados.length; i++) {
        if(!resultados[i])
        {
            break;
        }
        var item = '<div class="col-12 col-lg-6 col-md-6 item_loteria_nacional">' +
        '<div class="row container_loteria_nacional">' +
        '<div class="pull-left image_box_loteria_nacional" style="max-width: 26%;">' +
        '<div class="image_loteria_nacional">' +
        '<img src="' + gameRules.logo + '" style="width: 52%">' +
        '</div>' +
        '</div>' +
        '<div class="pull-right-boleto numbers_box_loteria_nacional">' +
        '<div class="pull-left number_box_loteria_nacional">' +
        '<span class="span_loteria_nacional">Lotería Nacional</span>' +
        '<span class="span_number_loterial_nacional">' + resultados[i].number + '</span>' +
        '</div>' +
        '<div class="pull-right-boleto number_box_loteria_nacional">' +
        '<span class="span_cantidad_loteria_nacional">Cantidad</span>' +
        '<div class="input-group float-right position_width_initial margin_div_cantidad_loteria_nacional">' +
        '<span class="input-group-btn">' +
        '<button type="button" class="btn p-0 my-1 btn-number button_transparent" ' +
        'disabled="disabled" data-type="minus"' +
        'data-field="' + resultados[i].number + '"><i class="fa fa-minus-circle fa-2x" style="color: #D3D3D3"></i></button>' +
        '</span>' +
        '<input onchange="lotteryChangedSelectedQuantity()" oninput="checkQuantityLottery(event)" type="text" ' +
        'name="' + resultados[i].number + '" ' +
        'class="form-control input-number cantidad_cupones cantidad_loteria_nacional" value="0" ' +
        'min="0" max="' + resultados[i].available + '" size="2">' +
        '<span class="input-group-btn" id="plus-button-boletos">' +
        '<button type="button" class="btn p-0 my-1 btn-number button_transparent" '  +
        'data-type="plus" data-field="' + resultados[i].number + '"><i class="fa fa-plus-circle fa-2x" style="color: #D3D3D3"></i></button>' +
        '</span>' +
        '</div>' +
        '</div>' +
        '</div>' +
        (showAvailability ? (
            (showMinAvailability ? (
                (showMinAvailability > resultados[i].available) ? '<span class="badge rounded-pill bg-danger pill_availability_box_loteria_nacional">Queda'+(resultados[i].available > 1 ? 'n' : '' )+': ' + resultados[i].available + '</span>' : '') : ('<span class="badge rounded-pill bg-primary pill_availability_box_loteria_nacional">Queda'+(resultados[i].available > 1 ? 'n' : '' )+': ' + resultados[i].available + '</span>'))
        ) : '') +
        '</div>' +
        '</div>';
        content += item;
    }
    document.getElementById('boletos-container').innerHTML= content;
}

function removeOldTickets(){
    document.getElementById('boletos-container').innerHTML = '';
}

function setActivePage(pagina){
    pageLinks = document.getElementsByClassName('page_links');
    for(var i = 0; i<pageLinks.length; i++){
        if(pagina == pageLinks[i].textContent){
            pageLinks[i].classList.add('pagina_activa');
        }
    }
    document.getElementsByClassName('pagina_activa')[0].classList.remove('pagina_activa');
    document.getElementById('num_pagina_'+pagina).classList.add('pagina_activa');
}

function comprobarCompleto(id) {
    //ej. id 'apuesta_1_numero_45' o 2
    let bet
    if (typeof id == 'number') {
        bet = id
    } else {
        bet = Number(id.split('_')[1])
    }
    let numbers, extras

    switch (gameRules.id_type) {
        case 1:
            numbers = boletos[bet]["numeros"].length
            extras = boletos[bet]["extras"] ? boletos[bet]["extras"].length : 0
            break;
        case 2:
            let isMissingMatches = false
            // alomejor hay 20 resultados y el num_number_per_bet es 14 pero son multiples y no estan todos seleccionados
            boletos[bet]["numeros"].forEach(partido => {
                if (!partido.length) {
                    isMissingMatches = true
                }
            })
            if (isMissingMatches) {
                marcarIncompleto(bet);
                return
            }
            numbers = getNumSportNumbers(boletos[bet]["numeros"])
            extras = getNumSportNumbers(boletos[bet]["extras"])
            break;            
        default:
            numbers = boletos[bet]["numeros"].length
            extras = boletos[bet]["extras"] ? boletos[bet]["extras"].length : 0
            break;
    }

    if (numbers < gameRules.num_number_per_bet) {
        marcarIncompleto(bet);
        return
    }

    if (gameRules.num_max_extras_per_slip && extras < gameRules.num_extra_per_bet) {
        marcarIncompleto(bet);
        return
    }

    if (gameRules.is_num_refund && gameRules.is_num_refund_selectable && empty(boletos[bet]["refund"])) {
        marcarIncompleto(bet);
        return
    }

    if (gameRules.is_code_a && !gameRules.is_code_a_optional) {
        if (gameRules.is_code_a_selectable) {
            if (gameRules.is_code_a_per_slip) {
                if ((!CODE_A.length && gameRules.code != 'LQ') || (CODE_A.length != ELIGE_8 && gameRules.code == 'LQ')) {
                    marcarIncompleto(bet);
                    return
                }
            } else {
                if ((!boletos[bet]["code_a"].length && gameRules.code != 'LQ') || (boletos[bet]["code_a"].length != ELIGE_8 && gameRules.code == 'LQ')) {
                    marcarIncompleto(bet);
                    return
                }
            }
        } else {
            if (gameRules.is_code_a_per_slip) {
                if ($("#code_a").length && !$("#code_a").hasClass("selected")) {
                    marcarIncompleto(bet);
                    return
                }
            } else {
                if (!boletos[bet]["code_a"]) {
                    marcarIncompleto(bet);
                    return
                }
            }
        }
    }

    if (gameRules.is_code_b && !gameRules.is_code_b_optional) {
        if (gameRules.is_code_b_selectable) {
            if (gameRules.is_code_b_per_slip) {
                if (!CODE_B.length) {
                    marcarIncompleto(bet);
                    return
                }
            } else {
                if (!boletos[bet]["code_b"].length) {
                    marcarIncompleto(bet);
                    return
                }
            }
        } else {
            if (gameRules.is_code_b_per_slip) {
                if ($("#code_b").length && !$("#code_b").hasClass("selected")) {
                    marcarIncompleto(bet);
                    return
                }
            } else {
                if (!boletos[bet]["code_b"]) {
                    marcarIncompleto(bet);
                    return
                }
            }
        }
    }

    boletos[bet]["completo"] = true;

    if (bet == boletos.length - 1) {
        crearDivApuesta();
    } else {
        habilitarBoleto(bet + 1);
    }
    return true
}

function marcarIncompleto(ap) {
    //marcamos como incompleto
    boletos[ap]["completo"] = false;

    //deshabilitamos siguientes
    if (ap != boletos.length && !boletos[ap]["completo"]) {
        apAux = ap;
        while (apAux < boletos.length) {
            $("#apuesta_" + (apAux + 1)).attr('style', 'opacity: 0.3');
            $("#apuesta_" + (apAux + 1)).addClass('disabled_tabla');

            apAux++;
        }
    }
}

function getQuinielaItemPrice(item, num_days = 1) {
    let price_bet = parseFloat(gameRules['price']);
    let num_bets = getQuinielaNumBets(item);
    if (!num_bets) {
        return customAlert('No se ha podido calcular el número de apuestas totales del boleto');
    }

    let total = num_bets * price_bet;
    let code_price

    // Código A: Obligatorio o si es opcional viene rellenado
    if (!gameRules['is_code_a_optional'] || (Array.isArray(item["code_a"]) && item["code_a"].length == ELIGE_8)) {
        // Si supone coste adicional miramos si es por boleto o apuesta
        code_price = parseFloat(gameRules['code_a_price']);
        if (code_price > 0) {
            total_code = gameRules['is_code_a_per_slip'] ? code_price: num_bets * code_price;

            if (gameRules['is_code_a_selectable']) {
                total_code *= getQuinielaNumBetsCode(item, item["code_a"]);
            }

            total += total_code;
        }
    }

    // Código B
    if (!gameRules['is_code_b_optional'] || (Array.isArray(item["code_b"]) && item["code_b"].length)) {
        // Si supone coste adicional miramos si es por boleto o apuesta
        code_price = parseFloat(gameRules['code_b_price']);
        if (code_price > 0) {
            total_code = gameRules['is_code_b_per_slip'] ? code_price: num_bets * code_price;

            if (gameRules['is_code_b_selectable']) {
                total_code *= getQuinielaNumBetsCode(item, item["code_a"]);
            }

            total += total_code;
        }
    }

    return total * num_days;
}

function getQuinielaNumBets(slip) {
    // Apuesta múltiple
    if (slip["tipo"] == 'multiple') {
        switch (gameRules['id_type']) {
            case 2:
                let num_bets = 1;
                if ((slip['numeros']) && Array.isArray(slip['numeros']) && (slip['numeros'][0]) && Array.isArray(slip['numeros'][0])) {
                    slip['numeros'].forEach(bet => {
                        num_bets *= bet.length;
                    })

                    if ((gameRules['num_extra_per_bet']) && (slip['extras']) && Array.isArray(slip['extras']) && (slip['extras'][0]) && Array.isArray(slip['extras'][0])) {
                        slip['extras'].forEach(extra => {
                            num_bets *= extra.length;
                        })
                    }
                }

                return num_bets;
                break;

            case 1:
                let t_numbers = 1;
                if ((slip['numeros']) && Array.isArray(slip['numeros']) && (slip['numeros'][0]) && Array.isArray(slip['numeros'][0])) {
                    t_numbers = getQuinielaCombinatoria(slip['numeros'][0].length, gameRules['num_number_per_bet']);

                    if (!empty(gameRules['num_extra_per_bet'])) {
                        let t_extras        = getQuinielaCombinatoria(slip['extras'][0].length, gameRules['num_extra_per_bet']);

                        // combinaciones
                        return t_numbers * t_extras;
                    }
                }

                return t_numbers;
                break;
        }
    }

    return 1;
}

function getQuinielaCombinatoria(m, n)
{
    if (m == n) {
        return 1;
    }

    return factorial(m) / (factorial(n) * factorial(m - n));
}

function getQuinielaNumBetsCode(slip, code)
{
    // Apuesta múltiple
    if (slip["tipo"] == 'multiple') {
        switch (gameRules['id_type']) {
            case 2:
                let num_bets = 1;
                if ((code) && (slip['numeros'][0]) && Array.isArray(slip['numeros'][0])) {
                    code.forEach(($v, $k) => {
                        if ((slip['numeros'][$v-1])) {
                            num_bets *= slip['numeros'][$v-1].length;
                        }
                    })
                }

                return num_bets;
                break;
        }
    }

    return 1;
}