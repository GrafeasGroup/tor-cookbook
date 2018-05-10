Tor Cookbook
============

Installs/Configures tor

Requirements
------------

### Platform:

* Centos (>= 7.3)

### Cookbooks:

* yum-ius (~> 2.2.0)

Attributes
----------

### `node['tor']['archivist_revision']`

Git commit SHA (or branch, or tag) which should be deployed for the `tor_archivist` project

### `node['tor']['core_revision']`

Git commit SHA (or branch, or tag) which should be deployed for the `tor_core` project

### `node['tor']['ocr_revision']`

Git commit SHA (or branch, or tag) which should be deployed for the `tor_ocr` project

### `node['tor']['tor_revision']`

Git commit SHA (or branch, or tag) which should be deployed for the `tor` project

Recipes
-------

### tor::default

Install ALL the things!

### tor::python

Installs/Configures python3, pip, and virtualenv

### tor::redis

Installs/Configures Redis server

### tor::app

Installs/Configures Redis server


License and Author
------------------

Author:: David Alexander (<opensource@thelonelyghost.com>)

Copyright:: 2017, Grafeas Group, Ltd.

License:: MIT

