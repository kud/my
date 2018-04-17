# index

## disable SIP

- cmd + r on Apple logo
- Utilities > Terminal
- `$ csrutil disable`
- restart

## sips

scriptable image processing system.

```
$ sips -Z 640 *.jpg
```

## change images

```
$ mogrify -format jpg --quality 85 *.{png,gif,svg} && rm -rf *.{png,gif,svg} && sips -Z 256 *.jpg && imagemin *.jpg --outdir=build
```
