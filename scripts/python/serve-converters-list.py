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

def strip_hidden_entries(obj, iteratively=True, is_hidden=(lambda s: isinstance(s, str) and s[0] == '_'), default_type=list):
    if is_hidden(obj):
        return None
    if iteratively:
        def parse_value(value):
            return strip_hidden_entries(value, iteratively, is_hidden)
    else:
        def parse_value(value):
            return value
            
    if isinstance(obj, dict):
        return dict((key, parse_value(obj[key])) for key in obj if not is_hidden(key))
    elif isinstance(obj, str):
        return obj
    else:
        try:
            rtn = (parse_value(i) for i in obj if not is_hidden(i))
        except TypeError:
            return obj
        try:
            return type(obj)(rtn)
        except Exception:
            try:
                return default_type(rtn)
            except Exception:
                return rtn

def main():
    
    form = cgi.FieldStorage()
    if "latex2html" in form and "html2latex" in form:
        make_error_message("Please specify ONE of latex2html or html2latex.")

    elif "latex2html" in form:
        print "Content-type: text/json\n";
        print json.dumps(strip_hidden_entries(TEX_TO_HTML_CONVERTERS))
        
    elif "html2latex" in form:
        print "Content-type: text/json\n";
        print json.dumps(strip_hidden_entries(HTML_TO_TEX_CONVERTERS))
        
    else:
        make_error_message("Please specify one of latex2html or html2latex.")



if __name__ == "__main__":
    main()

