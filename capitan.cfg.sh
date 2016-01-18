#!/bin/bash

# everything starts at prod
source "./environment/prod"

[ -n "$1" ] && source "./environment/$1"

echo "global project $ENVIRONMENT"

bash ./discovery/capitan.cfg.sh
bash ./infra/capitan.cfg.sh
