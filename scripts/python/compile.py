#!/usr/bin/python

import sys, cgi, cgitb, subprocess, os, re, tempfile
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


def compile_log(latex_file):
    print "Content-type: text/html"
    print

    os.chdir("/tmp")
    tex = tempfile.NamedTemporaryFile(mode="w", suffix=".tex", delete=False)
    tex.write(make_tex_string(latex_file))
    texname = tex.name
    tex.close()

    p = subprocess.Popen("rubber %s" % texname, shell=True, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate()

    log = open(texname.replace(".tex", ".log"), "r")
    print "<br />".join(log.readlines())
    log.close()

    p = subprocess.Popen("rubber --clean %s " % texname, shell=True, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    (stdout, stderr) = p.communicate()


def make_error_message(message):
    return "<html><head><title>MITeX -- Error!</title></head><body>" + \
        "<p><strong>Error: %s</strong></p></body></html>" % message


def main():
    form = cgi.FieldStorage()
    if "type" not in form:
        print "Content-type: text/html"
        print
        print make_error_message("Missing filetype!")

    elif "template" not in form:
        print "Content-type: text/html"
        print
        print make_error_message("Missing template name!")

    elif "filename" not in form:
        print "Content-type: text/html"
        print
        print make_error_message("Missing filename!")

    elif re.match("^[A-z0-9_. -]+$", form.getvalue("filename")) is None:
        print "Content-type: text/html"
        print
        print make_error_message("Please limit your filename to alphanumreic characters, underscores, dashes, spaces, and periods!")

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
        elif type == "log": compile_log(latex_file)
        else:
            print "Content-type: text/html"
            print
            print make_error_message("Unexpected filetype: %s" % type)


if __name__ == "__main__":
    sys.exit(main())
