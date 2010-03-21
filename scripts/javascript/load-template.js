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
			  begin.innerHTML = "<font face='Courier'>" + data + "</font>";
			  begin_latex = data;
		      });

		$.get("scripts/python/serve-template.py", { template: value, type: "preamble" },
		      function(data) {
			  preamble.value = data;
		      });
		
		$.get("scripts/python/serve-template.py", { template: value, type: "middle" },
		      function(data) {
			  middle.innerHTML = "<font face='Courier'>" + data + "</font>";
			  mid_latex = data;
		      });
		
		$.get("scripts/python/serve-template.py", { template: value, type: "body" },
		      function(data) {
			  body.value = data;
		      });
		
		$.get("scripts/python/serve-template.py", { template: value, type: "end" },
		      function(data) {
			  end.innerHTML = "<font face='Courier'>" + data + "</font>";
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