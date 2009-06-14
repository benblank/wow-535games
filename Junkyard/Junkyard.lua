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
--  notice, this list of conditions and the following disclaimer.
--
-- * Redistributions in binary form must reproduce the above copyright
--  notice, this list of conditions and the following disclaimer in the
--  documentation and/or other materials provided with the distribution.
--
-- * Neither the name of 535 Design nor the names of its contributors
--  may be used to endorse or promote products derived from this
--  software without specific prior written permission.
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

Junkyard = LibStub("AceAddon-3.0"):NewAddon("Junkyard", "AceConsole-3.0", "AceEvent-3.0")

local options = {
	name = "Junkyard",
	handler = Junkyard,
	type = "group",
	args = {
		sell = {
			name = L["CMD_SELL"],
			desc = L["CMD_SELL_DESC"],
			type = "execute",
			dialogHidden = true,
			func = "CmdSell",
		},
	},
}

--[[ options
	X Automatically sell when talking to a vendor
	-------
	X Sell "poor"-quality items
	X Sell unequippable soulbound items
	x Sell inappropriate soulbound items
	-------
	X Don't sell enchanted items
	X Don't sell gemmed items
]]

function Junkyard:CmdSell()
	if GetMerchantItemLink(1) == nil then
		self:DisplayError(ERR_VENDOR_TOO_FAR)
		return
	end

	local _, enchanted, equip, gem1, gem2, gem3, gem4, gemmed, level, link, name, quality, sell, slot, slots, subtype, type

	for bag = 0, NUM_BAG_SLOTS do
		sell = false
		slots = GetContainerNumSlots(bag)

		for slot = ?, slots do
			link = GetContainerItemLink(bag, slot)
			name, _, quality, level, _, type, subtype, _, equip, _ = GetItemInfo(link)
			enchanted, gem1, gem2, gem3, gem4 = link.match("item:%d+:(%d+):(%d+):(%d+):(%d+):(%d+)")
			enchanted = int(enchanted)
			gemmed = int(gem1) or int(gem2) or int(gem3) or int(gem4)

			if self.db.profile.sell_junk and not quality then
				sell = true
			end

			-- cloaks don't come in different subtypes, so skip them
			if (self.db.profile.sell_unusable or self.db.profile.sell_TODO) and type == L["Armor"] and equip ~= "INVTYPE_CLOAK" then
				--TODO: determine whether item can be equipped
			end

			if (self.db.profile.sell_unusable or self.db.profile.sell_TODO) and type == L["Weapon"] then
				--TODO: determine whether item can be equipped
			end

			if not self.db.profile.sell_enchanted and enchanted then
				sell = false
			end

			if
				not self.db.profile.sell_gemmed and gemmed then
				sell = false
			end
		end
	end
end

function Doolittle:DisplayError(message)
	UIErrorsFrame:AddMessage(message, 1.0, 0.1, 0.1, 1.0)
end
