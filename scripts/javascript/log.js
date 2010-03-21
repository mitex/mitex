function get_log () {
    preamble = document.getElementById("latex_preamble");
    body = document.getElementById("latex_body");
    filename = document.getElementById("filename");
    template = document.getElementById("templates");
    log = document.getElementById("log");
    log.innerHTML = "Loading, please wait..."
	    
    $.get("scripts/python/compile.py", { template: template.value, type: "log", 
		latex_preamble: preamble.value, latex_body: body.value,
		filename: filename.value },
	function(data) {
	    log.innerHTML = data;
		});
}