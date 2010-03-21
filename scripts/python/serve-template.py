#!/usr/bin/python

import sys, cgi, cgitb, os
cgitb.enable()


def serve():
    form = cgi.FieldStorage()

    if "template" not in form or "type" not in form:
        return

    file = None

    # Serve template/begin
    if form.getvalue("type") == "begin":
        file = open("../../templates/%s/begin" % form.getvalue("template"), "r")
        print "<br />".join(file.readlines())

    # Serve template/preamble (if it exists)
    elif form.getvalue("type") == "preamble":
        if os.path.exists("../../templates/%s/preamble" % form.getvalue("template")):
            file = open("../../templates/%s/preamble" % form.getvalue("template"), "r")
            print "".join(file.readlines())

    # Serve template/middle
    elif form.getvalue("type") == "middle":
        file = open("../../templates/%s/middle" % form.getvalue("template"), "r")
        print "<br />".join(file.readlines())

    # Serve template/body (if it exists)
    elif form.getvalue("type") == "body":
        if os.path.exists("../../templates/%s/body" % form.getvalue("template")):
            file = open("../../templates/%s/body" % form.getvalue("template"), "r")
            print "".join(file.readlines())

    # Serve template/end
    elif form.getvalue("type") == "end":
        file = open("../../templates/%s/end" % form.getvalue("template"), "r")
        print "<br />".join(file.readlines())
    

def main():
    print "Content-type: text/html\n";
    serve()


if __name__ == "__main__":
    sys.exit(main())
