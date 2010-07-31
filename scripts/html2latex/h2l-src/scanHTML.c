/*

             HTML 2.0 scanner

This package contains a simple HTML 2.0 scanner which recognizes
HTML constructs. It does not perform parsing.

The package is written in ANSI C. You must compile it with an
ANSI compliant compiler. Specifically, the compiler must
- support prototypes
- support functions which return structs
- support the ANSI C standard libraries
- implement "toupper" in a standard-conforming way (leaving
  characters other than A-Z intact).

The package was designed to be portable, modular, and efficient.
For efficiency reasons, and at the expense of modularity,
the scanner uses a character input routine with a fixed name
instead of calling a function passed as a parameter.

The scanner routine is called "scanHTML". It uses "nextch()" for
getting the next character (or EOF) from the input stream. Here
"nextch" is essentially defined as a macro which expands to "getch",
but it can of course be changed into any suitable macro or function.
The scanner "scanHTML" returns, as the function return value, a
struct of type "HTMLelem" with the following fields:
  - "type": of an enumerated type "elemtype", reflecting the kind
    of HTML element in question, or H_text if plain text between
    HTML elements
  - "is_end": 1 or 0 (logically, a truth value), depending on
    whether the construct is terminating like </h1> or not
  - "value": pointer to a string containing either the contents
    of the HTML element (dropping out the initial <, the following
    word and space, plus the final >) or, for H_text, the text
    between HTML elements.

The scanner allocates the strings pointed to by "value" fields dynamically,
using "malloc". You may wish (or you may need) to dispose of them,
using "free", after making use of the data.

HTML comments are ignored. More generally, anything from <! to the
next > is ignored. (Perhaps it would be better to change the code
so that a comment is returned as a special kind of "HTMLelem".)

Special character notations &lt; etc. are not converted. Thus, they
should be processed at a higher level, in a parser.

Author: Jukka Korpela, http://www.hut.fi/~jkorpela/

Date:   March 11, 1996

*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "scanHTML.h"

/* Configuration parameters: */

#define nextch() if((ch=getc(f))=='\n')linenr++
/* "nextch" can be changed to a function which reads a character and
   assigns it (or EOF) to "ch", or to a macro with the same effect.
   It must also update the line number counter in a manner similar
   to the code above. */

#define BLOCKSIZE 1000
/* The constant above defines how many bytes are _initially_ allocated
   for a string. When the entire string has been read, the size is
   realloc'ed to correspond to the actual length. */
#define NAMELEN 100
/* Maximum length of HTML element names.
   According to HTML 2.0 specification, 72 would be sufficient. */

/* The following definitions implement the recognized HTML element names. */
/* The array "names" must contain the names in alphabetic order, since
   table lookup is done using binary search. */

char *names[] =
  {
"A", "ABBREV", "ACRONYM", "ADDRESS", "APP", "APPLET", "AREA", "AU", "B",
"BANNER", "BASE", "BASEFONT", "BDO", "BGSOUND", "BIG", "BLINK", "BLOCKQUOTE",
"BODY", "BQ", "BR", "CAPTION", "CENTER", "CITE", "CODE", "COL", "COLGROUP",
"CREDIT", "DD", "DEL", "DFN", "DIR", "DIV", "DL", "DT", "EM", "EMBED", "FN",
"FIG", "FONT", "FORM", "FRAME", "FRAMESET", "H1", "H2", "H3", "H4", "H5",
"H6", "HEAD", "HP", "HR", "HTML", "I", "IMG", "INPUT", "INS", "ISINDEX",
"KBD", "LANG", "LH", "LI", "LINK", "LISTING", "MAP", "MARQUEE", "MENU", "META",
"NEXTID", "NOBR", "NOEMBED", "NOFRAMES", "NOTE", "OL", "OPTION", "OVERLAY",
"P", "PARAM", "PERSON", "PLAINTEXT", "PRE", "Q", "S", "SAMP", "SELECT",
"SMALL", "SPAN", "STRIKE", "STRONG", "SUB", "SUP", "TAB", "TABLE", "TBODY",
"TD", "TEXTAREA", "TFOOT", "TH", "THEAD", "TITLE", "TR", "TT", "U", "UL",
"VAR", "WBR", "XMP"
  };

#define NNAMES ((sizeof(names)/sizeof(char *)))

/* Global variable (for counting lines): */

long linenr = 1;

/* Error routines: */

static void out_of_memory(void)
{
fprintf(stderr, "scanHTML: Capacity restriction - cannot allocate enough memory.\n");
fprintf(stderr, "scanHTML: Aborting.\n");
exit(EXIT_FAILURE);
}

static void HTMLerror(char *msg, char *context)
{
#ifndef NOWARN
fprintf(stderr, "scanHTML: Error in HTML code: %s\n", msg);
fprintf(stderr, "scanHTML: Additional information: \
line number %ld, data %s\n", linenr, context);
#endif
}

/* The scanner itself: */

#define check_index \
if(++len >= buffersize)\
  if( (elem.value = realloc(elem.value,buffersize+=BLOCKSIZE)) == NULL)\
    out_of_memory();\
  else\
    pos = elem.value + len - 1;

HTMLelem scanHTML(FILE *f)
{

HTMLelem elem = { H_eof, 0, NULL };
long len = 0;
long buffersize = BLOCKSIZE;
static int ch = '\0';
char *pos;

if(ch == '\0') /* first invocation of this function */
   nextch();

if( (elem.value = malloc(BLOCKSIZE)) == NULL) out_of_memory();

pos = elem.value;

again :

if(ch == EOF) return elem;

if(ch == '<')
  {
  char name[NAMELEN+1], *nameptr = name;
  int index = 0;
  int low, high, mid;
  int order;
  nextch();
  if( ch == '/' )
    {
    elem.is_end = 1;
    nextch();
    }
  else if ( ch == '!') /* skip comment */
    {
    do
      nextch();
      while( ch != '>'  && ch != EOF );
    if(ch == EOF)
      HTMLerror("no closing > in HTML comment", name);
    else
      nextch();
    goto again;    
    }
  /* read element name */
  while(isalnum(ch) && ++index < NAMELEN)
    {
    *nameptr++ = toupper(ch);
      /* If name is longer than NAMELEN, there is an HTML error
         which is detected in the table lookup, so don't worry here. */
    nextch();
    }
  *nameptr = '\0';

  /* Table lookup to recognize the element name.
     Could use "bsearch", but this is faster. */
  low = 0;
  high = NNAMES-1;
  elem.type = H_unrecognized;
  do
    {
    mid = (high + low) / 2;
    order = strcmp(name, names[mid]);
    if(order <= 0)
      high = mid - 1;
    if(order >= 0)
      low = mid + 1;
    }
    while(low <= high);
  if(low-1 > high)
    elem.type = (elemtype) mid;
  else
    HTMLerror("unrecognized element name", name);

  if(isspace(ch))
    do
      nextch();
      while(isspace(ch));
  else if(ch != '>')
    HTMLerror("no white space after element name", name);
  /* read rest of element, storing pointer to it to elem.value */
  while( ch != '>'  && ch != EOF )
    {
    check_index;
    *pos++ = ch;
    nextch();
    }
  *pos = '\0';
  if(ch == EOF)
    HTMLerror("no closing > in HTML element", name);
  else
    nextch();
  }

else /* just text between HTML elements */
  {
  elem.type = H_text;
  do
    {
    check_index;
/* The following code would turn multiple white space into a single blank,
   as suggested by HTML specification. It is turned off, however,
   since the scanner might be used eg for modifying HTML files, and
   in that case one probably wants to preserve the original layout.
   Thus, multiple white space stuff should be processed at a higher
   level, in a parser, if desired.
   Notice that this approach removes the problem of using different
   character processing routines for normal text and text between eg
   <PRE> and </PRE> tags. */
#if 0
    if(isspace(ch))
      {
      do
        nextch();
        while(isspace(ch));
      *pos++ = ' ';
      }
    else
#endif
      {
      *pos++ = ch;
      nextch();
      }
    }
    while( ch != '<'  && ch != EOF );
  *pos = '\0';
  }

return elem;

}
