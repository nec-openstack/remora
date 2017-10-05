#!/usr/bin/env bash

set -eu
export LC_ALL=C

ROOT=$(dirname "${BASH_SOURCE}")

bash ${ROOT}/../gen-cert-ca.sh
