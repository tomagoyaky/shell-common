#!/bin/bash
clear
CURRENT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
shell_name="mem0"
#################################################
source "${CURRENT}/common.sh" $shell_name
source "${CURRENT}/docker.common.sh"
source "${CURRENT}/python.common.sh"
#################################################

log_info "OK"