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

L["ERROR_INAVLID_MOUNT_TYPE"] = function(command) return "Not a recognized mount type: \"" .. command .. "\"" end
L["ERROR_LOW_WEIGHT"] = "You may not set weighting factors to less than 1."
L["ERROR_NO_COMPANIONS"] = "You do not have any companions which can be used here."
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

L["OPT_ADVANCED"] = "Advanced"
L["OPT_ADVANCED_ABOUT"] = "<explain formula and variables here>"
L["OPT_ADVANCED_SIZE"] = "Pool size weight factor"
L["OPT_ADVANCED_SIZE_DESC"] = "The higher the number, the more pool size affects weighting.  At 1, pool size is completely disregarded."
L["OPT_ADVANCED_STARS"] = "Star rating weight factor"
L["OPT_ADVANCED_STARS_DESC"] = "The higher the number, the more star ratings affect weighting.  At 1, all star ratings have equal probability."
L["OPT_FASTEST_ONLY"] = "Include fastest only"
L["OPT_FASTEST_ONLY_DESC"] = "If checked, all other speed category settings for this mount type will be ignored."
L["OPT_INCLUDE_SPEED"] = function(speed) return "Include " .. speed .. "% mounts" end
L["OPT_MACRO"] = "Default mount macro"
L["OPT_MACRO_DESC"] = "The /mount command can be used with macro-style optons; this is the macro which will be run when you don't supply one."
L["OPT_MACRO_RESET"] = "Reset mount macro"
L["OPT_MACRO_RESET_DESC"] = "Restore the default macro bundled with Doolittle."
L["OPT_RANDOM"] = function(mode) return "Select a new " .. (mode == "CRITTER" and "companion" or "mount") .. " [NYI]" end
L["OPT_RANDOM_DESC"] = function(mode) return "Determines how often a new " .. (mode == "CRITTER" and "companion" or "mount") .. " will be randomly selected." end
L["OPT_RANDOM_ALWAYS"] = "every time"
L["OPT_RANDOM_DAILY"] = "once a day"
L["OPT_RANDOM_SESSION"] = "each session"

L["TERRAIN_HEADING_FLYING"] = "When summoning flying mounts"
L["TERRAIN_HEADING_GROUND"] = "When summoning ground mounts"
L["TERRAIN_HEADING_SWIMMING"] = "When summoning swimming mounts"
