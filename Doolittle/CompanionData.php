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
//   notice, this list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright
//   notice, this list of conditions and the following disclaimer in the
//   documentation and/or other materials provided with the distribution.
//
// * Neither the name of 535 Design nor the names of its contributors
//   may be used to endorse or promote products derived from this
//   software without specific prior written permission.
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

$start = microtime(true);

header("Content-Type: text/plain");

function getValue($xpath, $node) {
	return intval(substr($xpath->query("./small", $node)->item(0)->textContent, 7));
}

$mounts = array('flying' => array(), 'ground' => array(), 'swimming' => array());

foreach (array("http://www.wowhead.com/?spells=-5", "http://www.wowhead.com/?spells&filter=minle=2;me=21") as $url) {
	$mdoc = new DOMDocument();
	@$mdoc->loadHTMLFile($url);

	$mpath = new DOMXPath($mdoc);

	foreach($mpath->query("//div[@class='listview-void']/a") as $mnode) {
		$path = $mnode->attributes->getNamedItem("href")->value;

		if (substr($path, 0, 8) === "/?spell=") {
			$speeds = array();
			$id = intval(substr($path, 8));
			$name = $mnode->textContent;

			switch ($id) {
				case 28828: // Nether Drake
				case 42781: // Upper Deck - Spectral Tiger Mount
				case 64987: // Big Blizzard Bear [PH]
					// either unobtainable or not really a mount
					continue 2; // PHP considers "switch" a loop...?
				break;

				case 30174: // Riding Turtle
					$speeds[] = array('ground', 0);
				break;

				case 54729: // Winged Steed of the Ebon Blade
					$speeds[] = array('flying', 60);
					$speeds[] = array('flying', 280);
				break;

				case 48025: // Headless Horseman's Mount
					$speeds[] = array('flying', 60);
					$speeds[] = array('flying', 280);
				// fall through

				case 58983: // Big Blizzard Bear
					$speeds[] = array('ground', 60);
					$speeds[] = array('ground', 100);
				break;

				case 61442: // Swift Mooncloth Carpet
				case 61444: // Swift Shadoweave Carpet
				case 61446: // Swift Spellfire Carpet
					$speeds[] = array('flying', 280);
				break;

				default:
					$sdoc = new DOMDocument();
					@$sdoc->loadHTMLFile("http://www.wowhead.com/?spell=$id");

					$spath = new DOMXPath($sdoc);
					$type = false;

					foreach ($spath->query("//td[starts-with(preceding-sibling::th,'Effect #')]") as $snode) {
						$content = substr($snode->textContent, 0, 36);
						$value = getValue($spath, $snode);

						if ($value > 0 && substr($content, 0, 21) === "Apply Aura: Mod Speed") {
							if (substr($content, 22) === "Mounted Flight") {
								// flying mounts can only be used in flyable areas and so aren't considered any other kind of mount
								$speeds = array(array('flying', $value));
								break;
							} else if(substr($content, 22, 4) === "Swim") {
								// the swimming mount aura appears to apply the same speed bonus when out of water
								$speeds[] = array('ground', $value);
								$speeds[] = array('swimming', $value);
							} else if(substr($content, 22, 7) === "Mounted") {
								$speeds[] = array('ground', $value);
							}
						}
					}

					unset($spath, $sdoc);
				break;
			}

			foreach ($speeds as $speed) {
				if (!array_key_exists($speed[1], $mounts[$speed[0]])) {
					$mounts[$speed[0]][$speed[1]] = array();
				}

				$mounts[$speed[0]][$speed[1]][$id] = $name;
			}
		}
	}

	unset($mpath, $mdoc);
}

// This header is after the code most likely to generate errors so that the
// browser will not attempt to download a data file filled with error messages.
header("Content-Disposition: attachment; filename=CompanionData.lua");

echo <<<DONE
-- this file was automatically generated by CompanionData.php

local Doolittle = LibStub("AceAddon-3.0"):GetAddon("Doolittle")

Doolittle.critters = {
	pools = {
		-- if other pet reagents are ever added, this will be replaced
		-- with a proper generator like the one used for mounts
		i17202 = { -- Snowball
			26533, -- Father Winter's Helper
			26045, -- Tiny Snowman
			26529, -- Winter Reindeer
			26541, -- Winter's Little Helper
		},
	},
}

Doolittle.mounts = {
	pools = {
		aq40 = {
			25953, -- Blue Qiraji Battle Tank
			26056, -- Green Qiraji Battle Tank
			26054, -- Red Qiraji Battle Tank
			26055, -- Yellow Qiraji Battle Tank
		},

DONE;

foreach ($mounts as $type => $speeds) {
	echo "\t\t$type = {\n";

	foreach ($speeds as $speed => $mount) {
		echo "\t\t\t[$speed] = Pool{\n";

		foreach ($mount as $id => $name) {
			echo "\t\t\t\t$id, -- $name\n";
		}

		echo "\t\t\t},\n";
	}

	echo "\t\t},\n";
}

echo "\t},\n\tspeeds = {\n";

foreach ($mounts as $type => $speeds) {
	echo "\t\t$type = {\n";

	$list = array_keys($speeds);
	sort($list);
	$limit = count($list) - 2;
	foreach ($list as $i => $speed) {
		echo "\t\t\t[$speed] = " . ($i >= $limit ? "true" : "false") . ",\n";
	}

	echo "\t\t},\n";
}

echo "\t},\n}\n\n-- Generated on " . date(DATE_RFC2822) . " in " . (microtime(true) - $start) . " seconds\n";
