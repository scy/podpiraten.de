#!/bin/sh

export LC_ALL='en_US.UTF-8'

EYED3='eyeD3'
if ! which "$EYED3" >/dev/null 2>&1; then
	echo 'warning: eyeD3 is not available, skipping ID3 modification' >&2
	EYED3=':'
fi

if ! which mp3info >/dev/null 2>&1; then
	echo 'error: mp3info is not available' >&2
	exit 1
fi

SHORTNAME='PiPaPo'
LONGNAME='Piratenpartei Podcast'
AUTHOR='Podpiraten'
URL='http://podpiraten.de/'
LOGO="${URL}pipapo.jpg"
LANGUAGE='de'
CATEGORY='News &amp; Politics'
KEYWORDS='Piratenpartei,Podpiraten,Piratenpodcast,Politik,Gesellschaft,Pirate Party,Pirates,Politics,Society'
EXPLICIT='no'
SUBTITLE='Podcasts für und über die Piratenpartei'
DESCRIPTION='Podcasts für und über die Piratenpartei und aktuelle piratige Themen, das ist PiPaPo. Dabei sind die Inhalte nicht nur für Parteimitglieder und Sympathisanten interessant, auch Außenstehende bekommen einen Eindruck von den Bewegungen innerhalb der Partei, direkt aus Sicht der Basis. Denn Transparenz wird bei den Piraten groß geschrieben.'

cat > 'pipapo.new.rss' <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" version="2.0">
	<channel>
		<title>$SHORTNAME — $LONGNAME</title>
		<link>$URL</link>
		<description>$DESCRIPTION</description>
		<itunes:subtitle>$SUBTITLE</itunes:subtitle>
		<itunes:summary>$DESCRIPTION</itunes:summary>
		<language>$LANGUAGE</language>
		<generator>The Mighty mkfeed.sh!!</generator>
		<itunes:author>$AUTHOR</itunes:author>
		<itunes:owner>
			<itunes:name>$AUTHOR</itunes:name>
			<itunes:email>itunes-owner@podpiraten.de</itunes:email>
		</itunes:owner>
		<itunes:image href="$LOGO" />
		<category>$CATEGORY</category>
		<itunes:category text="$CATEGORY"/>
		<itunes:keywords>$KEYWORDS</itunes:keywords>
		<itunes:explicit>$EXPLICIT</itunes:explicit>
EOF

for txt in media/*.txt; do
	file="$(echo "$txt" | sed 's/\.txt$/-hi.mp3/')"
	echo "$file"

	# If the MP3 does not exist, try to recreate it from split files.
	if ! [ -e "$file" ]; then
		splits="$(find "$(dirname "$file")" -name "$(basename "$file").?" | sort)"
		if [ -z "$splits" ]; then
			echo "error: $file does not exist and neither to split files for it" >&2
			exit 1
		else
			cat $splits > "$file"
		fi
	fi

	# If there is already a digest file, set the MP3's modification date based on it and check the digests.
	if [ -e "$file.digest" ]; then
		touch -d "@$(awk '/time\t/ { print $2 }' "$file.digest")" "$file"
		grep -v '^time' "$file.digest" | while read -r alg hash; do
			if ! printf '%s *%s\n' "$hash" "$file" | "${alg}sum" -c --quiet; then
				echo "error: $alg checksum of $file seems wrong" >&2
				exit 1
			fi
		done
	fi

	title="$(head -n 1 "$txt")"
	subtitle="$(head -n 2 "$txt" | tail -n 1)"
	people="$(head -n 3 "$txt" | tail -n 1)"
	text="$(tail -n +4 "$txt")"
	nohtml="$(echo "$text" | sed -r -e 's#<a href="([^"<>]+)">([^<>]+)</a>#\2 (\1)#g' -e 's#<li>(.+)</li>#- \1#' -e 's#<[^<>]+>##g')"
	stem="$(echo "$txt" | sed -r -e 's#^media/(.+)\.txt$#\1#')"
	num="$(echo "$stem" | sed -r -e 's/^([^1-9]+)([0-9]+)/\2/' )"
	mime="$(file -bi "$file")"
	size="$(stat -c %s "$file")"
	seconds="$(mp3info -p %S "$file")"
	minutes="$(expr "$seconds" / 60)"
	hours="$(expr "$minutes" / 60)"
	seconds="$(expr "$seconds" - "$minutes" \* 60)"
	minutes="$(expr "$minutes" - "$hours" \* 60)"
	duration="$(printf '%02i:%02i:%02i' "$hours" "$minutes" "$seconds")"
	pubdate="$(date -r "$file" --rfc-2822)"
	dcdate="$(date -r "$file" --rfc-3339=seconds | tr ' ' 'T')"
	humandate="$(date -r "$file" '+%d.%m.%Y, %H:%M Uhr')"
	humansize="$(expr "$size" / 1024 / 1024)"
	ts="$(date -r "$file" '+%s')"
	year="$(date -r "$file" '+%Y')"
	url="$URL$file"
	perma="$URL$stem.html"
	cat >> 'pipapo.new.rss' <<EOF
		<item>
			<title>$title</title>
			<itunes:subtitle>$subtitle</itunes:subtitle>
			<description>$subtitle</description>
			<enclosure type="$mime" url="$url" length="$size"/>
			<itunes:duration>$duration</itunes:duration>
			<guid>$perma-$ts</guid>
			<link>$perma</link>
			<pubDate>$pubdate</pubDate>
			<!-- <dc:date>$dcdate</dc:date> -->
			<itunes:explicit>$EXPLICIT</itunes:explicit>
			<itunes:summary>$title
$subtitle

Veröffentlicht: $humandate
Teilnehmer: $people
$perma

$nohtml
</itunes:summary>
			<body xmlns="http://www.w3.org/1999/xhtml">
$text
			</body>
		</item>
EOF
	"$EYED3" --no-tagging-time-frame --remove-comments --remove-images --to-v2.4 "$file" >/dev/null 2>&1
	"$EYED3" --no-tagging-time-frame -2 -a "$AUTHOR" -t "$title" -A "$SHORTNAME" -n "$num" -G 101 -Y "$year" -c "::CC-BY-SA-3.0-DE; © $year Podpiraten" --add-image=pipapo.jpg:FRONT_COVER:Logo --set-encoding=utf8 --to-v2.4 "$file" >/dev/null 2>&1
	touch -d "@$ts" "$file"
	printf 'time\t%d\n' "$ts" > "$file.digest"
	for x in md5 sha1 sha256 sha512; do
		printf '%s\t%s\n' "$x" "$(${x}sum -b "$file" | cut -d ' ' -f 1)"
	done >> "$file.digest"
	(./_header.sh "$title"; cat; ./_footer.sh "$title") > "$stem.html" <<EOF
	<h2>$title</h2>
	<h3>$subtitle</h3>
	<div id="meta">
		<p class="fileinfo"><a href="$file">$stem-hi.mp3</a>, $humandate, $humansize&nbsp;MB, $duration</p>
		<p class="people">Teilnehmer: $people</p>
	</div>
	<div id="about">
$text
	</div>
	<pre class="digest">$(cat "$file.digest")</pre>
EOF
done

cat >> 'pipapo.new.rss' <<EOF
	</channel>
</rss>
EOF

mv 'pipapo.new.rss' 'pipapo.rss'

for txt in $(find media/pipapo-*.txt | sort -r | head -n 10); do
	link="$(echo "$txt" | sed -r -e 's#^(\./)?media/(.+)\.txt#\2.html#')"
	title="$(head -n 1 "$txt")"
	subtitle="$(head -n 2 "$txt" | tail -n 1)"
	echo "<li><a href=\"$link\">$title</a>&nbsp;— $subtitle</li>"
done | (./_header.sh; cat _index.pre.html - _index.post.html; ./_footer.sh) > index.html
