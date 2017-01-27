# postinstall

## SIP

Disable or not SIP:

- cmd + r on Apple logo
- Utilities > Terminal
- `$ csrutil disable`
- restart

## firefox

- `$ £ firefox-settings`
- Enter sync account
- Redefine GUI

## screensaver

- Download and install: http://littleendiangamestudios.com/project/ios-8-screen-saver/

# SSH

- Add this at the beggining of `~/.ssh/config`:

```
# jumper
Host *+*
ProxyCommand ssh $(echo %h | sed 's/+[^+]*$//;s/\([^+%%]*\)%%\([^+]*\)$/\2 -l \1/;s/:/ -p /') nc -w1 $(echo %h | sed 's/^.*+//;/:/!s/$/ %p/;s/:/ /')
```

- [Add SSH for GitHub](https://help.github.com/articles/connecting-to-github-with-ssh/
