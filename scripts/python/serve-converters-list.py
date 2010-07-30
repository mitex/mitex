#!/usr/bin/python

# serve-convert-list.py -- Code for serving list of converters
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
from convert import HTML_TO_TEX_CONVERTERS, TEX_TO_HTML_CONVERTERS, make_error_message
cgitb.enable()

def main():
    
    form = cgi.FieldStorage()
    if "latex2html" in form and "html2latex" in form:
        make_error_message("Please specify ONE of latex2html or html2latex.")

    elif "latex2html" in form:
        print "Content-type: text/json\n";
        print json.dumps(TEX_TO_HTML_CONVERTERS)
        
    elif "html2latex" in form:
        print "Content-type: text/json\n";
        print json.dumps(HTML_TO_TEX_CONVERTERS)
        
    else:
        make_error_message("Please specify one of latex2html or html2latex.")



if __name__ == "__main__":
    main()

