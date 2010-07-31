#!/usr/bin/python

# convert.py -- Wrapper for various TeX/HTML converters
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

from __future__ import with_statement
import cgi, cgitb
cgitb.enable(format="nothtml")
import sys, subprocess, os, re, tempfile, urllib
from compile import not_none, LaTeXFile, make_error_message

__all__ = ["HTML_TO_TEX_CONVERTERS", "TEX_TO_HTML_CONVERTERS"]

def convert_html_to_tex_with_html2tex(html, begin, middle, end, preamble, body):
    with open(begin, 'r') as f:
        begin = f.read()
    with open(middle, 'r') as f:
        middle = f.read()
    with open(end, 'r') as f:
        end = f.read()
    html_file = tempfile.NamedTemporaryFile(suffix='.html', delete=False)
    html_file.write(html)
    html_name = html_file.name
    html_file.close()
    tex_file = tempfile.NamedTemporaryFile(dir="/tmp", mode="r", suffix=".tex", delete=False)
    tex_name = tex_file.name
    skeleton = tempfile.NamedTemporaryFile(dir="/tmp", mode="w", delete=False)
    skeleton_name = skeleton.name
    skeleton.write(r"""%(begin)s
%%html -s article

%(preamble)s

\begin{document}

%%html %(html_name)s 1

\end{document}""" % locals())
    skeleton.close()
    
    p = subprocess.Popen("../html2latex/html2tex -o %(tex_name)s %(skeleton_name)s" % locals(),
                         shell=True, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate()

    rtn = tex_file.read()
    tex_file.close()
    for name in (html_name, tex_name, skeleton_name):
        os.remove(name)

    return rtn

def convert_html_to_tex_with_html2latex(html, begin, middle, end, preamble, body):
    with open(begin, 'r') as f:
        begin = f.read()
    with open(middle, 'r') as f:
        middle = f.read()
    with open(end, 'r') as f:
        end = f.read()
    html_file = tempfile.NamedTemporaryFile(suffix='.html', delete=False)
    html_file.write(html)
    html_name = html_file.name
    html_file.close()
    
    
    p = subprocess.Popen("../html2latex/html2latex %(html_name)s -s" % locals(),
                         shell=True, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate()

    rtn = stdout
    for name in (html_name,):
        os.remove(name)

    return rtn

    
    
        
def get_converter(name, check_list, attribute='short_name', case_insensitive=True):
    for converter_list in check:
        for converter in converter_list:
            if converter[attribute] == name or (case_insensitive and converter[attribute].lower() == name.lower()):
                return converter




def main():
    """
    Parse the cgi input, and respond with the converted TeX/HTML
    """
    
    form = cgi.FieldStorage()
    
    if "latex2html" in form and "html2latex" in form:
        print make_error_message("Please specify ONE of latex2html or html2latex.")
        return

    elif "latex2html" in form:
        converter_list = TEX_TO_HTML_CONVERTERS
        latex2html = True
        
    elif "html2latex" in form:
        converter_list = HTML_TO_TEX_CONVERTERS
        latex2html = False

    else:
        print make_error_message("Please specify one of latex2html or html2latex.")
        return

    allowed_types = dict((converter_type["short_name"], converter_type["_py_function"]) for converter_type in converter_list)
    
    
    if "type" not in form:
        print make_error_message("Missing converter type!")
        
    elif form.getvalue("type") not in allowed_types.keys():
        print make_error_message("Unexpected converter type: %s" % form.getvalue("type"))

    elif latex2html:
        latex_file = LaTeXFile(begin=os.path.abspath("../../templates/%s/begin" % form.getvalue("template")),
                               middle=os.path.abspath("../../templates/%s/middle" % form.getvalue("template")),
                               end=os.path.abspath("../../templates/%s/end" % form.getvalue("template")),
                               preamble=not_none(form.getvalue("latex_preamble")),
                               body=not_none(form.getvalue("latex_body")))
        print "Content-type: text/html"
        print
        print allowed_types[form.getvalue("type")](latex_file, html=not_none(form.getvalue("html")))
    else:
        print "Content-type: text/html"
        print
        print allowed_types[form.getvalue("type")](not_none(form.getvalue("html")),
                                                   begin=os.path.abspath("../../templates/%s/begin" % form.getvalue("template")),
                                                   middle=os.path.abspath("../../templates/%s/middle" % form.getvalue("template")),
                                                   end=os.path.abspath("../../templates/%s/end" % form.getvalue("template")),
                                                   preamble=not_none(form.getvalue("latex_preamble")),
                                                   body=not_none(form.getvalue("latex_body")))
        

HTML_TO_TEX_CONVERTERS = [
    {"full_name": "HTML to LaTeX (version 2.7)",
     "short_name": "html2tex",
     "_py_function": convert_html_to_tex_with_html2tex },
    {"full_name": "HTML2LaTeX",
     "short_name": "html2latex",
     "_py_function": convert_html_to_tex_with_html2latex },
    ]
TEX_TO_HTML_CONVERTERS = []



if __name__ == "__main__":
    sys.exit(main())
