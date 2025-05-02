<div class="{{class}}">
    <div class="row">
        <a href="{{draw_url ~ search_url ~ config['search_urls']['fullNumber'] ~ number}}">
            <img class="decimo" src="{{img}}" style="box-shadow: 0px -1px 3px rgb(0 0 0 / 20%); max-width: unset;">
        </a>
        <div class="inputParticipaciones d-flex justify-content-center tail-number-text">
            <div class="text-center font-numlae tail-number-text-size">{{number}}</div>
        </div>
        {% if show_availability | abs %}
            {% if (show_min_availability | abs) %}
                {% if (show_min_availability | abs) > stock %}
                    <span class="badge rounded-pill bg-danger pill_availability_box_searcher_tail_number">Queda{% if stock > 1 %}n{% endif %}: {{ stock }}</span>                                                        
                {% endif %}
            {% else %}
                <span class="badge rounded-pill bg-primary pill_availability_box_searcher_tail_number">Queda{% if stock > 1 %}n{% endif %}: {{ stock }}</span>
            {% endif %}
        {% endif %}
    </div>
    <div class="row bloque_azulClaro pt-1 justify-content-center" style="border-bottom-left-radius: 1rem; border-bottom-right-radius: 1rem;">
        <div class="col-12">
            <div class="input-group position_width_initial">
                <span class="input-group-btn">
                    <button id="restar-{{number}}" data-number="{{number}}" type="button" class="btn p-0 my-1 btn-number button_transparent" disabled="disabled" data-type="minus"><i class="fa fa-minus-circle fa-2x" style="color: #D3D3D3"></i></button>
                </span>
                <input
                    id="quantity-{{number}}"
                    data-number="{{number}}"
                    type="text"
                    name="{{number}}"
                    class="form-control input-number cantidad_cupones cantidad_loteria_nacional mx-2"
                    value="{% if !array_key_exists(number, stockInCart) %}0{% else %}{{stockInCart[number]}}{% endif %}"
                    min="0"
                    max="{{stock}}"
                    size="2"
                    autocomplete="off"
                >
                <span class="input-group-btn">
                    <button id="sumar-{{number}}" data-number="{{number}}" type="button" class="btn p-0 my-1 btn-number button_transparent" data-type="plus"><i class="fa fa-plus-circle fa-2x" style="color: #D3D3D3"></i></button>
                </span>
            </div>
        </div>
    </div>
</div>
