function loadTemplateFile(value) {
    $(function () {
	    begin = document.getElementById("begin");
	    middle = document.getElementById("middle");
	    end = document.getElementById("end");
	    head = document.getElementById("header");
	    body = document.getElementById("body");
	    
	    if(value != "none") {
		var begin_latex, mid_latex, end_latex;

		$.get("scripts/python/serve-template.py", { template: value, type: "begin" },
		      function(data) {
			  begin.innerHTML = "<font face='Courier'>" + data + "</font>";
		      });
		
		$.get("scripts/python/serve-template.py", { template: value, type: "middle" },
		      function(data) {
			  middle.innerHTML = "<font face='Courier'>" + data + "</font>";
		      });
		
		$.get("scripts/python/serve-template.py", { template: value, type: "end" },
		      function(data) {
			  end.innerHTML = "<font face='Courier'>" + data + "</font>";
		      });

		head.disabled = "";
		body.disabled = "";
	    } else {
		begin.innerHTML = "";
		middle.innerHTML = "";
		end.innerHTML = "";
		head.disabled = "true";
		body.disabled = "true";
	    }
	});
}