/****************************************************************************
 * NCSA Mosaic for the X Window System                                      *
 * Copyright (C) 1993                                                       *
 * National Center for Supercomputing Applications                          *
 * Software Development Group                                               *
 * 605 E. Springfield, Champaign IL 61820                                   *
 *                                                                          *
 * The NCSA software Mosaic, both binary and source, is copyrighted,        *
 * but available without fee for education, academic research and           *
 * non-commercial purposes.  The software is copyrighted in the name of     *
 * the University of Illinois, and ownership of the software remains with   *
 * the University of Illinois.  Users may distribute the binary and         *
 * source code to third parties provided that the copyright notice and      *
 * this statement appears on all copies and that no charge is made for      *
 * such copies.  Any entity wishing to integrate all or part of the         *
 * source code into a product for commercial use or resale, should          *
 * contact the University of Illinois, c/o NCSA, to negotiate an            *
 * appropriate license for such commercial use.                             *
 *                                                                          *
 * THE UNIVERSITY OF ILLINOIS MAKES NO REPRESENTATIONS ABOUT THE            *
 * SUITABILITY OF THE SOFTWARE FOR ANY PURPOSE.  IT IS PROVIDED "AS IS"     *
 * WITHOUT EXPRESS OR IMPLIED WARRANTY.  THE UNIVERSITY OF ILLINOIS SHALL   *
 * NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY THE USER OF THIS SOFTWARE.     *
 * The software may have been developed under agreements between the        *
 * University of Illinois and the Federal Government which entitle the      *
 * Government to certain rights.                                            *
 *                                                                          *
 * By copying this program, you, the user, agree to abide by the            *
 * copyright conditions and understandings with respect to any software     *
 * which is marked with a copyright notice.                                 *
 *                                                                          *
 * If you have problems or comments about NCSA Mosaic, please feel free     *
 * to mail them to marca@ncsa.uiuc.edu.                                     *
 ****************************************************************************/

#ifdef TIMING
#include <sys/time.h>
struct timeval Tv;
struct timezone Tz;
#endif

#include <stdio.h>
#include <string.h>
#include <ctype.h>
/* To get atoi. */
#include <stdlib.h>

#include "HTMLparse.h"


/*
 * prototypes
 */
static int caseless_equal(char *, char *);
static void clean_white_space(char *);
static void clean_text(char *);
static char *get_text(char *, char **);
static struct mark_up *get_mark(char *, char **);
static char *get_plain_text(char *, char **);
static int ParseMarkType(char *);


#ifdef NOT_ASCII
#define TOLOWER(x)	(tolower(x))
#else

char *mark_text[] = { "", "",
  "title", "h1", "h2", "h3", "h4", "h5", "h6", "a", "p", "address",
  "xmp", "ul", "li", "dl", "dt", "dd", "pre", "plaintext", "listing",
  "isindex", "menu", "dir", "img", "ol", "em", "tt", "b", "i", "u",
  "strong", "code", "samp", "kbd", "var", "dfn", "cite", "span", "gnat"
  };

/*
 * A hack to speed up caseless_equal.  Thanks to Quincey Koziol for
 * developing it for me
 */
static unsigned char map_table[256]={
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,
    24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,
    45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,97,98,
    99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,
    116,117,118,119,120,121,122,91,92,93,94,95,96,97,98,99,100,101,102,
    103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,
    120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,
    137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,
    154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,
    171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,
    188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,
    205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,
    222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,
    239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255};

#define TOLOWER(x)	(map_table[x])
#endif /* NOT_ASCII */


/*
 * Check if two strings are equal, ignoring case.
 * The strings must be of the same length to be equal.
 * return 1 if equal, 0 otherwise.
 */
static int
caseless_equal(str1, str2)
	char *str1;
	char *str2;
{
	if ((str1 == NULL)||(str2 == NULL))
	{
		return(0);
	}

	while ((*str1 != '\0')&&(*str2 != '\0'))
	{
		if (TOLOWER(*str1) != TOLOWER(*str2))
		{
			return(0);
		}
		str1++;
		str2++;
	}

	if ((*str1 == '\0')&&(*str2 == '\0'))
	{
		return(1);
	}
	else
	{
		return(0);
	}
}


/*
 * Clean up the white space in a string.
 * Remove all leading and trailing whitespace, and turn all
 * internal whitespace into single spaces separating words.
 * The cleaning is done by rearranging the chars in the passed
 * txt buffer.  The resultant string will probably be shorter,
 * it can never get longer.
 */
static void
clean_white_space(txt)
	char *txt;
{
	char *ptr;
	char *start;

	ptr = txt;

	/*
	 * Remove leading white space
	 */
	while ((*ptr == ' ')||(*ptr == '\t')||(*ptr == '\n'))
	{
		ptr++;
	}
	start = ptr;

	/*
	 * find a word, copying if we removed some space already
	 */
	if (start == ptr)
	{
		while ((*ptr != ' ')&&(*ptr != '\t')&&(*ptr != '\n')&&
			(*ptr != '\0'))
		{
			ptr++;
		}
		start = ptr;
	}
	else
	{
		while ((*ptr != ' ')&&(*ptr != '\t')&&(*ptr != '\n')&&
			(*ptr != '\0'))
		{
			*start++ = *ptr++;
		}
	}

	while (*ptr != '\0')
	{
		/*
		 * Remove trailing whitespace.
		 */
		while ((*ptr == ' ')||(*ptr == '\t')||(*ptr == '\n'))
		{
			ptr++;
		}
		if (*ptr == '\0')
		{
			break;
		}

		/*
		 * If there are more words, insert a space and if space was 
		 * removed move up remaining text.
		 */
		*start++ = ' ';
		if (start == ptr)
		{
			while ((*ptr != ' ')&&(*ptr != '\t')&&(*ptr != '\n')&&
				(*ptr != '\0'))
			{
				ptr++;
			}
			start = ptr;
		}
		else
		{
			while ((*ptr != ' ')&&(*ptr != '\t')&&(*ptr != '\n')&&
				(*ptr != '\0'))
			{
				*start++ = *ptr++;
			}
		}
	}

	*start = '\0';
}


/*
 * Clean the special HTML character escapes out of the text and replace
 * them with the appropriate characters "&lt;" = "<", "&gt;" = ">",
 * "&amp;" = "&"
 * GAG:  apperantly &lt etc. can be left unterminated, what a nightmare.
 * the '&' character must be immediately followed by a letter to be
 * a valid escape sequence.  Other &'s are left alone.
 * The cleaning is done by rearranging chars in the passed txt buffer.
 * if any escapes are replaced, the string becomes shorter.
 */
static void
clean_text(txt)
	char *txt;
{
	int unterminated;
	char *ptr;
	char *ptr2;
	char *ptr3;
	char *start;
	char *text;
	char tchar;

	if (txt == NULL)
	{
		return;
	}

	/*
	 * Quick scan to find escape sequences.
	 * Escape is '&' followed by a letter (or a hash mark).
	 * return if there are none.
	 */
	ptr = txt;
	while (*ptr != '\0')
	{
		if ((*ptr == '&')&&
			((isalpha((int)*(ptr + 1)))||(*(ptr + 1) == '#')))
		{
			break;
		}
		ptr++;
	}
	if (*ptr == '\0')
	{
		return;
	}

	/*
	 * Loop, replaceing escape sequences, and moving up remaining
	 * text.
	 */
	ptr2 = ptr;
	while (*ptr != '\0')
	{

		unterminated = 0;
		/*
		 * Extract the escape sequence from start to ptr
		 */
		start = ptr;
		while ((*ptr != ';')&&(*ptr != '\0'))
		{
			ptr++;
		}
		if (*ptr == '\0')
		{
#ifdef VERBOSE
			fprintf(stderr, "warning:  unterminated & (%s)\n",
				start);
#endif
			unterminated = 1;
		}

		/*
		 * Copy the escape sequence into a separate buffer.
		 * Then clean spaces so the "& lt ;" = "&lt;" etc.
		 * The cleaning should be unnecessary.
		 */
		tchar = *ptr;
		*ptr = '\0';
		text = (char *)malloc(strlen(start) + 1);
		if (text == NULL)
		{
			fprintf(stderr, "Cannot malloc space for & text\n");
			*ptr = tchar;
			return;
		}
		strcpy(text, start);
		*ptr = tchar;
		clean_white_space(text);

		/*
		 * Replace escape sequence with appropriate character
		 */
	/*
	 * Hack for unterminated & escapes
	 */
	if (unterminated)
	{
		ptr3 = (char *)(text + strlen(A_LESS_THAN));
		tchar = *ptr3;
		*ptr3 = '\0';
		if (caseless_equal(text, A_LESS_THAN))
		{
			*ptr2 = '<';
			ptr = (char *)(start + strlen(A_LESS_THAN) - 1);
			unterminated = 0;
		}
		*ptr3 = tchar;

		ptr3 = (char *)(text + strlen(A_GREATER_THAN));
		tchar = *ptr3;
		*ptr3 = '\0';
		if (caseless_equal(text, A_GREATER_THAN))
		{
			*ptr2 = '>';
			ptr = (char *)(start + strlen(A_GREATER_THAN) - 1);
			unterminated = 0;
		}
		*ptr3 = tchar;

		ptr3 = (char *)(text + strlen(A_AMPERSTAND));
		tchar = *ptr3;
		*ptr3 = '\0';
		if (caseless_equal(text, A_AMPERSTAND))
		{
			*ptr2 = '&';
			ptr = (char *)(start + strlen(A_AMPERSTAND) - 1);
			unterminated = 0;
		}
		*ptr3 = tchar;

		ptr3 = (char *)(text + 2);
		while (isdigit((int)*ptr3))
		{
			ptr3++;
		}
		tchar = *ptr3;
		*ptr3 = '\0';
		if (*(text + 1) == '#')
		{
			*ptr2 = (char)atoi((text + 2));
			ptr = (char *)(start + 2 + strlen((text + 2)) - 1);
			unterminated = 0;
		}
		*ptr3 = tchar;

		if (unterminated)
		{
#ifdef VERBOSE
			fprintf(stderr, "Error bad & string\n");
#endif
			free(text);
			return;
		}
	}
	else
	{
		if (caseless_equal(text, A_LESS_THAN))
		{
			*ptr2 = '<';
		}
		else if (caseless_equal(text, A_GREATER_THAN))
		{
			*ptr2 = '>';
		}
		else if (caseless_equal(text, A_AMPERSTAND))
		{
			*ptr2 = '&';
		}
		else if (*(text + 1) == '#')
		{
			*ptr2 = (char)atoi((text + 2));
		}
		else
		{
#ifdef VERBOSE
			fprintf(stderr, "Error bad & string\n");
#endif
			free(text);
			return;
		}
	}
		free(text);

		/*
		 * Copy forward remaining text until you find the next
		 * escape sequence
		 */
		ptr2++;
		ptr++;
		while (*ptr != '\0')
		{
			if ((*ptr == '&')&&
			    ((isalpha((int)*(ptr + 1)))||(*(ptr + 1) == '#')))
			{
				break;
			}
			*ptr2++ = *ptr++;
		}
	}
	*ptr2 = '\0';
}


/*
 * Get a block of text from a HTML document.
 * All text from start to the end, or the first mark
 * (a mark is '<' or '</' followed by any letter)
 * is returned in a malloced buffer.  Also, endp returns
 * a pointer to the next '<' or '\0'
 * The returned text has already expanded '&' escapes.
 */
static char *
get_text(start, endp)
	char *start;
	char **endp;
{
	char *ptr;
	char *text;
	char tchar;

	if (start == NULL)
	{
		return(NULL);
	}

	/*
	 * Copy text up to beginning of a mark, or the end
	 */
	ptr = start;
	while (*ptr != '\0')
	{
		if (*ptr == '<')
		{
			if (isalpha((int)(*(ptr + 1))))
			{
				break;
			}
			else if (*(ptr + 1) == '/')
			{
				if (isalpha((int)(*(ptr + 2))))
				{
					break;
				}
			}
		}
		ptr++;
	}
	*endp = ptr;

	if (ptr == start)
	{
		return(NULL);
	}

	/*
	 * Copy the text into its own buffer, and clean it
	 * of escape sequences.
	 */
	tchar = *ptr;
	*ptr = '\0';
	text = (char *)malloc(strlen(start) + 1);
	if (text == NULL)
	{
		fprintf(stderr, "Cannot malloc space for text\n");
		*ptr = tchar;
		return(NULL);
	}
	strcpy(text, start);
	*ptr = tchar;
	clean_text(text);

	return(text);
}


/*
 * Get the mark text between '<' and '>'.  From the text, determine
 * its type, and fill in a mark_up structure to return.  Also returns
 * endp pointing to the ttrailing '>' in the original string.
 */
static struct mark_up *
get_mark(start, endp)
	char *start;
	char **endp;
{
	char *ptr;
	char *text;
	char tchar;
	struct mark_up *mark;

	if (start == NULL)
	{
		return(NULL);
	}

	if (*start != '<')
	{
		return(NULL);
	}

	start++;

	mark = (struct mark_up *)malloc(sizeof(struct mark_up));
	if (mark == NULL)
	{
		fprintf(stderr, "Cannot malloc space for mark_up struct\n");
		return(NULL);
	}

	/*
	 * Grab the mark text
	 */
	ptr = start;
	while ((*ptr != '>')&&(*ptr != '\0'))
	{
		ptr++;
	}
	*endp = ptr;

	if (*ptr != '>')
	{
#ifdef VERBOSE
		fprintf(stderr, "error: bad mark format\n");
#endif
		return(NULL);
	}

	/*
	 * Copy the mark text to its own buffer, and
	 * clean it of escapes, and odd white space.
	 */
	tchar = *ptr;
	*ptr = '\0';
	text = (char *)malloc(strlen(start) + 1);
	if (text == NULL)
	{
		fprintf(stderr, "Cannot malloc space for mark\n");
		*ptr = tchar;
		return(NULL);
	}
	strcpy(text, start);
	*ptr = tchar;
	clean_text(text);
/*
 * No longer needed because the parsing code is now smarter
 *
	clean_white_space(text);
 *
 */

	/*
	 * Set whether this is the start or end of a mark
	 * block, as well as determining its type.
	 */
	if (*text == '/')
	{
		mark->is_end = 1;
		mark->type = ParseMarkType((char *)(text + 1));
		mark->start = NULL;
		mark->text = NULL;
		mark->end = text;
	}
	else
	{
		mark->is_end = 0;
		mark->type = ParseMarkType(text);
		mark->start = text;
		mark->text = NULL;
		mark->end = NULL;
	}
	mark->text = NULL;
	mark->next = NULL;

	return(mark);
}


/*
 * Special version of get_text.  It reads all text up to the
 * end of the plain text mark, or the end of the file.
 */
static char *
get_plain_text(start, endp)
	char *start;
	char **endp;
{
	char *ptr;
	char *text;
	char tchar;

	if (start == NULL)
	{
		return(NULL);
	}

	/*
	 * Read until stopped by end plain text mark.
	 */
	ptr = start;
	while (*ptr != '\0')
	{
		/*
		 * Beginning of a mark is '<' followed by any letter,
		 * or '</' followed by any letter.
		 */
		if ((*ptr == '<')&&
			((isalpha((int)(*(ptr + 1))))||
			((*(ptr + 1) == '/')&&(isalpha((int)(*(ptr + 2)))))))
		{
			struct mark_up *mp;
			char *ep;

			/*
			 * We think we found a mark.  If it is the
			 * end of plain text, break out
			 */
			mp = get_mark(ptr, &ep);
			if (mp != NULL)
			{
				if (((mp->type == M_PLAIN_TEXT)||
				    (mp->type == M_LISTING_TEXT))&&(mp->is_end))
				{
					if (mp->end != NULL)
					{
						free((char *)mp->end);
					}
					free((char *)mp);
					break;
				}
				if (mp->start != NULL)
				{
					free((char *)mp->start);
				}
				if (mp->end != NULL)
				{
					free((char *)mp->end);
				}
				free((char *)mp);
			}
		}
		ptr++;
	}
	*endp = ptr;

	if (ptr == start)
	{
		return(NULL);
	}

	/*
	 * Copy text to its own malloced buffer, and clean it of
	 * HTML escapes.
	 */
	tchar = *ptr;
	*ptr = '\0';
	text = (char *)malloc(strlen(start) + 1);
	if (text == NULL)
	{
		fprintf(stderr, "Cannot malloc space for text\n");
		*ptr = tchar;
		return(NULL);
	}
	strcpy(text, start);
	*ptr = tchar;
	clean_text(text);

	return(text);
}


/*
 * Main parser of HTML text.  Takes raw text, and produces a linked
 * list of mark objects.  Mark objects are either text strings, or
 * starting and ending mark delimiters.
 * The old list is passed in so it can be freed, and in the future we
 * may want to add code to append to the old list.
 */
extern struct mark_up *
HTMLParse(old_list, str)
	struct mark_up *old_list;
	char *str;
{
	int preformat;
	char *start, *end;
	char *text, *tptr;
	struct mark_up *mark;
	struct mark_up *list;
	struct mark_up *current;
#ifdef TIMING
gettimeofday(&Tv, &Tz);
fprintf(stderr, "HTMLParse enter (%d.%d)\n", Tv.tv_sec, Tv.tv_usec);
#endif

	preformat = 0;

	/*
	 * Free up the previous Object List if one exists
	 */
	FreeObjList(old_list);

	if (str == NULL)
	{
		return(NULL);
	}

	list = NULL;
	current = NULL;

	start = str;
	end = str;

	mark = NULL;
	while (*start != '\0')
	{
		/*
		 * Get some text (if any).  If our last mark was
		 * a begin plain text we call different function
		 * If last mark was <PLAINTEXT> we lump all the rest of
		 * the text in.
		 */
		if ((mark != NULL)&&(mark->type == M_PLAIN_FILE)&&
			(!mark->is_end))
		{
			text = start;
			end = text;
			while (*end != '\0')
			{
				end++;
			}
			/*
			 * Copy text to its own malloced buffer, and clean it of
			 * HTML escapes.
			 */
			tptr = (char *)malloc(strlen(text) + 1);
			if (tptr == NULL)
			{
				fprintf(stderr,
					"Cannot malloc space for text\n");
				return(list);
			}
			strcpy(tptr, text);
			text = tptr;
		}
		else if ((mark != NULL)&&
			 ((mark->type == M_PLAIN_TEXT)||
			  (mark->type == M_LISTING_TEXT))&&
			 (!mark->is_end))
		{
			text = get_plain_text(start, &end);
		}
		else
		{
			text = get_text(start, &end);
		}

		/*
		 * If text is OK, put it into a mark structure, and add
		 * it to the linked list.
		 */
		if (text == NULL)
		{
			if (start != end)
			{
				fprintf(stderr, "error parsing text, bailing out\n");
				return(list);
			}
		}
		else
		{
			mark = (struct mark_up *)malloc(sizeof(struct mark_up));
			if (mark == NULL)
			{
				fprintf(stderr, "Cannot malloc for mark_up struct\n");
				return(list);
			}
			mark->type = M_NONE;
			mark->is_end = 0;
			mark->start = NULL;
			mark->text = text;
			mark->end = NULL;
			mark->next = NULL;
			current = AddObj(&list, current, mark, preformat);
		}
		start = end;

		if (*start == '\0')
		{
			break;
		}

		/*
		 * Get the next mark if any, and if it is
		 * valid, add it to the linked list.
		 */
		mark = get_mark(start, &end);
		if (mark == NULL)
		{
			if (start != end)
			{
				fprintf(stderr, "error parsing mark, bailing out\n");
				return(list);
			}
		}
		else
		{
			mark->next = NULL;
			current = AddObj(&list, current, mark, preformat);
		}

		start = (char *)(end + 1);

		if ((mark != NULL)&&(mark->type == M_PLAIN_FILE)&&
			(!mark->is_end))
		{
			/*
			 * A linefeed immediately after the <PLAINTEXT>
			 * mark is to be ignored.
			 */
			if (*start == '\n')
			{
				start++;
			}
		}
		else if ((mark != NULL)&&((mark->type == M_PLAIN_TEXT)||
			(mark->type == M_LISTING_TEXT))&&
			(!mark->is_end))
		{
			/*
			 * A linefeed immediately after the <XMP>
			 * or <LISTING> mark is to be ignored.
			 */
			if (*start == '\n')
			{
				start++;
			}
		}
		/*
		 * If we are parsing pre-formatted text we need to set a
		 * flag so we don't throw out needed linefeeds.
		 */
		else if ((mark != NULL)&&(mark->type == M_PREFORMAT))
		{
			if (mark->is_end)
			{
				preformat = 0;
			}
			else
			{
				preformat = 1;
				/*
				 * A linefeed immediately after the <PRE>
				 * mark is to be ignored.
				 */
				if (*start == '\n')
				{
					start++;
				}
			}
		}
	}
#ifdef TIMING
gettimeofday(&Tv, &Tz);
fprintf(stderr, "HTMLParse exit (%d.%d)\n", Tv.tv_sec, Tv.tv_usec);
#endif
	return(list);
}


/*
 * Determine mark type from the identifying string passed
 */
static int
ParseMarkType(str)
	char *str;
{
	int type;
	char *tptr;
	char tchar;

	if (str == NULL)
	{
		return(M_NONE);
	}

	type = M_UNKNOWN;
	tptr = str;
	while (*tptr != '\0')
	{
		if (isspace((int)*tptr))
		{
			break;
		}
		tptr++;
	}
	tchar = *tptr;
	*tptr = '\0';

	for (type = M_TITLE; type != M_SENTINEL && !caseless_equal(str, mark_text[type]); type++)
	if (type == M_SENTINEL) {
#ifdef VERBOSE
	  fprintf(stderr, "warning: unknown mark (%s)\n", str);
#endif
	  type = M_UNKNOWN;
	}

	*tptr = tchar;
	return(type);
}


