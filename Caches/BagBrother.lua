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
if not BagBrother or Lib:HasCache() then
  return
end

local Cache, Realm = Lib:NewCache()
local Realm = BrotherBags[Realm]


--[[ Items ]]--

function Cache:GetBag(player, _, slot)
  local bag = Realm[player].equip[slot]
  if bag then
    return strsplit(';', bag)
  end
end

function Cache:GetItem(player, bag, slot)
  local bag = Realm[player][bag]
  local item = bag and bag[slot]
  if item then
    local link, count = strsplit(';', item)
    return 'item:' .. link, count
  end
end

function Cache:GetItemCount(player, id)
  local i = 0
  for key, value in pairs(Realm[player]) do
    if key ~= 'money' then
      for _, item in pairs(value) do
        if item:match('^(%d+)') == id then
          i = i + 1
        end
      end
    end
  end
  return i
end

function Cache:GetMoney(player)
  return Realm[player].money
end


--[[ Players ]]--

function Cache:GetPlayer(player)
  player = Realm[player]
  return  player.class, player.race, player.sex
end

function Cache:DeletePlayer(player)
  Realm[player] = nil
end

function Cache:IteratePlayers()
  return pairs(Realm)
end