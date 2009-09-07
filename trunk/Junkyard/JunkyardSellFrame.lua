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

local L = LibStub("AceLocale-3.0"):GetLocale("Junkyard")

local lines = 10
local lineheight = 16

local items, over

local function GetItemFromID(id)
	return FauxScrollFrame_GetOffset(JunkyardSellFrameScrollFrame) + tonumber(id)
end

function JunkyardSellFrame_OnHide(self)
	items = {}
end

function JunkyardSellFrame_OnLoad(self)
	JunkyardSellFrameTitleText:SetText("Junkyard")

	self.SetItems = function(self, newItems)
		items = newItems
		FauxScrollFrame_SetOffset(JunkyardSellFrameScrollFrame, 0)
		JunkyardSellFrameScrollFrame_Update(JunkyardSellFrameScrollFrame)
	end
end

function JunkyardSellFrameCancelButton_OnClick(self, button, down)
	self:GetParent():Hide()
end

function JunkyardSellFrameItem_OnClick(self, motion)
	for i, info in ipairs(table.remove(items, GetItemFromID(self:GetID()))) do
		ShowMerchantSellCursor(1)
		UseContainerItem(info.bag, info.slot)
	end

	if #items > 0 then
		JunkyardSellFrameScrollFrame_Update(JunkyardSellFrameScrollFrame)
	else
		JunkyardSellFrame:Hide()
	end
end

function JunkyardSellFrameItem_OnEnter(self, motion)
	local item = items[GetItemFromID(self:GetID())]

	over = self

	GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
	GameTooltip:SetHyperlink(item[1].link)

	JunkyardSellFrameItemHighlight:SetVertexColor(GetItemQualityColor(item[1].quality))
	JunkyardSellFrameItemHighlightFrame:SetPoint("TOPRIGHT", self, 0, -1)
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
	local button, item, numitems, line, offset

	numitems = #items
	FauxScrollFrame_Update(self, numitems, lines, lineheight)
	offset = FauxScrollFrame_GetOffset(self)

	for line = 1, lines do
		item = line + offset
		button = _G["JunkyardSellFrameItem" .. line]

		if item <= numitems then
			local count = 0

			for i, info in ipairs(items[item]) do
				count = count + info.count
			end

			MoneyFrame_Update(_G["JunkyardSellFrameItem" .. line .. "MoneyFrame"], count * items[item][1].price)

			count = (count > 1) and (count .. "x ") or ""

			button:SetText(count .. items[item][1].link)
			button:Show()
		else
			button:Hide()
		end
	end

	if over then
		JunkyardSellFrameItem_OnEnter(over)
	end
end

function JunkyardSellFrameSellButton_OnClick(self, button, down)
	local i, info, item

	for i, item in ipairs(items) do
		for j, info in ipairs(item) do
			ShowMerchantSellCursor(1)
			UseContainerItem(info.bag, info.slot)
		end
	end

	JunkyardSellFrame:Hide()
end

function JunkyardSellFrameSellButton_OnLoad(self)
	self:SetText(L["BUTTON_SELL"])
end
