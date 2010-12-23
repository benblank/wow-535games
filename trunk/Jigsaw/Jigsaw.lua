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
		recent = nil,
	},
}

local broker = LibStub("LibDataBroker-1.1", true):NewDataObject("Jigsaw", {
	type = "data source",
	label = "Jigsaw",
	icon = [[Interface\Archeology\Arch-Icon-Marker]],
})

function Jigsaw:FormatProgress(id)
	if not (self.ready or self:ScanRaces()) then
		return
	end

	local name, currency = GetArchaeologyRaceInfo(id)
	local count = GetNumArtifactsByRace(id)

	if count > 0 then
		SetSelectedArtifact(id) -- omitting the second parameter selects the "current" artifact for the selected race

		local item, _, rarity, icon, _, sockets = GetSelectedArtifactInfo()
		local keystones = min(sockets, GetItemCount(self.byid[id].keystone))

		for i = 1, keystones do
			SocketItemToArtifact()
		end

		local progress, bonus, total = GetArtifactProgress()

		if keystones > 0 then
			progress = GREEN_FONT_COLOR_CODE .. (progress + bonus) .. string.rep("+", keystones) .. HIGHLIGHT_FONT_COLOR_CODE
		else
			progress = HIGHLIGHT_FONT_COLOR_CODE .. progress
		end

		if sockets > keystones then
			progress = progress .. string.rep("+", sockets - keystones)
		end

		-- there is no reliable way to get the artifact *item*'s quality, so fake it by converting "common" (1) to "rare" (3)
		return name, "|T" .. icon .. ":0|t " .. select(4, GetItemQualityColor(rarity * 3)) .. item .. "|r", progress .. "/" .. total .. "|r"
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
		local name, artifact, progress = Jigsaw:FormatProgress(id)

		if progress then
			self:AddDoubleLine(artifact .. " (" .. name .. ")", progress)
		end
	end
end

function Jigsaw:OnEnable()
	self:RegisterEvent("ARTIFACT_COMPLETE", "ScanCurrency")
	self:RegisterEvent("ARTIFACT_UPDATE", "UpdateText")
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE", "ScanCurrency")
	self:RegisterEvent("PLAYER_ALIVE", "ScanRaces")
end

function Jigsaw:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("JigsawDB", defaults)
end

function Jigsaw:ScanCurrency()
	if not (self.ready or self:ScanRaces()) then
		return
	end

	local scan = {}

	for currency, info in pairs(self.bycurrency) do
		local amount = select(2, GetCurrencyInfo(currency))

		scan[currency] = amount

		if self.currency and self.currency[currency] ~= amount then
			self.db.profile.recent = info.name
			self:UpdateText()
		end
	end

	self.currency = scan
end

function Jigsaw:ScanRaces(event)
	local count = GetNumArchaeologyRaces()

	if count == 0 then
		self.ready = false
		return self.ready
	end

	self.byid = {}
	self.byname = {}
	self.bycurrency = {}
	self.bykeystone = {}

	for id = 1, count do
		local name, currency, _, keystone = GetArchaeologyRaceInfo(id)
		local info = { id = id, name = name, currency = currency, keystone = keystone }

		self.byid[id] = info
		self.byname[name] = info
		self.bycurrency[currency] = info
		self.bykeystone[keystone] = info
	end

	self.ready = true
	self:UpdateText()

	return self.ready
end

function Jigsaw:UpdateText()
	if not (self.ready or self:ScanRaces()) then
		return
	end

	if self.db.profile.recent then
		local name, _, progress = self:FormatProgress(self.byname[self.db.profile.recent].id)

		broker.text = name .. " " .. (progress or "???")
	end
end
