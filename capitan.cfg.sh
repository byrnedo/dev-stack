#!/bin/bash
set -euo pipefail

# everything starts at prod
source "./environment/prod"

# if an argument was given source that environment file
[ $# -gt 0 ] && [ -n "$1" ] && source "./environment/$1"

# sets the project prefix to environment name
echo "global project $ENVIRONMENT"

bash ./discovery/capitan.cfg.sh
bash ./infra/capitan.cfg.sh
