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

function JunkyardSellFrame_OnHide(self)
	self.items = {}
end

function JunkyardSellFrame_OnLoad(self)
	JunkyardSellFrameTitleText:SetText("Junkyard")

	self.SetItems = function(self, items)
		self.items = items
		FauxScrollFrame_SetOffset(JunkyardSellFrameScrollFrame, 0)
		JunkyardSellFrameScrollFrame_Update(JunkyardSellFrameScrollFrame)
	end
end

function JunkyardSellFrameCancelButton_OnClick(self, button, down)
	self:GetParent():Hide()
end

function JunkyardSellFrameListFrame_OnLoad(self)
	self:SetBackdropBorderColor(0.6, 0.6, 0.6);
end

function JunkyardSellFrameScrollFrame_OnVerticalScroll(self, offset)
	-- "self" here is JunkyardSellFrame!?
	FauxScrollFrame_OnVerticalScroll(JunkyardSellFrameScrollFrame, offset, lineheight, JunkyardSellFrameScrollFrame_Update)
end

function JunkyardSellFrameScrollFrame_Update(self)
	local fs, item, tiems, numitems, line, offset

	items = JunkyardSellFrame.items
	numitems = #items
	FauxScrollFrame_Update(self, numitems, lines, lineheight)
	offset = FauxScrollFrame_GetOffset(self)

	for line = 1, lines do
		item = line + offset
		fs = getglobal("JunkyardSellFrameItem" .. line)

		if item <= numitems then
			fs:SetText(items[item][3])
			fs:Show()
		else
			fs:Hide()
		end
	end
end

function JunkyardSellFrameSellButton_OnClick(self, button, down)
	local bag, i, item, items, parent, slot

	parent = self:GetParent()
	items = parent.items

	for i, item in pairs(items) do
		bag, slot = unpack(item)

		ShowMerchantSellCursor(1)
		UseContainerItem(bag, slot)
	end

	parent:Hide()
end

function JunkyardSellFrameSellButton_OnLoad(self)
	self:SetText(L["BUTTON_SELL"])
end
