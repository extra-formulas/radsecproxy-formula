{%- set default_sources = {'module' : 'radsecproxy', 'defaults' : True, 'pillar' : True, 'grains' : ['os_family']} %}
{%- from "radsecproxy/defaults/load_config.jinja" import config as radsec with context %}

{%- if radsec.use is defined %}

{%- if radsec.use | to_bool %}

radsecproxy_package:
  pkg.installed:
    - name: {{ radsec.package_name }}

{{ radsec.conf_file }}:
  file.managed:
    - source: salt://radsecproxy/radsecproxy.conf.jinja
    - template: jinja
    - context: {{ radsec }}
    - makedirs: True
    - require:
      - radsecproxy_package

radsecproxy_service:
  service.running:
    - name: {{ radsec.service_name }}
    - enable: True
    - require:
      - file: {{ radsec.conf_file }}
    - watch:
      - file: {{ radsec.conf_file }}

{%- if radsec.cert_ca is defined and (radsec.cert_ca is not none) %}
{{ radsec.cert_dir + radsec.ca_relative_dir + radsec.cert_ca.file_name }}:
  file.managed:
    - contents: |
        {{ radsec.cert_ca.content | indent(8) }}
{%- if radsec.cert_ca.mode is defined and (radsec.cert_ca.mode is not none) %}
    - mode: {{ radsec.cert_ca.mode }}
{%- endif %}
    - user: {{ radsec.user_name }}
    - group: {{ radsec.group_name }}
    - makedirs: True
    - require_in:
      - file: {{ radsec.conf_file }}
    - watch_in:
      - service: {{ radsec.service_name }}
{%- endif %}

{%- if radsec.cert_pub is defined and (radsec.cert_pub is not none) %}
{{ radsec.cert_dir + radsec.cert_pub.file_name }}:
  file.managed:
    - contents: |
        {{ radsec.cert_pub.content | indent(8) }}
{%- if radsec.cert_pub.mode is defined and (radsec.cert_pub.mode is not none) %}
    - mode: {{ radsec.cert_pub.mode }}
{%- endif %}
    - user: {{ radsec.user_name }}
    - group: {{ radsec.group_name }}
    - makedirs: True
    - require_in:
      - file: {{ radsec.conf_file }}
    - watch_in:
      - service: {{ radsec.service_name }}
{%- endif %}

{%- if radsec.cert_key is defined and (radsec.cert_key is not none) %}
{{ radsec.cert_dir + radsec.cert_key.file_name }}:
  file.managed:
    - contents: |
        {{ radsec.cert_key.content | indent(8) }}
{%- if radsec.cert_key.mode is defined and (radsec.cert_key.mode is not none) %}
    - mode: {{ radsec.cert_key.mode }}
{%- endif %}
    - user: {{ radsec.user_name }}
    - group: {{ radsec.group_name }}
    - makedirs: True
    - require_in:
      - file: {{ radsec.conf_file }}
    - watch_in:
      - service: {{ radsec.service_name }}
{%- endif %}


{%- else %}

# Uninstall stuff goes here

{%- endif %}

{%- endif %}






