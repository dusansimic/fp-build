#!/bin/bash
set -e

curl https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64 --create-dirs --output "/usr/local/bin/jq"
curl https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 --create-dirs --output "/usr/local/bin/yq"
curl https://raw.githubusercontent.com/dusansimic/fp-build/main/fp-build.sh --create-dirs --output "/usr/local/bin/fp-build"
chmod u=rwx,g=rx,o=rx /usr/local/bin/jq /usr/local/bin/yq /usr/local/bin/fp-build
