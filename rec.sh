#!/bin/bash
set -e
curl -sb "$COOKIE" "https://$DOMAIN/forum/index.php?type=rss;action=.xml;sa=news;boards=9,102;limit=50" | tee ori.xml | sed "s/$DOMAIN/DOMAIN/g;s|<!\[CDATA\[||g;s|]]>||g;s|&#093;|\]|g" | tee all.xml | csplit --quiet --digits=2 --prefix='_item' - '/<item>/' '{*}'
for I in _item??; do
   if [[ "$I" = "_item00" ]] || grep -iq '202.*1080p' "$I"; then cat "$I"; fi
done
echo "</channel></rss>"
