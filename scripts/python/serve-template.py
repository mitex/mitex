#!/usr/bin/python

# serve-template.py -- Code for serving template code
# Copyright (C) 2010  The MITeX Project
# (See the CONTRIBUTORS file for a complete list of contributors)

# This file is part of MITeX.

# MITeX is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# MITeX is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with MITeX; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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
