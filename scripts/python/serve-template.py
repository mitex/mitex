#!/usr/bin/python

import sys, cgi, cgitb
cgitb.enable()

def serve():
    form = cgi.FieldStorage()

    if "template" not in form or "type" not in form:
        return

    file = None
    if form.getvalue("type") == "begin":
        file = open("../../templates/%s/begin" % form.getvalue("template"), "r")
    elif form.getvalue("type") == "middle":
        file = open("../../templates/%s/middle" % form.getvalue("template"), "r")
    elif form.getvalue("type") == "end":
        file = open("../../templates/%s/end" % form.getvalue("template"), "r")
        
    if file == None:
        return

    print "<br />".join(file.readlines())

print "Content-type: text/html\n";
serve()
