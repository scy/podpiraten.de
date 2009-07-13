#!/bin/sh

export LC_ALL='en_US.UTF-8'

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
	eyeD3 --no-tagging-time-frame --remove-comments --remove-images --to-v2.4 "$file" >/dev/null 2>&1
	# eyeD3 -1 -a "$AUTHOR" -t "$title" -A "$SHORTNAME" -n "$num" -G 101 -Y "$year" -c "::CC-BY-SA-3.0-DE; (c) $year" "$file"
	eyeD3 --no-tagging-time-frame -2 -a "$AUTHOR" -t "$title" -A "$SHORTNAME" -n "$num" -G 101 -Y "$year" -c "::CC-BY-SA-3.0-DE; © $year Podpiraten" --add-image=pipapo.jpg:FRONT_COVER:Logo --set-encoding=utf8 "$file" >/dev/null 2>&1
	touch -d "@$ts" "$file"
	echo -e "time\\t$ts" > "$file.digest"
	for x in md5 sha1 sha256 sha512; do
		echo -ne "$x\\t"
		${x}sum -b "$file" | cut -d ' ' -f 1
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

for txt in $(find media/pipapo-*.txt | sort -r | tail -n 5); do
	link="$(echo "$txt" | sed -r -e 's#^(\./)?media/(.+)\.txt#\2.html#')"
	title="$(head -n 1 "$txt")"
	subtitle="$(head -n 2 "$txt" | tail -n 1)"
	echo "<li><a href=\"$link\">$title</a>&nbsp;— $subtitle</li>"
done | (./_header.sh; cat _index.pre.html - _index.post.html; ./_footer.sh) > index.html
