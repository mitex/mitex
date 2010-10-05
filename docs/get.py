#!/usr/bin/python

import re
import sys
import os

print 'Content-type: application/pdf'
print

path = '/mit/mitex/web_scripts/docs/tex.pdf'
delete = False
if len(sys.argv) == 2:
	arg = os.path.join('/mit/mitex/web_scripts/docs', os.path.basename(sys.argv[1]))
	if arg.endswith('.pdf') and os.path.exists(arg):
		path = arg
		delete = True
sys.stdout.write(open(path, 'rb').read())
if delete:
	os.unlink(path)
