editAreaLoader.load_syntax["latex"] = {
	'DISPLAY_NAME' : 'LaTeX',
	'COMMENT_SINGLE': { 1 : '%' },
	'DELIMITERS' : [ '(', ')', '[', ']', '{', '}' ],
	'REGEXPS' : {
		'command' : {
			'search' : '()(\\\\[^a-zA-Z\\[\\]\\(\\)]|\\\\[a-zA-Z]+)()',
			'class' : 'command',
			'modifiers' : 'g',
			'execute' : 'before'
		},
		'math1' : {
			'search' : '()(\\$\\$[^]*?[^\\\\]\\$\\$|\\$[^]*?[^\\\\]\\$)()',
			'class' : 'math',
			'modifiers' : 'g',
			'execute' : 'before'
		},
		'math2' : {
			'search' : '()(\\\\\\([^]*?[^\\\\]\\\\\\))()|()(\\\\\\[[^]*?[^\\\\]\\\\\\])()',
			'class' : 'math',
			'modifiers' : 'g',
			'execute' : 'before'
		}
	},
	'STYLES' : {
		'COMMENTS' : 'color: #0000ff;',
		'DELIMITERS' : 'color: #a52a2a;',
		'REGEXPS' : {
			'command' : 'color: #2eab57;',
			'math' : 'background-color: #dddddd;'
		}
	}
};
