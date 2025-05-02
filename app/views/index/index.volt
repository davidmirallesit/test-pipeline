<section class="container my-4">
    <div class="row">
        <div class="col-12 text-center">
            <h1 class="text-center">{{web_seo_onpage['h1']}}</h1>
        </div>
        {% if web_seo_onpage['txt_up'] is not empty %}
            <div class="col-12 text-center text-justify">
                <div>{{web_seo_onpage['txt_up']}}</div>
            </div>
        {% endif %}
    </div>
    <div class="row">
        <div class="col-12 {% if datosAdmon.mods.mod_featured_jackpots_enabled is not defined or (datosAdmon.mods.mod_featured_jackpots_enabled is defined and datosAdmon.mods.mod_featured_jackpots_enabled) %}col-lg-8{% endif %}">
            {% include 'layouts/boxs/box_featured_ln.volt' %}
            {% include 'layouts/boxs/box_ja_register.volt' %}

            {% if datosAdmon is defined and datosAdmon.pages is defined and (datosAdmon.pages.header or datosAdmon.pages.presentacion.title or datosAdmon.pages.presentacion.text) %}
                <div class="mt-0 blog-post">
                    {% if datosAdmon.pages.header is defined %}
                        <div class="feature-inner">
                            <a class="lightbox"><img src="{{datosAdmon.pages.header}}" alt="" /></a>
                        </div>
                    {% endif %}
                    {% if datosAdmon.pages.presentacion is defined %}
                    <div class="post-content p-4">
                        <h3 class="post-title width_height_100">
                            {{datosAdmon.pages.presentacion.title|default('')}}
                        </h3>
                        <div class="style_white_space">
                            {{datosAdmon.pages.presentacion.text|default('')}}
                        </div>
                    </div>
                    {% endif %}
                </div>
            {% endif %}
        </div>
        {% if datosAdmon.mods.mod_featured_jackpots_enabled is not defined or (datosAdmon.mods.mod_featured_jackpots_enabled is defined and datosAdmon.mods.mod_featured_jackpots_enabled) %}
            <aside id="sidebar" class="col-12 col-lg-4 left-sidebar order-lg-first">
                {% include 'layouts/boxs/box_jackpots.volt' %}
            </aside>
        {% endif %}

    </div>
    <div class="row">
        {% if web_seo_onpage['txt_down'] is not empty %}
            <div class="col-12 text-center text-justify">
                <div>{{web_seo_onpage['txt_down']}}</div>
            </div>
        {% endif %}
    </div>
</section>
{% if datosAdmon.mods.mod_featured_jackpots_enabled is not defined or (datosAdmon.mods.mod_featured_jackpots_enabled is defined and datosAdmon.mods.mod_featured_jackpots_enabled) %}
<script>
    window.addEventListener("load", function(event) {
        {% for id, date in close_dates %}
            showRemaining(
                "{{date}}",
                "countdown_{{id}}",
                false,
                null,
                true
            );
        {% endfor %}
    });
</script>
{% endif %}