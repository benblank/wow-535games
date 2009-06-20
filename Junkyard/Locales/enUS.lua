-- $Id: enUS.lua 23 2009-06-07 18:02:20Z drdark $

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

local L = LibStub("AceLocale-3.0"):NewLocale("Junkyard", "enUS", true)

if not L then
	return
end

L["CMD_SELL"] = "Sell"
L["CMD_SELL_DESC"] = "Sell everything marked as \"junk\" to the active merchant."

L["OPT_AUTO"] = "Automatically sell when talking to a merchant"
L["OPT_ENCHANTED"] = "Never sell enchanted items"
L["OPT_ENCHANTED_DESC"] = "Prevents enchanted items from being sold even if they match one of the other conditions."
L["OPT_GEMMED"] = "Never sell gemmed items"
L["OPT_GEMMED_DESC"] = "Prevents gemmed items from being sold even if they match one of the other conditions."
L["OPT_JUNK"] = "Sell \"poor\"-quality items"
L["OPT_JUNK_DESC"] = "Also called \"vendor trash\", \"grey\" items, etc."
L["OPT_LIGHT"] = "Sell light-weight soulbound armor"
L["OPT_LIGHT_DESC"] = "For example, leather armor is lighter-weight than Warriors typically wear."
L["OPT_PROMPT"] = "Ask before selling items"
L["OPT_PROMPT_DESC"] = "A window will appear showing the items to be sold and allowing you to cancel the sale."
L["OPT_REPAIR"] = "Repair all items when talking to a merchant who has that ability."
L["OPT_UNUSABLE"] = "Sell unequippable soulbound items"
L["OPT_UNUSABLE_DESC"] = "For example, soulbound plate is unusable by a Mage."
