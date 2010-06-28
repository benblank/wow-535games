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
local strsplit = strsplit
local tonumber = tonumber
local UnitClass = UnitClass
local UnitLevel = UnitLevel
local UseContainerItem = UseContainerItem

-- the meaning of the word "type" is overloaded by both WoW and AceConfig
local typeof = type

local L = LibStub("AceLocale-3.0"):GetLocale("Junkyard")
local LBIR = LibStub("LibBabble-Inventory-3.0"):GetReverseLookupTable()

Junkyard = LibStub("AceAddon-3.0"):NewAddon("Junkyard", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")

local opts_list = {}
local opts_selected = {}

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

			repair_source = {
				name = L["OPT_REPAIR_SOURCE"],
				type = "select",
				order = 35,
				width = "full",
				get = "GetOption",
				set = "SetOption",

				values = {
					auto     = L["OPT_REPAIR_SOURCE_AUTO"],
					guild    = L["OPT_REPAIR_SOURCE_GUILD"],
					personal = L["OPT_REPAIR_SOURCE_PERSONAL"],
				},
			},

			compare = {
				name = L["OPT_COMPARE"],
				desc = L["OPT_COMPARE_DESC"],
				type = "toggle",
				order = 40,
				width = "full",
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
				hidden = "OptionsHack",
			},

			["junklist-add"] = {
				name = L["OPT_JUNKLIST_ADD"],
				desc = L["OPT_JUNKLIST_ADD_DESC"],
				type = "input",
				order = 50,
				width = "full",
				set = function(info, value) Junkyard:CmdJunkListAdd(value) end,
			},

			["junklist-remove"] = {
				name = L["OPT_JUNKLIST_REMOVE"],
				desc = L["OPT_JUNKLIST_REMOVE_DESC"],
				type = "input",
				order = 60,
				width = "full",
				set = function(info, value) Junkyard:CmdJunkListRemove(value) end,
			},

			["junklist-select"] = {
				name = L["OPT_JUNKLIST"],
				type = "multiselect",
				order = 70,
				width = "full",
				values = function() return Junkyard:GetJunkList() end,
				set = function(info, key, checked) opts_selected[key] = checked end,
				get = function(info, key, checked) return opts_selected[key] end,
			},

			["junklist-select-remove"] = {
				name = L["OPT_REMOVE_SELECTED"],
				type = "execute",
				order = 80,
				func = "CmdJunkListRemoveSelected",
			},

			["junklist-select-clear"] = {
				name = L["OPT_CLEAR_SELECTED"],
				type = "execute",
				order = 90,
				func = function() opts_selected = {} end,
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
				hidden = "OptionsHack",
			},

			["notjunklist-add"] = {
				name = L["OPT_NOTJUNKLIST_ADD"],
				desc = L["OPT_NOTJUNKLIST_ADD_DESC"],
				type = "input",
				order = 40,
				width = "full",
				set = function(info, value) Junkyard:CmdNotJunkListAdd(value) end,
			},

			["notjunklist-remove"] = {
				name = L["OPT_NOTJUNKLIST_REMOVE"],
				desc = L["OPT_NOTJUNKLIST_REMOVE_DESC"],
				type = "input",
				order = 50,
				width = "full",
				set = function(info, value) Junkyard:CmdNotJunkListRemove(value) end,
			},

			["notjunklist-select"] = {
				name = L["OPT_JUNKLIST"],
				type = "multiselect",
				order = 60,
				width = "full",
				values = function() return Junkyard:GetNotJunkList() end,
				set = function(info, key, checked) opts_selected[key] = checked end,
				get = function(info, key, checked) return opts_selected[key] end,
			},

			["notjunklist-select-remove"] = {
				name = L["OPT_REMOVE_SELECTED"],
				type = "execute",
				order = 70,
				func = "CmdNotJunkListRemoveSelected",
			},

			["notjunklist-select-clear"] = {
				name = L["OPT_CLEAR_SELECTED"],
				type = "execute",
				order = 80,
				func = function() opts_selected = {} end,
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

			open_skill = {
				name = L["OPT_BAGS_OPEN_SKILL"],
				type = "toggle",
				order = 65,
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

			skip_ammo = {
				name = L["OPT_BAGS_SKIP_AMMO"],
				type = "toggle",
				order = 75,
				width = "full",
				get = "GetOption",
				set = "SetOption",
			},

			skip_soul = {
				name = L["OPT_BAGS_SKIP_SOUL"],
				type = "toggle",
				order = 76,
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

			close_skill = {
				name = L["OPT_BAGS_CLOSE_SKILL"],
				type = "toggle",
				order = 135,
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
		close_skill = false,
		close_trade = false,
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
		open_skill = false,
		open_trade = true,
		prompt_sell = true,
		repair_source = "auto",
		skip_ammo = true,
		skip_soul = true,

		junk_list = {
		},

		notjunk_list = {
			[7189] = true, -- Goblin Rocket Boots
			[10506] = true, -- Deepdive Helmet
			[10542] = true, -- Goblin Mining Helmet
			[10543] = true, -- Goblin Construction Helmet
			[10588] = true, -- Goblin Rocket Helmet
			[10721] = true, -- Gnomish Harm Prevention Belt
			[10724] = true, -- Gnomish Rocket Boots
			[10726] = true, -- Gnomish Mind Control Cap
			[19969] = true, -- Nat Pagle's Extreme Anglin' Boots
			[19972] = true, -- Lucky Fishing Hat
			[33820] = true, -- Weather-Beaten Fishing Hat
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
	TRADE_SKILL_CLOSE     = "close_skill",
	TRADE_SKILL_SHOW      = "open_skill",
	TRADE_CLOSED          = "close_trade",
	TRADE_SHOW            = "open_trade",
}

local function ItemListTool(self, args, list, value, success, dupe)
	local _, id, link, price

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
			link, _, _, _, _, _, _, _, _, price = select(2, GetItemInfo(id))

			if price == 0 and list == Junkyard.db.profile.junk_list and value == true then
				self:Print(L["MSG_NO_SELL_PRICE"](link))
			else
				if list[id] == value then
					self:Print(L[dupe](link))
				else
					list[id] = value

					self:Print(L[success](link))
				end
			end
		end
	end

	if not found then
		self:PrintError(L["MSG_INVALID_ITEM"])

		return
	end
end

local function RemoveSelected(list)
	for key in pairs(opts_selected) do
		list[opts_list[key]] = nil
	end

	opts_selected = {}
end

function Junkyard:GetOption(info)
	return self.db.profile[info[#info]]
end

function Junkyard:SetOption(info, value)
	self.db.profile[info[#info]] = value
end

function Junkyard:OptionsHack(info)
	if not self:IsHooked("IsOptionFrameOpen") then
		self:RawHook("IsOptionFrameOpen", function() return nil end, true)
	end

	if not self:IsHooked("OptionsFrame_OnHide") then
		self:SecureHook("OptionsFrame_OnHide", "OptionsUnhack")
	end

	return false -- called as a "hidden" handler
end

function Junkyard:OptionsUnhack()
	self:Unhook("IsOptionFrameOpen")
	self:Unhook("OptionsFrame_OnHide")
end

function Junkyard:CmdJunkListAdd(args)
	ItemListTool(self, args, self.db.profile.junk_list, true, "MSG_JUNK_ADDED", "MSG_JUNK_ADDED_DUPE")
end

function Junkyard:CmdJunkListRemove(args)
	ItemListTool(self, args, self.db.profile.junk_list, nil, "MSG_JUNK_REMOVED", "MSG_JUNK_REMOVED_DUPE")
end

function Junkyard:CmdJunkListRemoveSelected()
	RemoveSelected(self.db.profile.junk_list)
end

function Junkyard:CmdNotJunkListAdd(args)
	ItemListTool(self, args, self.db.profile.notjunk_list, true, "MSG_NOTJUNK_ADDED", "MSG_NOTJUNK_ADDED_DUPE")
end

function Junkyard:CmdNotJunkListRemove(args)
	ItemListTool(self, args, self.db.profile.notjunk_list, nil, "MSG_NOTJUNK_REMOVED", "MSG_NOTJUNK_REMOVED_DUPE")
end

function Junkyard:CmdNotJunkListRemoveSelected()
	RemoveSelected(self.db.profile.notjunk_list)
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

function Junkyard:CmdIsJunk(id_or_link)
	local is_junk, conditions, link = self:IsJunk(id_or_link)

	if is_junk == nil then
		self:Print(L["MSG_ISJUNK_USAGE"])
	else
		self:Print(L["MSG_ISJUNK"](is_junk, conditions, link))
	end
end

function Junkyard:CmdRepair()
	if not self.at_merchant then
		self:PrintError(L["MSG_NO_MERCHANT"])
		return
	elseif not CanMerchantRepair() then
		self:PrintError(L["MSG_REPAIR_INVALID"])
	end

	local cost, needs_repair = GetRepairAllCost()

	if not needs_repair then
		return
	end

	local funds
	local size = select(2, DEFAULT_CHAT_FRAME:GetFont())
	local source = self.db.profile.repair_source

	-- attempt repair from guild bank funds
	if CanGuildBankRepair() and source ~= "personal" then
		funds = GetGuildBankWithdrawMoney()

		-- withdraw limit is -1 for guild masters
		if funds == -1 then
			funds = GetGuildBankMoney()
		else
			funds = math.min(funds, GetGuildBankMoney())
		end

		if cost > funds then
			self:Print(L["MSG_REPAIR_GUILD_POOR"](GetCoinTextureString(funds, size)))
		else
			RepairAllItems(1)
			self:Print(L["MSG_REPAIR_GUILD"](GetCoinTextureString(cost, size)))
			return
		end
	end

	if source ~= "guild" then
		funds = GetMoney()
		if cost > funds then
			self:Print(L["MSG_REPAIR_PERSONAL_POOR"](GetCoinTextureString(funds, size)))
		else
			RepairAllItems()
			self:Print(L["MSG_REPAIR_PERSONAL"](GetCoinTextureString(cost, size)))
			return
		end
	end

	self:DisplayWarning(L["MSG_REPAIR_POOR"](GetCoinTextureString(cost, size)))
end

function Junkyard:CmdSell()
	if not self.at_merchant then
		self:PrintError(L["MSG_NO_MERCHANT"])
		return
	end

	local _, count, id, is_junk, link, price, quality, slots

	local indices = {}
	local items = {}
	local sold = 0

	for bag = 0, NUM_BAG_SLOTS do
		slots = GetContainerNumSlots(bag)

		for slot = 1, slots do
			link = GetContainerItemLink(bag, slot)

			if link then
				is_junk, _, _, id, quality, price = self:IsJunk(link)

				if is_junk then
					count = select(2, GetContainerItemInfo(bag, slot))

					if self.db.profile.prompt_sell then
						if indices[id] then
							table.insert(items[indices[id]], {bag=bag, slot=slot, count=count})
						else
							table.insert(items, { {bag=bag, slot=slot, count=count, quality=quality, link=link, price=price} })
							indices[id] = #items
						end
					else
						UseContainerItem(bag, slot)

						sold = sold + count * price
					end
				end
			end
		end
	end

	if #items > 0 then
		self.frame:SetItems(items)
		self.frame:Show()
	end

	if sold > 0 then
		self:Print(L["MSG_SOLD"](GetCoinTextureString(sold, select(2, DEFAULT_CHAT_FRAME:GetFont()))))
	end
end

local function GetList(list)
	local link, name
	local map = {}

	for id in pairs(list) do
		name, link = GetItemInfo(id)

		if not link then
			-- query from server; this is a potentially dangerous
			-- operation for "junk" items which are rare enough, but if
			-- they're so rare, why are they in your "junk" list at all?
			Junkyard.tooltip:ClearLines()
			Junkyard.tooltip:SetHyperlink("item:" .. id .. ":0:0:0:0:0:0:0")

			name, link = GetItemInfo(id)
		end

		if not link then
			-- occasionally, SetHyperlink will successfully cache the item
			-- (i.e. not cause a disconnect) but the data still won't be
			-- available immediately
			link = L["UNKNOWN_ITEM"](id)
			name = link
		end

		-- AceGUI sorts multiselects by key
		name = name .. id
		opts_list[name] = id
		map[name] = link
	end

	return map
end

function Junkyard:GetJunkList()
	return GetList(self.db.profile.junk_list)
end

function Junkyard:GetNotJunkList()
	return GetList(self.db.profile.notjunk_list)
end

function Junkyard:OnBagEvent(event)
	local action = bag_events[event]
	local maxbag = 4
	local use_skips = false

	if action == "close_merchant" then
		self.at_merchant = false
		self.frame:Hide()
	elseif action == "open_merchant" then
		self.at_merchant = true

		if CanMerchantRepair() and self.db.profile.auto_repair then
			self:CmdRepair()
		end

		if self.db.profile.auto_sell then
			self:CmdSell()
		end
	elseif action == "open_bank" or action == "close_bank" then
		maxbag = 11
	end

	if self.db.profile[action] then
		if strsplit("_", action) == "open" then
			action = OpenBag
			use_skips = true
		else
			action = CloseBag
		end

		for i = 0, maxbag do
			repeat -- my kingdom for `continue` >.<
				if use_skips then
					bagtype = select(2, GetContainerNumFreeSlots(i))

					-- quivers
					if self.db.profile.skip_ammo and bagtype == 1 then
						break
					end

					-- ammo bags
					if self.db.profile.skip_ammo and bagtype == 2 then
						break
					end

					-- soul bags
					if self.db.profile.skip_soul and bagtype == 4 then
						break
					end
				end

				action(i)
			until true
		end
	end
end

function Junkyard:OnEnable()
	for event, action in pairs(bag_events) do
		self:RegisterEvent(event, "OnBagEvent")
	end
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

	self:RegisterChatCommand("isjunk", "CmdIsJunk")
	self:RegisterChatCommand("junkyard", "CmdOptions")
	self:RegisterChatCommand("sell", "CmdSell")
	self:RegisterChatCommand("repair", "CmdRepair")

	self.tooltip = CreateFrame("GameTooltip", "JunkyardTooltip")
	self.tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	self.tooltip:AddFontStrings(self.tooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"), self.tooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText"));

	self.frame = JunkyardSellFrame

	self.at_merchant = false
end

function Junkyard:PrintError(message)
	self:Print("[|cffe61a1aERROR|r] " .. message)
	PlaySoundFile([[Sound\interface\Error.wav]])
end

function Junkyard:PrintWarning(message)
	self:Print("[|cffefea1aWarning|r] " .. message)
	PlaySoundFile([[Sound\interface\Error.wav]])
end

function Junkyard:IsJunk(id_or_link)
	local _, class, enchanted, gem1, gem2, gem3, gem4, gemmed, id, level, link, loc, lsubtype, ltype, price, quality, slot, slots, soulbound, subtype, type

	local is_junk = false
	local profile = self.db.profile
	local conditions = {}

	-- IsJunk("7073")
	if typeof(id_or_link) == "string" and id_or_link:match("^%d+$") then
		id_or_link = tonumber(id_or_link)
	end

	-- IsJunk(7073)
	if typeof(id_or_link) == "number" then
		id = id_or_link
		enchanted = false
		gemmed = false
		link, quality, _, _, ltype, lsubtype, _, loc, _, price = select(2, GetItemInfo(id))

	-- IsJunk("item:7073:0:0:0:0:0:0:0")
	-- IsJunk("|cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0|h[Broken Fang]|h|r")
	else
		link = strtrim(id_or_link)
		id, enchanted, gem1, gem2, gem3, gem4 = strsplit(":", link:sub(link:sub(0, 1) == "|" and 18 or 6))
		id = tonumber(id)

		if id == nil then
			-- invalid argument
			return nil
		end

		enchanted = tonumber(enchanted) > 0
		gemmed = tonumber(gem1) > 0 or tonumber(gem2) > 0 or tonumber(gem3) > 0 or tonumber(gem4) > 0
		quality, _, _, ltype, lsubtype, _, loc, _, price = select(3, GetItemInfo(id))
	end

	if profile.junk_unusable or profile.junk_light then
		type = LBIR[ltype]
		subtype = LBIR[lsubtype]

		if self[type] then
			if self[type].known[subtype] then
				-------------------
				--   UGLY HACK   --
				-------------------

				-- Even with a hyperlink created from a bag item (which
				-- uniquely identifies the item instance), :SetHyperlink never
				-- reports whether the item is soulbound.  Instead, we must
				-- hunt through the player's bags to see whether the item from
				-- which the link was created exists there so that we can see
				-- whether or not it's soulbound.  Yuck!

				local slots

				for bag = 0, NUM_BAG_SLOTS do
					slots = GetContainerNumSlots(bag)

					for slot = 1, slots do
						if link == GetContainerItemLink(bag, slot) then
							self.tooltip:ClearLines()
							self.tooltip:SetBagItem(bag, slot)
							soulbound = JunkyardTooltipTextLeft2:GetText() == ITEM_SOULBOUND

							break
						end
					end

					if soulbound ~= nil then
						break
					end
				end

				if soulbound == nil then
					self.tooltip:ClearLines()
					self.tooltip:SetHyperlink(link)
					soulbound = JunkyardTooltipTextLeft2:GetText() == ITEM_SOULBOUND
				end

				if soulbound then
					class = select(2, UnitClass("player"))
					level = UnitLevel("player")
				end
			else
				soulbound = false -- prevent type-based sales from occurring
				self:PrintWarning(L["MSG_UNKNOWN_TYPE"](link, ltype, lsubtype))
			end
		else
			soulbound = false
		end
	end

	if profile.junk_poor and quality == 0 then
		is_junk = true
		table.insert(conditions, "junk_poor")
	end

	if profile.junk_light and soulbound and type == "Armor" and loc ~= "INVTYPE_CLOAK" and level >= (self.Armor[class][subtype] or 1000) then
		is_junk = true
		table.insert(conditions, "junk_light")
	end

	if profile.junk_unusable and soulbound and not self[type][class][subtype] then
		is_junk = true
		table.insert(conditions, "junk_unusable")
	end

	if profile.junk_list[id] then
		is_junk = true
		table.insert(conditions, "junk_list")
	end

	if price == 0 then
		is_junk = false
		table.insert(conditions, "price")
	end

	if profile.notjunk_enchanted and enchanted then
		is_junk = false
		table.insert(conditions, "notjunk_enchanted")
	end

	if profile.notjunk_gemmed and gemmed then
		is_junk = false
		table.insert(conditions, "notjunk_gemmed")
	end

	if profile.notjunk_list[id] then
		is_junk = false
		table.insert(conditions, "notjunk_list")
	end

	return is_junk, conditions, link, id, quality, price -- extra values are used by CmdIsJunk and CmdSell
end
