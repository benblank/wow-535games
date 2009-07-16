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

-- local references to commonly-used global variables for faster access
local GetContainerItemLink = GetContainerItemLink
local GetItemInfo = GetItemInfo
local LibStub = LibStub
local ShowMerchantSellCursor = ShowMerchantSellCursor
local strsplit = strsplit
local tonumber = tonumber
local UseContainerItem = UseContainerItem

local L = LibStub("AceLocale-3.0"):GetLocale("Junkyard")
local LBIR = LibStub("LibBabble-Inventory-3.0"):GetReverseLookupTable()

Junkyard = LibStub("AceAddon-3.0"):NewAddon("Junkyard", "AceConsole-3.0", "AceEvent-3.0")

local options = {
	name = "Junkyard",
	handler = Junkyard,
	type = "group",
	args = {
		options = {
			name = L["CMD_OPTIONS"],
			desc = L["CMD_OPTIONS_DESC"],
			type = "execute",
			order = 9,
			dialogHidden = true,
			func = "CmdOptions",
		},

		sell = {
			name = L["CMD_SELL"],
			desc = L["CMD_SELL_DESC"],
			type = "execute",
			order = 10,
			dialogHidden = true,
			func = "CmdSell",
		},

		repair = {
			name = L["CMD_SELL"],
			desc = L["CMD_SELL_DESC"],
			type = "execute",
			order = 11,
			dialogHidden = true,
			func = "CmdRepair",
		},

		["open-bags"] = {
			name = L["CMD_BAGS_OPEN"],
			desc = L["CMD_BAGS_OPEN_DESC"],
			type = "execute",
			order = 12,
			dialogHidden = true,
			func = "CmdBagsOpen",
		},

		["close-bags"] = {
			name = L["CMD_BAGS_CLOSE"],
			desc = L["CMD_BAGS_CLOSE_DESC"],
			type = "execute",
			order = 13,
			dialogHidden = true,
			func = "CmdBagsClose",
		},

		general = {
			name = L["OPT_GENERAL"],
			type = "header",
			order = 20,
		},

		["opt-auto-sell"] = {
			name = L["OPT_AUTO_SELL"],
			desc = L["OPT_AUTO_SELL_DESC"],
			type = "toggle",
			order = 30,
			width = "full",
			get = function(info) return Junkyard.db.profile.auto_sell end,
			set = function(info, value) Junkyard.db.profile.auto_sell = value end,
		},

		["opt-prompt-sell"] = {
			name = L["OPT_PROMPT_SELL"],
			desc = L["OPT_PROMPT_SELL_DESC"],
			type = "toggle",
			order = 31,
			width = "full",
			get = function(info) return Junkyard.db.profile.prompt end,
			set = function(info, value) Junkyard.db.profile.prompt = value end,
		},

		["opt-auto-repair"] = {
			name = L["OPT_AUTO_REPAIR"],
			desc = L["OPT_AUTO_REPAIR_DESC"],
			type = "toggle",
			order = 32,
			width = "full",
			get = function(info) return Junkyard.db.profile.auto_repair end,
			set = function(info, value) Junkyard.db.profile.auto_repair = value end,
		},

		junk = {
			name = L["OPT_JUNK"],
			type = "header",
			order = 40,
		},

		["junk-poor"] = {
			name = L["OPT_JUNK_POOR"],
			desc = L["OPT_JUNK_POOR_DESC"],
			type = "toggle",
			order = 50,
			width = "full",
			get = function(info) return Junkyard.db.profile.junk_poor end,
			set = function(info, value) Junkyard.db.profile.junk_poor = value end,
		},

		["junk-unusable"] = {
			name = L["OPT_JUNK_UNUSABLE"],
			desc = L["OPT_JUNK_UNUSABLE_DESC"],
			type = "toggle",
			order = 60,
			width = "full",
			get = function(info) return Junkyard.db.profile.junk_unusable end,
			set = function(info, value) Junkyard.db.profile.junk_unusable = value end,
		},

		["junk-light"] = {
			name = L["OPT_JUNK_LIGHT"],
			desc = L["OPT_JUNK_LIGHT_DESC"],
			type = "toggle",
			order = 70,
			width = "full",
			get = function(info) return Junkyard.db.profile.junk_light end,
			set = function(info, value) Junkyard.db.profile.junk_light = value end,
		},

		notjunk = {
			name = L["OPT_NOTJUNK"],
			type = "header",
			order = 80,
		},

		["notjunk-enchanted"] = {
			name = L["OPT_NOTJUNK_ENCHANTED"],
			desc = L["OPT_NOTJUNK_ENCHANTED_DESC"],
			type = "toggle",
			order = 90,
			width = "full",
			get = function(info) return Junkyard.db.profile.notjunk_enchanted end,
			set = function(info, value) Junkyard.db.profile.notjunk_enchanted = value end,
		},

		["notjunk-gemmed"] = {
			name = L["OPT_NOTJUNK_GEMMED"],
			desc = L["OPT_NOTJUNK_GEMMED_DESC"],
			type = "toggle",
			order = 100,
			width = "full",
			get = function(info) return Junkyard.db.profile.notjunk_gemmed end,
			set = function(info, value) Junkyard.db.profile.notjunk_gemmed = value end,
		},

		["junklist"] = {
			name = L["OPT_JUNKLIST"],
			type = "header",
			order = 110,
		},

		["junklist-add"] = {
			name = L["OPT_JUNKLIST_ADD"],
			desc = L["OPT_JUNKLIST_ADD_DESC"],
			type = "input",
			order = 120,
			width = "full",
			set = function(info, value) Junkyard:CmdJunkListAdd(value) end,
		},

		["junklist-remove"] = {
			name = L["OPT_JUNKLIST_REMOVE"],
			desc = L["OPT_JUNKLIST_REMOVE_DESC"],
			type = "input",
			order = 130,
			width = "full",
			set = function(info, value) Junkyard:CmdJunkListRemove(value) end,
		},

		["notjunklist"] = {
			name = L["OPT_NOTJUNKLIST"],
			type = "header",
			order = 140,
		},

		["notjunklist-add"] = {
			name = L["OPT_NOTJUNKLIST_ADD"],
			desc = L["OPT_NOTJUNKLIST_ADD_DESC"],
			type = "input",
			order = 150,
			width = "full",
			set = function(info, value) Junkyard:CmdNotJunkListAdd(value) end,
		},

		["notjunklist-remove"] = {
			name = L["OPT_NOTJUNKLIST_REMOVE"],
			desc = L["OPT_NOTJUNKLIST_REMOVE_DESC"],
			type = "input",
			order = 160,
			width = "full",
			set = function(info, value) Junkyard:CmdNotJunkListRemove(value) end,
		},
	},
}

local defaults = {
	profile = {
		auto_repair = true,
		auto_sell = true,
		debug = false,
		junk_light = false,
		junk_list = {},
		junk_poor = true,
		junk_unusable = false,
		notjunk_enchanted = true,
		notjunk_gemmed = true,
		notjunk_list = {},
	},
}

local ItemListTool = function(self, args, list, value, success, dupe)
	local id, link

	local found = false
	local pat_id = "^%d+$"
	local pat_str = "^item:(%d+)"
	local pat_link = "|Hitem:(%d+)"

	for arg in strtrim(args):gmatch("[^%s]+") do
		id = arg:match(pat_id)
		if not id then id = arg:match(pat_str) end
		if not id then id = arg:match(pat_link) end

		if id then
			found = true

			id = tonumber(id)
			link = select(2, GetItemInfo(id))

			if list[id] == value then
				self:PrintWarning(L[dupe](link))
			else
				list[id] = value

				self:Print(L[success](link))
			end
		end
	end

	if not found then
		self:PrintError(L["MSG_INVALID_ITEM"])
		if self.db.profile.debug then self:Print(args:gsub("|", "||")) end
		return
	end
end

function Junkyard:CmdBagsClose()
	 -- unlike OpenAllBags, this actually does what it says on the tin
	CloseAllBags()
end

function Junkyard:CmdBagsOpen()
	-- OpenAllBags doesn't (at least, there's no way to guarantee it will work
	-- as expected without running CloseAllBags first) - this function is
	-- patterened after CloseAllBags, which *always* works as expected
	OpenBackpack();
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		OpenBag(i);
	end
end

function Junkyard:CmdJunkListAdd(args)
	ItemListTool(self, args, self.db.profile.junk_list, true, "MSG_JUNK_ADDED", "MSG_JUNK_ADDED_DUPE")
end

function Junkyard:CmdJunkListRemove(args)
	ItemListTool(self, args, self.db.profile.junk_list, nil, "MSG_JUNK_REMOVED", "MSG_JUNK_REMOVED_DUPE")
end

function Junkyard:CmdNotJunkListAdd(args)
	ItemListTool(self, args, self.db.profile.notjunk_list, true, "MSG_NOTJUNK_ADDED", "MSG_NOTJUNK_ADDED_DUPE")
end

function Junkyard:CmdNotJunkListRemove(args)
	ItemListTool(self, args, self.db.profile.notjunk_list, nil, "MSG_NOTJUNK_REMOVED", "MSG_NOTJUNK_REMOVED_DUPE")
end

function Junkyard:CmdOptions()
	-- opening the "Profile" sub-category first ensures the primary category is expanded
	InterfaceOptionsFrame_OpenToCategory(self.opt_profile);
	InterfaceOptionsFrame_OpenToCategory(self.opt_main);
end

function Junkyard:CmdRepair()
	if not self.at_merchant then
		self:PrintError(L["MSG_NO_MERCHANT"])
		return
	elseif not CanMerchantRepair() then
		self:PrintError(L["MSG_CANNOT_REPAIR"])
	end
	RepairAllItems()
end

function Junkyard:CmdSell()
	if not self.at_merchant then
		self:PrintError(L["MSG_NO_MERCHANT"])
		return
	end

	local _, enchanted, gem1, gem2, gem3, gem4, gemmed, id, link, lsubtype, ltype, quality, sell, slot, slots, soulbound, subtype, type

	local class = select(2, UnitClass("player"))
	local items = {}
	local level = UnitLevel("player")
	local profile = self.db.profile

	for bag = 0, NUM_BAG_SLOTS do
		slots = GetContainerNumSlots(bag)

		for slot = 1, slots do
			link = GetContainerItemLink(bag, slot)

			if link then
				sell = false
				quality, _, _, ltype, lsubtype = select(3, GetItemInfo(link))
				id, enchanted, gem1, gem2, gem3, gem4 = strsplit(":", link:sub(18))
				id = tonumber(id)
				enchanted = tonumber(enchanted) > 0
				gemmed = tonumber(gem1) > 0 or tonumber(gem2) > 0 or tonumber(gem3) > 0 or tonumber(gem4) > 0

				if profile.junk_unusable or profile.junk_light then
					type = LBIR[ltype]
					subtype = LBIR[lsubtype]

					if self[type] then
						if self[type].known[subtype] then
							self.tooltip:ClearLines()
							self.tooltip:SetBagItem(bag, slot)
							soulbound = getglobal("JunkyardTooltipTextLeft2"):GetText() == ITEM_SOULBOUND
						else
							soulbound = false -- prevent type-based sales from occurring
							self:PrintWarning(L["MSG_UNKNOWN_TYPE"](link, ltype, lsubtype))
						end
					else
						soulbound = false
					end
				else
					soulbound = false
				end

				if profile.junk_poor and quality == 0 then
					sell = true
				end

				if profile.junk_light and type == "Armor" and soulbound and level >= (self.Armor[class][subtype] or 1000) then
					sell = true
				end

				if profile.junk_unusable and soulbound and not self[type][class][subtype] then
					sell = true
				end

				if profile.junk_list[id] then
					sell = true
				end

				if profile.notjunk_enchanted and enchanted then
					sell = false
				end

				if profile.notjunk_gemmed and gemmed then
					sell = false
				end

				if profile.notjunk_list[id] then
					sell = false
				end

				if sell then
					if profile.prompt then
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
		self.frame:SetItems(items)
		self.frame:Show()
	end
end

function Junkyard:OnEnable()
	self:RegisterEvent("MERCHANT_CLOSED", "OnMerchantClosed")
	self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")
end

function Junkyard:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("JunkyardDB", defaults)
	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	options.args.profile.dialogHidden = true

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Junkyard", options, "junkyard")
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Junkyard", options)
	self.opt_main = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Junkyard", "Junkyard")

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("JunkyardProfile", options.args.profile)
	self.opt_profile = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("JunkyardProfile", "Profile", "Junkyard")

	self.tooltip = CreateFrame("GameTooltip", "JunkyardTooltip")
	self.tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	self.tooltip:AddFontStrings(self.tooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"), self.tooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText"));

	self.frame = JunkyardSellFrame

	self.at_merchant = false
end

function Junkyard:OnMerchantClosed()
	self.at_merchant = false

	self.frame:Hide()
end

function Junkyard:OnMerchantShow()
	self.at_merchant = true

	if CanMerchantRepair() and self.db.profile.auto_repair then
		self:CmdRepair()
	end

	if self.db.profile.auto_sell then
		self:CmdSell()
	end
end

function Junkyard:PrintError(message)
	self:Print("[|cffe61a1aERROR|r] " .. message)
	PlaySoundFile([[Sound\interface\Error.wav]])
end

function Junkyard:PrintWarning(message)
	self:Print("[|cffefea1aWarning|r] " .. message)
	PlaySoundFile([[Sound\interface\Error.wav]])
end
