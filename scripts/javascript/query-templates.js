include("jquery.js");

alert("here")

.get("../python/serve-template-list.py",
     function(data) {
	 alert("Data loaded:" + data)
     });