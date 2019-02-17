#!/bin/sh

title="$1"
[ -n "$title" ] && title="$title — "

cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de" lang="de">
<head>
	<meta charset="UTF-8" />
	<title>${title}Podpiraten</title>
	<link rel="stylesheet" href="/09.css" type="text/css" />
	<link rel="alternate" type="application/rss+xml" title="PiPaPo (Podcast-Feed)" href="http://podpiraten.de/pipapo.rss" />
</head>
<body><div id="top">
<div id="head"><a href="/"><img src="/pipapo-medium.png" alt="Podpiraten-Logo" width="100" height="100" align="right" /></a><h1><a href="/">Podpiraten</a></h1></div>
<div id="body">
EOF
