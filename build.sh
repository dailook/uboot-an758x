#!/bin/sh
cd "$(dirname "$0")"
. ./setenv.sh
exec ./scripts/build-an758x.sh "$@"
