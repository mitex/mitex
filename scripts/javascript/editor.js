// editor.js -- Functions controlling the editing textareas
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

var editor;

function switchToSource() {
    if (editor) {
        editor.destroy();
    }

    document.getElementById("source_button").disabled = "true";
    document.getElementById("wysiwyg_button").disabled = "";

    $('#source_editor').show();
    $('#wysiwyg_editor').hide();
    resize_log();
    reload_editarea();
}

function switchToWYSIWYG() {
    editor = CKEDITOR.replace("wysiwyg_editor");
    
    document.getElementById("source_button").disabled = "";
    document.getElementById("wysiwyg_button").disabled = "true";

    $('#source_editor').hide();
    resize_log();
}

$(function () {
        switchToSource();
        close_log();
    });
