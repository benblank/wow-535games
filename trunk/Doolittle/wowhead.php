<?php // $Id$

// Copyright (c) 2009, Ben Blank
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
// * Redistributions of source code must retain the above copyright
//	notice, this list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright
//	notice, this list of conditions and the following disclaimer in the
//	documentation and/or other materials provided with the distribution.
//
// * Neither the name of 535 Design nor the names of its contributors
//	may be used to endorse or promote products derived from this
//	software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED.	IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

header("Content-Type: text/plain");

function getValue($xpath, $node) {
	return intval(substr($xpath->query("./small", $node)->item(0)->textContent, 7));
}

$var = "mountInfo";

$mdoc = new DOMDocument();
@$mdoc->loadHTMLFile("http://www.wowhead.com/?spells=-5");

$mpath = new DOMXPath($mdoc);

echo "$var = []\n";

foreach($mpath->query("//div[@class='listview-void']/a") as $mnode) {
	$path = $mnode->attributes->getNamedItem("href")->value;

	if (substr($path, 0, 8) === "/?spell=") {
		$id = intval(substr($path, 8));

		$sdoc = new DOMDocument();
		@$sdoc->loadHTMLFile("http://www.wowhead.com/?spell=$id");

		$spath = new DOMXPath($sdoc);
		$special = true;

		echo "\n{$var}[$id] = [] -- {$mnode->textContent}\n";

		foreach ($spath->query("//td[starts-with(preceding-sibling::th,'Effect #')]") as $snode) {
			$speeds = array();
			$content = substr($snode->textContent, 0, 36);
			$value = getValue($spath, $snode);

			if ($value > 0) {
				$special = false;

				if ($content === "Apply Aura: Mod Speed Mounted Flight") {
					echo "{$var}[$id]['air'] = " . getValue($spath, $snode) . "\n";
				} else if(substr($content, 0, 29) === "Apply Aura: Mod Speed Mounted") {
					echo "{$var}[$id]['ground'] = " . getValue($spath, $snode) . "\n";
				}
			}
		}

		if ($special) {
			echo "{$var}[$id]['special'] = true\n";
		}

		unset($spath, $sdoc);
	}
}

unset($mpath, $mdoc);
