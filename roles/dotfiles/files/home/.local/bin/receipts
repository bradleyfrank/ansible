#!/usr/bin/env python3

import locale
import sys
from decimal import Decimal
from datetime import datetime
from operator import itemgetter
from pathlib import PosixPath

locale.setlocale(locale.LC_ALL, '')
total_cost = Decimal("0.00")

ls = PosixPath.cwd().glob("**/*")
receipts = [file.name.split(".") for file in ls if (file.is_file() and file.name[0] != ".")]
receipts.sort(key=itemgetter(0,1))

print(f'{"DATE":<15} {"ENTITY":<30} {"CATEGORY":<10} {"SUBCAT":<15} {"AMOUNT":>8}')

for f in receipts:
  if len(f) < 5:
    print(f"Parsing error: {'.'.join(f)}")
    sys.exit(1)

  if int(f[5]) > 1:
    continue

  date = datetime.strptime(f[0], "%Y%m%d").strftime("%d %b %Y")
  entity = f[1].replace("_", " ")
  category = f[2]
  subcat = f[3]
  cost = Decimal(f'{f[4][:-2]}.{f[4][-2:]}')
  total_cost = total_cost + cost
  cost = f"${cost}"

  print(f'{date:15} {entity:30} {category:10} {subcat:15} {cost:>8}')

print(f"\nTOTAL: {locale.currency(total_cost, grouping=True)}")
