#!/usr/bin/python

# compile.py -- Wrapper for various TeX compilers
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

import sys, cgi, cgitb, subprocess, os, re, tempfile, urllib
#cgitb.enable(format="nothtml")
cgitb.enable(format="html")

# Make sure the object passed in is not None
# (change it to "" if it is)
def not_none(obj):
    if obj is None:
        return ""
    else:
        return obj

# Wrapper for a tex file -- split up into beginning,
# preamble, middle, body, and end.  It also has a name.
# Can be made into a single string.
class LaTeXFile(object):
    def __init__(self, begin, middle, end, preamble, body, name):
        self.begin = begin
        self.middle = middle
        self.end = end
        self.preamble = not_none(preamble)
        self.body = not_none(body)
        self.name = name

    def __str__(self):
        tex = ""
        file = open(self.begin, "r")
        tex += "".join(file.readlines()) + "\n"
        file.close()
        tex += self.preamble + "\n"
        file = open(self.middle, "r")
        tex += "".join(file.readlines()) + "\n"
        file.close()
        tex += self.body + "\n"
        file = open(self.end, "r")
        tex += "".join(file.readlines()) + "\n"
        file.close()

        return tex

# Respond with a tex file
def compile_tex(latex_file):
    print "Content-type: application/x-tex"
    print "Content-disposition: attachment; filename=%s.tex" % latex_file.name
    print

    tex = str(latex_file)
    print tex

# Respond with a pdf file piped to Google Reader
def compile_google(latex_file):
    tex = str(latex_file)
    old_dir = os.getcwd()
    os.chdir("/tmp")
    p = subprocess.Popen("rubber-pipe --pdf", shell=True, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate(tex)
    
    os.chdir(old_dir)
    tmp = tempfile.NamedTemporaryFile(suffix=".pdf", dir="../../docs", delete=False)
    tmp.write(stdout)
    print "Location: http://docs.google.com/viewer?url=" + urllib.quote("http://" + os.environ['SERVER_NAME'] + "/docs/get.py?" + os.path.basename(tmp.name), "")
    print
    tmp.close()

# Respond with a pdf file
def compile_pdf(latex_file):
    print "Content-type: application/pdf"
    print "Content-disposition: attachment; filename=%s.pdf" % latex_file.name
    print

    tex = str(latex_file)
    os.chdir("/tmp")
    p = subprocess.Popen("rubber-pipe --pdf", shell=True, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate(tex)

    print stdout

# Respond with a ps file
def compile_ps(latex_file):
    print "Content-type: application/postscript"
    print "Content-disposition: attachment; filename=%s.ps" % latex_file.name
    print

    tex = str(latex_file)
    os.chdir("/tmp")
    p = subprocess.Popen("rubber-pipe --ps", shell=True, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate(tex)

    print stdout

# Respond with a log file
def compile_log(latex_file):
    print "Content-type: text/html"
    print

    os.chdir("/tmp")
    tex = tempfile.NamedTemporaryFile(mode="w", suffix=".tex", delete=False)
    tex.write(str(latex_file))
    texname = tex.name
    tex.close()

    p = subprocess.Popen("rubber %s" % texname, shell=True, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate()

    log = open(texname.replace(".tex", ".log"), "r")
    print "".join(log.readlines())
    log.close()

    p = subprocess.Popen("rubber --clean %s " % texname, shell=True, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate()


# Make an error message
def make_error_message(message):
    return """Content-type: text/html

<html><head><title>MITeX -- Error!</title></head><body>
<p><strong>Error: %s</strong></p></body></html>
""" % message


# Parse the cgi input, and give a response of a certain file
# type.
def main():
    allowed_types = {"tex": compile_tex, "pdf": compile_pdf,
                     "ps": compile_ps,   "log": compile_log,
                     "google": compile_google}

    form = cgi.FieldStorage()
    if "type" not in form:
        print make_error_message("Missing filetype!")

    elif "template" not in form:
        print make_error_message("Missing template name!")

    elif "filename" not in form:
        print make_error_message("Missing filename!")

    elif re.match("^[A-z0-9_. -]+$", form.getvalue("filename")) is None:
        print make_error_message("Please limit your filename to alphanumeric characters, underscores, dashes, spaces, and periods!")

    elif form.getvalue("type") not in allowed_types.keys():
        print make_error_message("Unexpected filetype: %s" % form.getvalue("type"))

    else:
        latex_file = LaTeXFile(begin=os.path.abspath("../../templates/%s/begin" % form.getvalue("template")),
                               middle=os.path.abspath("../../templates/%s/middle" % form.getvalue("template")),
                               end=os.path.abspath("../../templates/%s/end" % form.getvalue("template")),
                               preamble=form.getvalue("latex_preamble"),
                               body=form.getvalue("latex_body"),
                               name=form.getvalue("filename"))

        allowed_types[form.getvalue("type")](latex_file)

if __name__ == "__main__":
    sys.exit(main())
