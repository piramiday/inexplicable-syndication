#!/bin/bash
set -e
grep -vP '</?rss' old.xml > old.dat
curl -s "https://$DOMAIN/recenti" | grep class=.lista > R
grep -oP 'action="[^"]*"' R | cut -d '"' -f2 > L
grep -oP 'value="[a-f0-9]{40}"' R | cut -d '"' -f2 > H
echo "<rss version=\"2.0\"><channel><title>ICN</title><lastBuildDate>$(date)</lastBuildDate>"
I=0
while read -r L H; do
   [[ $I -ge 39 ]] && break || I=$((I+1))
   T=$(grep "$H" old.dat || true)
   [[ -n "$T" ]] && echo "$T" && continue
   N=${L##*/}
   echo "<item><pubDate>$(date -d @$(($(date +%s)-60*I)))</pubDate><title>${N//_/.}</title><guid>https://DOMAIN$L</guid><link>magnet:?xt=urn:btih:$H&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce</link></item>"
done < <( paste L H )
echo "</channel></rss>"
