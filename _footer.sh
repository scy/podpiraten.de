#!/bin/sh

if [ -z "$1" ]; then
	work='Die Website'
else
	work="<span xmlns:dc=\"http://purl.org/dc/elements/1.1/\" href=\"http://purl.org/dc/dcmitype/Sound\" property=\"dc:title\" rel=\"dc:type\">$1</span>"
fi

cat <<EOF
</div>
<div id="foot">
<a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/de/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-sa/3.0/de/88x31.png" width="88" heigth="31" /></a><br />
$work der <a xmlns:cc="http://creativecommons.org/ns#" href="http://podpiraten.de/" property="cc:attributionName" rel="cc:attributionURL">Podpiraten</a> steht unter einer <a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/de/">Creative Commons Namensnennung-Weitergabe unter gleichen Bedingungen 3.0 Deutschland Lizenz</a>.<br />
© $(date +%Y) Podpiraten&nbsp;— <span class="epost">post klammeraffe podpiraten pünktele de</span>&nbsp;— <a href="http://scytale.name/contact/">vorläufiges Impressum</a>
</div>
</div></body>
</html>
EOF
