#!/usr/bin/python

import re
import sys
import os

print 'Content-type: application/pdf'
print

path = '/mit/mitex/web_scripts/docs/tex.pdf'
delete = False
if len(sys.argv) == 2:
	arg = os.path.basename(sys.argv[1])
	if arg.endswith('.pdf') and re.match("^[^/]+$", arg):
		path = os.path.join('/mit/mitex/web_scripts/docs', arg)
		delete = True
sys.stdout.write(open(path, 'rb').read())
if delete:
	os.unlink(path)
