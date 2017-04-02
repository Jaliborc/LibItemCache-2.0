--[[
Copyright 2011-2017 João Cardoso
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

if not WoWUnit then
	return
end

local Lib = LibStub('LibItemCache-1.1')
local AreEqual, IsTrue, Replace = WoWUnit.AreEqual, WoWUnit.IsTrue, WoWUnit.Replace
local Tests = WoWUnit('ItemCache', 'PLAYER_LOGIN', 'GET_ITEM_INFO_RECEIVED')

local Shadowmourne = '|cffff8000|Hitem:49623:0:0:0:0:0:0:0:%d+:%d+:0:0:0|h%[Shadowmourne%]|h|r'
local Hatchling = '|cff1eff00|Hbattlepet:236:1:2:157:10:10:0x0|h[Obsidian Hatchling]|h|r'


--[[ Partial Links ]]--

function Tests:RestoreNothing()
	AreEqual(nil, Lib:RestoreLink(nil))
end

function Tests:RestoreItemLink()
	local link, icon, quality = Lib:RestoreLink('49623')

	AreEqual(icon:upper(), strupper('Interface\\Icons\\inv_axe_113.blp'))
	IsTrue(link:find(Shadowmourne))
	AreEqual(quality, 5)
end

function Tests:RestorePetLink()
	local results = {Lib:RestoreLink('236:1:2:157:10:10:0')}
	local expected = {
		Hatchling,
		strupper('Interface\\Icons\\Ability_Mount_Raptor.blp'),
		2
	}

	results[2] = strupper(results[2])
	AreEqual(expected, results)
end

function Tests:GetItemQuality()
	AreEqual(5, Lib:GetItemQuality(Shadowmourne))
	AreEqual(2, Lib:GetItemQuality(Hatchling))
end


--[[ Bag Types ]]--

function Tests:GetBagType()
	AreEqual({false, false, false, nil}, {Lib:GetBagType(nil, 1)})
	AreEqual({true, false, false, nil}, {Lib:GetBagType('X', 1)})

	AreEqual({true, true, false, nil}, {Lib:GetBagType('X', BANK_CONTAINER)})
	AreEqual({true, true, false, nil}, {Lib:GetBagType('X', 6)})
	AreEqual({true, false, true, nil}, {Lib:GetBagType('X', 'vault')})
	AreEqual({true, nil, nil, 3}, {Lib:GetBagType(nil, 'guild3')})
end


--[[ Players ]]--

function Tests:GetPlayerInfo()
	Replace(Lib.Cache, 'GetPlayer', function(self, realm, name) return realm, name, 1 end)
	AreEqual({'Realm', 'Player', 1}, {Lib:GetPlayerInfo('Player - Realm')})
end