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

Jigsaw = LibStub("AceAddon-3.0"):NewAddon("Jigsaw", "AceEvent-3.0")

local options = {
	name = "Jigsaw",
	handler = Jigsaw,
	type = "group",
	args = {
	},
}

local defaults = {
	profile = {
	},
}

local broker = LibStub("LibDataBroker-1.1", true):NewDataObject("Jigsaw", {
	type = "data source",
	label = "Jigsaw",
	icon = [[Interface\Archeology\Arch-Icon-Marker]],
})

local function FormatLines(id)
	local name, currency = GetArchaeologyRaceInfo(id)
	local count = GetNumArtifactsByRace(id)

	if count > 0 then
		SetSelectedArtifact(id) -- omitting the second parameter selects the "current" artifact for the selected race

		local base, _, total = GetArtifactProgress()
		local item, _, rarity, icon, _, sockets = GetSelectedArtifactInfo()
		local keystones = min(sockets, Jigsaw.keystones[id] or 0)

		local current = base

		if keystones > 0 then
			current = GREEN_FONT_COLOR_CODE .. (current + keystones * 12) .. string.rep("+", keystones) .. HIGHLIGHT_FONT_COLOR_CODE
		else
			current = HIGHLIGHT_FONT_COLOR_CODE ..current
		end

		if sockets > keystones then
			current = current .. string.rep("+", sockets - keystones)
		end

		return "|T" .. icon .. ":0|t " .. select(4, GetItemQualityColor(rarity)) .. item .. "|r (" .. name .. ")", current .. "/" .. total
	else
		return name
	end
end

function broker:OnClick()
	CastSpellByName("Archaeology")
end

function broker:OnTooltipShow()
	self:AddLine(ARCHAEOLOGY_CURRENT)

	for id = 1, GetNumArchaeologyRaces() do
		local artifact, progress = FormatLines(id)

		if progress then
			self:AddDoubleLine(artifact, progress)
		end
	end
end

function Jigsaw:OnEnable()
	self:RegisterEvent("BAG_UPDATE", "ScanKeystones")
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE", "ScanCurrency")
end

function Jigsaw:OnInitialize()
	self.byid = {}
	self.byname = {}
	self.bycurrency = {}
	self.bykeystone = {}

	for id = 1, GetNumArchaeologyRaces() do
		local name, currency, _, keystone = GetArchaeologyRaceInfo(id)
		local info = { id = id, name = name, currency = currency }

		self.byid[id] = info
		self.byname[name] = info
		self.bycurrency[currency] = info
		self.bykeystone[keystone] = info
	end
end

function Jigsaw:ScanCurrency()
	local scan = {}

	for currency, info in pairs(self.bycurrency) do
		local amount = select(2, GetCurrencyInfo(currency))

		scan[currency] = amount

		if self.currency and self.currency[currency] < amount then
			local artifact, progress = FormatLines(info.id)

			broker.text = artifact .. " " .. progress
		end
	end

	self.currency = scan
end

function Jigsaw:ScanKeystones()
	local scan = {}

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local info = self.bykeystone[GetContainerItemID(bag, slot)]

			if info then
				scan[info.id] = (scan[info.id] or 0) + select(2, GetContainerItemInfo(bag, slot))
			end
		end
	end

	self.keystones = scan
end
