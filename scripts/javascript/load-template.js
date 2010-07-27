// load-templates.js -- Code faciliating loading of LaTeX templates
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

function loadTemplateFile(value) {
    $(function () {
	    submit = document.getElementById("submit");
	    check = document.getElementById("check");
	    
	    if(value != "none") {
 		$.get("scripts/python/serve-template.py", { template: value, type: "begin" }, set_latex_begin);

		$.get("scripts/python/serve-template.py", { template: value, type: "preamble" }, set_latex_preamble);
		
		$.get("scripts/python/serve-template.py", { template: value, type: "middle" }, set_latex_middle);
		
		$.get("scripts/python/serve-template.py", { template: value, type: "body" }, set_latex_body);
		
		$.get("scripts/python/serve-template.py", { template: value, type: "end" }, set_latex_end);

		LATEX_PREAMBLE.disabled = "";
		LATEX_BODY.disabled = "";
		submit.disabled = "";
		check.disabled = "";
	    } else {
		LATEX_BEGIN.innerHTML = "";
		LATEX_MIDDLE.innerHTML = "";
		LATEX_END.innerHTML = "";
		LATEX_PREAMBLE.disabled = "true";
		LATEX_BODY.disabled = "true";
		submit.disabled = "true";
		check.disabled = "true";
	    }
	    
	    reload_editarea();
	});
}
