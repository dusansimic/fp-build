#!/bin/bash
#
# Copyright © 2024 Dušan Simić <dusan.simic1810@gmail.com>
# Copyright © 2021 Lionir
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation;
# version 2.1 of the License.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library. If not, see <https://www.gnu.org/licenses/>.
#

_help_print() {
    echo "usage: $(basename "$0") [options] <manifest file>"
    echo ""
    echo "  -X <dir>, --xdg-cache <dir>  xdg cache directory (default: ~/.cache)"
    echo "  -fc <command>, --flatpak-command <command>  command to execute flatpak builder default: flatpak run org.flatpak.Builder)"
    echo ""
    echo "  -S, --system  run flatpak builder in system mode"
    echo "  -U, --user    run flatpak builder in user mode"
    echo "  -h, --help    show this page"
}

if [ "$#" -lt 1 ]
then
	echo "incorret use!"
	_help_print
	exit 1
fi

XDG_CACHE_HOME="$HOME/.cache"
FLATPAK_BUILDER="flatpak run org.flatpak.Builder"

while [ "$#" -gt 1 ]
do
    if [ "$1" = "-S" -o "$1" = "--system" ]
    then
        BUILDER_MODE="--system"
        shift
    elif [ "$1" = "-U" -o "$1" = "--user" ]
    then
        BUILDER_MODE="--user"
        shift
    elif [ "$1" = "-X" -o "$1" = "--xdg-cache" ]
    then
        shift
        if [ -z "$1" ]
        then
            echo "xdg cache directory is not specified!"
            _help_print
            exit 1
        fi
        XDG_CACHE_HOME="$1"
        shift
    elif [ "$1" = "-fc" -o "$1" = "--flatpak-command" ]
    then
        shift
        if [ -z "$1" ]
        then
            echo "flatpak builder command not specified!"
        _help_print
        exit 1
        fi
        FLATPAK_BUILDER="$1"
        shift
    elif [ "$1" = "-h" -o "$1" = "--help" ]
    then
        _help_print
        exit 0
    fi
done

if [ ! -e "$1" ]
then
    echo "manifest doesn't exist!"
    exit 1
fi

if ! $FLATPAK_BUILDER \
    $BUILDER_MODE \
    --download-only --no-shallow-clone \
    --force-clean --allow-missing-runtimes \
    --ccache \
    --state-dir="$XDG_CACHE_HOME/flatpak-builder" \
    "$XDG_CACHE_HOME/flatpak-builder-builddir/${1%.*}" "$1"
then
    echo "Download failed!" >&2
    exit 1
fi

if ! $FLATPAK_BUILDER \
    $BUILDER_MODE \
    --verbose --sandbox \
    --bundle-sources --force-clean --ccache \
    --install-deps-from=flathub \
    --default-branch=localtest \
    --state-dir="$XDG_CACHE_HOME/flatpak-builder" \
    --extra-sources="$XDG_CACHE_HOME/flatpak-builder/downloads" \
    "$XDG_CACHE_HOME/flatpak-builder-builddir/${1%.*}" "$1"
then
    echo "Build failed!" >&2
    exit 1
fi

if ! $FLATPAK_BUILDER \
    $BUILDER_MODE \
    --install --force-clean \
    --repo="$XDG_CACHE_HOME/flatpak-builder-repo/" \
    --default-branch=localtest \
    --state-dir="$XDG_CACHE_HOME/flatpak-builder" \
    "$XDG_CACHE_HOME/flatpak-builder-builddir/${1%.*}" "$1"
then
    echo "Committing or install failed" >&2
    exit 1
fi

flathub_json=$(dirname "$1")/flathub.json

if zgrep -q "<id>${1%.*}\(\.\w\+\)*\(.desktop\)\?</id>" "$XDG_CACHE_HOME/flatpak-builder-builddir/${1%.*}/files/share/app-info/xmls/${1%.*}.xml.gz"
then
    echo "---"
    echo "AppID check.. passed!"
else
    echo "---"
    echo "AppID check.. failed!" >&2
fi

if [ -e "$flathub_json" ] && python3 -c 'import sys, json; sys.exit(not json.load(sys.stdin).get("skip-icons-check", False))' < "$flathub_json"
then
    echo "Skipping icon check.."
else
    if zgrep "<icon type=\\'remote\\'>" "$XDG_CACHE_HOME/flatpak-builder-builddir/${1%.*}/files/share/app-info/xmls/${1%.*}.xml.gz" || test -f "$XDG_CACHE_HOME/flatpak-builder-builddir/${1%.*}/files/share/app-info/icons/flatpak/128x128/${1%.*}.png"
    then
        echo "128x128 icon check.. passed!"
    else
        echo "128x128 icon check.. failed!" >&2
    fi
fi

if [ -e "$flathub_json" ] && python3 -c 'import sys, json; sys.exit(not json.load(sys.stdin).get("skip-appstream-check", False))' < "$flathub_json"
then
    echo "Skipping Appstream check"
    echo "---"
else
    echo "Appstream check"
    flatpak run org.freedesktop.appstream-glib validate "$XDG_CACHE_HOME/flatpak-builder-builddir/${1%.*}/files/share/appdata/${1%.*}.appdata.xml"
    echo "---"
fi
