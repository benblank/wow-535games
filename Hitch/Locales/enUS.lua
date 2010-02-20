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

local L = LibStub("AceLocale-3.0"):NewLocale("Hitch", "enUS", true)

if not L then
	return
end

L["MSG_JOINED_FOLLOWER"] = function(follower) return follower .. " has joined the team." end
L["MSG_JOINED_INVITEE"] = function(leader) return "You have joined " .. leader .. "'s team." end
L["MSG_JOINED_LEADER"] = function(follower) return follower .. " has joined your team." end

L["PROMPT_TEAM_INVITE"] = "%s has invited you to join a Hitch team."

L["REASON_BUSY"] = function(invitee) return invitee .. " could not join your team because they are being invited by someone else." end
L["REASON_CANCEL"] = function(invitee) return invitee .. " did not accept your invitation." end
L["REASON_FULL"] = function(invitee) return "You cannot invite " .. invitee .. " because your team is already full." end
L["REASON_INVITED"] = function(invitee, inviter) return "You cannot invite " .. invitee .. " to your team because you are currently being invited to " .. inviter .. "'s team." end
L["REASON_INVITING"] = function(invitee1, invitee) return "You cannot invite " .. invitee1 .. " to your team because you are currently inviting " .. invitee2 .. "." end
L["REASON_ON_TEAM"] = function(invitee) return invitee .. " is already on a team." end
L["REASON_TEAMMATE"] = function(invitee) return invitee .. " is already on your team." end
