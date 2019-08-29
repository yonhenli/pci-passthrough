#!/bin/bash

# Check the migration status.
if [[ $# != 1 ]]; then
  echo "Usage: $0 <SOCKET>"
  exit 1
fi
socket=$1

echo '{"execute": "qmp_capabilities"} {"execute": "query-migrate"}' | nc -U "${socket}"
