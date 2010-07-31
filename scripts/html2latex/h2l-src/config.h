/* Configuration file for the h2l program.
   See http://www.hut.fi/~jkorpela/h2l/

   You can modify the definitions to suit your needs, environment
   and preferences. Notice that the macros are defined so that
   you can override the definitions given here by providing
   compile time options.
*/

/* DOC_URL is the URL for the description of the program.
   It is displayed in some messages from the program. */

#ifndef DOC_URL
#define DOC_URL "http://www.hut.fi/~jkorpela/h2l/"
#endif

/* When invoked improperly, the program issues a message
   containing USAGE and DOC_URL. */

#ifndef USAGE
#define USAGE "usage: please see "
#endif

/* ID is a message written to the LaTeX file (in a comment). */

#ifndef ID
#define ID "% Converted from HTML to LaTeX with h2l"
#endif

/* VERSION is the h2l version number. It is also written to the
   LaTeX file (in a comment). */

#ifndef VERSION
#define VERSION "0.9"
#endif

/* HTML_EXTENSION is the file name suffix recognized by h2l. */

#ifndef HTML_EXTENSION
#define HTML_EXTENSION ".html"
#endif

/* DEF_CLASS, DEF_CLASS_OPTS, DEF_PACKS, and DEF_PRELUDE define the default
   documentclass, documentclass options, usepackage, and prelude definitions. */

/* The following is for LaTeX 2e, Finnish text, article documents,
   Finnish layout style. */

#ifndef DEF_CLASS
#define DEF_CLASS "report"
#endif

#ifndef DEF_CLASS_OPTS
#define DEF_CLASS_OPTS "a4paper,finnish"
#endif

#ifndef DEF_PACKS
#define DEF_PACKS "t1enc,isolatin1,babel"
#endif

#ifndef DEF_PRELUDE
#define DEF_PRELUDE ""
#endif

/* Default settings for options. 0 means off, 1 means on.
   OPT_NUM, OPT_PAGES, OPT_CONT, OPT_STDOUT correspond to
     -n       -p         -c         -s
   in the command line. */

#ifndef OPT_NUM
#define OPT_NUM 0
#endif

#ifndef OPT_PAGES
#define OPT_PAGES 0
#endif

#ifndef OPT_CONT
#define OPT_CONT 0
#endif

#ifndef OPT_STDOUT
#define OPT_STDOUT 0
#endif

/* You may also wish to define NOWARN, in which case no warning
   messages are issued about HTML constructs not supported yet
   or about syntax errors in HTML elements. */
