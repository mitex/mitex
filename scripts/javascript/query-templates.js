// query-templates.js -- Code faciliating querying for LaTeX templates
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

function setTemplateList(data) {
    elements = Array();
    $.each(data, function(i, item) {
            elements[elements.length] = item;
	});
    elements.sort();
    var len = elements.length; // because JS is stupid and otherwise it's quadratic
    list = document.getElementById("templates");
    for (var i = 0; i < len; i++) {
        list[list.options.length] = new Option(elements[i], elements[i]);
    }
}

$(function () {
	$.getJSON("scripts/python/serve-template-list.py", setTemplateList);
    });