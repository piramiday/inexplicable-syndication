#!/bin/bash
set -e
curl -s "https://$DOMAIN/recenti" | grep class=.lista > R
grep -oP 'action="[^"]*"' R | cut -d '"' -f2 > L
grep -oP 'value="[a-f0-9]{40}"' R | cut -d '"' -f2 > H
echo "<rss version=\"2.0\"><channel><title>ICN</title><lastBuildDate>$(date)</lastBuildDate>"
while read -r L H; do
   echo "<item><title>${L##*/}</title><guid>https://DOMAIN$L</guid><link>magnet:?xt=urn:btih:$H&tr=udp%3A%2F%2Ftracker.torrent.eu.org%3A451%2Fannounce</link></item>"
done < <( paste L H )
echo "</channel></rss>"
