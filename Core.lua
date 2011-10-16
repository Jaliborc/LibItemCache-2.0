--[[
Copyright 2011 João Cardoso
LibItemCache-1.0 is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of LibItemSearch.

LibItemCache-1.0 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

LibItemCache-1.0 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with LibItemSearch. If not, see <http://www.gnu.org/licenses/>.
--]]

local Lib = LibStub:NewLibrary('LibItemCache-1.0', 1)
if Lib then
  Lib.PLAYER = UnitName('player')
  Lib.REALM = GetRealmName()
else
	return
end

local function CachedPlayer(player)
  return player and player ~= Lib.PLAYER
end

local function BagType(player, bag)
  local isBank = bag > NUM_BAG_SLOTS or bag == BANK_CONTAINER
  local isCached = CachedPlayer(player) or isBank and not Lib.atBank
  return isCached, isBank
end


--[[ Items ]]--

-- GetItemCount(player, item)       TESTAR
-- GetMoney(player)                 TESTAR

function Lib:GetItem(player, bag, slot)
  local isCached, isBank = BagType(player, bag)
  local isVault = bag == 'vault'

  if isCached then
    local data, count = self.Cache:GetItem(player or self.PLAYER, bag, slot, isBank, isVault)

    if data then
      local _, link, quality, _,_,_,_,_,_, icon = GetItemInfo(data)

      if isVault then
        return link, icon, nil, nil, nil, true
      else
        return icon, count or 1, nil, quality, nil, nil, link, true
      end
    end
  elseif isVault then
    return GetVoidItemInfo(slot)
  else
    return GetContainerItemInfo(bag, slot)
  end
end

function Lib:GetBag(player, bag)
  local isCached, isBank = BagType(player, bag)
  local slot = ContainerIDToInventoryID(bag)

  if isCached then
    local data, size = self.Cache:GetBag(player or self.PLAYER, bag, slot, isBank)

    if data and size then
      local _, link, _, _,_,_,_,_,_, icon = GetItemInfo(data)
      return link, 0, icon, size, true
    end
  else
    local link = GetInventoryItemLink('player', slot)
    local count = GetInventoryItemCount('player', slot)
    local icon = GetInventoryItemTexture('player', slot)

    return link, count, icon, GetContainerNumSlots(bag)
  end
end

-- or GetItemIcon(link)?

function Lib:GetItemCount(player, item)
  if CachedPlayer(player) then
    return self.Cache:GetItemCount(player or self.PLAYER, item)
  else
    return GetItemCount(item, true)
  end
end

function Lib:GetMoney(player)
  if CachedPlayer(player) then
    return self.Cache:GetMoney(player or self.PLAYER), true
  else
    return GetMoney()
  end
end


--[[ Players ]]--

function Lib:IteratePlayers()
  return self.Cache:IteratePlayers()
end

function Lib:DeletePlayer(...)
  self.Cache:DeletePlayer(...)
end


--[[ Caches ]]--

function Lib:NewCache()
  self.Cache = {}
  self.NewCache = nil
  return self.Cache, self.REALM
end