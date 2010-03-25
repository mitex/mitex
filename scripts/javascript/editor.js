var editor;

function switchToSource() {
    if (editor) {
	editor.destroy();
    }

    source_button = document.getElementById("source_button");
    wysiwyg_button = document.getElementById("wysiwyg_button");
    source_button.disabled = "true";
    wysiwyg_button.disabled = "";
}

function switchToWYSIWYG() {
    editor = CKEDITOR.replace("editor");
    
    source_button = document.getElementById("source_button");
    wysiwyg_button = document.getElementById("wysiwyg_button");
    source_button.disabled = "";
    wysiwyg_button.disabled = "true";
}

$(function () {
	switchToWYSIWYG();
    });