# DNSCrypt-Proxy

Recommended configuration snippet:

```toml
server_names = ['rethinkdns-doh', 'rethinkdns-doh-max']

[static]
  [static.'rethinkdns-doh']
    stamp = 'sdns://AgYAAAAAAAAAACBdzvEcz84tL6QcR78t69kc0nufblyYal5di10An6SyUBJza3kucmV0aGlua2Rucy5jb20KL2Rucy1xdWVyeQ'

  [static.'rethinkdns-doh-max']
    stamp = 'sdns://AgYAAAAAAAAAACCaOjT3J965vKUQA9nOnDn48n3ZxSQpAcK6saROY1oCGRJtYXgucmV0aGlua2Rucy5jb20KL2Rucy1xdWVyeQ'
```

Set Wi-Fi DNS:
```
sudo networksetup -setdnsservers "Wi-Fi" 127.0.0.1
```
