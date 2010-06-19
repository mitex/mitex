#!/usr/bin/python

# serve-template-list.py -- Code for serving list of templates
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

import sys, os, json, cgi, cgitb
cgitb.enable()


def main():
    print "Content-type: text/json\n";

    templates = os.listdir(os.path.join(os.getcwd(),  "..", "..", "templates"))
    print json.dumps(dict((t,t) for t in templates))


if __name__ == "__main__":
    sys.exit(main())

