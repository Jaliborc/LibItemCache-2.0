local Lib = LibStub('LibItemCache-1.0')
local AreEqual, IsTrue, Replace = WoWUnit.AreEqual, WoWUnit.IsTrue, WoWUnit.Replace
local Tests = WoWUnit('ItemCache', 'PLAYER_LOGIN', 'GET_ITEM_INFO_RECEIVED')

local Shadowmourne = '|cffff8000|Hitem:49623:0:0:0:0:0:0:0:%d+:0:0|h%[Shadowmourne%]|h|r'
local Hatchling = '|cff1eff00|Hbattlepet:236:1:2:157:10:10:0x0|h[Obsidian Hatchling]|h|r'


--[[ Links ]]--

function Tests:RestoreNothing()
	AreEqual(nil, Lib:RestoreLink(nil))
end

function Tests:RestoreItemLink()
	local icon, link, quality = Lib:RestoreLink('49623')

	AreEqual(icon, 'Interface\\Icons\\inv_axe_113')
	IsTrue(link:find(Shadowmourne))
	AreEqual(quality, 5)
end

function Tests:RestorePetLink()
	local results = {Lib:RestoreLink('236:1:2:157:10:10:0')}
	local expected = {
		strupper('Interface\\Icons\\Ability_Mount_Raptor.blp'),
		Hatchling,
		2
	}

	AreEqual(expected, results)
end

function Tests:GetItemQuality()
	AreEqual(5, Lib:GetItemQuality(Shadowmourne))
	AreEqual(2, Lib:GetItemQuality(Hatchling))
end