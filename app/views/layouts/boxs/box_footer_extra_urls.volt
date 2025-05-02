<h3>Acerca de</h3>
<ul>
    <li>
        <a href="{{ url('contacto') }}">Contacto</a>
    </li>
    <li>
        <a href="{{ url('quienes-somos') }}">Quienes Somos</a>
    </li>
    {% if datosAdmon.is_blog %}
    <li>
        <a href="{{datosAdmon.url.blog}}">Blog</a>
    </li>
    {% endif %}
</ul>
<h3>Legal</h3>
<ul>
    <li>
        <a href="{{ url('aviso-legal') }}">Aviso Legal</a>
    </li>
    <li>
        <a href="{{ url('politica-de-cookies') }}">Política de Cookies</a>
    </li>
    <li>
        <a href="{{ url('politica-privacidad') }}">Política de Privacidad</a>
    </li>
</ul>