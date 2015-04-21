# nginx

- alias:

http://nginx.org/en/docs/http/ngx_http_core_module.html#alias

ex:

```
  location ^~ /mount/player/ {
    alias /vagrant/libjs-player/dist/;
  }
```
