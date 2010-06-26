// editor.js -- Functions controlling the editing textareas
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
    reload_editarea();
}

function init_tinyMCE() {
  tinyMCE.init({
      mode : "exact",
      elements : "wysiwyg-textarea",
      theme : "advanced",
      theme_advanced_buttons1 : "fontselect,fontsizeselect,formatselect,bold,italic,underline,strikethrough,separator,sub,sup,separator,cut,copy,paste,undo,redo",
      theme_advanced_buttons2 : "justifyleft,justifycenter,justifyright,justifyfull,separator,numlist,bullist,outdent,indent,separator,forecolor,backcolor,separator,hr,link,unlink,image,table,code,separator,asciimath,asciimathcharmap,asciisvg",
      theme_advanced_buttons3 : "",
      theme_advanced_fonts : "Arial=arial,helvetica,sans-serif,Courier New=courier new,courier,monospace,Georgia=georgia,times new roman,times,serif,Tahoma=tahoma,arial,helvetica,sans-serif,Times=times new roman,times,serif,Verdana=verdana,arial,helvetica,sans-serif",
      theme_advanced_toolbar_location : "top",
      theme_advanced_toolbar_align : "left",
      theme_advanced_statusbar_location : "bottom",
      plugins : 'safari,asciimath,asciisvg,table,inlinepopups',
      
      // If someone can get the following php file working on scripts, change the path to a local version (scripts/php/svgimg.php).
      AScgiloc : 'http://www.imathas.com/editordemo/php/svgimg.php',			      //change me  
      ASdloc : 'scripts/javascript/tiny_mce/plugins/asciisvg/js/d.svg',	

//      AScgiloc : 'scripts/php/svgimg.php',			      //change me  
     
  
      content_css : "/css/content.css"
  });
}

function switchToWYSIWYG() {
    //editor = CKEDITOR.replace("wysiwyg_editor");
    init_tinyMCE();
    
    document.getElementById("source_button").disabled = "";
    document.getElementById("wysiwyg_button").disabled = "true";

    $('#wysiwyg_editor').show();
    $('#source_editor').hide();
    resize_log();
}

$(function () {
        switchToSource();
        close_log();
    });
