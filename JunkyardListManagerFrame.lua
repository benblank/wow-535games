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
local tinsert = table.insert
local UseContainerItem = UseContainerItem

local L = LibStub("AceLocale-3.0"):GetLocale("Junkyard")

local lines = 10
local lineheight = 16

local items, over

local function CompareItems(item1, item2)
end

local function GetIndexFromButton(id)
	return FauxScrollFrame_GetOffset(JunkyardListManagerFrameScrollFrame) + tonumber(id)
end

function JunkyardListManagerFrame_OnHide(self)
	items = {}

	PlaySound("igMainMenuContinue");
end

function JunkyardListManagerFrame_OnLoad(self)
	JunkyardListManagerFrameTitleText:SetText("Junkyard")
end

function JunkyardListManagerFrame_OnShow(self)
	local link, name, quality

	items = {}

	for id in pairs(Junkyard.db.profile.junk_list) do
		name, link, quality = GetItemInfo(id)

		if not link then
			-- query from server; this is a potentially dangerous
			-- operation for "junk" items which are rare enough, but if
			-- they're so rare, why are they in your "junk" list at all?
			Junkyard.tooltip:ClearLines()
			Junkyard.tooltip:SetHyperlink("item:" .. id .. ":0:0:0:0:0:0:0")

			name, link, quality = GetItemInfo(id)
		end

		if not link then
			-- often, SetHyperlink will successfully cache the item
			-- (i.e. not cause a disconnect) but the data still won't be
			-- available immediately
			name, quality = link, L["UNKNOWN_ITEM"](id)
		end

		tinsert(items, { id = id, name = name, link = link, quality = quality, checked = false })
	end

LMitems = items

	JunkyardListManagerFrameScrollFrame_Update(JunkyardListManagerFrameScrollFrame)
end

function JunkyardListManagerFrameItem_OnClick(self, motion)
	--TODO: remove from list

	JunkyardListManagerFrameScrollFrame_Update(JunkyardListManagerFrameScrollFrame)
end

function JunkyardListManagerFrameItem_OnEnter(self, motion)
	over = self

	local id = self:GetID()
	local item = items[GetIndexFromButton(id)]

	-- "unknown" items don't have tooltips
	if item.link then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(item.link)
	end

	local r, g, b = GetItemQualityColor(item.quality)
	JunkyardListManagerFrameItemHighlight:SetVertexColor(r, g, b, .6)

	JunkyardListManagerFrameItemHighlightFrame:SetPoint("TOPLEFT", self)
	JunkyardListManagerFrameItemHighlightFrame:SetPoint("BOTTOMRIGHT", self)
	JunkyardListManagerFrameItemHighlightFrame:Show()
end

function JunkyardListManagerFrameItem_OnLeave(self, motion)
	over = nil

	GameTooltip:Hide()

	JunkyardListManagerFrameItemHighlightFrame:Hide()
end

function JunkyardListManagerFrameScrollFrame_OnVerticalScroll(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, lineheight, JunkyardListManagerFrameScrollFrame_Update)
end

function JunkyardListManagerFrameScrollFrame_Update(self)
	local button, index, offset
	local numitems = #items

	if numitems <= lines then
		JunkyardListManagerFrameItem1:SetPoint("TOPRIGHT", -8, -7);
	else
		-- leave room for scroll bar
		JunkyardListManagerFrameItem1:SetPoint("TOPRIGHT", -26, -7);
	end

	FauxScrollFrame_Update(self, numitems, lines, lineheight)
	offset = FauxScrollFrame_GetOffset(self)

	for line = 1, lines do
		index = line + offset
		button = _G["JunkyardListManagerFrameItem" .. line]

		if index <= numitems then
			button:SetText(items[index].link)
			button:Show()
		else
			button:Hide()
		end
	end

	local total = 0

	if over then
		JunkyardListManagerFrameItem_OnEnter(over)
	end
end
