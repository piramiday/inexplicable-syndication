#!/bin/bash
set -e
curl -s -o A "https://$DOMAIN/rss.php"
curl -s -o B "https://$DOMAIN/rssdd.php"
grep -oP "\s+<ti.*" A > 0
grep -oP "\s+<gu.*" A | sed "s|http.*//$DOMAIN|https://DOMAIN|" > 1
grep -oP "\s+<li.*" B > 2
grep -oP "\s+<pu.*" A > 3
head -n10 A
while IFS=$'\t' read T G L P; do
   echo "<item>$T$G$L$P</item>"
done < <( paste 0 1 2 3 )
tail -n2 A
