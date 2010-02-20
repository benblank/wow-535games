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

StaticPopupDialogs["HITCH_TEAM_INVITE"] = {
	text = L["PROMPT_TEAM_INVITE"],
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = "igPlayerInvite",
	timeout = 60,
	whileDead = 1,
	hideOnEscape = 1,

	OnShow = function(self)
		self.inviteAccepted = nil;
	end,

	OnAccept = function(self)
		Hitch:AcceptInvite();

		self.inviteAccepted = 1;
	end,

	OnCancel = function(self)
		Hitch:DeclineInvite();
	end,

	OnHide = function(self)
		if not self.inviteAccepted then
			Hitch:DeclineInvite();
		end
	end,
};

Hitch:SetDefaultModuleLibraries("AceEvent-3.0")

Hitch:SetDefaultModulePrototype({
	Print = function(self, ...) Hitch:Print(...) end,

	Send = function(self, id, func, args)
		Hitch:Send(id, self:GetName(), func, args)
	end,

	SendName = function(self, id, func, args)
		Hitch:SendName(id, self:GetName(), func, args)
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
		team = { UnitName("player") },
	},
}

function Hitch:AcceptInvite()
	-- this will be updated by a call from the leader
	self:SetTeam(self.inviter, self.names.player)
	self.inviter = nil
	self:Send("leader", "Hitch", "OnAcceptInvite", self.names.player)
end

function Hitch:DeclineInvite()
	self:SendName(self.inviter, "Hitch", "OnDeclineInvite", self.names.player, "REASON_CANCEL")
	self.inviter = nil
end

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

function Hitch:Invite(invitee)
	if self.inviter then
		self:Print(L["REASON_INVITED"](invitee, self.inviter))
		return
	end

	if self.invitee then
		self:Print(L["REASON_INVITING"](invitee, self.invitee))
		return
	end

	if self.ids[invitee] then
		self:Print(L["REASON_TEAMMATE"](invitee))
		return
	end

	if self.names.follower4 then
		self:Print(L["REASON_FULL"](invitee))
		return
	end

	self.invitee = invitee
	self:SendName(invitee, "Hitch", "OnInvite", self.names.player)
end

function Hitch:OnAcceptInvite(invitee)
	if not self.names.follower1 then
		self:SetTeam(self.names.player, invitee)
	elseif not self.names.follower2 then
		self:SetTeam(self.names.player, self.names.follower1, invitee)
	elseif not self.names.follower3 then
		self:SetTeam(self.names.player, self.names.follower1, self.names.follower2, invitee)
	else
		self:SetTeam(self.names.player, self.names.follower1, self.names.follower2, self.names.follower3, invitee)
	end

	self.invitee = nil
	self:Send("followers", "Hitch", "SetTeam", self.names.player, self.names.follower1, self.names.follower2, self.names.follower3, self.names.follower4)
	self:Send("all", "Hitch", "OnTeamJoin", invitee)
end

function Hitch:OnCommReceived(prefix, message, channel)
	local success, targets, module_name, func_name, args = self:Deserialize(message)

	if not success then
		--TODO: error handling (deserialization failure)

		self:Print("deserialization failure: " .. targets)
		return
	end

	if channel == "PARTY" and not targets[self.names.player] then
		-- party message not targeted at this character
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

function Hitch:OnDeclineInvite(invitee, reason)
	self:Print(L[reason](invitee))
	self.invitee = nil
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
	self:SetTeam(unpack(self.db.profile.team))
end

function Hitch:OnInvite(inviter)
	if self.names.follower1 then
		-- already on a team

		self:SendName(inviter, "Hitch", "OnDeclineInvite", self.names.player, "REASON_ON_TEAM")

		return
	end

	if self.inviter then
		-- currently showing an invite

		if self.inviter ~= inviter then
			self:SendName(inviter, "Hitch", "OnDeclineInvite", self.names.player, "REASON_BUSY")
		end

		return
	end

	self.inviter = inviter
	StaticPopup_Show("HITCH_TEAM_INVITE", inviter)
end

function Hitch:OnTeamJoin(invitee)
	if invitee == self.names.player then
		self:Print(L["MSG_JOINED_INVITEE"](self.names.leader))
	elseif self.names.leader == self.names.player then
		self:Print(L["MSG_JOINED_LEADER"](invitee))
	else
		self:Print(L["MSG_JOINED_FOLLOWER"](invitee))
	end
end

function Hitch:Send(id, module, func, ...)
	local exclude_player = false

	if string.sub(id, 1, 1) == "-" then
		exclude_player = true
		id = string.sub(id, 2)
	end

	local name
	local player = self.names.player
	local nParty = 0
	local party = {}
	local targets = {}
	local whispers = {}

	if id == "all" or id == "leader" then
		name = self:GetName("leader")

		if not exclude_player or name ~= player then
			if not targets[name] then
				targets[name] = true

				if self.roster[name] then
					party[name] = true
					nParty = nParty + 1
				else
					whispers[name] = true
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

						if self.roster[name] then
							party[name] = true
							nParty = nParty + 1
						else
							whispers[name] = true
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

					if self.roster[name] then
						party[name] = true
						nParty = nParty + 1
					else
						whispers[name] = true
					end
				end
			end
		end
	end

	if id == "player" and not exclude_player then
		name = self.names.player

		if not targets[name] then
			targets[name] = true

			if not self.roster[name] then
				whispers[name] = true
			end
		end
	end

	if nParty then
		self:SendCommMessage("HitchRPC", self:Serialize(targets, module, func, {...}), "PARTY", nil, "NORMAL")
	end

	for target, _ in pairs(whispers) do
		self:SendName(target, module, func, ...)
	end
end

function Hitch:SendName(name, module, func, ...)
	local message = self:Serialize(nil, module, func, {...})

	if name == self.names.player then
		-- trigger callback directly rather than whispering oneself
		self:OnCommReceived("HitchRPC", message, "LOCAL")
	else
		self:SendCommMessage("HitchRPC", message, "WHISPER", name, "NORMAL")
	end
end

function Hitch:SetTeam(leader, ...)
	local player = UnitName("player")

	self.ids = {
		all = "all",
		leader = "leader",
		followers = "followers",
		player = "player",
	}

	self.names = {
		leader = leader,
		player = player
	}

	self.ids[leader] = "leader"
	self.ids[player] = "player"
	self.names[leader] = leader
	self.names[player] = player

	if ... then
		self.db.profile.team = { leader, ... }

		for i, follower in ipairs({ ... }) do
			if follower then
				local id = "follower" .. i

				self.ids[follower] = id
				self.ids[id]       = id
				self.names[follower] = follower
				self.names[id]       = follower
			end
		end
	else
		self.db.profile.team = { leader }
	end
end

function Hitch:UpdateRoster()
	self.roster = {}

	for i = 1, GetNumPartyMembers() do
		self.roster[UnitName("party" .. i)] = true
	end
end
