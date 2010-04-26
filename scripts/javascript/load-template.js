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
	    begin = document.getElementById("begin");
	    middle = document.getElementById("middle");
	    end = document.getElementById("end");
	    submit = document.getElementById("submit");
	    preamble = document.getElementById("latex_preamble");
	    body = document.getElementById("latex_body");
	    check = document.getElementById("check");
	    
	    if(value != "none") {
 		$.get("scripts/python/serve-template.py", { template: value, type: "begin" },
		      function(data) {
			  begin.innerHTML = data;
			  begin_latex = data;
		      });

		$.get("scripts/python/serve-template.py", { template: value, type: "preamble" },
		      function(data) {
			  preamble.value = data;
		      });
		
		$.get("scripts/python/serve-template.py", { template: value, type: "middle" },
		      function(data) {
			  middle.innerHTML = data;
			  mid_latex = data;
		      });
		
		$.get("scripts/python/serve-template.py", { template: value, type: "body" },
		      function(data) {
			  body.value = data;
		      });
		
		$.get("scripts/python/serve-template.py", { template: value, type: "end" },
		      function(data) {
			  end.innerHTML = data;
			  end_latex = data;
		      });

		preamble.disabled = "";
		body.disabled = "";
		submit.disabled = "";
		check.disabled = "";
	    } else {
		begin.innerHTML = "";
		middle.innerHTML = "";
		end.innerHTML = "";
		preamble.disabled = "true";
		body.disabled = "true";
		submit.disabled = "true";
		check.disabled = "true";
	    }
	});
}