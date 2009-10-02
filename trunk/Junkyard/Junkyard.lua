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

Junkyard = LibStub("AceAddon-3.0"):NewAddon("Junkyard", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")

local options = {
	main = {
		name = "Junkyard",
		handler = Junkyard,
		type = "group",
		args = {
			auto_sell = {
				name = L["OPT_AUTO_SELL"],
				desc = L["OPT_AUTO_SELL_DESC"],
				type = "toggle",
				order = 10,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			prompt_sell = {
				name = L["OPT_PROMPT_SELL"],
				desc = L["OPT_PROMPT_SELL_DESC"],
				type = "toggle",
				order = 20,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			auto_repair = {
				name = L["OPT_AUTO_REPAIR"],
				desc = L["OPT_AUTO_REPAIR_DESC"],
				type = "toggle",
				order = 30,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			compare = {
				name = L["OPT_COMPARE"],
				desc = L["OPT_COMPARE_DESC"],
				type = "toggle",
				order = 40,
				get = function(info) return GetCVarBool("alwaysCompareItems") end,
				set = function(info, value) SetCVar("alwaysCompareItems", value and "1" or "0") end,
			},
		},
	},

	junk = {
		name = L["OPT_JUNK"],
		handler = Junkyard,
		type = "group",
		args = {
			junk_poor = {
				name = L["OPT_JUNK_POOR"],
				desc = L["OPT_JUNK_POOR_DESC"],
				type = "toggle",
				order = 10,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			junk_unusable = {
				name = L["OPT_JUNK_UNUSABLE"],
				desc = L["OPT_JUNK_UNUSABLE_DESC"],
				type = "toggle",
				order = 20,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			junk_light = {
				name = L["OPT_JUNK_LIGHT"],
				desc = L["OPT_JUNK_LIGHT_DESC"],
				type = "toggle",
				order = 30,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			["junklist"] = {
				name = L["OPT_JUNKLIST"],
				type = "header",
				order = 40,
			},

			["junklist-add"] = {
				name = L["OPT_JUNKLIST_ADD"],
				desc = L["OPT_JUNKLIST_ADD_DESC"],
				type = "input",
				order = 50,
				width = "full",
				set = function(info, value) Junkyard:CmdJunkListAdd(value) end,
				dialogControl = "LinkBox",
				hidden = "AllowBagsHack",
			},

			["junklist-select"] = {
				name = L["OPT_JUNKLIST"],
				type = "multiselect",
				order = 55,
				width = "full",
				values = function() return Junkyard:GetJunkList() end,
			},

			["junklist-remove"] = {
				name = L["OPT_JUNKLIST_REMOVE"],
				desc = L["OPT_JUNKLIST_REMOVE_DESC"],
				type = "input",
				order = 60,
				width = "full",
				set = function(info, value) Junkyard:CmdJunkListRemove(value) end,
				dialogControl = "LinkBox",
			},
		},
	},

	notjunk = {
		name = L["OPT_NOTJUNK"],
		handler = Junkyard,
		type = "group",
		args = {
			notjunk_enchanted = {
				name = L["OPT_NOTJUNK_ENCHANTED"],
				desc = L["OPT_NOTJUNK_ENCHANTED_DESC"],
				type = "toggle",
				order = 10,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			notjunk_gemmed = {
				name = L["OPT_NOTJUNK_GEMMED"],
				desc = L["OPT_NOTJUNK_GEMMED_DESC"],
				type = "toggle",
				order = 20,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			["notjunklist"] = {
				name = L["OPT_NOTJUNKLIST"],
				type = "header",
				order = 30,
			},

			["notjunklist-add"] = {
				name = L["OPT_NOTJUNKLIST_ADD"],
				desc = L["OPT_NOTJUNKLIST_ADD_DESC"],
				type = "input",
				order = 40,
				width = "full",
				set = function(info, value) Junkyard:CmdNotJunkListAdd(value) end,
				dialogControl = "LinkBox",
				hidden = "AllowBagsHack",
			},

			["notjunklist-remove"] = {
				name = L["OPT_NOTJUNKLIST_REMOVE"],
				desc = L["OPT_NOTJUNKLIST_REMOVE_DESC"],
				type = "input",
				order = 50,
				width = "full",
				set = function(info, value) Junkyard:CmdNotJunkListRemove(value) end,
				dialogControl = "LinkBox",
			},
		},
	},

	bags = {
		name = L["OPT_BAGS"],
		handler = Junkyard,
		type = "group",
		args = {
			open = {
				name = L["OPT_BAGS_OPEN"],
				type = "header",
				order = 10,
			},

			open_auction = {
				name = L["OPT_BAGS_OPEN_AUCTION"],
				type = "toggle",
				order = 20,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			open_bank = {
				name = L["OPT_BAGS_OPEN_BANK"],
				type = "toggle",
				order = 30,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			open_guild = {
				name = L["OPT_BAGS_OPEN_GUILD"],
				type = "toggle",
				order = 40,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			open_mail = {
				name = L["OPT_BAGS_OPEN_MAIL"],
				type = "toggle",
				order = 50,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			open_merchant = {
				name = L["OPT_BAGS_OPEN_MERCHANT"],
				type = "toggle",
				order = 60,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			open_trade = {
				name = L["OPT_BAGS_OPEN_TRADE"],
				type = "toggle",
				order = 70,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			close = {
				name = L["OPT_BAGS_CLOSE"],
				type = "header",
				order = 80,
			},

			close_auction = {
				name = L["OPT_BAGS_CLOSE_AUCTION"],
				type = "toggle",
				order = 90,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			close_bank = {
				name = L["OPT_BAGS_CLOSE_BANK"],
				type = "toggle",
				order = 100,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			close_guild = {
				name = L["OPT_BAGS_CLOSE_GUILD"],
				type = "toggle",
				order = 110,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			close_mail = {
				name = L["OPT_BAGS_CLOSE_MAIL"],
				type = "toggle",
				order = 120,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			close_merchant = {
				name = L["OPT_BAGS_CLOSE_MERCHANT"],
				type = "toggle",
				order = 130,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			close_trade = {
				name = L["OPT_BAGS_CLOSE_TRADE"],
				type = "toggle",
				order = 140,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},
		},
	},
}

local defaults = {
	profile = {
		auto_repair = true,
		auto_sell = true,
		close_auction = true,
		close_bank = true,
		close_guild = true,
		close_mail = true,
		close_merchant = true,
		close_trade = true,
		debug = false,
		junk_light = false,
		junk_poor = true,
		junk_unusable = false,
		notjunk_enchanted = true,
		notjunk_gemmed = true,
		open_auction = true,
		open_bank = true,
		open_guild = true,
		open_mail = true,
		open_merchant = true,
		open_trade = true,
		prompt_sell = true,

		junk_list = {
		},

		notjunk_list = {
			7189, -- Goblin Rocket Boots
			10506, -- Deepdive Helmet
			10542, -- Goblin Mining Helmet
			10543, -- Goblin Construction Helmet
			10588, -- Goblin Rocket Helmet
			10721, -- Gnomish Harm Prevention Belt
			10724, -- Gnomish Rocket Boots
			10726, -- Gnomish Mind Control Cap
			19969, -- Nat Pagle's Extreme Anglin' Boots
			19972, -- Lucky Fishing Hat
			33820, -- Weather-Beaten Fishing Hat
		},
	},
}

local bag_events = {
	AUCTION_HOUSE_CLOSED  = "close_auction",
	AUCTION_HOUSE_SHOW    = "open_auction",
	BANKFRAME_CLOSED      = "close_bank",
	BANKFRAME_OPENED      = "open_bank",
	GUILDBANKFRAME_CLOSED = "close_guild",
	GUILDBANKFRAME_OPENED = "open_guild",
	MAIL_CLOSED           = "close_mail",
	MAIL_SHOW             = "open_mail",
	MERCHANT_CLOSED       = "close_merchant",
	MERCHANT_SHOW         = "open_merchant",
	TRADE_CLOSED          = "close_trade",
	TRADE_SHOW            = "open_trade",
}

local function ItemListTool(self, args, list, value, success, dupe)
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
				self:Print(L[dupe](link))
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

function Junkyard:GetOption(info)
	return self.db.profile[info[#info]]
end

function Junkyard:SetOption(info, value)
	self.db.profile[info[#info]] = value
end

function Junkyard:AllowBagsHack(info)
	if not self:IsHooked("IsOptionFrameOpen") then
		self:RawHook("IsOptionFrameOpen", function() return nil end, true)
	end

	if not self:IsHooked("OptionsFrame_OnHide") then
		self:SecureHook("OptionsFrame_OnHide", "AllowBagsUnhack")
	end

	return false -- called as a "hidden" handler
end

function Junkyard:AllowBagsUnhack()
	self:Unhook("IsOptionFrameOpen")
	self:Unhook("OptionsFrame_OnHide")
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

function Junkyard:CmdOptions(which)
	which = self.panels[strtrim(which)]

	if which then
		InterfaceOptionsFrame_OpenToCategory(which)
	else
		-- opening a sub-category first ensures the primary category is expanded
		InterfaceOptionsFrame_OpenToCategory(self.panels.profile);
		InterfaceOptionsFrame_OpenToCategory(self.panels.main);
	end
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

	local _, count, enchanted, gem1, gem2, gem3, gem4, gemmed, id, link, lsubtype, ltype, price, quality, sell, slot, slots, soulbound, subtype, type

	local class = select(2, UnitClass("player"))
	local indices = {}
	local items = {}
	local level = UnitLevel("player")
	local profile = self.db.profile

	for bag = 0, NUM_BAG_SLOTS do
		slots = GetContainerNumSlots(bag)

		for slot = 1, slots do
			link = GetContainerItemLink(bag, slot)

			if link then
				sell = false
				id, enchanted, gem1, gem2, gem3, gem4 = strsplit(":", link:sub(18))
				id = tonumber(id)
				enchanted = tonumber(enchanted) > 0
				gemmed = tonumber(gem1) > 0 or tonumber(gem2) > 0 or tonumber(gem3) > 0 or tonumber(gem4) > 0
				link, quality, _, _, ltype, lsubtype, _, _, _, price = select(2, GetItemInfo(id))

				if profile.junk_unusable or profile.junk_light then
					type = LBIR[ltype]
					subtype = LBIR[lsubtype]

					if self[type] then
						if self[type].known[subtype] then
							self.tooltip:ClearLines()
							self.tooltip:SetBagItem(bag, slot)
							soulbound = JunkyardTooltipTextLeft2:GetText() == ITEM_SOULBOUND
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
					if profile.prompt_sell then
						count = select(2, GetContainerItemInfo(bag, slot))

						if indices[id] then
							table.insert(items[indices[id]], {bag=bag, slot=slot, count=count})
						else
							table.insert(items, { {bag=bag, slot=slot, count=count, quality=quality, link=link, price=price} })
							indices[id] = #items
						end
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

function Junkyard:GetJunkList()
	local map = {}

	for i, id in ipairs(self.db.profile.notjunk_list) do
		map[id] = select(2, GetItemInfo(id))
print(id, map[id])
	end

	return map
end

function Junkyard:OnBagEvent(event)
	local action = bag_events[event]

	if self.db.profile[action] then
		if strsplit("_", action) == "open" then
			-- "OpenAllBags" (from ContainerFrame.lua) doesn't actually open
			-- all bags (at least, there's no way to guarantee it unless you
			-- run CloseAllBags first), so this function is patterened after
			-- CloseAllBags, which *always* works as expected.

			OpenBackpack()

			for i=1, NUM_CONTAINER_FRAMES, 1 do
				OpenBag(i)
			end
		else
			CloseAllBags()
		end
	end
end

function Junkyard:OnEnable()
	self:RegisterEvent("MERCHANT_CLOSED", "OnMerchantClosed")
	self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")
	self:RegisterEvent("AUCTION_HOUSE_CLOSED", "OnBagEvent")
	self:RegisterEvent("AUCTION_HOUSE_SHOW", "OnBagEvent")
	self:RegisterEvent("BANKFRAME_CLOSED", "OnBagEvent")
	self:RegisterEvent("BANKFRAME_OPENED", "OnBagEvent")
	self:RegisterEvent("GUILDBANKFRAME_CLOSED", "OnBagEvent")
	self:RegisterEvent("GUILDBANKFRAME_OPENED", "OnBagEvent")
	self:RegisterEvent("MAIL_CLOSED", "OnBagEvent")
	self:RegisterEvent("MAIL_SHOW", "OnBagEvent")
	self:RegisterEvent("TRADE_CLOSED", "OnBagEvent")
	self:RegisterEvent("TRADE_SHOW", "OnBagEvent")
end

function Junkyard:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("JunkyardDB", defaults)

	options.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

	self.panels = {}

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Junkyard", options.main)
	self.panels.main = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Junkyard", "Junkyard")

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("JunkyardJunk", options.junk)
	self.panels.junk = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("JunkyardJunk", options.junk.name, "Junkyard")

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("JunkyardNotJunk", options.notjunk)
	self.panels.notjunk = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("JunkyardNotJunk", options.notjunk.name, "Junkyard")

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("JunkyardBags", options.bags)
	self.panels.bags = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("JunkyardBags", options.bags.name, "Junkyard")

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("JunkyardProfile", options.profile)
	self.panels.profile = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("JunkyardProfile", options.profile.name, "Junkyard")

	self:RegisterChatCommand("junkyard", "CmdOptions")
	self:RegisterChatCommand("sell", "CmdSell")
	self:RegisterChatCommand("repair", "CmdRepair")

	self.tooltip = CreateFrame("GameTooltip", "JunkyardTooltip")
	self.tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	self.tooltip:AddFontStrings(self.tooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"), self.tooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText"));

	self.frame = JunkyardSellFrame

	self.at_merchant = false
end

function Junkyard:OnMerchantClosed()
	self.at_merchant = false
	self.frame:Hide()

	self:OnBagEvent("MERCHANT_CLOSED")
end

function Junkyard:OnMerchantShow()
	self.at_merchant = true

	if CanMerchantRepair() and self.db.profile.auto_repair then
		self:CmdRepair()
	end

	if self.db.profile.auto_sell then
		self:CmdSell()
	end

	self:OnBagEvent("MERCHANT_SHOW")
end

function Junkyard:PrintError(message)
	self:Print("[|cffe61a1aERROR|r] " .. message)
	PlaySoundFile([[Sound\interface\Error.wav]])
end

function Junkyard:PrintWarning(message)
	self:Print("[|cffefea1aWarning|r] " .. message)
	PlaySoundFile([[Sound\interface\Error.wav]])
end
