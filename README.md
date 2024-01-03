# fp-build

> [!WARNING]
> This script is a modified version of the original script developed by
> [Lionir](https://github.com/lionirdeadman/fp-build). I've modified it to contain a few more
> features (options) and be more suited for use with Flatpak Builder that's packaged as a flatpak
> package.

This script tries to reproduce as much as possible of the flathub checks and flags used in
flatpak-builder as to avoid pushing and then realizing that something was wrong.

The script takes options and a required argument which is a path to a flatpak manifest file. It
expects it to be properly formatted (`com.my.App`) and with an appropriate extension (json, yaml,
yml).

```
usage: fp-build.sh [options] <manifest file>

  -X <dir>, --xdg-cache <dir>  xdg cache directory (default: ~/.cache)
  -fc <command>, --flatpak-command <command>  command to execute flatpak builder default: flatpak run org.flatpak.Builder)

  -S, --system  run flatpak builder in system mode
  -U, --user    run flatpak builder in user mode
  -h, --help    show this page
```

# Authors

Original author of this script is [Lionir](https://github.com/lionirdeadman/fp-build) but I wanted
to add some changes which I considered are very opinionated. I might push some of those changes back
upstream but since `fp-build` is not an official tool, I doubt it.

# License

LGPLv2.1
