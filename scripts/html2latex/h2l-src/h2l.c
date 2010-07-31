/*

HTML (2.0) to LaTeX (2e) converter

The program accepts HTML code as input and outputs corresponding LaTeX code.
See http://www.hut.fi/~jkorpela/tools/h2l.html for more information.

The program is believed to be ANSI C conformant and portable except for
- the use of "getopt" library
- character code dependency: the character set should be ASCII or
  an extension of ASCII

Author: Jukka Korpela, http://www.hut.fi/~jkorpela/ 

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>

#include "config.h"

#include "scanHTML.h"

/* You may need to turn the following include if "getopt" is
   not declared in stdio.h */
#if 0
#include <getopt.h>
#endif

typedef struct { char *name; char rep; } esc_mapping;

static esc_mapping escmap[] = {
  { "lt", '<' },
  { "gt", '>' },
  { "amp", '&' },
  { "quot", '\"' },
  };

FILE *fpin, *fpout;

char current_date[20];

/* option_t is used to enumerate the options */
typedef enum {
  o_author, o_title, o_number, o_page, o_contents, o_stdout, o_header,
  o_footer, o_class, o_options, o_preamble, o_error
} option_t;

/* global variables for options */

char *option_string="npcst:a:h:f:o:O:C:";	/* getopts string */
char option[o_error+1] =		/* booleans -- if given or not */
  { 0, 0, OPT_NUM, OPT_PAGES, OPT_CONT, OPT_STDOUT, 0, 0, 0, 0, 0 };
char *option_s[o_error+1];		/* strings if needed */
int option_i[o_error+1];		/* integers if needed */

char *documentclass = DEF_CLASS;
int article_class;
char *sectioning[] =
  { "chapter",
    "section",
    "subsection",
    "subsubsection",
    "paragraph",
    "subparagraph" };

/* Flags describing "modes" of HTML processing or LaTeX generation: */

int preformatted = 0;

int math_mode_nesting = 0;

int first_note = 1;

/* The logical level of nesting of constructs implemented using
   math mode. Used in order to prevent emitting $'s incorrectly
   when there are eg nested subscripts. */

/* safe malloc() code.  Does the checking for NULL returns from malloc() */

void *s_malloc(size_t size) {
  void *f = malloc(size);
  if (!f) {
    fprintf(stderr, "cannot allocate memory\n");
    exit(1);
  }
  return f;
}

void get_date(void)
{
time_t now = time(NULL);
strftime(current_date,20,"%B %d, %Y",localtime(&now));
}

char special_char(char *name)
{
int i;
for(i=0; i < sizeof(escmap)/sizeof(esc_mapping); i++)
  if(strcmp(name,escmap[i].name)==0)
    return escmap[i].rep;
return '\0'; /* to signal that the name was unknown */
}

void char_to_latex(char ch)
/* Outputs a character in a form acceptable to LaTeX.
   This means eg that < must be represented as $<$  */

/* this could be made more efficiently using an array */

{
if(preformatted)
  putc(ch, fpout);
else
  switch(ch) {
    case '^':
      fputs("\\^{}", fpout);
      return;
    case '\\':
      fputs("$\\backslash$", fpout);
      return;
    /* The following two cases are handled in a brutal way, but
       haven't figured out anything better. The LaTeX documentation
       is not very explicit as regards to tilde and double quote
       characters, but simple \~ seems to get combined with the
       following character and " by itself seems to eat up
       the following space. */
    case '~':
      fputs("{\\char'0176}", fpout);
      return;
    case '"': /* the double quote _is_ a metasymbol in LaTeX! */
      fputs("{\\char'042}", fpout);
      return;
    case '-': /* output as "- to get hyphenation right */
      fputs("\"-", fpout);
      return;
    case '&':
    case '$':
    case '{':
    case '}':
    case '%':
    case '#':
    case '_':
      putc('\\', fpout);
      /* fall thru! */
    default:
      putc(ch, fpout);
      return;
    }
}

void string_to_latex(char *s)
/* Outputs the string pointed to by "s" in a form acceptable to LaTeX.
   This means eg that &lt; must be converted to < and that several
   characters must be quoted or presented otherwise to prevent
   them from acting as LaTeX control characters. The conversion to
   LaTeX presentation is done in char_to_latex function. */

/* Note: &#nn not handled yet. */

{
while(*s != '\0')
  {
  if( *s == '&' )
      {
#define N 80
      char name[N], *nameptr = name;
      char *tmp = s+1;
      char rep;
      int i = 0;
      while(isalpha(*tmp) && ++i < N)
        *nameptr++ = *tmp++;
      *nameptr = '\0';
      /* terminating semicolon is allowed but not required: */
      if(*tmp == ';')
        tmp++;
      if( (rep = special_char(name)) == '\0' )
	/* Not a recognized ampersand escape. Print out the
           ampersand character (in LaTeX representation) and
           continue normal processing from the character
           following it. */
        {
	char_to_latex('&');
	s++;
	}
      else
	/* A recognized ampersand escape. Print out the character
	   represented (in LaTeX representation) and continue
           normal processing from the character following the escape. */
        {
	char_to_latex(rep);
	s = tmp;
        }
      }
  else if(isspace(*s) && !preformatted)
    /* Convert a sequence of white space into a single blank or newline.
       Notice that two or more consecutive newlines MUST NOT be output
       as such, since LaTeX would produce a new paragraph, contrary
       to HTML semantics. */
    {
    int newline_seen = *s == '\n';
    while(isspace(*++s))
      if(*s == '\n')
        newline_seen = 1;;
    if(newline_seen)
      putc('\n', fpout);
    else
      putc(' ', fpout);
    }
  else /* normal character */
    {
    char_to_latex(*s);
    s++;
    }
  }
}

void niye(char *element_name)
{
#ifndef NOWARN
fprintf(stderr,"h2l: HTML element %s not implemented yet.\n", element_name);
#endif
}

void process_options(int argc, char **argv)
{
  option_t opt;
  int c;

  for (opt = 0; opt != o_error; opt++) {
    option[opt] = 0;
    option_s[opt] = NULL;
    option_i[opt] = 0;
  }
    
  while ((c = getopt(argc, argv, option_string)) != EOF)
    switch(c) {
    case 'n':
      option[o_number]=1;
      break;
    case 't':
      option_s[o_title] = optarg;
      option[o_title] = 1;
      break;
    case 'a':
      option_s[o_author] = optarg;
      option[o_author] = 1;
      break;
    case 'p':
      option[o_page] = 1;
      break;
    case 'c':
      option[o_contents] = 1;
      break;
    case 's':
      option[o_stdout] = 1;
      break;
    case 'h':
      option[o_header] = 1;
      option_s[o_header] = optarg;
      break;
    case 'f':
      option[o_footer] = 1;
      option_s[o_footer] = optarg;
      break;
    case 'C':
      option[o_class] = 1;
      option_s[o_class] = optarg;
      documentclass = optarg;
      break;
    case 'o':
      option[o_options] = 1;
      option_s[o_options] = optarg;
      break;
    case 'O':
      option[o_preamble] = 1;
      option_s[o_preamble] = optarg;
      break;
    case '?':
      option[o_error] = 1;
      break;
    }
  if (option[o_error] || optind == argc) {
    fprintf(stderr, "%s%s\n", USAGE, DOC_URL);
    exit(1);
  }
}

void write_headers(void)
{
  /* LaTeX headers and title pages, etc */
    fprintf(fpout, "%s version %s.\n", ID, VERSION);
    fprintf(fpout, "%% See %s\n", DOC_URL);
    fprintf(fpout, "%% Conversion date: %s\n", current_date);
    fprintf(fpout, "\\documentclass[%s]{%s}\n",
	    option[o_options] ? option_s[o_options] : DEF_CLASS_OPTS,
	    documentclass);
    fprintf(fpout, "\\usepackage{%s}\n", DEF_PACKS);
    if (option[o_preamble])
       fprintf(fpout, "\n%s\n", option_s[o_preamble]);
    fprintf(fpout, "\\begin{document}\n");
    if (option[o_header])
      fprintf(fpout, "%s", option_s[o_header]);
    else
      fprintf(fpout, "%s", DEF_PRELUDE);
    if (option[o_title]) {
      fprintf(fpout, "\\title{");
      string_to_latex(option_s[o_title]);
      fprintf(fpout, "}\n");
    }
    if (option[o_author]) {
      fprintf(fpout, "\\author{");
      string_to_latex(option_s[o_author]);
      fprintf(fpout, "}\n");
    } else if (option[o_title])
      fprintf(fpout, "\\author{}\n");
      
    if (option[o_title] || option[o_author]) {
      fprintf(fpout, "\\maketitle\n");
      if (option[o_page])
	fprintf(fpout, "\\newpage\n");
    }
    if (option[o_contents])  {
      fprintf(fpout, "\\tableofcontents \n");
      if (option[o_page])
	fprintf(fpout, "\\newpage\n");
    }
}

void write_trailers(void)
{
    if (option[o_footer])
      fprintf(fpout, "%s", option_s[o_footer]);
    fprintf(fpout, "\\end{document}\n");
}

#define environ(e) if(elem.is_end)fputs("\\end{"e"}",fpout);\
else fputs("\\begin{"e"}",fpout)

#define command(e) if(elem.is_end)putc('}',fpout);\
else fputs("\\"e"{",fpout)

#define font(e) if(elem.is_end)putc('}',fpout);\
else fputs("{\\"e" ",fpout)

void process_HTML()
{
for(;;)
  {
  HTMLelem elem;
  elemtype hdrtype;
  elem = scanHTML(fpin);
  switch(hdrtype = elem.type) {

case H_A :
  /* Ignored. One might consider converting some A HREF's and
     A NAME's to cross references or footnotes, under user's
     control with options. */
  break;

case H_ABBREV :
  /* Ignored, ie use normal text style. */
  break;

case H_ACRONYM :
  /* Ignored, ie use normal text style. */
  break;

case H_ADDRESS :
  /* Ignored, ie use normal text style. */
  /* But we might consider using the following if in letter style. */
#if 0  
  command("address");
#endif
  break;

case H_APP :
  niye(names[H_APP]);
  break;

case H_APPLET :
  niye(names[H_APPLET]);
  break;

case H_AREA :
  niye(names[H_AREA]);
  break;

case H_AU :
  font("sc");
  break;

case H_B :
  font("bf");
  break;

case H_BANNER :
  niye(names[H_BANNER]);
  break;

case H_BASE :
  /* Ignore. If A HREF's will be processed, then H_BASE should
     be taken into account. */
  break;

case H_BASEFONT :
  niye(names[H_BASEFONT]);
  break;

case H_BDO :
  niye(names[H_BDO]);
  break;

case H_BGSOUND :
  /* Ignore. */
  break;

case H_BIG :
  font("large");
  break;

case H_BLINK :
  /* Ignore. */
  break;

case H_BLOCKQUOTE :
  environ("quotation");
  break;

case H_BODY :
  /* Ignore. */
  break;

case H_BQ :
  environ("quotation");
  break;

case H_BR :
  fputs("\\\\", fpout);
  break;

case H_CAPTION :
  niye(names[H_CAPTION]);
  break;

case H_CENTER :
  environ("center");
  break;

case H_CITE :
  font("it");
  break;

case H_CODE :
  font("tt");
  break;

case H_COL :
  niye(names[H_COL]);
  break;

case H_COLGROUP :
  niye(names[H_COLGROUP]);
  break;

case H_CREDIT :
  /* Ignore, ie use normal font. */
  break;

case H_DD :
  if(!elem.is_end)
    putc(']',fpout);
  break;

case H_DEL :
  niye(names[H_DEL]);
  break;

case H_DFN :
  font("bf\\it");
  break;

case H_DIR :
  environ("itemize");
  break;

case H_DIV :
  niye(names[H_DIV]);
  break;

case H_DL :
  environ("description");
  break;

case H_DT :
  if(!elem.is_end)
    fputs("\\item[", fpout);
  break;

case H_EM :
  font("it");
  break;

case H_EMBED :
  niye(names[H_EMBED]);
  break;

case H_FN :
  command("footnote");
  break;

case H_FIG :
  niye(names[H_FIG]);
  break;

case H_FONT :
  niye(names[H_FONT]);
  break;

case H_FORM :
  niye(names[H_FORM]);
  break;

case H_FRAME :
  niye(names[H_FRAME]);
  break;

case H_FRAMESET :
  niye(names[H_FRAMESET]);
  break;

case H_H6 :
  if(article_class)
    /* There is no suitable LaTeX construct, so we just output
       the heading as a separate paragraph using normal font. */
    {
    fputs("\\par", fpout);
    break;
    }
  /* else fall thru! */

case H_H1 :
case H_H2 :
case H_H3 :
case H_H4 :
case H_H5 :
  if (elem.is_end)
    putc('}', fpout);
  else
    {
    putc('\\', fpout);
    /* Pick up a suitable environment from the array "sectioning",
       omitting the first entry, "chapter", if we have article class. */
    fputs(sectioning[article_class + (int) (elem.type - H_H1)], fpout);
    if(!option[o_number])
      putc('*', fpout);
    putc('{', fpout);
    }
  break;

case H_HEAD :
  /* Ignore. */
  break;

case H_HP :
  niye(names[H_HP]);
  break;

case H_HR :
  fputs("\\vspace{5mm}\\hrule\\vspace{5mm}", fpout);
  break;

case H_HTML :
  /* Ignore. */
  break;

case H_I :
  font("it");
  break;

case H_IMG :
  niye(names[H_IMG]);
  break;

case H_INPUT :
  niye(names[H_INPUT]);
  break;

case H_INS :
  niye(names[H_INS]);
  break;

case H_ISINDEX :
  niye(names[H_ISINDEX]);
  break;

case H_KBD :
  font("tt\\bf");
  break;

case H_LANG :
  niye(names[H_LANG]);
  break;

case H_LH :
  niye(names[H_LH]);
  break;

case H_LI :
  fputs("\\item ", fpout);
  break;

case H_LINK :
  /* Ignore. */
  break;

case H_LISTING :
  environ("verbatim");
  preformatted = !elem.is_end;
  break;

case H_MAP :
  niye(names[H_MAP]);
  break;

case H_MARQUEE :
  niye(names[H_MARQUEE]);
  break;

case H_MENU :
  environ("itemize");
  break;

case H_META :
  niye(names[H_META]);
  break;

case H_NEXTID :
  niye(names[H_NEXTID]);
  break;

case H_NOBR :
  command("mbox");
  break;

case H_NOEMBED :
  niye(names[H_NOEMBED]);
  break;

case H_NOFRAMES :
  niye(names[H_NOFRAMES]);
  break;

case H_NOTE :
  /* This could probably be implemented in a more elegant way. */
  if(elem.is_end)
    fputs("\\end{minipage}}", fpout);
  else
    {
    if(first_note)
      {
      fputs("\\setlength{\\fboxrule}{2pt}\\setlength{\\fboxsep}{2mm}\n", fpout);
      first_note = 0;
      }
    fputs("\\fbox{\\begin{minipage}{\\textwidth}", fpout);
    }
  break;

case H_OL :
  environ("enumerate");
  break;

case H_OPTION :
  niye(names[H_OPTION]);
  break;

case H_OVERLAY :
  niye(names[H_OVERLAY]);
  break;

case H_P :
  fputs("\\par", fpout);
  break;

case H_PARAM :
  niye(names[H_PARAM]);
  break;

case H_PERSON :
  font("sc");
  break;

case H_PLAINTEXT :
  /* The following is not satisfactory, since markup should not be
     recognized. But it works in some cases. */
  environ("verbatim");
  preformatted = !elem.is_end;
  break;

case H_PRE :
  environ("verbatim");
  preformatted = !elem.is_end;
  break;

case H_Q :
  fputs("{\\char'042}", fpout);
  break;

case H_S :
  niye(names[H_S]);
  break;

case H_SAMP :
  font("tt");
  break;

case H_SELECT :
  niye(names[H_SELECT]);
  break;

case H_SMALL :
  font("small");
  break;

case H_SPAN :
  niye(names[H_SPAN]);
  break;

case H_STRIKE :
  niye(names[H_STRIKE]);
  break;

case H_STRONG :
  font("bf");
  break;

case H_SUB :
  /* Use LaTeX math mode. */
  if (elem.is_end)
    {
    putc('}', fpout);
    if(--math_mode_nesting == 0)
      putc('$', fpout);
    }
  else
    {
    if(math_mode_nesting++ == 0)
      putc('$', fpout);
    fputs("_{", fpout);
    }
  break;

case H_SUP :
  /* Use LaTeX math mode. */
  if (elem.is_end)
    {
    putc('}', fpout);
    if(--math_mode_nesting == 0)
      putc('$', fpout);
    }
  else
    {
    if(math_mode_nesting++ == 0)
      putc('$', fpout);
    fputs("^{", fpout);
    }
  break;

case H_TAB :
  niye(names[H_TAB]);
  break;

case H_TABLE :
  niye(names[H_TABLE]);
  break;

case H_TBODY :
  niye(names[H_TBODY]);
  break;

case H_TD :
  niye(names[H_TD]);
  break;

case H_TEXTAREA :
  niye(names[H_TEXTAREA]);
  break;

case H_TFOOT :
  niye(names[H_TFOOT]);
  break;

case H_TH :
  niye(names[H_TH]);
  break;

case H_THEAD :
  niye(names[H_THEAD]);
  break;

case H_TITLE :
  if (elem.is_end)
    putc('}', fpout);
  else
    fputs("\\title{", fpout);
  break;
  /* Must consider how to deal with titles given as options. */
  /* Perhaps that option should be removed? */

case H_TR :
  niye(names[H_TR]);
  break;

case H_TT :
  font("tt");
  break;

case H_U :
  environ("underline");
  break;

case H_UL :
  environ("itemize");
  break;

case H_VAR :
  font("it"); /* might consider "sl" as an alternative */
  break;

case H_WBR :
  /* The following is not satisfactory since LaTeX \- prohibits
     hyphenation of a word except in points specified by \- */
#if 0
  fputs("\\-", fpout);
#endif
  niye(names[H_WBR]);
  break;

case H_XMP :
  /* The following is not satisfactory, since markup should not be
     recognized. But it works in some cases. */
  environ("verbatim");
  preformatted = !elem.is_end;
  break;

case H_unrecognized :
  break;

case H_text :
  string_to_latex(elem.value);
  break;

case H_eof :
  return;

default :
  fprintf(stderr,"h2l: Internal error!\n");
  break;

    } /* end of switch */

  free(elem.value);

  } /* end of for */
}

void process_file(void)
{
write_headers();
process_HTML();
write_trailers();
}

int main(int argc, char **argv)
{
  char *fin, *fout;
  get_date();
  process_options(argc, argv);
  article_class = strcmp(documentclass,"article") == 0;
  fpin = stdin;
  fpout = stdout;
  do {
    if (optind != argc)
      if (!strcmp(argv[optind], "-")) {
	/* read from standard in and write to standard out */
	fpin = stdin;
	fpout = stdout;
      } else {
	/* must find filenames and open ourselves */
	char *s;
	fin = s_malloc(sizeof(char)*(strlen(argv[optind])+6));
	fout = s_malloc(sizeof(char)*(strlen(argv[optind])+5));
	strcpy(fin, argv[optind]);
	strcpy(fout, argv[optind]);
	s = strrchr(fout, '.');
	if (s != NULL && !strcmp(s, HTML_EXTENSION))
	  /* file given as foo.html */
	  strcpy(strrchr(fout, '.'), ".tex");
	else {
	  /* file given as foo, as we must add .tex and .html */
	  strcat(fout, ".tex");
	  /* check if .html needed */
	  fpin = fopen(fin, "r");		/* if it opens, use it */
	  if (fpin)
	    fclose(fpin);
	  else
	    strcat(fin, HTML_EXTENSION);		/* otherwise try .html */
	}
	/* filenames are decided and allocated -- try and open */
	if (!(fpin = fopen(fin, "r"))) {
	  fprintf(stderr, "can't open file %s for reading.\n", fin);
	  free(fin);
	  free(fout);
	  optind++;
	  continue;
	}
	if (option[o_stdout])
	  fpout = stdout;
	else if (!(fpout = fopen(fout, "w"))) {
	  fprintf(stderr, "can't open file %s for writing.\n", fin);
	  free(fin);
	  free(fout);
	  fclose(fpin);
	  optind++;
	  continue;
	}
      }
    
    process_file();

    /* if we processed a file, then we malloc()ed memory.  Free it */
    if (optind != argc && !strcmp(argv[optind], "-")) {
      free(fin);
      free(fout);
      fclose(fpin);
      if (!option[o_stdout])
	fclose(fpout);
    }
    /* move on to next argument */
    optind++;
  } while (optind != argc);

  return 0;
}
