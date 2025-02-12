#!/usr/bin/env bash

vault="$(op vault list --format json 2>/dev/null \
  | jq -r '.[]|.name' \
  | grep -Eo '(Employee|Private)'
)"

op read "op://${vault}/$(uname -n)/${SSH_ASKPASS_KEY}" 2>/dev/null
