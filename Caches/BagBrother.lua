--[[
Copyright 2011-2013 João Cardoso
LibItemCache is distributed under the terms of the GNU General Public License.
You can redistribute it and/or modify it under the terms of the license as
published by the Free Software Foundation.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this library. If not, see <http://www.gnu.org/licenses/>.

This file is part of LibItemCache.
--]]

local Lib = LibStub('LibItemCache-1.1')
if not BagBrother or Lib:HasCache() then
	return
end

local Cache = Lib:NewCache()
local LAST_BANK_SLOT = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
local FIRST_BANK_SLOT = NUM_BAG_SLOTS + 1
local ITEM_COUNT = ';(%d+)$'
local ITEM_ID = '^(%d+)'


--[[ Items ]]--

function Cache:GetBag(realm, player, bag, tab, slot)
	if tab then
		local guild = self:GetGuildID(realm, player)
		local tab = guild and BrotherBags[realm][guild][tab]
		if tab then
			return tab.name, tab.icon, true
		end
	else
		return self:GetItem(realm, player, 'equip', nil, slot)
	end
end

function Cache:GetItem(realm, player, bag, tab, slot)
	if tab then
		player, bag = self:GetGuildID(realm, player), tab
	end

	local bag = player and BrotherBags[realm][player][bag]
	local item = bag and bag[slot]
	if item then
		return strsplit(';', item)
	end
end


--[[ Item Counts ]]--

function Cache:GetItemCounts(realm, player, id)
	local player = BrotherBags[realm][player]
	local equipment = self:GetItemCount(player.equip, id, true)
	local vault = self:GetItemCount(player.vault, id, true)
	local bank = self:GetItemCount(player[BANK_CONTAINER], id)
	local bags = 0
	
	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		bags = bags + self:GetItemCount(player[i], id)
	end
	
	for i = FIRST_BANK_SLOT, LAST_BANK_SLOT do
		bank = bank + self:GetItemCount(player[i], id)
    end
	
	return equipment, bags, bank, vault
end

function Cache:GetItemCount(bag, id, unique)
	local i = 0
	
	if bag then
		for _,item in pairs(bag) do
			if strmatch(item, ITEM_ID) == id then
				i = i + (not unique and tonumber(strmatch(item, ITEM_COUNT)) or 1)
			end
		end
	end
	
	return i
end


--[[ Others ]]--

function Cache:GetGuildID(realm, player)
	local guild = self:GetGuild(realm, player)
	return guild and (guild .. '*')
end

function Cache:GetGuild(realm, player)
	return BrotherBags[realm][player].guild
end

function Cache:GetMoney(realm, player)
	return BrotherBags[realm][player].money
end


--[[ Players ]]--

function Cache:GetPlayer(realm, player)
	player = BrotherBags[realm][player]
	if player then
		return player.class, player.race, player.sex
	end
end

function Cache:DeletePlayer(realm, player)
	local realm = BrotherBags[realm]
	local guild = realm[player].guild
	realm[player] = nil

	for _, actor in pairs(realm) do
		if actor.guild == guild then
			return
		end
	end

	realm[guild .. '*'] = nil
end

function Cache:GetPlayers(realm)
	local players = {}
	for name in pairs(BrotherBags[realm]) do
		if not name:find('*$') then
			tinsert(players, name)
		end
	end

	return players
end