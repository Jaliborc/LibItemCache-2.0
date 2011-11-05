--[[
Copyright 2011 João Cardoso
LibItemCache is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of LibItemCache.

LibItemCache is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

LibItemCache is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with LibItemCache. If not, see <http://www.gnu.org/licenses/>.
--]]

local Lib = LibStub:NewLibrary('LibItemCache-1.0', 5)
if Lib then
  if not Lib[0] then
    local frame = CreateFrame('Frame')
    setmetatable(Lib, getmetatable(frame))
    Lib[0] = frame[0] -- nice hack, turns the lib into a frame. MUHAHAHAHA! I'm evil.
  end

  Lib.__index = function() return Lib.__empty end
  Lib.__empty = function() end -- another hack, stops errors if there is no cache

  Lib.Cache = setmetatable({}, Lib)
  Lib.PLAYER = UnitName('player')
  Lib.REALM = GetRealmName()
end

local function BagType(player, bag)
  local isBank = bag > NUM_BAG_SLOTS or bag == BANK_CONTAINER
  local isVault = bag == 'vault'

  local isCached = Lib:PlayerCached(player) or isBank and not Lib.atBank or isVault and not Lib.atVault
  return isCached, isBank, isVault
end


--[[ Items ]]--

function Lib:GetItem(player, bag, slot)
  local isCached, isBank, isVault = BagType(player, bag)

  if isCached then
    local data, count = self.Cache:GetItem(player or self.PLAYER, bag, slot, isBank, isVault)

    if data then
      local _, link, quality = GetItemInfo(data)
      local icon = GetItemIcon(data)

      if isVault then
        return link, icon, nil, nil, nil, true
      else
        return icon, tonumber(count) or 1, nil, quality, nil, nil, link, true
      end
    end
  elseif isVault then
    return GetVoidItemInfo(slot)
  else
	local icon, count, locked, quality, readable, lootable, link = GetContainerItemInfo(bag, slot)
	if link and quality < 0 then -- GetContainerItemInfo does not return a quality value for all items
		quality = select(3, GetItemInfo(link)) 
	end
	
    return icon, count, locked, quality, readable, lootable, link
  end
end

function Lib:GetBag(player, bag)
  local isCached, isBank = BagType(player, bag)

  if bag ~= BACKPACK_CONTAINER and bag ~= BANK_CONTAINER then
    local slot = ContainerIDToInventoryID(bag)

    if isCached then
      local data, size = self.Cache:GetBag(player or self.PLAYER, bag, slot, isBank)

      if data and size then
        local _, link = GetItemInfo(data)
        return link, 0, GetItemIcon(data), slot, tonumber(size), true
      end
    else
      local link = GetInventoryItemLink('player', slot)
      local count = GetInventoryItemCount('player', slot)
      local icon = GetInventoryItemTexture('player', slot)

      return link, count, icon, slot, GetContainerNumSlots(bag)
    end
  end

  return nil, 0, nil, nil, GetContainerNumSlots(bag), isCached
end

function Lib:GetItemCounts(player, id)
  if self:PlayerCached(player) then
    return self.Cache:GetItemCounts(player or self.PLAYER, id)
  else
	local item, equip = tonumber(id), 0
    local total = GetItemCount(id, true)
	local bags = GetItemCount(id)

	for i = 1, INVSLOT_LAST_EQUIPPED do
      if GetInventoryItemID('player', i) == id then
		equip = equip + 1
	  end
    end

    return equip, bags - equip, total - bags
  end
end

function Lib:GetMoney(player)
  if self:PlayerCached(player) then
    return self.Cache:GetMoney(player or self.PLAYER), true
  else
    return GetMoney()
  end
end


--[[ Players ]]--

function Lib:PlayerCached(player)
  return player and player ~= self.PLAYER
end

function Lib:GetPlayer(player)
  if not self:PlayerCached(player) then
    return select(2, UnitClass('player')), select(2, UnitRace('player')), UnitSex('player')
  else
    return self.Cache:GetPlayer(player)
  end
end

function Lib:IteratePlayers()
  if not self.players then
    self.players = {}

    local list = self.Cache:GetPlayers()
    if list then
      for player in pairs(list) do
        tinsert(self.players, player)
      end

      sort(self.players)
    end
  end

  return pairs(self.players)
end

function Lib:DeletePlayer(...)
  self.Cache:DeletePlayer(...)
  self.players = nil
end


--[[ Caches ]]--

function Lib:NewCache()
  self.NewCache = nil
  return self.Cache, self.REALM
end

function Lib:HasCache()
  return not self.NewCache
end


--[[ Events ]]--

Lib:SetScript('OnEvent', function(_, event)
	if event == 'BANKFRAME_OPENED' then
		Lib.atBank = true
	elseif event == 'BANKFRAME_CLOSED' then
		Lib.atBank = nil
	elseif event == 'VOID_STORAGE_OPEN' then
		Lib.atVault = true
	else
		Lib.atVault = nil
	end
end)

Lib:RegisterEvent('BANKFRAME_OPENED')
Lib:RegisterEvent('BANKFRAME_CLOSED')

Lib:RegisterEvent('VOID_STORAGE_OPEN')
Lib:RegisterEvent('VOID_STORAGE_CLOSE')