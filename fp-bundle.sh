#!/bin/bash
#
# Copyright © 2024 Dušan Simić <dusan.simic1810@gmail.com>
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

RUNTIME_REPO="https://flathub.org/repo/flathub.flatpakrepo"
BUNDLE_ARCH="x86_64"
XDG_CACHE_HOME="$HOME/.cache"

_help_print() {
    echo "usage: $(basename "$0") [options] <manifest file> <branch>"
    echo ""
    echo "  -R <repo>, --runtime-repo <repo>   flatpakrepo file of runtime packages (default: $RUNTIME_REPO)"
    echo "  -A <arch>, --arch <arch>           architecture of the bundle (default: $BUNDLE_ARCH)"
    echo "  -X <dir>, --xdg-cache <dir>  xdg cache directory (default: $XDG_CACHE_HOME)"
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

while [ "$#" -gt 2 ]
do
  if [ "$1" = "-S" -o "$1" = "--system" ]
  then
    BUILDER_MODE="--system"
    shift
  elif [ "$1" = "-U" -o "$1" = "--user" ]
  then
    BUILDER_MODE="--user"
    shift
  elif [ "$1" = "-R" -o "$1" = "--runtime-repo" ]
  then
    shift
    if [ -z "$1" ]
    then
      echo "runtime repo not specified!"
      _help_print
      exit 1
    fi
    RUNTIME_REPO="$1"
    shift
  elif [ "$1" = "-A" -o "$1" = "--arch" ]
  then
    shift
    if [ -z "$1" ]
    then
      echo "bundle arch not specified!"
      _help_print
      exit 1
    fi
    BUNDLE_ARCH="$1"
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

MANIFEST="$1"
shift

if [ -z "$1" ]
then
    echo "branch not specified!"
    exit 1
fi

BRANCH="$1"
shift

FLATPAK_ID="$(yq -r '."app-id"' $MANIFEST)"

echo "Bundling..."
if ! flatpak \
  $BUILDER_MODE \
  build-bundle \
  "$XDG_CACHE_HOME/flatpak-builder-repo/" \
  "$FLATPAK_ID.flatpak" \
  --runtime-repo=$RUNTIME_REPO \
  --arch=$BUNDLE_ARCH \
  "$FLATPAK_ID" "$BRANCH"
then
  echo "Bundle failed!" >&2
  exit 1
fi
