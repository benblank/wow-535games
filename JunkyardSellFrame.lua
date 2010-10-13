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
local MoneyFrame_Update = MoneyFrame_Update
local UseContainerItem = UseContainerItem

local L = LibStub("AceLocale-3.0"):GetLocale("Junkyard")

local lines = 10
local lineheight = 16

local items, over

local function GetIndexFromButton(id)
	return FauxScrollFrame_GetOffset(JunkyardSellFrameScrollFrame) + tonumber(id)
end

function JunkyardSellFrame_OnHide(self)
	items = {}

	PlaySound("igMainMenuContinue");
end

function JunkyardSellFrame_OnLoad(self)
	JunkyardSellFrameTitleText:SetText("Junkyard")

	self.SetItems = function(self, newItems)
		items = newItems
		FauxScrollFrame_SetOffset(JunkyardSellFrameScrollFrame, 0)
		JunkyardSellFrameScrollFrame_Update(JunkyardSellFrameScrollFrame)
	end
end

function JunkyardSellFrameItem_OnClick(self, motion)
	for i, info in ipairs(table.remove(items, GetIndexFromButton(self:GetID()))) do
		UseContainerItem(info.bag, info.slot)
	end

	JunkyardSellFrameScrollFrame_Update(JunkyardSellFrameScrollFrame)
end

function JunkyardSellFrameItem_OnEnter(self, motion)
	over = self

	local id = self:GetID()

	if id ~= 0 then
		local item = items[GetIndexFromButton(id)]

		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")

		-- if there's exactly one of an item, show its real tooltip (in case of
		-- enchants, etc.), otherwise use generic tooltip for one of that item
		if #item == 1 and item[1].count == 1 then
			GameTooltip:SetBagItem(item[1].bag, item[1].slot)
		else
			GameTooltip:SetHyperlink(item[1].link)
		end

		local r, g, b = GetItemQualityColor(item[1].quality)
		JunkyardSellFrameItemHighlight:SetVertexColor(r, g, b, .6)
	else
		JunkyardSellFrameItemHighlight:SetVertexColor(1, 1, 1, .6)
	end

	JunkyardSellFrameItemHighlightFrame:SetPoint("TOPLEFT", self)
	JunkyardSellFrameItemHighlightFrame:SetPoint("BOTTOMRIGHT", self)
	JunkyardSellFrameItemHighlightFrame:Show()
end

function JunkyardSellFrameItem_OnLeave(self, motion)
	over = nil

	GameTooltip:Hide()

	JunkyardSellFrameItemHighlightFrame:Hide()
end

function JunkyardSellFrameItemMoneyFrame_OnLoad(self)
	-- the "STATIC" moneyType needs no events, but has no OnLoadFunc, so fake it
	self.small = 1
	MoneyFrame_SetType(self, "STATIC")
end

function JunkyardSellFrameScrollFrame_OnVerticalScroll(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, lineheight, JunkyardSellFrameScrollFrame_Update)
end

function JunkyardSellFrameScrollFrame_Update(self)
	local button, index, offset
	local numitems = #items

	if numitems == 0 then
		JunkyardSellFrame:Hide()
		return
	end

	if numitems <= lines then
		JunkyardSellFrameItem1:SetPoint("TOPRIGHT", -8, -7);
	else
		-- leave room for scroll bar
		JunkyardSellFrameItem1:SetPoint("TOPRIGHT", -26, -7);
	end

	FauxScrollFrame_Update(self, numitems, lines, lineheight)
	offset = FauxScrollFrame_GetOffset(self)

	for line = 1, lines do
		index = line + offset
		button = _G["JunkyardSellFrameItem" .. line]

		if index <= numitems then
			local count = 0

			for _, info in ipairs(items[index]) do
				count = count + info.count
			end

			MoneyFrame_Update(_G["JunkyardSellFrameItem" .. line .. "MoneyFrame"], count * items[index][1].price)

			count = (count > 1) and (count .. "x ") or ""

			button:SetText(count .. items[index][1].link)
			button:Show()
		else
			button:Hide()
		end
	end

	local total = 0

	for _, item in ipairs(items) do
		local count = 0

		for _, info in ipairs(item) do
			count = count + info.count
		end

		total = total + item[1].price * count
	end

	MoneyFrame_Update(JunkyardSellFrameSellAllButtonMoneyFrame, total)

	if over then
		JunkyardSellFrameItem_OnEnter(over)
	end
end

function JunkyardSellFrameSellAllButton_OnClick(self, button, down)
	Junkyard.halt_scanning = true

	for i, item in ipairs(items) do
		for j, info in ipairs(item) do
			UseContainerItem(info.bag, info.slot)
		end
	end

	JunkyardSellFrame:Hide()

	Junkyard.halt_scanning = false
	Junkyard:ScanJunk()
end

function JunkyardSellFrameSellAllButton_OnLoad(self)
	self:SetText(L["BUTTON_SELL"])
end
