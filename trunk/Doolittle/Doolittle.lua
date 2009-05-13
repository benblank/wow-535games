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

Doolittle = LibStub("AceAddon-3.0"):NewAddon("Doolittle", "AceEvent-3.0")

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
			func = "CmdMount",
		},

		options = {
			name = L["OPTIONS"],
			type = "group",
			args = {
				flying = {
					name = L["TYPE_FLYING"],
					type = "group",
					args = {
						fastest = {
							name = L["OPT_FASTEST_ONLY"],
							type = "toggle",
							order = 0,
							width = "full",
							get = function(info) return Doolittle.db.profile.flying.fastest end,
							set = function(info, value) Doolittle.db.profile.flying.fastest = value end,
						},

						speed60 = {
							name = L["OPT_INCLUDE_SPEED"](60),
							type = "toggle",
							order = 60,
							width = "full",
							disabled = function(info) return Doolittle.db.profile.flying.fastest end,
							get = function(info) return Doolittle.db.profile.flying.speed60 end,
							set = function(info, value) Doolittle.db.profile.flying.speed60 = value end,
						},

						speed280 = {
							name = L["OPT_INCLUDE_SPEED"](280),
							type = "toggle",
							order = 280,
							width = "full",
							disabled = function(info) return Doolittle.db.profile.flying.fastest end,
							get = function(info) return Doolittle.db.profile.flying.speed280 end,
							set = function(info, value) Doolittle.db.profile.flying.speed280 = value end,
						},

						speed310 = {
							name = L["OPT_INCLUDE_SPEED"](310),
							type = "toggle",
							order = 310,
							width = "full",
							disabled = function(info) return Doolittle.db.profile.flying.fastest end,
							get = function(info) return Doolittle.db.profile.flying.speed310 end,
							set = function(info, value) Doolittle.db.profile.flying.speed310 = value end,
						},
					},
				},
			},
		},
	},
}

local defaults = {
	profile = {
		flying = {
			fastest = true,
			speed60 = false,
			speed280 = true,
			speed310 = true,
		},

		ground = {
			fastest = true,
			speed0 = false,
			speed60 = true,
			speed100 = true,
		},
	},
}

function Doolittle:CmdMount()
end

function Doolittle:OnDisable()
end

function Doolittle:OnEnable()
end

function Doolittle:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("DoolittleDB", defaults)
	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Doolittle", options, {"doolittle"})
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Doolittle", options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Doolittle", "Doolittle")

	--TODO: read mount/pet data
end
