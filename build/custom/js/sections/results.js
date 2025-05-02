function enabledDay(date) {
    let datestring = dateToYMD(date)

    if (available_dates.includes(datestring)) {
        return [true]
    }

    return [false]
}

function seePrizes() {
    /*let key = $("#button_see_prizes").data('key')*/
    let key = $("#date").val();

    $("#collapse" + key).collapse('show')

    location.href = "#anchor" + key
}

function triggerCalendar() {
    if ($("#date").attr('type') == "text") {
        $("#date").datepicker("show")
    }
}
