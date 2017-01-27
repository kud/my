# SSH

Add this at the beggining of `~/.ssh/config`:

```
# jumper
Host *+*
ProxyCommand ssh $(echo %h | sed 's/+[^+]*$//;s/\([^+%%]*\)%%\([^+]*\)$/\2 -l \1/;s/:/ -p /') nc -w1 $(echo %h | sed 's/^.*+//;/:/!s/$/ %p/;s/:/ /')
```
