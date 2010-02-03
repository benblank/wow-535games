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
local Hitch = LibStub("AceAddon-3.0"):NewAddon("Hitch", "AceComm-3.0", "AceConsole-3.0", "AceEvent-3.0", "AceSerializer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Hitch")

_G["Hitch"] = Hitch

Hitch:SetDefaultModuleLibraries("AceEvent-3.0")

Hitch:SetDefaultModulePrototype({
	Deserialize = function(self, ...) Hitch:Deserialize(...) end,
	Print       = function(self, ...) Hitch:Print(...) end,
	Serialize   = function(self, ...) Hitch:Serialize(...) end,

	Send = function(self, id, func, args)
		Hitch:Send(id, self:GetName(), func, args)
	end,
})

local options = {
	main = {
		name = "Hitch",
		handler = Hitch,
		type = "group",
		args = {
		},
	},
}

local defaults = {
	profile = {
	},
}

local valid_ids = {"all", "leader", "followers", "follower1", "follower2", "follower3", "follower4", "player"}

Hitch.ids = {
	all = "all",
	leader = "leader",
	followers = "followers",
	follower1 = "follower1",
	follower2 = "follower2",
	follower3 = "follower3",
	follower4 = "follower4",
	player = "player",

	Palter = "leader",
	Shatterhoof = "follower1",
}

Hitch.names = {
	player = "Palter",
	leader = "Palter",
	follower1 = "Shatterhoof",
}

function Hitch:GetID(name)
	local id = self.ids[name]

	if id then
		return id
	end

	if type(name) == "string" then
		name = UnitName(name)

		if name then
			return self.ids[name]
		end
	end

	return nil
end

function Hitch:GetName(id)
	local name = self.names[id]

	if name then
		return name
	end

	if type(id) == "string" then
		name = UnitName(id)

		if name then
			return self.names[name]
		end
	end

	return nil
end

function Hitch:OnCommReceived(prefix, message, channel)
	local success, targets, module_name, func_name, args = self:Deserialize(message)

	if not targets[UnitName("player")] then
		-- message is not targeted at this character
		return
	end

	if not success then
		--TODO: error handling (deserialization failure)

		self:Print("deserialization failure")
		return
	end

	local module

	if module_name == "Hitch" then
		module = Hitch
	else
		module = self:GetModule(module_name, true)
	end

	if not module then
		--TODO: error handling (missing module)

		self:Print("missing module:", module_name)
		return
	end

	if not module:IsEnabled() then
		--TODO: error handling (disabled module)

		self:Print("disabled module:", module_name)
		return
	end

	local func = module[func_name]

	if not func or type(func) ~= "function" then
		--TODO: error handling (not a function)

		self:Print("missing function:", func_name)
		return
	end

	func(module, unpack(args))
end

function Hitch:OnEnable()
	self:RegisterComm("HitchRPC")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "UpdateRoster")
end

function Hitch:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("HitchDB", defaults)

	options.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

	self.panels = {}

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Hitch", options.main)
	self.panels.main = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Hitch", "Hitch")

	self:UpdateRoster()
end

function Hitch:Send(id, module, func, ...)
	local exclude_player = false

	if string.sub(id, 1, 1) == "-" then
		exclude_player = true
		id = string.sub(id, 2)
	end

	local name
	local player = UnitName("player")
	local targets = {}
	local whispers = {}

	if id == "all" or id == "leader" then
		name = self:GetName("leader")

		if not exclude_player or name ~= player then
			if not targets[name] then
				targets[name] = true

				if not self.roster[name] then
					table.insert(whispers, name)
				end
			end
		end
	end

	if id == "all" or id == "followers" then
		for n = 1, 4 do
			name = self:GetName("follower" .. n)

			if name then
				if not exclude_player or name ~= player then
					if not targets[name] then
						targets[name] = true

						if not self.roster[name] then
							table.insert(whispers, name)
						end
					end
				end
			end
		end
	end

	for n = 1, 4 do
		if id == "follower" .. n then
			name = self:GetName(id)

			if not name then
				--TODO: error handling (no such teammate)

				self:Print("missing teammate:", id)
				return
			end

			if not exclude_player or name ~= player then
				if not targets[name] then
					targets[name] = true

					if not self.roster[name] then
						table.insert(whispers, name)
					end
				end
			end
		end
	end

	if id == "player" and not exclude_player then
		name = UnitName("player")

		if not targets[name] then
			targets[name] = true

			if not self.roster[name] then
				table.insert(whispers, name)
			end
		end
	end

	local message = self:Serialize(targets, module, func, {...})

	self:SendCommMessage("HitchRPC", message, "PARTY", nil, "NORMAL")

	for _, target in ipairs(whispers) do
		if target == player then
			-- trigger callback directly rather than whispering oneself
			self:OnCommReceived("HitchRPC", message, "LOCAL")
		else
			self:SendCommMessage("HitchRPC", message, "WHISPER", target, "NORMAL")
		end
	end
end

function Hitch:UpdateRoster()
	self.roster = {}

	for i = 1, GetNumPartyMembers() do
		self.roster[UnitName("party" .. i)] = true
	end
end
