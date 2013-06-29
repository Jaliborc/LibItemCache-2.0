local Cache = LibStub('LibItemCache-1.0').Cache
local AreEqual, Replace = WoWUnit.AreEqual, WoWUnit.Replace
local Tests = WoWUnit('ItemCache.BagBrother')


--[[ GetItem ]]--

local function MockItemRequest(item)
	Replace(Cache, 'Realm', {
		['Player'] = {
			[1] = {
				[5] = item
			}
		}
	})
	
	return {Cache:GetItem('Player', 1, 5)}
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


--[[ GetBag ]]--


