// log.js -- Functions controlling the retrieval of the LaTeX logs
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

function get_log () {
    filename = document.getElementById("filename");
    template = document.getElementById("templates");
    open_log();
    log = document.getElementById("log");
    log.innerHTML = "Loading, please wait...";
    
    $.get("scripts/python/compile.py", { template: template.value, type: "log", 
        latex_preamble: get_latex_preamble(), latex_body: get_latex_body(),
        filename: filename.value },
    function(data) {
        log.innerHTML = data;
    });
}

function open_log() {
    $("#log-span").show();
    resize_log();
}

function close_log() {
    $("#log-span").hide();
}

function resize_log() {
    $("#log").css("height", $("#pagetable").height() + "px");
}
