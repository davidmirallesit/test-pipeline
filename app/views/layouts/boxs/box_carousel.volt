{% if config.datosadmon.data.media.carousel is defined %}
<div id="carouselExampleIndicators" class="carousel slide" data-ride="carousel">
    <ol class="carousel-indicators">
        {% for k, car in config.datosadmon.data.media.carousel %}
        <li data-target="#carouselExampleIndicators" data-slide-to="{{k}}"{% if loop.first %} class="active"{% endif %}></li>
        {% endfor %}
    </ol>
    <div class="carousel-inner">
        {% for k, car in config.datosadmon.data.media.carousel %}
        <div class="carousel-item{% if loop.first %} active{% endif %}">
            {% if car.lnk is defined and car.lnk != '' %}
            <a href="{{car.lnk}}">
            {% endif %}
            {% if check_remote_file(car.img) %}
                <img class="d-block w-100" src="{{car.img}}">
            {% endif %}
            <div class="carousel-caption d-none d-md-block">
                <h2 class="bg-azulclaro d-table mx-auto text-azul">{{car.txt|default('')}}</h2>
            </div>
            {% if car.lnk is defined and car.lnk != '' %}
            </a>
            {% endif %}
        </div>
        {% endfor %}
    </div>
{#
    <a class="carousel-control-prev" href="#carouselBotones" role="button" data-slide="prev">
        <span class="carousel-control-prev-icon" aria-hidden="true"></span>
        <span class="sr-only">Previous</span>
    </a>
    <a class="carousel-control-next" href="#carouselBotones" role="button" data-slide="next">
        <span class="carousel-control-next-icon" aria-hidden="true"></span>
        <span class="sr-only">Next</span>
    </a>
#}
</div>
{% endif %}
