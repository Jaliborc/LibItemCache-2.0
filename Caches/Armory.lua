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

local Lib = LibStub('LibItemCache-1.0')
if not ArmoryDB or Lib:HasCache() then
  return
end

local Cache, Realm = Lib:NewCache()
local Realm = ArmoryDB[Realm]


--[[ Items ]]--

function Cache:GetBag(player, bag, slot)
  local player = Realm[player]
  local link = player['InventoryItemLink' .. slot] -- TO ASK: Armory does not save bag id or link
  local bag = player.Inventory['Container' .. bag]

  if bag and link then
    return link, bag.Info.count
  end
end

function Cache:GetItem(player, bag, slot)
  local bag = Realm[player].Inventory['Container' .. bag]
  if bag then
    local item = bag['Link' .. slot]
    if item then
      return item['1'], item.count
    end
  end
end

function Cache:GetItemCount(player, id)
  local i = 0
  for bag, contents in pairs(Realm[player].Inventory) do
    for name, data in pairs(contents) do
      if name:sub(0,4) == 'Link' and data['1']:sub(17, -1):match('^(%d+)') == id then
        i = i + 1
      end
    end
  end

  return i
end


function Cache:GetMoney(player)
  return Realm[player].Money
end


--[[ Players ]]--

function Cache:IteratePlayers()
  return pairs(Realm)
end

function Cache:DeletePlayer(player)
  Realm[player] = nil
end