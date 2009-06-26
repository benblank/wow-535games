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

L["BUTTON_SELL"] = "Sell"

L["CMD_SELL"] = "Sell \"junk\" items now"
L["CMD_SELL_DESC"] = "Sell everything marked as \"junk\" to the active merchant."
L["CMD_REPAIR"] = "Repair all items now."

L["ERROR_CANNOT_REPAIR"] = "This merchant cannot repair your equipment."
L["ERROR_INVALID_ITEM"] = "Not a valid item.  Please use a bare item ID (e.g. \"12345\"), an item reference (e.g. \"item:12345\" or \"item:12345:0:0:0:0:0:0:0\") or an item link (by shift-clicking on an item)."
L["ERROR_NO_MERCHANT"] = "You are not speaking to a merchant."

L["OPT_AUTO_REPAIR"] = "Repair equipment at merchants"
L["OPT_AUTO_REPAIR_DESC"] = "When set, all equipment will automatically be repaired when talking to a merchant who has that ability."
L["OPT_AUTO_SELL"] = "Sell \"junk\" items at merchant"
L["OPT_AUTO_SELL_DESC"] = "When set, all items considered \"junk\" will automatically be sold when talking to any merchant."
L["OPT_GENERAL"] = "General options"
L["OPT_JUNK"] = "\"Junk\" options"
L["OPT_JUNK_LIGHT"] = "Light-weight, soulbound armor is junk"
L["OPT_JUNK_LIGHT_DESC"] = "When set, armor which is soulbound and lighter-weight than a class typically wears (taking level into account) is considered junk.  For example, leather is light-weight for Warriors.  Some specs (healadins wearing spellpower cloth, high-level hunters wearing agility leather) probably want to leave this off."
L["OPT_JUNK_POOR"] = "\"Poor\"-quality items are junk"
L["OPT_JUNK_POOR_DESC"] = "When set, \"poor\"-quality items (whose names appear in grey) are considered junk.  Also called \"vendor trash\"."
L["OPT_JUNK_UNUSABLE"] = "Unusable, soulbound equipment is junk"
L["OPT_JUNK_UNUSABLE_DESC"] = "When set, equipment which is soulbound but cannot be equipped by your character is considered junk.  For example, maces and plate are unusable by a Mage.  Enchanters probably want to leave this off."
L["OPT_NOTJUNK"] = "\"Not junk\" options"
L["OPT_NOTJUNK_ENCHANTED"] = "Enchanted items are not junk"
L["OPT_NOTJUNK_ENCHANTED_DESC"] = "When set, enchanted items will never be considered \"junk\" unless they are specifically included in the \"junk\" list."
L["OPT_NOTJUNK_GEMMED"] = "Gemmed items are not junk"
L["OPT_NOTJUNK_GEMMED_DESC"] = "When set, gemmed items will never be considered \"junk\" unless they are specifically included in the \"junk\" list."
L["OPT_PROMPT_SELL"] = "Ask before selling items"
L["OPT_PROMPT_SELL_DESC"] = "When set, a window will appear showing the items to be sold and allowing you to cancel the sale."

L["WARN_UNKNOWN_TYPE"] = function(link, type, subtype) return "Item " .. link .. " has unknown type \"" .. type .. ", " .. subtype .. "\" and will not be sold.  Please check to see if a new version of this addon is available." end
