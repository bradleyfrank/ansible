#!/usr/bin/env python3

import json
import sys
import platform
import distro

hostname = getattr(platform.uname(), "node")
distro_name = distro.id().capitalize()

inventory = {
  "_meta": {
    "hostvars": {
      hostname: {
        "ansible_connection": "local"
      }
    }
  },
  distro_name: {
    "hosts": [hostname],
  },
}

if distro_like := distro.like().capitalize():
  inventory[distro_like] = { "hosts": [hostname] }

if __name__ == "__main__":
  try:
    flag = sys.argv[1]
  except IndexError:
    sys.exit(1)

  print(json.dumps(inventory)) if flag == "--list" else print(json.dumps({}))
