#!/usr/bin/python

import sys, cgi, cgitb, subprocess, os, tempfile, re
cgitb.enable()

def not_none(obj):
    if obj is None:
        return ""
    else:
        return obj

class LaTeXFile(object):
    def __init__(self, begin, middle, end, preamble, body, name):
        self.begin = begin
        self.middle = middle
        self.end = end
        self.preamble = not_none(preamble)
        self.body = not_none(body)
        self.name = name


def make_tex_string(latex_file):
    tex = ""
    file = open(latex_file.begin, "r")
    tex += "".join(file.readlines()) + "\n"
    file.close()
    tex += latex_file.preamble + "\n"
    file = open(latex_file.middle, "r")
    tex += "".join(file.readlines()) + "\n"
    file.close()
    tex += latex_file.body + "\n"
    file = open(latex_file.end, "r")
    tex += "".join(file.readlines()) + "\n"
    file.close()

    return tex

def compile_tex(latex_file):
    print "Content-type: application/x-tex"
    print "Content-disposition: attachment; filename=%s.tex" % latex_file.name
    print

    tex = make_tex_string(latex_file)
    print tex

def compile_pdf(latex_file):
    print "Content-type: application/pdf"
    print "Content-disposition: attachment; filename=%s.pdf" % latex_file.name
    print

    tex = make_tex_string(latex_file)
    os.chdir("/tmp")
    p = subprocess.Popen("rubber-pipe --pdf", shell=True, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate(tex)

    print stdout

def compile_ps(latex_file):
    print "Content-type: application/postscript"
    print "Content-disposition: attachment; filename=%s.ps" % latex_file.name
    print

    tex = make_tex_string(latex_file)
    os.chdir("/tmp")
    p = subprocess.Popen("rubber-pipe --ps", shell=True, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate(tex)

    print stdout

form = cgi.FieldStorage()
if "type" not in form:
    print "Content-type: text/plain"
    print
elif "template" not in form:
    print "Content-type: text/plain"
    print
elif re.match("^[A-z0-9_. -]+$", form.getvalue("filename")) is None:
    print "Content-type: text/html"
    print
    print """
<html><head><title>MITeX -- Error!</title></head><body>
<p><strong>Error: Please limit your filename to alphanumreic characters, underscores, dashes, spaces, and periods!</strong></p>
</body></html>"""
else:
    latex_file = LaTeXFile(begin=os.path.abspath("../../templates/%s/begin" % form.getvalue("template")),
                           middle=os.path.abspath("../../templates/%s/middle" % form.getvalue("template")),
                           end=os.path.abspath("../../templates/%s/end" % form.getvalue("template")),
                           preamble=form.getvalue("latex_preamble"),
                           body=form.getvalue("latex_body"),
                           name=form.getvalue("filename"))

    type = form.getvalue("type")
    if type == "tex": compile_tex(latex_file)
    elif type == "pdf": compile_pdf(latex_file)
    elif type == "ps": compile_ps(latex_file)
    else:
        print "Content-type: text/plain"
        print
