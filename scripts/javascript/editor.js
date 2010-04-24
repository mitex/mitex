var editor;

function switchToSource() {
    if (editor) {
	editor.destroy();
    }

    source_button = document.getElementById("source_button");
    wysiwyg_button = document.getElementById("wysiwyg_button");
    source_button.disabled = "true";
    wysiwyg_button.disabled = "";

    $('#source_editor').show();
    $('#wysiwyg_editor').hide();
}

function switchToWYSIWYG() {
    editor = CKEDITOR.replace("wysiwyg_editor");
    
    source_button = document.getElementById("source_button");
    wysiwyg_button = document.getElementById("wysiwyg_button");
    source_button.disabled = "";
    wysiwyg_button.disabled = "true";

    $('#source_editor').hide();
}

$(function () {
	switchToWYSIWYG();
    });