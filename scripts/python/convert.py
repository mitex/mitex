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
cgitb.enable(format="html")
import sys, subprocess, os, re, tempfile, urllib
from compile import not_none, LaTeXFile, make_error_message

__all__ = ["HTML_TO_TEX_CONVERTERS", "TEX_TO_HTML_CONVERTERS"]


def make_convert_html_to_tex(make_command, input_file_name="html_name", output_file_name="tex_name", pre_hook=None, post_hook=None):
    def convert_html_to_tex(html, begin, middle, end, preamble, body):
        dict_args = locals()
        list_args = list()
        if pre_hook:
            hook_args = pre_hook(*list_args, **dict_args)
            if isinstance(hook_args, dict):
                dict_args.update(hook_args)
            elif hook_args:
                list_args = hook_args
        html_file = tempfile.NamedTemporaryFile(suffix='.html', delete=False)
        html_file.write(html)
        html_name = html_file.name
        html_file.close()
        tex_file = tempfile.NamedTemporaryFile(dir="/tmp", mode="r", suffix=".tex", delete=False)
        tex_name = tex_file.name

        param_dict = {input_file_name:html_name, output_file_name:tex_name}
        try:
            cmd = make_command(**param_dict)
        except TypeError:
            cmd = make_command % param_dict

        p = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE,
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (stdout, stderr) = p.communicate()

        rtn = tex_file.read()
        tex_file.close()
        for name in (html_name, tex_name):
            os.remove(name)

        if post_hook:
            post_hook(*list_args, **dict_args)

        return rtn
    return convert_html_to_tex

def make_convert_tex_to_html(make_command, input_file_name="tex_name", output_file_name="html_name", pre_hook=None, post_hook=None):
    def convert_tex_to_html(latex_document, html):
        dict_args = locals()
        list_args = list()
        if pre_hook:
            hook_args = pre_hook(*list_args, **dict_args)
            if isinstance(hook_args, dict):
                dict_args.update(hook_args)
            elif hook_args:
                list_args = hook_args
        tex_file = tempfile.NamedTemporaryFile(dir="/tmp", mode="r", suffix=".tex", delete=False)
        tex_name = tex_file.name
        tex_file.write(latex_document)
        tex_file.close()
        html_file = tempfile.NamedTemporaryFile(suffix='.html', delete=False)
        html_name = html_file.name
        
        param_dict = {input_file_name:tex_name, output_file_name:html_name}
        try:
            cmd = make_command(**param_dict)
        except TypeError:
            cmd = make_command % param_dict

        p = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE,
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (stdout, stderr) = p.communicate()

        rtn = html_file.read()
        html_file.close()
        for name in (html_name, tex_name):
            os.remove(name)

        if post_hook:
            post_hook(*list_args, **dict_args)

        return rtn
    return convert_tex_to_html

convert_html_to_tex_with_html2latex = make_convert_html_to_tex("../html2latex/html2latex %(html_name)s %(tex_name)s")
convert_html_to_tex_with_htmltolatex = make_convert_html_to_tex("../html2latex/htmltolatex -input %(html_name)s -output %(tex_name)s")

convert_tex_to_html_with_tth = make_convert_tex_to_html("../latex2html/tth < %(tex_name) > %(html_name)s")

#################################### html2tex ####################################
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
################################## end html2tex ##################################



    
        
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
        print allowed_types[form.getvalue("type")](str(latex_file), html=not_none(form.getvalue("html")))
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
    {"full_name": "HTML to LaTeX",
     "short_name": "htmltolatex",
     "_py_function": convert_html_to_tex_with_htmltolatex }
    ]
TEX_TO_HTML_CONVERTERS = [
    {"full_name": "TtH (version 3.82)",
     "short_name": "TtH",
     "_py_function": convert_tex_to_html_with_tth }
    ]



if __name__ == "__main__":
    sys.exit(main())
