#
# normalize-eps.awk, Rolf Niepraschk, 11/97, niepraschk@ptb.de
# translatete the boundingbox and added a pagedevice operator
# based on the perl script from the "LaTeX Graphics Companion" page 459
#
BEGIN {
  bbneeded = 1
}

{
  if ($1 == "%%BoundingBox:")
  {
    if (bbneeded)
    {
      bbneeded = 0
      width = $4 - $2; height = $5 - $3;
      xoffset = -$2; yoffset = -$3; 
      print $1 " 0 0 " width " " height
      print "<< /PageSize [" width " " height "] >> setpagedevice"
      print "gsave " xoffset " " yoffset " translate"
    }    
  }
  else print
}

END {
  print "grestore"
}
