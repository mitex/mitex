#!/usr/bin/python

import sys, os, json, cgi, cgitb
cgitb.enable()


def main():
    print "Content-type: text/json\n";

    templates = os.listdir("../../templates")
    print json.dumps(dict((t,t) for t in templates))


if __name__ == "__main__":
    sys.exit(main())
