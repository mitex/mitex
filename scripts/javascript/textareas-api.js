// textareas-api.js -- Encapsulates the LaTeX and HTML text/editareas,
//                     so that changes to them don't have to remember
//                     all the details about how to change them.
// Copyright (C) 2010  The MITeX Project
// (See the CONTRIBUTORS file for a complete list of contributors)

// This file is part of MITeX.

// MITeX is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.

// MITeX is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with MITeX; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

var LATEX_BEGIN, LATEX_MIDDLE, LATEX_END, LATEX_PREAMBLE, LATEX_BODY;

$(function () {
                LATEX_BEGIN = document.getElementById("begin");
                LATEX_MIDDLE = document.getElementById("middle");
                LATEX_END = document.getElementById("end");
                LATEX_PREAMBLE = document.getElementById("latex_preamble");
	            LATEX_BODY = document.getElementById("latex_body");
	          });

function set_latex_begin(data) {
    LATEX_BEGIN.innerHTML = data;
    begin_latex = data;
}

function set_latex_preamble(data) {
    LATEX_PREAMBLE.value = data;
    copy_to_editarea(LATEX_PREAMBLE);
}

function set_latex_middle(data) {
    LATEX_MIDDLE.innerHTML = data;
    mid_latex = data;
}

function set_latex_body(data) {
    LATEX_BODY.value = data;
    copy_to_editarea(LATEX_BODY);
}

function set_latex_end(data) {
    LATEX_END.innerHTML = data;
    end_latex = data;
}

function get_latex_begin() {
    return LATEX_BEGIN.innerHTML;
}

function get_latex_preamble() {
    return LATEX_PREAMBLE.value;
}

function get_latex_middle() {
    return LATEX_MIDDLE.innerHTML;
}

function get_latex_body() {
    return LATEX_BODY.value;
}

function get_latex_end() {
    return LATEX_END.innerHTML;
}

function set_wysiwyg_html(html, editor) {
    if (editor === undefined) {
        if (tinyMCE.editors['wysiwyg-textarea'])
            return tinyMCE.editors['wysiwyg-textarea'].setContent(html);
        else
            return document.getElementById("wysiwyg-textarea").innerHTML = html;
    return editor.setContent(html);
}

function get_wysiwyg_html(editor) {
    if (editor === undefined)
        editor = tinyMCE.editors['wysiwyg-textarea'];
    return editor.getContent();
}
