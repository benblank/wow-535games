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

L["CMD_MOUNT_DESC"] = "Hop into the saddle of a random mount."

L["ERROR_FLYING"] = function(key) return "Hold the " .. key .. " to dismount while flying." end
L["ERROR_NO_MOUNTS"] = "You do not have any mounts which can be used here."

L["OPT_DISMOUNT"] = "Dismount-in-flight key"
L["OPT_DISMOUNT_DESC"] = "Hold this key to dismount even when flying."
L["OPT_FASTEST_ONLY"] = "Include fastest only"
L["OPT_FASTEST_ONLY_DESC"] = "If checked, all speed category settings for this mount type will be ignored."
L["OPT_INCLUDE_SPEED"] = function(speed) return "Include " .. speed .. "% mounts" end
L["OPT_WEIGHT_FOR"] = function(rating) return "Weight for rating " .. rating end
L["OPT_WEIGHTS"] = "Weights"
L["OPT_WEIGHTS_DESC"] = "Mounts whose ratings have a higher weight are more likely to be selected."
L["OPT_ZERO"] = "A rating of 0 means \"unrated\".  Unrated mounts have normal odds of being selected."

L["TYPE_FLYING"] = "Flying"
L["TYPE_GROUND"] = "Ground"
L["TYPE_SWIMMING"] = "Swimming"
