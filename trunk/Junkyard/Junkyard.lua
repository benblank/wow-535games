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

Junkyard = LibStub("AceAddon-3.0"):NewAddon("Junkyard", "AceConsole-3.0", "AceEvent-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Junkyard")
local LBIR = LibStub("LibBabble-Inventory-3.0"):GetReverseLookupTable()

local options = {
	name = "Junkyard",
	handler = Junkyard,
	type = "group",
	args = {
		sell = {
			name = L["CMD_SELL"],
			desc = L["CMD_SELL_DESC"],
			type = "execute",
			order = 10,
			dialogHidden = true,
			func = "CmdSell",
		},

		sep1 = {
			name = "",
			type = "header",
			order = 20,
			dialogHidden = true,
		},

		auto = {
			name = L["OPT_AUTO"],
			type = "toggle",
			order = 30,
			width = "full",
			get = function(info) return Junkyard.db.profile.auto end,
			set = function(info, value) Junkyard.db.profile.auto = value end,
		},

		prompt = {
			name = L["OPT_PROMPT"],
			desc = L["OPT_PROMPT_DESC"],
			type = "toggle",
			order = 31,
			width = "full",
			get = function(info) return Junkyard.db.profile.prompt end,
			set = function(info, value) Junkyard.db.profile.prompt = value end,
		},

		repair = {
			name = L["OPT_REPAIR"],
			type = "toggle",
			order = 32,
			width = "full",
			get = function(info) return Junkyard.db.profile.repair end,
			set = function(info, value) Junkyard.db.profile.repair = value end,
		},

		sep2 = {
			name = "",
			type = "header",
			order = 40,
		},

		junk = {
			name = L["OPT_JUNK"],
			desc = L["OPT_JUNK_DESC"],
			type = "toggle",
			order = 50,
			width = "full",
			get = function(info) return Junkyard.db.profile.junk end,
			set = function(info, value) Junkyard.db.profile.junk = value end,
		},

		unusable = {
			name = L["OPT_UNUSABLE"],
			desc = L["OPT_UNUSABLE_DESC"],
			type = "toggle",
			order = 60,
			width = "full",
			get = function(info) return Junkyard.db.profile.unusable end,
			set = function(info, value) Junkyard.db.profile.unusable = value end,
		},

		light = {
			name = L["OPT_LIGHT"],
			desc = L["OPT_LIGHT_DESC"],
			type = "toggle",
			order = 70,
			width = "full",
			get = function(info) return Junkyard.db.profile.light end,
			set = function(info, value) Junkyard.db.profile.light = value end,
		},

		sep3 = {
			name = "",
			type = "header",
			order = 80,
		},

		["no-enchanted"] = {
			name = L["OPT_ENCHANTED"],
			desc = L["OPT_ENCHANTED_DESC"],
			type = "toggle",
			order = 90,
			width = "full",
			get = function(info) return Junkyard.db.profile.no_enchanted end,
			set = function(info, value) Junkyard.db.profile.no_enchanted = value end,
		},

		["no-gemmed"] = {
			name = L["OPT_GEMMED"],
			desc = L["OPT_GEMMED_DESC"],
			type = "toggle",
			order = 100,
			width = "full",
			get = function(info) return Junkyard.db.profile.no_gemmed end,
			set = function(info, value) Junkyard.db.profile.no_gemmed = value end,
		},
	},
}

local defaults = {
	profile = {
		auto = true,
		junk = true,
		unusable = true,
		light = false,
		no_enchanted = true,
		no_gemmed = true,
	},
}

function Junkyard:CmdSell(skipcheck)
	-- GetMerchantItemLink(1) occasionally returns nil at the time MERCHANT_SHOW is fired, so the event handler passes "true" to skip the usual check
	if not skipcheck and GetMerchantItemLink(1) == nil then
		self:DisplayError(ERR_VENDOR_TOO_FAR)
		return
	end

	local _, class, enchanted, equip, gem1, gem2, gem3, gem4, gemmed, level, link, name, quality, req, items, sell, slot, slots, soulbound, subtype, type

	items = {}

	for bag = 0, NUM_BAG_SLOTS do
		slots = GetContainerNumSlots(bag)

		for slot = 1, slots do
			link = GetContainerItemLink(bag, slot)

			if link then
				sell = false
				name, _, quality, _, req, type, subtype, _, equip, _ = GetItemInfo(link)
				enchanted, gem1, gem2, gem3, gem4 = link:match("item:%d+:(%d+):(%d+):(%d+):(%d+):(%d+)")
				enchanted = tonumber(enchanted) > 0
				gemmed = tonumber(gem1) > 0 or tonumber(gem2) > 0 or tonumber(gem3) > 0 or tonumber(gem4) > 0

				if self.db.profile.unusable or self.db.profile.light then
					_, class = UnitClass("player")
					level = UnitLevel("player")
					type = LBIR[type]
					subtype = LBIR[subtype]

					if self[type] then
						if self[type].known[subtype] then
							self.tooltip:ClearLines()
							self.tooltip:SetBagItem(bag, slot)
							soulbound = getglobal("JunkyardTooltipTextLeft2"):GetText() == ITEM_SOULBOUND
						else
							soulbound = false -- prevent type-based sales from occurring
							self:Print(L["WARN_UNKNOWN_TYPE"](link, type, subtype))
						end
					else
						soulbound = false
					end
				else
					soulbound = false
				end

				if self.db.profile.junk and quality == 0 then
					sell = true
				end

				if self.db.profile.light and type == "Armor" and soulbound and level >= self.Armor[class][subtype] then
					sell = true
				end

				if self.db.profile.unusable and soulbound and not self[type][class][subtype] then
					sell = true
				end

				if self.db.profile.no_enchanted and enchanted then
					sell = false
				end

				if self.db.profile.no_gemmed and gemmed then
					sell = false
				end

				if sell then
					if self.db.profile.prompt then
						items[#items + 1] = {bag, slot, link}
					else
						ShowMerchantSellCursor(1)
						UseContainerItem(bag, slot)
					end
				end
			end
		end
	end

	if #items > 0 then
		self.frame.items = items
		self.frame:Show()
	end
end

function Junkyard:DisplayError(message)
	UIErrorsFrame:AddMessage(message, 1.0, 0.1, 0.1, 1.0)
end

function Junkyard:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("JunkyardDB", defaults)
	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Junkyard", options, {"junkyard"})
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Junkyard", options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Junkyard", "Junkyard")

	self:RegisterEvent("MERCHANT_CLOSED", "OnMerchantClosed")
	self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")

	self.tooltip = CreateFrame("GameTooltip", "JunkyardTooltip")
	self.tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	self.tooltip:AddFontStrings(self.tooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"), self.tooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText"));

	self.frame = JunkyardSellFrame
end

function Junkyard:OnMerchantClosed()
	self.frame:Hide()
end

function Junkyard:OnMerchantShow()
	if CanMerchantRepair() and self.db.profile.repair then
		RepairAllItems()
	end

	if self.db.profile.auto then
		-- GetMerchantItemLink(1) occasionally returns nil at the time MERCHANT_SHOW is fired, so skip the usual check
		self:CmdSell(true)
	end
end
