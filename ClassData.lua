-- $Id: Junkyard.lua 26 2009-06-14 01:50:29Z drdark $

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

local Junkyard = LibStub("AceAddon-3.0"):GetAddon("Junkyard")

Junkyard.Armor = {
	known = {
		["Cloth"] = true,
		["Idols"] = true,
		["Leather"] = true,
		["Librams"] = true,
		["Mail"] = true,
		["Miscellaneous"] = true,
		["Plate"] = true,
		["Shields"] = true,
		["Sigils"] = true,
		["Totems"] = true,
	},

	DEATHKNIGHT = {
		["Cloth"] = -1,
		["Leather"] = -1,
		["Mail"] = -1,
		["Miscellaneous"] = 1000,
		["Plate"] = 1000,
		["Sigils"] = 1000,
	},

	DRUID = {
		["Cloth"] = -1,
		["Idols"] = 1000,
		["Leather"] = 1000,
		["Miscellaneous"] = 1000,
	},

	HUNTER = {
		["Cloth"] = -1,
		["Leather"] = 50,
		["Mail"] = 1000,
		["Miscellaneous"] = 1000,
	},

	MAGE = {
		["Cloth"] = 1000,
		["Miscellaneous"] = 1000,
	},

	PALADIN = {
		["Cloth"] = -1,
		["Leather"] = -1,
		["Librams"] = 1000,
		["Mail"] = 50,
		["Miscellaneous"] = 1000,
		["Plate"] = 1000,
		["Shields"] = 1000,
	},

	PRIEST = {
		["Cloth"] = 1000,
		["Miscellaneous"] = 1000,
	},

	ROGUE = {
		["Cloth"] = -1,
		["Leather"] = 1000,
		["Miscellaneous"] = 1000,
	},

	SHAMAN = {
		["Cloth"] = -1,
		["Leather"] = 50,
		["Mail"] = 1000,
		["Miscellaneous"] = 1000,
		["Shields"] = 1000,
		["Totems"] = 1000,
	},

	WARLOCK = {
		["Cloth"] = 1000,
		["Miscellaneous"] = 1000,
	},

	WARRIOR = {
		["Cloth"] = -1,
		["Leather"] = -1,
		["Mail"] = 50,
		["Miscellaneous"] = 1000,
		["Plate"] = 1000,
		["Shields"] = 1000,
	},
}

Junkyard.Weapon = {
	known = {
		["Bows"] = true,
		["Crossbows"] = true,
		["Daggers"] = true,
		["Fishing Poles"] = true,
		["Fist Weapons"] = true,
		["Guns"] = true,
		["Miscellaneous"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Maces"] = true,
		["One-Handed Swords"] = true,
		["Polearms"] = true,
		["Staves"] = true,
		["Thrown"] = true,
		["Two-Handed Axes"] = true,
		["Two-Handed Maces"] = true,
		["Two-Handed Swords"] = true,
		["Wands"] = true,
	},

	DEATHKNIGHT = {
		["Fishing Poles"] = true,
		["Miscellaneous"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Maces"] = true,
		["One-Handed Swords"] = true,
		["Polearms"] = true,
		["Two-Handed Axes"] = true,
		["Two-Handed Maces"] = true,
		["Two-Handed Swords"] = true,
	},

	DRUID = {
		["Daggers"] = true,
		["Fishing Poles"] = true,
		["Fist Weapons"] = true,
		["Miscellaneous"] = true,
		["One-Handed Maces"] = true,
		["Polearms"] = true,
		["Staves"] = true,
		["Two-Handed Maces"] = true,
	},

	HUNTER = {
		["Bows"] = true,
		["Crossbows"] = true,
		["Daggers"] = true,
		["Fishing Poles"] = true,
		["Fist Weapons"] = true,
		["Guns"] = true,
		["Miscellaneous"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Swords"] = true,
		["Polearms"] = true,
		["Staves"] = true,
		["Thrown"] = true,
		["Two-Handed Axes"] = true,
		["Two-Handed Swords"] = true,
	},

	MAGE = {
		["Daggers"] = true,
		["Fishing Poles"] = true,
		["Miscellaneous"] = true,
		["One-Handed Swords"] = true,
		["Staves"] = true,
		["Wands"] = true,
	},

	PALADIN = {
		["Fishing Poles"] = true,
		["Miscellaneous"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Maces"] = true,
		["One-Handed Swords"] = true,
		["Polearms"] = true,
		["Two-Handed Axes"] = true,
		["Two-Handed Maces"] = true,
		["Two-Handed Swords"] = true,
	},

	PRIEST = {
		["Daggers"] = true,
		["Fishing Poles"] = true,
		["Miscellaneous"] = true,
		["One-Handed Maces"] = true,
		["Staves"] = true,
		["Wands"] = true,
	},

	ROGUE = {
		["Bows"] = true,
		["Crossbows"] = true,
		["Daggers"] = true,
		["Fishing Poles"] = true,
		["Fist Weapons"] = true,
		["Guns"] = true,
		["Miscellaneous"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Maces"] = true,
		["One-Handed Swords"] = true,
		["Thrown"] = true,
	},

	SHAMAN = {
		["Daggers"] = true,
		["Fishing Poles"] = true,
		["Fist Weapons"] = true,
		["Miscellaneous"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Maces"] = true,
		["Staves"] = true,
		["Two-Handed Axes"] = true,
		["Two-Handed Maces"] = true,
	},

	WARLOCK = {
		["Daggers"] = true,
		["Fishing Poles"] = true,
		["Miscellaneous"] = true,
		["One-Handed Swords"] = true,
		["Staves"] = true,
		["Wands"] = true,
	},

	WARRIOR = {
		["Bows"] = true,
		["Crossbows"] = true,
		["Daggers"] = true,
		["Fishing Poles"] = true,
		["Fist Weapons"] = true,
		["Guns"] = true,
		["Miscellaneous"] = true,
		["One-Handed Axes"] = true,
		["One-Handed Maces"] = true,
		["One-Handed Swords"] = true,
		["Polearms"] = true,
		["Staves"] = true,
		["Thrown"] = true,
		["Two-Handed Axes"] = true,
		["Two-Handed Maces"] = true,
		["Two-Handed Swords"] = true,
	},
}
