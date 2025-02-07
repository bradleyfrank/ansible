#!/usr/bin/env python3

import json
import sys
import platform
import distro

hostname = getattr(platform.uname(), "node")

inventory = {
  "_meta": {
    "hostvars": {}
  },
  "all": {
    "hosts": [hostname],
    "children": {
      distro.name(): {
        "hosts": [hostname]
      }
    },
    "vars": {
      "ansible_connection": "local"
    }
  }
}

if __name__ == "__main__":
  try:
    flag = sys.argv[1]
  except IndexError:
    sys.exit(1)

  print(json.dumps(inventory)) if flag == "--list" else print(json.dumps({}))
