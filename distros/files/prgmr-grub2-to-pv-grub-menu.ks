#!/usr/bin/env python

import sys
import os
import re

contents = sys.stdin.read()

menu = ""

menuentries = re.split("\nmenuentry ", contents)
if len(menuentries) < 2:
    sys.stderr.write("No menu entries found\n")
    sys.exit(1)

print("default=0")

match = re.search("set timeout=([0-9]+)", contents)
if match is not None:
    print("timeout=%s" % match.group(1))
else:
    print("timeout=10")

for entry in menuentries[1:]:
    name_match = re.match("'([^']+)'", entry)
    if name_match is None:
        name_match = re.match('"([^"]+)"', entry)   
    if name_match is None:
        name_match = re.search("/boot/([^\s]+)", linux_match.group(1))
    if name_match is None:
        name_match = re.search("/([^\s]+)", linux_match.group(1))
    root_match = re.search("set root='(hd[0-9]),msdos([0-9])'", entry)
    linux_match = re.search("\n\s+linux1?6?\s+(.+)\n", entry)
    initrd_match = re.search("\n\s+initrd1?6?\s+(.+)\n", entry)
    print('title %s' % name_match.group(1))
    if root_match is not None:
        print('  root (%s,%d)' % (root_match.group(1), int(root_match.group(2)) - 1))
    else:
        print('  root (hd0,0)')
    print('  kernel %s' % linux_match.group(1))
    print('  initrd %s' % initrd_match.group(1))
    print('')

