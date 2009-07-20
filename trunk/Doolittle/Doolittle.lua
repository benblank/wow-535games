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

		summon = {
			name = SUMMON,
			desc = L["CMD_SUMMON_DESC"],
			type = "execute",
			dialogHidden = true,
			func = "CmdSummon",
		},

		options = {
			name = L["CMD_OPTIONS"],
			desc = L["CMD_OPTIONS_DESC"],
			type = "execute",
			dialogHidden = true,
			func = "CmdOptions",
		},

		critters = {
			name = COMPANIONS,
			type = "group",
			inline = true,
			args = {
			},
		},

		mounts = {
			name = MOUNTS,
			type = "group",
			inline = true,
			args = {
				dismountkey = {
					name = L["OPT_DISMOUNT"],
					desc = L["OPT_DISMOUNT_DESC"],
					type = "select",
					order = 0,
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
			},
		},
	},
}

local defaults = {
	profile = {
		critters = {
			random = "always",

			ratings = {
				["*"] = 3,
			},

			weights = {
				[1] = 10,
				[2] = 16,
				[3] = 25,
				[4] = 40,
				[5] = 63,
			},
		},

		mounts = {
			dismountkey = "shift",
			random = "always",

			ratings = {
				["*"] = 3,
			},

			weights = {
				[1] = 10,
				[2] = 16,
				[3] = 25,
				[4] = 40,
				[5] = 63,
			},
		},
	},
}

local function GetSelectedCompanion()
	local mode = PetPaperDollFrameCompanionFrame.mode
	local spell = select(3, GetCompanionInfo(mode, PetPaperDollFrame_FindCompanionIndex()))

	return mode:lower() .. "s", spell
end

local function GetSummonedCompanion(mode)
	local _, spell, summoned
	local id = nil

	for i = 1, GetNumCompanions(mode) do
		spell, _, summoned = select(3, GetCompanionInfo(mode, i))

		if summoned then
			id = spell
		end
	end

	return id
end

function Doolittle:BuildOptionsAndDefaults()
	for mode in pairs{critters=1, mounts=1} do
		local args = options.args[mode].args
		local defaults = defaults.profile[mode]

		args.weights = {
			name = L["OPT_WEIGHTS"],
			desc = L["OPT_WEIGHTS_DESC"],
			type = "group",
			order = 50,
			inline = true,
			args = {
			},
		}

		args.random = {
			name = L["OPT_RANDOM"](mode),
			desc = L["OPT_RANDOM_DESC"](mode),
			type = "select",
			order = 0,
			style = "dropdown",
			get = function(info) return self.db.profile[mode].random end,
			set = function(info, value) self.db.profile[mode].random = value end,
			values = {
				daily = L["OPT_RANDOM_DAILY"],
				session = L["OPT_RANDOM_SESSION"],
				always = L["OPT_RANDOM_ALWAYS"],
			},
		}

		for i = 1, 5 do
			args.weights.args["rating" .. i] = {
				name = L["OPT_WEIGHT_FOR"](i),
				type = "range",
				width = "full",
				min = 1,
				max = 100,
				step = 1,
				get = function(info) return self.db.profile[mode].weights[i] end,
				set = function(info, value) self.db.profile[mode].weights[i] = value end,
			}
		end

		if mode == "mounts" then
			for terrain, speeds in pairs(self.mounts.speeds) do
				defaults[terrain] = {fastest = true}

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
							get = function(info) return self.db.profile[mode][terrain].fastest end,
							set = function(info, value) self.db.profile[mode][terrain].fastest = value end,
						},
					},
				}

				for speed, default in pairs(speeds) do
					local sspeed = "speed" .. speed

					defaults[terrain][sspeed] = default

					args[terrain].args[sspeed] = {
						name = L["OPT_INCLUDE_SPEED"](speed),
						type = "toggle",
						order = 1000 + speed,
						width = "full",
						disabled = function(info) return self.db.profile[mode][terrain].fastest end,
						get = function(info) return self.db.profile[mode][terrain][sspeed] end,
						set = function(info, value) self.db.profile[mode][terrain][sspeed] = value end,
					}
				end
			end
		end
	end
end

function Doolittle:CmdMount()
	local zone = GetRealZoneText()
	local subzone = GetSubZoneText()
	local macro = "[mounted]dismount;[combat]error-combat;[indoors]error-indoors;[swimming]swimming;[flyable]flying;ground"
	local profile = self.db.profile.mounts
	local dismountkey = profile.dismountkey
	local pools = self.mounts.pools

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
	elseif GetCurrentMapContinent() == 4 and not IsUsableSpell(GetSpellLink(54197):sub(27, -6)) then
		command = "ground"
	end

	local pool = self:GetMountPool(command)

	if GetRealZoneText() ~= LBZ["Temple of Ahn'Qiraj"] then
		pool = pool - pools.aq40
	end

	-- ground mounts can be used anywhere if no flying/swimming mounts are available
	if not (pool:size() > 0) and command ~= "ground" then
		pool = self:GetMountPool("ground")
	end

	if not (pool:size() > 0) then
		self:DisplayError(L["ERROR_NO_MOUNTS"])
		return
	end

	pools = pools.ratings
	local rating
	local ratings = {}
	local tickets = {}

	for i = 1, 5 do
		rating = pools[i] * pool

		if rating:size() > 0 then
			ratings[i] = rating

			for j = 1, profile.weights[i] do
				table.insert(tickets, i)
			end
		end
	end

	rating = tickets[math.random(#tickets)]

	CallCompanion("MOUNT", ratings[rating][ratings[rating]()][1])
end

function Doolittle:CmdOptions()
	-- opening the "Profile" sub-category first ensures the primary category is expanded
	InterfaceOptionsFrame_OpenToCategory(self.opt_profile);
	InterfaceOptionsFrame_OpenToCategory(self.opt_main);
end

function Doolittle:CmdSummon()
	local profile = self.db.profile.critters
	local pools = self.critters.pools
	local pool = pools.ratings[1] + pools.ratings[2] + pools.ratings[3] + pools.ratings[4] + pools.ratings[5]
	local summoned = GetSummonedCompanion("CRITTER")

	if summoned then
		pool = pool - summoned
	end

	-- TODO: generalize this?
	-- TODO: check for reagent/option?
	pool = pool - pools.i17202

	if not (pool:size() > 0) then
		self:DisplayError(L["ERROR_NO_COMPANIONS"])
		return
	end

	pools = pools.ratings
	local rating
	local ratings = {}
	local tickets = {}

	for i = 1, 5 do
		rating = pools[i] * pool

		if rating:size() > 0 then
			ratings[i] = rating

			for j = 1, profile.weights[i] do
				table.insert(tickets, i)
			end
		end
	end

	rating = tickets[math.random(#tickets)]

	CallCompanion("CRITTER", ratings[rating][ratings[rating]()][1])
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

	return pool * (pools.ratings[1] + pools.ratings[2] + pools.ratings[3] + pools.ratings[4] + pools.ratings[5])
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
end

function Doolittle:OnPreviewUpdate()
	self.slider:SetValue(self:GetRating(GetSelectedCompanion()))
end

function Doolittle:ScanCompanions(mode)
	local count = GetNumCompanions(mode)
	local ratings = {[0] = Pool{}, Pool{}, Pool{}, Pool{}, Pool{}, Pool{}}
	local pools = self[mode:lower() .. "s"].pools
	local profile = self.db.profile[mode:lower() .. "s"].ratings

	if count then
		local name, spell, icon

		for id = 1, count do
			name, spell, icon = select(2, GetCompanionInfo(mode, id))

			ratings[profile[spell]][spell] = {id, name, icon}
		end
	end

	pools.ratings = ratings

	if mode == "MOUNT" then
		local fastest
		local known = ratings[1] + ratings[2] + ratings[3] + ratings[4] + ratings[5]

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

function Doolittle:SetRating(newval, mode, spell)
	local ratings = self.db.profile[mode].ratings
	local pools = self[mode].pools.ratings
	local oldval = ratings[spell]

	pools[oldval][spell] = nil
	pools[newval][spell] = pools[oldval][spell]
	ratings[spell] = newval
end
