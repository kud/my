# index

## disable SIP

- cmd + r on Apple logo
- Utilities > Terminal
- `$ csrutil enable --without fs`
- restart

## disable AutoBoot

- disable

```
$ sudo nvram AutoBoot=%00
```

- enable

```
$ sudo nvram AutoBoot=%03
```

## sips

scriptable image processing system.

```
$ sips -Z 640 *.jpg
```

## change images

```
$ mogrify -format jpg --quality 85 *.{png,gif,svg} && rm -rf *.{png,gif,svg} && sips -Z 256 *.jpg && imagemin *.jpg --outdir=build
```

## add "anywhere" to "allow apps downloaded from"

```
$ sudo spctl --master-disable
```
