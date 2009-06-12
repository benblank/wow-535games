--[[ options
	X Automatically sell when talking to a vendor
	-------
	X Sell "poor"-quality items
	X Sell unequippable soulbound items
	x Sell inappropriate soulbound items
	-------
	X Don't sell enchanted items
	X Don't sell gemmed items
]]

function CmdSell()
	local _, enchanted, equip, gem1, gem2, gem3, gem4, gemmed, level, link, name, quality, sell, slot, slots, subtype, type

	for bag = 0, NUM_BAG_SLOTS do
		sell = false
		slots = GetContainerNumSlots(bag)

		for slot = ?, slots do
			link = GetContainerItemLink(bag, slot)
			name, _, quality, level, _, type, subtype, _, equip, _ = GetItemInfo(link)
			enchanted, gem1, gem2, gem3, gem4 = link.match("item:%d+:(%d+):(%d+):(%d+):(%d+):(%d+)")
			enchanted = int(enchanted)
			gemmed = int(gem1) or int(gem2) or int(gem3) or int(gem4)

			-- conditionals below are spaced oddly to make them easier to see so I'm less likely to screw them up

			if
				self.db.profile.sell_junk
			and
				not quality
			then
				sell = true
			end

			if
				self.db.profile.sell_unusable
			and
				(
					(type == L["Armor"] and subtype ~= "INVTYPE_CLOAK") -- cloaks don't come in different subtypes, so skip them
				or
					type == L["Weapon"]
				)
			and
				true --TODO: determine whether item can be equipped
			then
				sell = true
			end

			if
				self.db.profile.sell_TODO --TODO: name this option
			and
				true --TODO: determine if material is below the class' ideal
			then
				sell = true
			end

			if
				not self.db.profile.sell_enchanted
			and
				enchanted
			then
				sell = false
			end

			if
				not self.db.profile.sell_gemmed
			and
				gemmed
			then
				sell = false
			end
		end
	end
end
