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
--  notice, this list of conditions and the following disclaimer.
--
-- * Redistributions in binary form must reproduce the above copyright
--  notice, this list of conditions and the following disclaimer in the
--  documentation and/or other materials provided with the distribution.
--
-- * Neither the name of 535 Design nor the names of its contributors
--  may be used to endorse or promote products derived from this
--  software without specific prior written permission.
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

Doolittle = LibStub("AceAddon-3.0"):NewAddon("Doolittle", "AceConsole-3.0", "AceEvent-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("Doolittle")

local options = {
	name = "Doolittle",
	handler = Doolittle,
	type = "group",
	args = {
		mount = {
			name = L["CMD_MOUNT"],
			desc = L["CMD_MOUNT_DESC"],
			type = "execute",
			dialogHidden = true,
			func = "CmdMount",
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
					values = { --BUG: these display sorted in GUI; NONE_KEY should appear first
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
					},
				},
			},
		},
	},
}

local defaults = {
	profile = {
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

local orders = {
	flying   = 1000,
	ground   = 2000,
	swimming = 3000,
}

function Doolittle:AddMount(id, spell, type, speed, icon, name)
	if not self.mounts[type] then
		self.mounts[type] = {}
	end

	self.mounts[type][spell] = id

	local args = options.args.mounts.args
	local ratings = self.db.profile.mounts.ratings
	local typespeed = type .. speed

	if not args[typespeed] then
		args[typespeed] = {
			name = L["TYPE_" .. type:upper()] .. " (" .. speed .. "%)",
			type = "group",
			order = orders[type] + speed,
			args = {
				zero = {
					name = L["OPT_ZERO"],
					type = "description",
					order = 0,
				},
			},
		}
	end

	args[typespeed].args["spell" .. spell] = {
		name = name,
		type = "range",
		width = "full",
		min = 0,
		max = 5,
		step = 1,
		get = function(info) return ratings[spell] end,
		set = function(info, value) ratings[spell] = value end,
	}
end

function Doolittle:BuildOptionsAndDefaults()
	local args = options.args.mounts.args
	local mounts = defaults.profile.mounts

	for type, speeds in pairs(self.mounts.speeds) do
		mounts[type] = {fastest = true}

		args[type] = {
			name = L["TYPE_" .. type:upper()],
			type = "group",
			inline = true,
			args = {
				fastest = {
					name = L["OPT_FASTEST_ONLY"],
					desc = L["OPT_FASTEST_ONLY_DESC"],
					type = "toggle",
					order = 50,
					width = "full",
					get = function(info) return self.db.profile.mounts[type].fastest end,
					set = function(info, value) self.db.profile.mounts[type].fastest = value end,
				},
			},
		}

		for speed, default in pairs(speeds) do
			local sspeed = "speed" .. speed

			mounts[type][sspeed] = default

			args[type].args[sspeed] = {
				name = L["OPT_INCLUDE_SPEED"](speed),
				type = "toggle",
				order = 1000 + speed,
				width = "full",
				disabled = function(info) return self.db.profile.mounts[type].fastest end,
				get = function(info) return self.db.profile.mounts[type][sspeed] end,
				set = function(info, value) self.db.profile.mounts[type][sspeed] = value end,
			}
		end
	end
end

function Doolittle:CmdMount()
	local zone = GetRealZoneText()
	local subzone = GetSubZoneText()
	local macro = "[mounted]dismount;[combat]error-combat;[indoors]error-indoors;[swimming]swimming;[flyable]flying;ground"
	local dismountkey = self.db.profile.mounts.dismountkey

	if dismountkey ~= "none" then
		macro = "[mounted,flying,nomodifier:" .. dismountkey .. "]error-flying;" .. macro
	end

	local command, _ = SecureCmdOptionParse(macro)

	if command == "dismount" then
		Dismount()
		return
	elseif command == "error-combat" then
		self:DisplayError(ERR_NOT_IN_COMBAT)
		return
	elseif command == "error-flying" then
		self:DisplayError(L["ERROR_FLYING"](L["KEY_" .. dismountkey:upper()]))
		return
	elseif command == "error-indoors" then
		self:DisplayError(SPELL_FAILED_NO_MOUNTS_ALLOWED)
		return
	elseif command == "flying" and (zone == L["ZONE_WINTERGRASP"] or (zone == L["ZONE_DALARAN"] and subzone ~= L["ZONE_KRASUS_LANDING"])) then
		command = "ground"
	end

	local type = self.mounts[command]

	if not type then
		--TODO: no mounts of type
		return
	end

	local mounts = self.db.profile.mounts
	local tickets = {}

	--TODO: restrict to selected speed brackets
	--TODO: randomize to rating, then randomize within rating?
	for spell, id in pairs(type) do
		for i = 1, mounts.weights[mounts.ratings[spell]] do
			table.insert(tickets, id)
		end
	end

	CallCompanion("MOUNT", tickets[math.random(#tickets) - 1])
end

function Doolittle:DisplayError(message)
	UIErrorsFrame:AddMessage(message, 1.0, 0.1, 0.1, 1.0)
end

function Doolittle:MapType(type)
	return type:lower() .. "s"
end

function Doolittle:OnCompanionUpdate(event, type)
	if type == nil then
		self:ScanCompanions("CRITTER")
		self:ScanCompanions("MOUNT")
	else
		self:ScanCompanions(type)
	end
end

function Doolittle:OnDisable()
	self:Print("Disabled")
end

function Doolittle:OnEnable()
	self:Print("Enabled")
end

function Doolittle:OnInitialize()
	self:BuildOptionsAndDefaults() -- sets defaults; MUST be before AceDB call

	self.db = LibStub("AceDB-3.0"):New("DoolittleDB", defaults)
	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Doolittle", options, {"doolittle"})
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Doolittle", options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Doolittle", "Doolittle")

	self:OnCompanionUpdate() -- COMPANION_UPDATE does not fire on UI reload
end

function Doolittle:ScanCompanions(type)
	local count = GetNumCompanions(type)
	local known = {}

	if count then
		local _, name, spell, icon, speeds

		for id = 1, count do
			_, name, spell, icon, _ = GetCompanionInfo(type, id)

			known[spell] = {id, name, icon}
		end
	end

	type = self:MapType(type)

	-- these two if blocks can be removed once critters have been added to CompanionData.php
	if not self[type] then
		self[type] = {}
	end

	if not self[type].pools then
		self[type].pools = {}
	end

	self[type].pools.known = known
end

Doolittle:RegisterEvent("COMPANION_LEARNED", "OnCompanionUpdate")
Doolittle:RegisterEvent("COMPANION_UPDATE", "OnCompanionUpdate")
