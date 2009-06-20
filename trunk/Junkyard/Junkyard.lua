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

function Junkyard:CmdSell()
	if GetMerchantItemLink(1) == nil then
		self:DisplayError(ERR_VENDOR_TOO_FAR)
		return
	end

	local _, class, enchanted, equip, gem1, gem2, gem3, gem4, gemmed, level, link, name, quality, req, sales, sell, slot, slots, soulbound, subtype, type

	sales = {}

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

					self.tooltip:ClearLines()
					self.tooltip:SetBagItem(bag, slot)
					soulbound = getglobal("JunkyardTooltipTextLeft2"):GetText() == ITEM_SOULBOUND
				end

				if self.db.profile.junk and quality == 0 then
					sell = true
				end

				if self.db.profile.light and type == "Armor" and soulbound and level >= self.armor[class][subtype] then
					sell = true
				end

				if self.db.profile.unusable and type == "Armor" and soulbound and not self.armor[class][subtype] then
					sell = true
				end

				if self.db.profile.unusable and type == "Weapon" and soulbound and not self.weapons[class][subtype] then
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
						sales[#sales + 1] = {bag, slot, link}
					else
						ShowMerchantSellCursor(1)
						UseContainerItem(bag, slot)
					end
				end
			end
		end
	end

	if #sales > 0 then
		local frame = self.frame
		local list = self.list

		list:Clear()

		for i, sell in ipairs(sales) do
			list:AddMessage(sell[3], 1, 1, 1, 0, true)
		end

		frame:Show()

		self.button:SetScript("OnClick", function()
			for i, sell in ipairs(sales) do
				ShowMerchantSellCursor(1)
				UseContainerItem(sell[1], sell[2])
			end

			frame:Hide()
		end)
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

	local button, cancel, frame, list

	frame = CreateFrame("Frame", "JunkyardFrame", UIParent)
	frame:SetWidth(400)
	frame:SetHeight(300)
	frame:SetPoint("CENTER",UIParent,"CENTER",0,0)
	frame:EnableMouse()
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:SetBackdrop({ bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32, insets = { left = 8, right = 8, top = 8, bottom = 8 } })
	frame:SetBackdropColor(0,0,0,1)
	frame:SetToplevel(true)
	frame:Hide()

	frame:SetScript("OnHide", function()
		button:SetScript("OnClick", nil)
	end)

	button = CreateFrame("Button", "JunkyardSellButton", frame, "UIPanelButtonTemplate2")
	button:SetPoint("BOTTOMLEFT", 17, 17)
	button:SetHeight(24)
	button:SetWidth(100)
	button:SetText(L["CMD_SELL"])

	cancel = CreateFrame("Button", "JunkyardCancelButton", frame, "UIPanelButtonTemplate2")
	cancel:SetScript("OnClick", function() frame:Hide() end)
	cancel:SetPoint("BOTTOMRIGHT", -17, 17)
	cancel:SetHeight(24)
	cancel:SetWidth(100)
	cancel:SetText(CANCEL)

	list = CreateFrame("ScrollingMessageFrame", "JunkyardItemList", frame)
	list:SetFading(false)
	list:SetFontObject(GameFontNormal)
	list:SetInsertMode("TOP")
	list:SetJustifyH("LEFT")
	list:SetJustifyV("TOP")
	list:SetMaxLines(104) -- 4x22 + 16
	list:SetPoint("TOPLEFT", 18, -18)
	list:SetPoint("TOPRIGHT", -18, -18)
	list:SetPoint("BOTTOMLEFT", 18, 49)
	list:SetPoint("BOTTOMRIGHT", -18, 49)

	list:SetScript("OnHyperlinkEnter", function(self, data, link)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(link)
	end)

	list:SetScript("OnHyperlinkLeave", function(self, data, link)
		GameTooltip:Hide()
	end)

	self.button = button
	self.frame = frame
	self.list = list
end

function Junkyard:OnMerchantClosed()
	self.frame:Hide()
end

function Junkyard:OnMerchantShow()
	if CanMerchantRepair() and self.db.profile.repair then
		RepairAllItems()
	end

	if self.db.profile.auto then
		self:CmdSell()
	end
end
