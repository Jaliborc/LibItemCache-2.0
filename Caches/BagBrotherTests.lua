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

local Cache = LibStub('LibItemCache-1.1').Cache
local AreEqual, Replace = WoWUnit.AreEqual, WoWUnit.Replace
local Tests = WoWUnit('ItemCache.BagBrother')


--[[ GetItem ]]--

local function MockItemRequest(item)
	Replace('BrotherBags', {
		Realm = {
			Player = {
				[1] = {
					[5] = item
				}
			}
		}
	})
	
	return {Cache:GetItem('Realm', 'Player', 1, nil, 5)}
end

function Tests:SingleItem()
	local results = MockItemRequest('3246:5:0')
	local expected = {'3246:5:0', nil}
	
	AreEqual(expected, results)
end

function Tests:ItemStack()
	local results = MockItemRequest('3246:5:0;3')
	local expected = {'3246:5:0', '3'}
	
	AreEqual(expected, results)
end

function Tests:GuildItem()
	Replace('BrotherBags', {
		Realm = {
			['Player'] = {guild = 'Guild'},
			['Guild*'] = {[3] = {'3246:5:0;3'}}
		}
	})

	local results = {Cache:GetItem('Realm', 'Player', 'guild3', 3, 1)}
	local expected = {'3246:5:0', '3'}

	AreEqual(expected, results)
end


--[[ Other Gets ]]--

function Tests:GetBag()
	Replace('BrotherBags', {
		Realm = {
			Player = {
				equip = {
					[10] = '123;20',
					[5] = '444;5'
				}
			}
		}
	})
	
	AreEqual({'123', '20'}, {Cache:GetBag('Realm', 'Player', 1, nil, 10)})
	AreEqual({'444', '5'}, {Cache:GetBag('Realm', 'Player', -1, nil, 5)})
end

function Tests:GetItemCounts()
	Replace('BrotherBags', {
		Realm = {
			Player = {
				equip = {'10;2'},
				vault = {'10;2', '10'},
				guild = 'Guild',

				[1] = {'10;4', '200', '10'},
				[-1] = {'10;5', '200', '10'},
			}
		}
	})
	
	AreEqual({1, 5, 6, 2}, {Cache:GetItemCounts('Realm', 'Player', '10')})
end

function Tests:GetPlayers()
	Replace('BrotherBags', {
		Realm = {
			['Player1'] = {},
			['Player2'] = {},
			['Guild*'] = {}
		}
	})

	AreEqual({'Player1', 'Player2'}, Cache:GetPlayers('Realm'))
end