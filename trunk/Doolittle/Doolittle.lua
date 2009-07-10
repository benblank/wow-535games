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

local LibStub = LibStub
local PetPaperDollFrameCompanionFrame = PetPaperDollFrameCompanionFrame

Doolittle = LibStub("AceAddon-3.0"):NewAddon("Doolittle", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Doolittle")
local LBZ = LibStub("LibBabble-Zone-3.0"):GetLookupTable()

local options = {
	name = "Doolittle",
	handler = Doolittle,
	type = "group",
	args = {
		mount = {
			name = MOUNT,
			desc = L["CMD_MOUNT_DESC"],
			type = "execute",
			dialogHidden = true,
			func = "CmdMount",
		},

		options = {
			name = L["CMD_OPTIONS"],
			desc = L["CMD_OPTIONS_DESC"],
			type = "execute",
			dialogHidden = true,
			func = "CmdOptions",
		},

		mounts = {
			name = MOUNTS,
			type = "group",
			args = {
				dismountkey = {
					name = L["OPT_DISMOUNT"],
					desc = L["OPT_DISMOUNT_DESC"],
					type = "select",
					order = 50,
					style = "dropdown",
					get = function(info) return Doolittle.db.profile.mounts.dismountkey end,
					set = function(info, value) Doolittle.db.profile.mounts.dismountkey = value end,
					values = { --BUG: these display sorted in GUI; NONE_KEY should appear last
						none = NONE_KEY,
						alt = ALT_KEY,
						ctrl = CTRL_KEY,
						shift = SHIFT_KEY,
					},
				},

				weights = {
					name = L["OPT_WEIGHTS"],
					desc = L["OPT_WEIGHTS_DESC"],
					type = "group",
					order = 50,
					inline = true,
					args = {
						rating0 = {
							name = L["OPT_WEIGHT_FOR"](0),
							type = "range",
							width = "full",
							min = 0,
							max = 10,
							step = 1,
							get = function(info) return Doolittle.db.profile.mounts.weights[0] end,
							set = function(info, value) Doolittle.db.profile.mounts.weights[0] = value end,
						},
						rating1 = {
							name = L["OPT_WEIGHT_FOR"](1),
							type = "range",
							width = "full",
							min = 0,
							max = 10,
							step = 1,
							get = function(info) return Doolittle.db.profile.mounts.weights[1] end,
							set = function(info, value) Doolittle.db.profile.mounts.weights[1] = value end,
						},
						rating2 = {
							name = L["OPT_WEIGHT_FOR"](2),
							type = "range",
							width = "full",
							min = 0,
							max = 10,
							step = 1,
							get = function(info) return Doolittle.db.profile.mounts.weights[2] end,
							set = function(info, value) Doolittle.db.profile.mounts.weights[2] = value end,
						},
						rating3 = {
							name = L["OPT_WEIGHT_FOR"](3),
							type = "range",
							width = "full",
							min = 0,
							max = 10,
							step = 1,
							get = function(info) return Doolittle.db.profile.mounts.weights[3] end,
							set = function(info, value) Doolittle.db.profile.mounts.weights[3] = value end,
						},
						rating4 = {
							name = L["OPT_WEIGHT_FOR"](4),
							type = "range",
							width = "full",
							min = 0,
							max = 10,
							step = 1,
							get = function(info) return Doolittle.db.profile.mounts.weights[4] end,
							set = function(info, value) Doolittle.db.profile.mounts.weights[4] = value end,
						},
						rating5 = {
							name = L["OPT_WEIGHT_FOR"](5),
							type = "range",
							width = "full",
							min = 0,
							max = 10,
							step = 1,
							get = function(info) return Doolittle.db.profile.mounts.weights[5] end,
							set = function(info, value) Doolittle.db.profile.mounts.weights[5] = value end,
						},
					},
				},
			},
		},
	},
}

local defaults = {
	profile = {
		critters = {
			ratings = {
				["*"] = 0,
			},

			weights = {
				[0] = 5,
				[1] = 0,
				[2] = 2,
				[3] = 5,
				[4] = 8,
				[5] = 10,
			},
		},

		mounts = {
			dismountkey = "shift",

			ratings = {
				["*"] = 0,
			},

			weights = {
				[0] = 5,
				[1] = 0,
				[2] = 2,
				[3] = 5,
				[4] = 8,
				[5] = 10,
			},
		},
	},
}

local function GetSelectedCompanion()
	local mode = PetPaperDollFrameCompanionFrame.mode
	local spell = select(3, GetCompanionInfo(mode, PetPaperDollFrame_FindCompanionIndex()))

	return mode:lower() .. "s", spell
end

function Doolittle:BuildOptionsAndDefaults()
	local args = options.args.mounts.args
	local profile = defaults.profile.mounts

	for terrain, speeds in pairs(self.mounts.speeds) do
		profile[terrain] = {fastest = true}

		args[terrain] = {
			name = L["TYPE_" .. terrain:upper()],
			type = "group",
			inline = true,
			args = {
				fastest = {
					name = L["OPT_FASTEST_ONLY"],
					desc = L["OPT_FASTEST_ONLY_DESC"],
					type = "toggle",
					order = 50,
					width = "full",
					get = function(info) return self.db.profile.mounts[terrain].fastest end,
					set = function(info, value) self.db.profile.mounts[terrain].fastest = value end,
				},
			},
		}

		for speed, default in pairs(speeds) do
			local sspeed = "speed" .. speed

			profile[terrain][sspeed] = default

			args[terrain].args[sspeed] = {
				name = L["OPT_INCLUDE_SPEED"](speed),
				type = "toggle",
				order = 1000 + speed,
				width = "full",
				disabled = function(info) return self.db.profile.mounts[terrain].fastest end,
				get = function(info) return self.db.profile.mounts[terrain][sspeed] end,
				set = function(info, value) self.db.profile.mounts[terrain][sspeed] = value end,
			}
		end
	end
end

function Doolittle:CmdMount()
	local zone = GetRealZoneText()
	local subzone = GetSubZoneText()
	local macro = "[mounted]dismount;[combat]error-combat;[indoors]error-indoors;[swimming]swimming;[flyable]flying;ground"
	local profile = self.db.profile.mounts
	local dismountkey = profile.dismountkey

	if dismountkey ~= "none" then
		macro = "[mounted,flying,nomodifier:" .. dismountkey .. "]error-flying;" .. macro
	end

	local command = SecureCmdOptionParse(macro)

	if command == "dismount" then
		Dismount()
		return
	elseif command == "error-combat" then
		self:DisplayError(ERR_NOT_IN_COMBAT)
		return
	elseif command == "error-flying" then
		self:DisplayError(L["ERROR_FLYING"](getglobal(dismountkey:upper() .. "_KEY")))
		return
	elseif command == "error-indoors" then
		self:DisplayError(SPELL_FAILED_NO_MOUNTS_ALLOWED)
		return
	elseif command == "flying" and (zone == LBZ["Wintergrasp"] or (zone == LBZ["Dalaran"] and subzone ~= LBZ["Krasus' Landing"])) then
		command = "ground"
	end

	local pool = self:GetMountPool(command)

	-- ground mounts can be used anywhere if no flying/swimming mounts are available
	if not (pool:size() > 0) and command ~= "ground" then
		pool = self:GetMountPool("ground")
	end

	if not (pool:size() > 0) then
		self:DisplayError(L["ERROR_NO_MOUNTS"])
		return
	end

	local rating
	local ratings = {}
	local pools = self.mounts.pools.ratings
	local tickets = {}

	for i = 0, 5 do
		rating = pools[i] * pool

		if rating:size() > 0 then
			ratings[i] = rating

			for j = 1, profile.weights[i] do
				table.insert(tickets, i)
			end
		end
	end

	-- somehow, there are occasionally zero tickets at this point; I need to add code to analyze the problem
	if not (#tickets > 0) then
		self:Print("[|cffe61a1aERROR|r] Can't happen: zero tickets")
		return
	end

	rating = tickets[math.random(#tickets)]

	CallCompanion("MOUNT", ratings[rating][ratings[rating]()][1])
end

function Doolittle:CmdOptions()
	-- opening the "Profile" sub-category first ensures the primary category is expanded
	InterfaceOptionsFrame_OpenToCategory(self.opt_profile);
	InterfaceOptionsFrame_OpenToCategory(self.opt_main);
end

function Doolittle:DisplayError(message)
	UIErrorsFrame:AddMessage(message, 1.0, 0.1, 0.1, 1.0)
end

function Doolittle:GetMountPool(terrain)
	local pool
	local pools = self.mounts.pools
	local tpools = pools[terrain]
	local profile = self.db.profile.mounts[terrain]

	if profile.fastest then
		if tpools.fastest < 0 then
			return Pool{}
		end

		pool = tpools[tpools.fastest]
	else
		pool = Pool{}

		for speed, default in pairs(profile) do
			if speed:sub(1, 5) == "speed" then
				pool = pool + tpools[tonumber(speed:sub(6))]
			end
		end
	end

	return pool * pools.known
end

function Doolittle:GetRating(mode, spell)
	return self.db.profile[mode].ratings[spell]
end

function Doolittle:OnCompanionUpdate(event, mode)
	if mode == nil then
		self:ScanCompanions("CRITTER")
		self:ScanCompanions("MOUNT")
	else
		self:ScanCompanions(mode)
	end

	-- companion data isn't always available during
	-- OnInitialize, but this only needs to occur once
	if not self.built_rating_pools then
		for mode in pairs{critters=1, mounts=1} do
			local ratings = {}

			for rating = 0, 5 do
				ratings[rating] = Pool{}
			end

			for spell, info in pairs(self[mode].pools.known) do
				local rating = self.db.profile[mode].ratings[spell]
				ratings[rating][spell] = true
			end

			self[mode].pools.ratings = ratings
		end

		self.built_rating_pools = true
	end
end

function Doolittle:OnDisable()
	AceGUI:Release(self.slider)
end

function Doolittle:OnEnable()
	self.slider = AceGUI:Create("Slider")
	self.slider:SetSliderValues(0,5,1)
	self.slider.frame:SetParent(CompanionModelFrame)
	self.slider:SetPoint("TOPRIGHT")
	self.slider:SetCallback("OnValueChanged", function(info) self:SetRating(info.value, GetSelectedCompanion()) end)

	Doolittle:RegisterEvent("COMPANION_LEARNED", "OnCompanionUpdate")
	Doolittle:RegisterEvent("COMPANION_UPDATE", "OnCompanionUpdate")

	-- there's no real need for this to be a secure hook, but it has no side effects
	Doolittle:SecureHook("PetPaperDollFrame_UpdateCompanionPreview", "OnPreviewUpdate")

	self:OnCompanionUpdate()
end

function Doolittle:OnInitialize()
	self:BuildOptionsAndDefaults() -- sets defaults; MUST be before AceDB call

	self.db = LibStub("AceDB-3.0"):New("DoolittleDB", defaults)
	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	options.args.profile.dialogHidden = true

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Doolittle", options, {"doolittle"})
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Doolittle", options)
	self.opt_main = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Doolittle", "Doolittle")

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DoolittleProfile", options.args.profile)
	self.opt_profile = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DoolittleProfile", "Profile", "Doolittle")

	self.built_rating_pools = false
end

function Doolittle:OnPreviewUpdate()
	self.slider:SetValue(self:GetRating(GetSelectedCompanion()))
end

function Doolittle:ScanCompanions(mode)
	local count = GetNumCompanions(mode)
	local known = Pool{}
	local pools = self[mode:lower() .. "s"].pools

	if count then
		local name, spell, icon

		for id = 1, count do
			name, spell, icon = select(2, GetCompanionInfo(mode, id))

			known[spell] = {id, name, icon}
		end
	end

	pools.known = known

	if mode == "MOUNT" then
		local fastest

		for terrain, speeds in pairs(self.mounts.speeds) do
			pools[terrain].fastest = -1

			for speed in pairs(speeds) do
				fastest = known * pools[terrain][speed]

				if fastest:size() > 0 and speed > pools[terrain].fastest then
					pools[terrain].fastest = speed
				end
			end
		end
	end
end

function Doolittle:SetRating(value, mode, spell)
	local ratings = self.db.profile[mode].ratings
	local pools = self[mode].pools.ratings

	pools[ratings[spell]][spell] = nil
	ratings[spell] = value
	pools[value][spell] = true
end
