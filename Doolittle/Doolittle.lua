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

local L = LibStub("AceLocale-3.0"):GetLocale("Doolittle")
local LBZ = LibStub("LibBabble-Zone-3.0"):GetLookupTable()

local options = {
	main = {
		name = "Doolittle",
		handler = Doolittle,
		type = "group",
		args = {
			keys = {
				name = KEY_BINDINGS,
				type = "group",
				order = 0,
				inline = true,
				args = {
					options = {
						name = L["KEY_OPTIONS"],
						type = "keybinding",
						order = 10,
						get = function(info) return GetBindingKey("DOOLITTLE_OPTIONS") end,
						set = function(info, value) SetBinding(value, "DOOLITTLE_OPTIONS") SaveBindings(GetCurrentBindingSet()) end,
					},

					summon = {
						name = L["KEY_SUMMON"],
						type = "keybinding",
						order = 20,
						get = function(info) return GetBindingKey("DOOLITTLE_SUMMON") end,
						set = function(info, value) SetBinding(value, "DOOLITTLE_SUMMON") SaveBindings(GetCurrentBindingSet()) end,
					},

					mount = {
						name = L["KEY_MOUNT"],
						type = "keybinding",
						order = 30,
						get = function(info) return GetBindingKey("DOOLITTLE_MOUNT") end,
						set = function(info, value) SetBinding(value, "DOOLITTLE_MOUNT") SaveBindings(GetCurrentBindingSet()) end,
					},
				},
			},

			macro = {
				name = L["OPT_MACRO"],
				desc = L["OPT_MACRO_DESC"],
				type = "input",
				width = "full",
				get = function(info) return Doolittle.db.profile.MOUNT.macro end,
				set = function(info, value) Doolittle.db.profile.MOUNT.macro = value end,
			},

			resetmacro = {
				name = L["OPT_RESET_MACRO"],
				type = "execute",
				order = 10,
				func = "ResetMacro",
			},
		},
	},

	advanced = {
		name = L["OPT_ADVANCED"],
		handler = Doolittle,
		type = "group",
		childGroups = "tab",
		args = {
			about = {
				name = L["OPT_ABOUT"],
				type = "group",
				order = 10,
				args = {
					weights = {
						name = L["OPT_ABOUT_WEIGHTS"],
						type = "description",
						order = 0,
					},

					reset = {
						name = L["OPT_RESET_WEIGHTS"],
						type = "execute",
						order = 10,
						func = "ResetWeights",
					},
				},
			},

			CRITTER = {
				name = COMPANIONS,
				type = "group",
				order = 20,
				args = {
				},
			},

			MOUNT = {
				name = MOUNTS,
				type = "group",
				order = 30,
				args = {
				},
			},
		},
	},
}

local defaults = {
	profile = {
		CRITTER = {
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

		MOUNT = {
			random = "always",
			macro = "[mounted]dismount;[swimming]swimming;[flyable]flying;ground",

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

	return mode, spell
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
	for mode in pairs{CRITTER=1, MOUNT=1} do
		local main = options.main.args
		local advanced = options.advanced.args[mode].args
		local defaults = defaults.profile[mode]

		main["random" .. mode] = {
			name = L["OPT_RANDOM"](mode),
			desc = L["OPT_RANDOM_DESC"](mode),
			type = "select",
			order = 10,
			style = "dropdown",
			get = function(info) return self.db.profile[mode].random end,
			set = function(info, value) self.db.profile[mode].random = value end,
			values = {
				daily = L["OPT_RANDOM_DAILY"],
				session = L["OPT_RANDOM_SESSION"],
				always = L["OPT_RANDOM_ALWAYS"],
			},
		}

		advanced.weights = {
			name = L["OPT_WEIGHTS"],
			desc = L["OPT_WEIGHTS_DESC"],
			type = "group",
			inline = true,
			args = {
			},
		}

		for i = 1, 5 do
			advanced.weights.args["rating" .. i] = {
				name = L["OPT_WEIGHT_FOR"](mode, i),
				type = "range",
				width = "full",
				min = 1,
				max = 100,
				step = 1,
				get = function(info) return self.db.profile[mode].weights[i] end,
				set = function(info, value) self.db.profile[mode].weights[i] = value end,
			}
		end

		if mode == "MOUNT" then
			for terrain, speeds in pairs(self.MOUNT.speeds) do
				defaults[terrain] = {fastest = true}

				main[terrain] = {
					name = L["TERRAIN_HEADING_" .. terrain:upper()],
					type = "group",
					inline = true,
					order = 100,
					args = {
						fastest = {
							name = L["OPT_FASTEST_ONLY"],
							desc = L["OPT_FASTEST_ONLY_DESC"],
							type = "toggle",
							width = "full",
							get = function(info) return self.db.profile[mode][terrain].fastest end,
							set = function(info, value) self.db.profile[mode][terrain].fastest = value end,
						},
					},
				}

				for speed, default in pairs(speeds) do
					local sspeed = "speed" .. speed

					defaults[terrain][sspeed] = default

					main[terrain].args[sspeed] = {
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

function Doolittle:CmdMount(macro)
	local zone = GetRealZoneText()
	local subzone = GetSubZoneText()
	local profile = self.db.profile.MOUNT
	local defmacro = profile.macro
	local pools = self.MOUNT.pools
	local command = nil

	if macro ~= nil then
		macro = strtrim(macro)

		if macro ~= "" then
			command = SecureCmdOptionParse(macro)
		end
	end

	if command == nil or command == "default" then
		command = SecureCmdOptionParse(defmacro)
	end

	if command == "dismount" then
		Dismount()
		return
	-- you can't fly in Wintergrasp when the battle is active
	elseif command == "flying" and (zone == LBZ["Wintergrasp"] and GetWintergraspWaitTime() == nil) then
		command = "ground"
	-- you can't fly in Dalaran (except on Krasus' Landing)
	elseif command == "flying" and (zone == LBZ["Dalaran"] and subzone ~= LBZ["Krasus' Landing"]) then
		command = "ground"
	-- you can't fly in Northrend w/o Cold Weather Flying
	elseif command == "flying" and GetCurrentMapContinent() == 4 and not IsUsableSpell(GetSpellLink(54197):sub(27, -6)) then
		command = "ground"
	end

	if command ~= "ground" and command ~= "flying" and command ~= "swimming" then
		self:DisplayError(L["ERROR_INAVLID_MOUNT_TYPE"](command))
		return
	end

	local pool = self:GetMountPool(command)
	local summoned = GetSummonedCompanion("MOUNT")

	if summoned then
		pool = pool - summoned
	end

	if GetRealZoneText() ~= LBZ["Temple of Ahn'Qiraj"] then
		pool = pool - pools.aq40
	end

	-- ground mounts can be used anywhere if no flying/swimming mounts are available
	if not (pool:size() > 0) and command ~= "ground" then
		pool = self:GetMountPool("ground")
	end

	if not (pool:size() > 0) then
		self:DisplayError(L["ERROR_NO_MOUNTS"](summoned))
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

function Doolittle:CmdOptions(which)
	which = self.panels[strtrim(which)]

	if which then
		InterfaceOptionsFrame_OpenToCategory(which)
	else
		-- opening a sub-category first ensures the primary category is expanded
		InterfaceOptionsFrame_OpenToCategory(self.panels.profile);
		InterfaceOptionsFrame_OpenToCategory(self.panels.main);
	end
end

function Doolittle:CmdSummon()
	local profile = self.db.profile.CRITTER
	local pools = self.CRITTER.pools
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

function Doolittle:GetCurrentRating()
	return self:GetRating(GetSelectedCompanion())
end

function Doolittle:GetMountPool(terrain)
	local pool
	local pools = self.MOUNT.pools
	local tpools = pools[terrain]
	local profile = self.db.profile.MOUNT[terrain]

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

function Doolittle:OnEnable()
	Doolittle:RegisterEvent("COMPANION_LEARNED", "OnCompanionUpdate")
	Doolittle:RegisterEvent("COMPANION_UPDATE", "OnCompanionUpdate")

	-- there's no real need for this to be a secure hook, but it has no side effects
	Doolittle:SecureHook("PetPaperDollFrame_UpdateCompanionPreview", "OnPreviewUpdate")

	self:OnCompanionUpdate()
end

function Doolittle:OnInitialize()
	self:BuildOptionsAndDefaults() -- sets defaults; MUST be before AceDB call

	self.db = LibStub("AceDB-3.0"):New("DoolittleDB", defaults)
	self.db.RegisterCallback(self, "OnProfileReset", "OnPreviewUpdate")

	options.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

	self.panels = {}

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Doolittle", options.main)
	self.panels.main = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Doolittle", "Doolittle")

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DoolittleAdvanced", options.advanced)
	self.panels.advanced = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DoolittleAdvanced", options.advanced.name, "Doolittle")

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DoolittleProfile", options.profile)
	self.panels.profile = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DoolittleProfile", options.profile.name, "Doolittle")

	self.panels.about = LibStub("LibAboutPanel").new("Doolittle", "Doolittle")

	self:RegisterChatCommand("doolittle", "CmdOptions")
	self:RegisterChatCommand("companion", "CmdSummon")
	self:RegisterChatCommand("mount", "CmdMount")
end

function Doolittle:OnPreviewUpdate()
	DoolittleRatingFrameRating_OnLeave(DoolittleRatingFrameRating0)
end

function Doolittle:ResetMacro()
	self.db.profile.MOUNT.macro = nil
	self.db:RegisterDefaults(defaults) -- rebuild metatable(s)
end

function Doolittle:ResetWeights()
	self.db.profile.CRITTER.weights = nil
	self.db.profile.MOUNT.weights = nil
	self.db:RegisterDefaults(defaults) -- rebuild metatable(s)
end

function Doolittle:ScanCompanions(mode)
	local count = GetNumCompanions(mode)
	local ratings = {[0] = Pool{}, Pool{}, Pool{}, Pool{}, Pool{}, Pool{}}
	local pools = self[mode].pools
	local profile = self.db.profile[mode].ratings

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

		for terrain, speeds in pairs(self.MOUNT.speeds) do
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

function Doolittle:SetCurrentRating(newval)
	self:SetRating(newval, GetSelectedCompanion())
end

function Doolittle:SetRating(newval, mode, spell)
	local ratings = self.db.profile[mode].ratings
	local pools = self[mode].pools.ratings
	local oldval = ratings[spell]

	pools[oldval][spell] = nil
	pools[newval][spell] = pools[oldval][spell]
	ratings[spell] = newval
end
