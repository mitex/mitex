#!/usr/bin/python

import sys, cgi, cgitb, subprocess, os, tempfile
cgitb.enable()

def make_tex_string(begin_file, middle_file, end_file, preamble, body):
    tex = ""
    file = open(begin_file, "r")
    tex += "".join(file.readlines()) + "\n"
    file.close()
    tex += preamble + "\n"
    file = open(middle_file, "r")
    tex += "".join(file.readlines()) + "\n"
    file.close()
    tex += body + "\n"
    file = open(end_file, "r")
    tex += "".join(file.readlines()) + "\n"
    file.close()

    return tex

def compile_tex(begin_file, middle_file, end_file, preamble, body, name):
    print "Content-type: application/x-tex"
    print "Content-disposition: attachement; filename=%s.tex" % name
    print

    file = open(begin_file, "r")
    print "".join(file.readlines())
    file.close()
    print preamble
    file = open(middle_file, "r")
    print "".join(file.readlines())
    file.close()
    print body
    file = open(end_file, "r")
    print "".join(file.readlines())
    file.close()

def compile_dvi(begin_file, middle_file, end_file, preamble, body, name):
    print "Content-type: application/x-dvi"
    print "Content-disposition: attachment; filename=%s.dvi" % name
    print

    tex = make_tex_string(begin_file, middle_file, end_file, preamble, body)
    os.chdir("/tmp")
    p = subprocess.Popen("rubber-pipe", shell=True, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate(tex)

    return stdout

def compile_pdf(begin_file, middle_file, end_file, preamble, body, name):
    print "Content-type: application/pdf"
    print "Content-disposition: attachement; filename=%s.pdf" % name
    print

    tex = make_tex_string(begin_file, middle_file, end_file, preamble, body)
    os.chdir("/tmp")
    p = subprocess.Popen("rubber-pipe --pdf", shell=True, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate(tex)

    print stdout

def compile_ps(begin_file, middle_file, end_file, preamble, body, name):
    print "Content-type: application/postscript"
    print "Content-disposition: attachement; filename=%s.ps" % name
    print

    tex = make_tex_string(begin_file, middle_file, end_file, preamble, body)
    os.chdir("/tmp")
    p = subprocess.Popen("rubber-pipe --ps", shell=True, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate(tex)

    print stdout

form = cgi.FieldStorage()
if "type" not in form:
    print "Content-type: text/plain"
    print
else:
    if not "template" in form:
        print "Content-type: text/plain";
        print
    else:
        begin_file = os.path.abspath("../../templates/%s/begin" % form.getvalue("template"))
        middle_file = os.path.abspath("../../templates/%s/middle" % form.getvalue("template"))
        end_file = os.path.abspath("../../templates/%s/end" % form.getvalue("template"))
        
        preamble = form.getvalue("latex_preamble")
        body = form.getvalue("latex_body")

        if preamble == None: preamble = ""
        if body == None: body = ""

        name = form.getvalue("filename")
        
        type = form.getvalue("type")
        if type == "tex": compile_tex(begin_file, middle_file, end_file, preamble, body, name)
        elif type == "dvi": compile_dvi(begin_file, middle_file, end_file, preamble, body, name)
        elif type == "pdf": compile_pdf(begin_file, middle_file, end_file, preamble, body, name)
        elif type == "ps": compile_ps(begin_file, middle_file, end_file, preamble, body, name)
        else:
            print "Content-type: text/plain"
            print
