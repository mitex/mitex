#!/usr/bin/python

import os, json, cgi, cgitb
cgitb.enable()

print "Content-type: text/json\n";

templates = os.listdir("../../templates")
print json.dumps(dict((t,t) for t in templates))
