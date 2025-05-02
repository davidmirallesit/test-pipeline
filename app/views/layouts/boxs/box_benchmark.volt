<pre class="m-3 border rounded p-3" style="background-color: #ddd">
<h1 class="text-center">BENCHMARK ENABLED</h1>
{% if benchmark_times is defined and benchmark_times is iterable %}
<h1 class="border-secondary border-top border-bottom">TIMES</h1>
{% for time in benchmark_times %}
{{ str_repeat('    ', time['level']) }}{{time['name']}}: {{time['time']|number_float}} sec.
{% endfor %}
{% endif %}
{% if benchmark_mem is defined %}
<h1 class="mt-3 border-secondary border-top border-bottom">MEMORY</h1>
{{ benchmark_mem }}
{% endif %}
{% if benchmark_content_length is defined %}
<h1 class="mt-3 border-secondary border-top border-bottom">SIZE</h1>
{{ benchmark_content_length }}
{% endif %}
</pre>
