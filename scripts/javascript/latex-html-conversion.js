// latex-html-conversion.js -- Functions controlling the conversion of
//                             LaTeX to HTML and back.
// Copyright (C) 2010  The MITeX Project
// (See the CONTRIBUTORS file for a complete list of contributors)

// This file is part of MITeX.

// MITeX is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.

// MITeX is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with MITeX; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

var _HTML_TO_LATEX_CONVERTER_INPUT, _LATEX_TO_HTML_CONVERTER_INPUT,
    _WHICH_CONVERTER_SPAN;

var _latex_to_html_converters = [];
var _html_to_latex_converters = [];

function _add_converter(full_name, short_name, function_call, converters_list, path) {
    if (short_name === undefined) short_name = full_name;
    if (path)
        document.write('<script type="text/javascript" src="' + path + '"></script>');
    converters_list.push({
                                "full_name"     : full_name,
                                "short_name"    : short_name,
                                "function_call" : function_call
                           });
}


function _add_latex_to_html_converter(full_name, short_name, function_call, path) {
    _add_converter(full_name, short_name, function_call, _latex_to_html_converters, path);
}

function _add_html_to_latex_converter(full_name, short_name, function_call, path) {
    _add_converter(full_name, short_name, function_call, _html_to_latex_converters, path);
}

function _get_converter(name, converters_list, is_full_name, is_case_sensitive) {
    var cur_name;
    var len = converters_list.length; // because JS is stupid and otherwise it's quadratic
    for (var i = 0; i < len; i++) {
        var converter = converters_list[i];
        if (is_full_name && converter["full_name"])
            cur_name = converter["full_name"];
        else
            cur_name = converter["short_name"];
        if (cur_name == name || 
              (!is_case_sensitive && cur_name.toLowerCase() == name.toLowerCase()))
            return converter;
    }
}

function _get_latex_to_html_converter(name, is_full_name, is_case_sensitive) {
    _get_converter(name, _latex_to_html_converters, is_full_name, is_case_sensitive);
}

function _get_html_to_latex_converter(name, is_full_name, is_case_sensitive) {
    _get_converter(name, _html_to_latex_converters, is_full_name, is_case_sensitive);
}


function get_current_converter(converter_input, converters_list) {
    name = converter_input[converter_input.selectedIndex].value;
    return _get_converter(name, converters_list);
}

function _latex_html_switch(converter_type_description, old_input, new_input, new_converters_list, old_converters_list, editor) {
    // Convert the content
    converter = get_current_converter(old_input, old_converters_list);
    if (converter["function_call"])
        converter["function_call"](editor);
    // Change the listing
    _WHICH_CONVERTER_SPAN.innerHTML = converter_type_description;
    if (old_input != new_input) {
        $(old_input).hide();
        $(new_input).show();
    }
    // clear the options list
    for (var i = new_input.options.length - 1; i >= 0; i--) {
      new_input.removeChild(new_input.options[i]);
    }
    var len = new_converters_list.length; // because JS is stupid and otherwise it's quadratic
    for (var i = 0; i < len; i++) {
        var converter = new_converters_list[i];
        if (converter["full_name"] && converter["short_name"] && converter["function_call"]) {
            new_input[new_input.options.length] = new Option(converter["full_name"], converter["short_name"]);
        }
    }

}

function switch_to_latex_to_html_conversion(editor) {
    _latex_html_switch("a LaTeX to HTML", _LATEX_TO_HTML_CONVERTER_INPUT, _HTML_TO_LATEX_CONVERTER_INPUT, _latex_to_html_converters, _html_to_latex_converters, editor);
}

function switch_to_html_to_latex_conversion(editor) {
    _latex_html_switch("an HTML to LaTeX", _HTML_TO_LATEX_CONVERTER_INPUT, _LATEX_TO_HTML_CONVERTER_INPUT, _html_to_latex_converters, _latex_to_html_converters, editor);
}

function _set_converters_list(converters_list, default_function_call) {
    return function(data) {
        jQuery.each(data, function(i, item) {
                if (!item["function_call"]) {
                    if (item["short_name"])
                        item["function_call"] = default_function_call(item["short_name"]);
                    else if (item["full_name"])
                        item["function_call"] = default_function_call(item["full_name"]);
                    else
                        item["function_call"] = default_function_call;
                }
                converters_list.push(item);
                
    	});
    };
}

function get_latex_parts() {
    return {
                "begin"    : get_latex_begin(),
                "middle"   : get_latex_middle(),
                "end"      : get_latex_end(),
                "preamble" : get_latex_preamble(),
                "body"     : get_latex_body()
           };

}

function get_all_latex() {
    var latex = get_latex_parts();
    return latex["begin"] + latex["preamble"] + latex["middle"] + latex["body"] + latex["end"];
}

function set_latex_parts(begin, preamble, middle, body, end) {
//    if (begin)
//        set_latex_begin(begin);

    if (preamble !== undefined)
        set_latex_preamble(preamble);

//    if (middle)
//        set_latex_middle(middle);

    if (body !== undefined)
        set_latex_body(body);
        
//    if (end)
//        set_latex_end(end);
}

function set_all_latex(tex) {
    var cur_latex = get_latex_parts();
    var begin = "",
        preamble = "",
        middle = "",
        body = tex,
        end = "";
     
    if (body.indexOf("\\begin{document}") > -1) {
        if (cur_latex.middle.indexOf("\\begin{document}") > -1) {
            middle = cur_latex.middle;
            preamble = body.substring(0, body.indexOf("\\begin{document}"));
            body = body.substring(body.indexOf("\\begin{document}") + "\\begin{document}".length);
        } else {
            preamble = body.substring(0, body.indexOf("\\begin{document}"));
            body = body.substring(body.indexOf("\\begin{document}"));
        }
    }

    if (cur_latex.end.indexOf("\\end{document}") > -1) {
        if (body.indexOf("\\end{document}") > -1)
            end = cur_latex.end;
            body = body.substring(0, body.indexOf("\\end{document}"));
    }
    


    if (preamble.indexOf(cur_latex.begin) > -1) {
        preamble= preamble.substring(preamble.index(cur_latex.begin) + cur_latex.begin.length);
    }

    set_latex_parts(cur_latex.begin, preamble, cur_latex.middle, body, cur_latex.end);
}

function _default_convert_latex_to_html(converter_type) {
    return function (editor) {
        var latex = get_latex_parts();
        jQuery.get("scripts/python/convert.py", 
                    {
                        "latex2html"     : true,
                        "type"           : converter_type, 
                        "template"       : document.getElementById("templates").value,
                        "latex_preamble" : latex["preamble"],
                        "latex_body"     : latex["body"],
                        "html"           : get_wysiwyg_html()
                    },
                    set_wysiwyg_html);
        };
}

function _default_convert_html_to_latex(converter_type) {
    return function (editor) {
        var latex = get_latex_parts();
        jQuery.get("scripts/python/convert.py", 
                    {
                        "html2latex"     : true,
                        "type"           : converter_type, 
                        "template"       : document.getElementById("templates").value,
                        "latex_preamble" : latex["preamble"],
                        "latex_body"     : latex["body"],
                        "html"           : get_wysiwyg_html()
                    },
                    set_all_latex);
        };
}

	    

$(function () {
        _add_latex_to_html_converter("No converter", "none", (function () {}));
        _add_html_to_latex_converter("No converter", "none", (function () {}));
        _add_latex_to_html_converter("Literal text", "literal", (function (editor) { set_wysiwyg_html(get_all_latex(), editor); }));
        _add_html_to_latex_converter("Literal text", "literal", (function (editor) { set_all_latex(get_wysiwyg_html(editor)); }));
        jQuery.getJSON("scripts/python/serve-converters-list.py", {"latex2html":true}, _set_converters_list(_latex_to_html_converters, _default_convert_latex_to_html));
        jQuery.getJSON("scripts/python/serve-converters-list.py", {"html2latex":true}, _set_converters_list(_html_to_latex_converters, _default_convert_html_to_latex));
        _LATEX_TO_HTML_CONVERTER_INPUT = _HTML_TO_LATEX_CONVERTER_INPUT = document.getElementById("converter");
        _WHICH_CONVERTER_SPAN = document.getElementById("converter-type");
    });
