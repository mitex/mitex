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

#include <stdio.h>
#include <stdlib.h>

#include "HTMLparse.h"

/*
 * prototypes
 */

extern void FreeObjList(struct mark_up *List);
extern struct mark_up *AddObj(struct mark_up **, struct mark_up *, struct mark_up *, int);
extern void PrintType(mark_t);
extern void PrintList(struct mark_up *);


/*
 * Code to manage a linked list of parsed HTML objects generated
 * from a raw text file.
 * Also code to manage a linked list of formatted elements that
 * make up a page of a formatted document.
 */


/*
 * Free up the passed linked list of parsed elements, freeing
 * all memory associates with each element.
 */
extern void
FreeObjList(List)
	struct mark_up *List;
{
	struct mark_up *current;
	struct mark_up *mptr;

	current = List;
	while (current != NULL)
	{
		mptr = current;
		current = current->next;
		mptr->next = NULL;
		if (mptr->start != NULL)
		{
			free((char *)mptr->start);
		}
		if (mptr->text != NULL)
		{
			free((char *)mptr->text);
		}
		if (mptr->end != NULL)
		{
			free((char *)mptr->end);
		}
		free((char *)mptr);
	}
}


/*
 * Add an object to the parsed object list.
 * return a pointer to the current (end) position in the list.
 * If the object is a normal text object containing nothing but
 * white space, throw it out, unless we have been told to keep
 * white space.
 */
extern struct mark_up *
AddObj(listp, current, mark, keep_wsp)
	struct mark_up **listp;
	struct mark_up *current;
	struct mark_up *mark;
	int keep_wsp;
{
	if (mark == NULL)
	{
		return(current);
	}

	/*
	 * Throw out normal text blocks that are only white space,
	 * unless keep_wsp is set.
	 */
	if ((mark->type == M_NONE)&&(!keep_wsp))
	{
		char *ptr;

		ptr = mark->text;
		if (ptr == NULL)
		{
			free((char *)mark);
			return(current);
		}

		while ((*ptr == ' ')||(*ptr == '\t')||(*ptr == '\n'))
		{
			ptr++;
		}

		if (*ptr == '\0')
		{
			free(mark->text);
			free((char *)mark);
			return(current);
		}
	}

	/*
	 * Add object to either the head of the list for a new list,
	 * or at the end after the current pointer.
	 */
	if (*listp == NULL)
	{
		*listp = mark;
		current = *listp;
	}
	else
	{
		current->next = mark;
		current = current->next;
	}

	current->next = NULL;

	return(current);
}


/*
 * Convert type number to a printed string for debug
 */
extern void
PrintType(type)
	mark_t type;
{
	switch(type)
	{
		case M_NONE:
			printf("M_NONE");
			break;
		case M_TITLE:
			printf("M_TITLE");
			break;
		case M_HEADER_1:
			printf("M_HEADER_1");
			break;
		case M_HEADER_2:
			printf("M_HEADER_2");
			break;
		case M_HEADER_3:
			printf("M_HEADER_3");
			break;
		case M_HEADER_4:
			printf("M_HEADER_4");
			break;
		case M_HEADER_5:
			printf("M_HEADER_5");
			break;
		case M_HEADER_6:
			printf("M_HEADER_6");
			break;
		case M_ANCHOR:
			printf("M_ANCHOR");
			break;
		case M_PARAGRAPH:
			printf("M_PARAGRAPH");
			break;
		case M_ADDRESS:
			printf("M_ADDRESS");
			break;
		case M_PLAIN_TEXT:
			printf("M_PLAIN_TEXT");
			break;
		case M_LISTING_TEXT:
			printf("M_LISTING_TEXT");
			break;
		case M_UNUM_LIST:
			printf("M_UNUM_LIST");
			break;
		case M_MENU:
			printf("M_MENU");
			break;
		case M_DIRECTORY:
			printf("M_DIRECTORY");
			break;
		case M_LIST_ITEM:
			printf("M_LIST_ITEM");
			break;
		case M_DESC_LIST:
			printf("M_DESC_LIST");
			break;
		case M_DESC_TITLE:
			printf("M_DESC_TITLE");
			break;
		case M_DESC_TEXT:
			printf("M_DESC_TEXT");
			break;
		case M_IMAGE:
			printf("M_IMAGE");
			break;
		case M_INDEX:
			printf("M_INDEX");
			break;
		default:
			printf("UNKNOWN %d", type);
			break;
	}
}


/*
 * Print the contents of a parsed object list, for debug
 */
extern void
PrintList(list)
	struct mark_up *list;
{
	struct mark_up *mptr;

	mptr = list;
	while (mptr != NULL)
	{
		PrintType(mptr->type);
		if (mptr->is_end)
		{
			printf(" END");
		}
		else
		{
			printf(" START");
		}
		if (mptr->text != NULL)
		{
			printf("\n{\n\t");
			printf("%s", mptr->text);
			printf("}\n");
		}
		else
		{
			printf("\n");
		}
		mptr = mptr->next;
	}
}

