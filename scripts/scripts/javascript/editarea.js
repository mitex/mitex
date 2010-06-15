function reload_editarea() {
    $(".tex-edit").each(function() {
        editAreaLoader.init({
            id: this.id,
            start_highlight: true,
            allow_resize: "no",
            allow_toggle: false,
            language: "en",
            syntax: "latex",
            toolbar: "",
            is_editable: !this.disabled,
            show_line_colors: true,
            font_size: 10,
            font_family: "Lucida Console",
            cursor_position: "auto",
            change_callback: "copy_to_textarea"
        });
        
        copy_to_editarea(this);
    });
}

function copy_to_editarea(element) {
    editAreaLoader.setValue(element.id, element.value);
}

function copy_to_textarea(id) {
    document.getElementById(id).value = editAreaLoader.getValue(id);
}

$(function() {
	// a horrible hack
	editAreaLoader.iframe_css += '<link rel="stylesheet" type="text/css" href="editarea.css">';
});
