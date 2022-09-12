#!/bin/bash
set -e
if [ "$1" = 'nova' ]; then
    echo "Starting NOVA server...."
    ./start_nova.sh
fi
exec "$@"
