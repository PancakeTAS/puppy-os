#!/usr/bin/env bash
set -euo pipefail

if [ -f .env ]; then
    source .env
fi

case "$1" in
    prepare)
        shift
        scripts/do_prepare.sh "$@"
        ;;
    build)
        shift
        scripts/do_build.sh "$@"
        ;;
    update)
        shift
        scripts/do_update.sh "$@"
        ;;
    *)
        echo "Usage: $0 {prepare|build|update} [additional args]"
        exit 1
        ;;
esac
