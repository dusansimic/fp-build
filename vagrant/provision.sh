#!/bin/bash
set -e

curl https://raw.githubusercontent.com/dusansimic/fp-build/main/fp-build.sh --create-dirs --output "/usr/local/bin/fp-build"
chmod u=rwx,g=rx,o=rx /usr/local/bin/fp-build
