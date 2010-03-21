var begin_latex, mid_latex, end_latex, head, body;

function loadTemplateFile(value) {
    $(function () {
	    begin = document.getElementById("begin");
	    middle = document.getElementById("middle");
	    end = document.getElementById("end");
	    submit = document.getElementById("submit");
	    head = document.getElementById("header");
	    body = document.getElementById("body");
	    
	    if(value != "none") {
		$.get("scripts/python/serve-template.py", { template: value, type: "begin" },
		      function(data) {
			  begin.innerHTML = "<font face='Courier'>" + data + "</font>";
			  begin_latex = data;
		      });
		
		$.get("scripts/python/serve-template.py", { template: value, type: "middle" },
		      function(data) {
			  middle.innerHTML = "<font face='Courier'>" + data + "</font>";
			  mid_latex = data;
		      });
		
		$.get("scripts/python/serve-template.py", { template: value, type: "end" },
		      function(data) {
			  end.innerHTML = "<font face='Courier'>" + data + "</font>";
			  end_latex = data;
		      });

		head.disabled = "";
		body.disabled = "";
		submit.disabled = "";
	    } else {
		begin.innerHTML = "";
		middle.innerHTML = "";
		end.innerHTML = "";
		head.disabled = "true";
		body.disabled = "true";
		submit.disabled = "true";
	    }
	});
}