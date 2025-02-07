#! /usr/bin/env sh

if [ "$1" == "--list" ]; then
  echo '{"all":{"hosts":["'$(uname --nodename)'"],"vars":{"ansible_connection":"local"}}}'
elif [ "$1" == "--host" ]; then
  echo '{"_meta": {hostvars": {"ansible_connection": "local"}}}'
else
  echo "{}"
fi
