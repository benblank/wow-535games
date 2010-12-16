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
local SpellBookCompanionsFrame = SpellBookCompanionsFrame

Doolittle = LibStub("AceAddon-3.0"):NewAddon("Doolittle", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("Doolittle")
local LBZ = LibStub("LibBabble-Zone-3.0"):GetLookupTable()
local LM = LibStub("LibMounts-1.0")

local options = {
	main = {
		name = "Doolittle",
		handler = Doolittle,
		type = "group",
		args = {
			keys = {
				name = KEY_BINDINGS,
				type = "group",
				order = 10,
				inline = true,
				args = {
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
				order = 30,
				width = "full",
				get = function(info) return Doolittle.db.profile.MOUNT.macro end,
				set = function(info, value) Doolittle.db.profile.MOUNT.macro = value end,
			},

			resetmacro = {
				name = L["OPT_MACRO_RESET"],
				desc = L["OPT_MACRO_RESET_DESC"],
				type = "execute",
				order = 40,
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
				name = L["OPT_ADVANCED_ABOUT"],
				type = "description",
				order = 10,
			},

			weight_size = {
				name = L["OPT_ADVANCED_SIZE"],
				desc = L["OPT_ADVANCED_SIZE_DESC"],
				type = "input",
				order = 20,
				get = function(info) return tostring(Doolittle.db.profile.weight_size) end,
				set = function(info, value) Doolittle.db.profile.weight_size = tonumber(value) end,
				validate = function(info, value) if tonumber(value) < 1 then return L["ERROR_LOW_WEIGHT"] end end,
			},

			weight_stars = {
				name = L["OPT_ADVANCED_STARS"],
				desc = L["OPT_ADVANCED_STARS_DESC"],
				type = "input",
				order = 30,
				get = function(info) return tostring(Doolittle.db.profile.weight_stars) end,
				set = function(info, value) Doolittle.db.profile.weight_stars = tonumber(value) end,
				validate = function(info, value) if tonumber(value) < 1 then return L["ERROR_LOW_WEIGHT"] end end,
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
		},

		MOUNT = {
			random = "always",
			macro = "[mounted]dismount;[swimming]swimming;[flyable]flying;ground",

			ratings = {
				["*"] = 3,
			},
		},

		weight_size = 2,
		weight_stars = 10,
	},
}

local function GetWeight(s, c, x, y)
	-- apologies for the short variable names, but these are taken
	-- directly from the formula this function is patterned after

	local function f(n)
		local retval = (y ^ ((n - 1) / 5)) / ((c[n] / (c[1] + c[2] + c[3] + c[4] + c[5])) ^ (1 / x))

		return math.abs(retval) == 1/0 and 0 or retval
	end

	return c[s] == 0 and 0 or f(s) / (f(1) * c[1] + f(2) * c[2] + f(3) * c[3] + f(4) * c[4] + f(5) * c[5])
end

local function GetWeightedRandom(pool, ratings)
	-- apologies for the short variable names, but these are taken
	-- directly from the formula this function is patterned after

	local c = {} -- count
	local p = {[0] = 0, nil, nil, nil, nil, 1} -- probability
	local x = Doolittle.db.profile.weight_size
	local y = Doolittle.db.profile.weight_stars

	for i = 1, 5 do
		ratings[i] = ratings[i] * pool
		c[i] = ratings[i]:size()
	end

	for s = 1, 4 do -- p[5] will always be 1 (delta precision), so don't bother calculating
		p[s] = p[s - 1] + GetWeight(s, c, x, y) * c[s]
	end

	local rand = math.random()

	for i = 1, 5 do
		if rand < p[i] then
			return ratings[i][ratings[i]()]
		end
	end
end

local function GetSelectedCompanion()
	local mode = SpellBookCompanionsFrame.mode
	local spell = select(3, GetCompanionInfo(mode, SpellBookCompanionsFrame_FindCompanionIndex()))

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
		local defaults = defaults.profile[mode]

		main["random" .. mode] = {
			name = L["OPT_RANDOM"](mode),
			desc = L["OPT_RANDOM_DESC"](mode),
			type = "select",
			order = 20,
			style = "dropdown",
			get = function(info) return self.db.profile[mode].random end,
			set = function(info, value) self.db.profile[mode].random = value end,
			values = {
				daily = L["OPT_RANDOM_DAILY"],
				session = L["OPT_RANDOM_SESSION"],
				always = L["OPT_RANDOM_ALWAYS"],
			},
		}
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

	local continent = GetCurrentMapContinent()

	if command == "dismount" then
		Dismount()
		return
	-- you can't fly in Wintergrasp when the battle is active
	elseif command == "flying" and (zone == LBZ["Wintergrasp"] and GetWintergraspWaitTime() == nil) then
		command = "ground"
	-- you can't fly in Azeroth w/o Flight Master's License
	elseif command == "flying" and (continent == 1 or continent == 2) and not IsUsableSpell(GetSpellLink(90269):sub(27, -6)) then
		command = "ground"
	-- you can't fly in Northrend w/o Cold Weather Flying
	elseif command == "flying" and continent == 4 and not IsUsableSpell(GetSpellLink(54197):sub(27, -6)) then
		command = "ground"
	end

	if command ~= "ground" and command ~= "flying" and command ~= "swimming" then
		self:DisplayError(L["ERROR_INAVLID_MOUNT_TYPE"](command))
		return
	end

	local pool = self:GetMountPool(command)

	if command == "swimming" then
		if zone == LBZ["Vashj'ir"] or zone == LBZ["Shimmering Expanse"] or zone == LBZ["Kelp'thar Forest"] or zone == LBZ["Abyssal Depths"] then
			local ratings = pools.ratings

			-- Abyssal Seahorse
			pool = Pool{ 75207 } * (ratings[1] + ratings[2] + ratings[3] + ratings[4] + ratings[5])
		else
			pool = pool - 75207
		end
	end

	-- ground mounts can be used anywhere if no flying/swimming mounts are available
	if not (pool:size() > 0) and command ~= "ground" then
		pool = self:GetMountPool("ground")
	end

	local summoned = GetSummonedCompanion("MOUNT")

	if summoned then
		pool = pool - summoned
	end

	if command == "ground" and zone ~= LBZ["Temple of Ahn'Qiraj"] then
		pool = pool - pools.aq40
	end

	if not (pool:size() > 0) then
		self:DisplayError(L["ERROR_NO_MOUNTS"](summoned))
		return
	end

	CallCompanion("MOUNT", GetWeightedRandom(pool, pools.ratings)[1])
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
	--pool = pool - pools.i17202

	if not (pool:size() > 0) then
		self:DisplayError(L["ERROR_NO_COMPANIONS"])
		return
	end

	CallCompanion("CRITTER", GetWeightedRandom(pool, pools.ratings)[1])
end

function Doolittle:DisplayError(message)
	UIErrorsFrame:AddMessage(message, 1.0, 0.1, 0.1, 1.0)
end

function Doolittle:GetCurrentRating()
	return self:GetRating(GetSelectedCompanion())
end

function Doolittle:GetMountPool(terrain)
	local pools = self.MOUNT.pools
	local tpools = pools[terrain]

	return tpools * (pools.ratings[1] + pools.ratings[2] + pools.ratings[3] + pools.ratings[4] + pools.ratings[5])
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
	self:RegisterEvent("COMPANION_LEARNED", "OnCompanionUpdate")
	self:RegisterEvent("COMPANION_UPDATE", "OnCompanionUpdate")

	-- there's no real need for this to be a secure hook, but it has no side effects
	self:SecureHook("SpellBookCompanionsFrame_UpdateCompanionPreview", "OnPreviewUpdate")

	self:OnCompanionUpdate()
end

function Doolittle:OnInitialize()
	self.CRITTER = { pools = { } }

	self.MOUNT = { pools = {
		aq40     = LM:GetMountList("Temple of Ahn'Qiraj", Pool{}),
		flying   = LM:GetMountList("air", Pool{}),
		ground   = LM:GetMountList("ground", Pool{}),
		swimming = LM:GetMountList("water", Pool{}),
	} }

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
