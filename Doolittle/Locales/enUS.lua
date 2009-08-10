-- $Id$

-- Copyright (c) 2009, Ben Blank
--
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
--
-- * Redistributions of source code must retain the above copyright
--   notice, this list of conditions and the following disclaimer.
--
-- * Redistributions in binary form must reproduce the above copyright
--   notice, this list of conditions and the following disclaimer in the
--   documentation and/or other materials provided with the distribution.
--
-- * Neither the name of 535 Design nor the names of its contributors
--   may be used to endorse or promote products derived from this
--   software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
-- A PARTICULAR PURPOSE ARE DISCLAIMED.	IN NO EVENT SHALL THE COPYRIGHT
-- OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
-- LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
-- DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
-- THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

local L = LibStub("AceLocale-3.0"):NewLocale("Doolittle", "enUS", true)

if not L then
	return
end

L["ERROR_NO_MOUNTS"] = function(mounted) return "You do not have any" .. (mounted and " other" or "") .. " mounts which can be used here." end

L["KEY_OPTIONS"] = "Options"
L["KEY_SUMMON"] = "Summon companion"
L["KEY_MOUNT"] = "Summon mount"

L["LABEL_RATING"] = {
	[0] = "I never want to see it",
	[1] = "I don't really like it",
	[2] = "It's okay sometimes",
	[3] = "I like it",
	[4] = "I really like it",
	[5] = "One of my favorites",
}

L["OPT_ABOUT"] = "About"
L["OPT_ABOUT_WEIGHTS"] = "A warning about the options in this section — you don't need to change them.  Really.  I don't even use them.  They exist so that people who are very good at math and care a lot about the statistical distribution of their random mount/companion selection can fiddle with it to their hearts' content.  The rest of us just don't need to worry about it.  :-)\n\nIf you're curious, though, feel free to play around and see how it works (that's why there's a reset button here).  Basically, Doolittle first chooses which rating level it's going to pick from (and the more \"weight\" a rating has, the more often that rating level will be chosen).  Then, it chooses randomly from all the mounts/companions which have that rating (each one is equally likely), so if you have (for example) a lot 4-star mounts and very few 3-star mounts, |cffffff00each|r 4-four star mount might come up less often than each 3-star mount, but the total chance of getting |cffffff00any|r four-star mount is still higher than the total chance of getting any 3-star mount as long as the 4-star rating has a higher weight than the 3-star rating.\n\nSee why I told you not to worry about it?"
L["OPT_ADVANCED"] = "Advanced"
L["OPT_FASTEST_ONLY"] = "Include fastest only"
L["OPT_FASTEST_ONLY_DESC"] = "If checked, all other speed category settings for this mount type will be ignored."
L["OPT_INCLUDE_SPEED"] = function(speed) return "Include " .. speed .. "% mounts" end
L["OPT_RANDOM"] = function(mode) return "Select a new " .. (mode == "CRITTER" and "companion" or "mount") .. " [NYI]" end
L["OPT_RANDOM_DESC"] = function(mode) return "Determines how often a new " .. (mode == "CRITTER" and "companion" or "mount") .. " will be randomly selected." end
L["OPT_RANDOM_ALWAYS"] = "every time"
L["OPT_RANDOM_DAILY"] = "once a day"
L["OPT_RANDOM_SESSION"] = "each session"
L["OPT_RESET_WEIGHTS"] = "Reset weights"
L["OPT_WEIGHT_FOR"] = function(mode, rating) return "Weight for " .. rating .. "-star " .. (mode == "CRITTER" and "companions" or "mounts") end
L["OPT_WEIGHTS"] = "Weights"
L["OPT_WEIGHTS_DESC"] = "Mounts whose ratings have a higher weight are more likely to be selected."

L["TERRAIN_HEADING_FLYING"] = "When summoning flying mounts"
L["TERRAIN_HEADING_GROUND"] = "When summoning ground mounts"
L["TERRAIN_HEADING_SWIMMING"] = "When summoning swimming mounts"
