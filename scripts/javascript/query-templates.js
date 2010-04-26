function setTemplateList(data) {
    list = document.getElementById("templates");

    $.each(data, function(i, item) {
      	    list.options[list.options.length] = new Option(item, item);
	});  
}

$(function () {
	$.getJSON("scripts/python/serve-template-list.py", setTemplateList);
    });