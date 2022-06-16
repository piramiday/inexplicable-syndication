#!/bin/bash
set -e
[[ -s old.xml ]] && grep -vP '</?rss' old.xml > old.dat
echo "<rss version=\"2.0\"><channel><title>ICV</title><lastBuildDate>$(date)</lastBuildDate>"
while read -r T; do
   URL="forum/index.php?topic=$T"
   curl "https://$DOMAIN/$URL" -sb "$COOKIE" | tee "$T.htm" | grep -o "<a href=.magnet[^>]*>" > "$T.dat" || true
   if [[ ! -s "$T.dat" ]]; then
      U=$(grep -om1 "action=thank;msg=[0-9]*;member=[0-9]*;topic=$T" "$T.htm")
      U="forum/index.php?${U};refresh=1;ajax=1;xml=1"
      curl "https://$DOMAIN/$U" -sb "$COOKIE" -H 'X-Requested-With: XMLHttpRequest' > "$T.thanks"
      curl "https://$DOMAIN/$URL" -sb "$COOKIE" | tee "$T.htm" | grep -o "<a href=.magnet[^>]*>" > "$T.dat"
   fi
   cut -d'"' -f2 "$T.dat" > "M$T"
   cut -d'"' -f4 "$T.dat" > "N$T"
   grep -o '<span style="color: orange;" class="bbc_color">[^<]*</span>[^<]*<br />' "$T.htm" | sed 's|<[^>]*>||g;s/&nbsp;//' > "$T.txt"
   [[ ! -s "$T.txt" ]] && grep -o '<strong>.::.I.F..T.CN.CH..::.*::.M.DI.IN.O.::.</strong>' "$T.htm" | sed -E 's|<strong>[^<]*</strong>||g;s|<br />|\n|g;s|<[^>]*>||g' | grep -v '^$' > "$T.txt" || true
   C=$(grep '<title>' "$T.htm" | grep -o -e COMPLETA -e '[0-9][0-9]*/[0-9][0-9]*' | tr -d [])
   echo " <!--@${T}@${C:-unknown}@$(base64 -w0 "$T.txt")@-->"
   while read -r N M; do
      [[ $M =~ [a-zA-Z0-9]{40} ]] && H=${BASH_REMATCH[0]} || H=
      [[ -s old.dat ]] && L=$(grep "$H" old.dat || true) || L=
      [[ -n "$L" ]] && echo "$L" && continue
      echo " <item><pubDate>$(date)</pubDate><title>$N</title><guid>https://DOMAIN/$URL</guid><link>$M</link></item>"
   done < <( paste "N$T" "M$T" )
done < icv.dat
echo "</channel></rss>"

