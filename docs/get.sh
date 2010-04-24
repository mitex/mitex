#!/bin/bash
if [ -e "$QUERY_STRING" ]; then
	echo "Content-type: application/pdf"
	echo
	cat "$QUERY_STRING"
	rm "$QUERY_STRING"
else
	echo "Content-type: image/tiff"
	echo
	cat "/mit/mitex/web_scripts/docs/tex.tif"
fi
