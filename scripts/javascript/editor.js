var editor;

function switchToSource() {
    if (editor) {
        editor.destroy();
    }

    document.getElementById("source_button").disabled = "true";
    document.getElementById("wysiwyg_button").disabled = "";

    $('#source_editor').show();
    $('#wysiwyg_editor').hide();
    resize_log();
}

function switchToWYSIWYG() {
    editor = CKEDITOR.replace("wysiwyg_editor");
    
    document.getElementById("source_button").disabled = "";
    document.getElementById("wysiwyg_button").disabled = "true";

    $('#source_editor').hide();
    resize_log();
}

$(function () {
        switchToWYSIWYG();
        close_log();
    });
