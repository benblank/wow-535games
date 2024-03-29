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

local Doolittle = LibStub("AceAddon-3.0"):GetAddon("Doolittle")
local L = LibStub("AceLocale-3.0"):GetLocale("Doolittle")

local function Enable(button, enabled)
	local color = enabled and 1 or .5

	button:GetNormalTexture():SetVertexColor(color, color, color)
end

local function ShowRating(rating)
	Enable(DoolittleRatingFrameRating0, rating == 0)

	for i = 1, 5 do
		Enable(_G["DoolittleRatingFrameRating" .. i], i <= rating)
	end

	DoolittleRatingFrameText:SetText(L["LABEL_RATING"][rating])
end

function DoolittleRatingFrameRating_OnClick(self, button, down)
	Doolittle:SetCurrentRating(tonumber(self:GetID()))
end

function DoolittleRatingFrameRating_OnEnter(self, motion)
	ShowRating(tonumber(self:GetID()))
end

function DoolittleRatingFrameRating_OnLeave(self, motion)
	ShowRating(Doolittle:GetCurrentRating())
end
