#!/bin/sh 

OFFICIEL_WEBSITE="http://www.gouvernement.fr/loi-travail"
OFFICIAL_PDF=$(wget -q 'http://www.gouvernement.fr/loi-travail' -O - |sed -n 's/^.*<div class="file">.*intégralité.*href="\([^"]*\)".*$/\1/p')

LOCAL_PDF="avant-projet-loi.pdf"
LOCAL_TXT="avant-projet-loi.txt"

# Download
rm -f "$LOCAL_PDF"
wget -q -O "$LOCAL_PDF" "$OFFICIAL_PDF"

# Convert to text
pdftotext "$LOCAL_PDF" "$LOCAL_TXT"

# Remove pages numbers & escape chars (^Lpage)
sed -i 's/^\xc.*$//' "$LOCAL_TXT"

# Split into multiple files
./scripts/splitter.rb "$LOCAL_TXT"

