--[[

    ArmoryBagnon.lua
        A BagnonDB wrapper for the Armory addon, by Warmexx
--]]

assert(not BagnonDB, 'Unable to load Bagnon_Armory. Another BagnonDB wrapper is already loaded');
BagnonDB = {addon = 'Armory'};

--[[
    Helper functions
--]]

local function CanUseArmory()
   return Armory and Armory:HasInventory();
end

local function ArmorySelect(player)
    local currentProfile = Armory:CurrentProfile();
    local currentRealm = Armory.playerRealm;
    local profile;

    if ( type(player) == "number" ) then
        player = Armory:CharacterList(currentRealm)[player];
    end

    profile = {realm=currentRealm, character=player, current=currentProfile};

    if ( Armory:ProfileExists(profile) ) then
        Armory:SelectProfile(profile);
        return profile;
    end
end

local function ArmoryRestore(profile)
    if ( profile and profile.current ) then
        Armory:SelectProfile(profile.current);
    end
end

--[[
    BagnonDB:GetPlayers()
        returns:
            iterator of all players on this realm with data
        usage:
            for playerName, data in BagnonDB:GetPlayers()
--]]
function BagnonDB:GetPlayers()
    return pairs(self:GetPlayerList())
end

function BagnonDB:GetPlayerList()
    if ( CanUseArmory() ) then
        return Armory:CharacterList(Armory.playerRealm);
    else
        return {};
    end
end


--[[
    BagnonDB:GetMoney(player)
        args:
            player (string)
                the name of the player we're looking at.  This is specific to the current realm we're on

        returns:
            (number) How much money, in copper, the given player has
--]]
function BagnonDB:GetMoney(player)
    local profile = ArmorySelect(player);
    local money;

    if ( profile ) then
        money = Armory:GetMoney();
    end

    ArmoryRestore(profile);

    return money or 0;
end


--[[
    BagnonDB:GetNumBankSlots(player)
        args:
            player (string)
                the name of the player we're looking at.  This is specific to the current realm we're on

        returns:
            (number or nil) How many bank slots the current player has purchased
--]]
function BagnonDB:GetNumBankSlots(player)
    local profile = ArmorySelect(player);
    local numSlots;

    if ( profile ) then
        numSlots = Armory:GetNumBankSlots();
    end

    ArmoryRestore(profile);

    return numSlots;
end


--[[
    BagnonDB:GetBagData(bag, player)
        args:
            player (string)
                the name of the player we're looking at.  This is specific to the current realm we're on
            bag (number)
                the number of the bag we're looking at.

        returns:
            size (number)
                How many items the bag can hold (number)
            hyperlink (string)
                The hyperlink of the bag
            count (number)
                How many items are in the bag.  This is used by ammo and soul shard bags
            texture (string)
                The filepath of the bag's texture
--]]
function BagnonDB:GetBagData(bag, player)
    local profile = ArmorySelect(player);
    local numSlots, link, count, texture;

    if ( profile ) then
        _, numSlots = Armory:GetInventoryContainerInfo(bag);
        if ( numSlots and numSlots > 0 ) then
            if ( bag > 0 and bag <= NUM_BAG_SLOTS ) then
                link = Armory:GetInventoryItemLink("player", ContainerIDToInventoryID(bag));
            elseif ( bag > NUM_BAG_SLOTS and bag <= NUM_BAG_SLOTS + NUM_BANKBAGSLOTS ) then
                link = Armory:GetContainerItemLink(BANK_CONTAINER, NUM_BANKGENERIC_SLOTS + bag - NUM_BAG_SLOTS);
            end
            if ( link ) then
                texture = GetItemIcon(link);
            end

            count = 0;
            for i = 1, numSlots do
                if ( Armory:GetContainerItemInfo(bag, i) ) then
                    count = count + 1;
                end
            end
        end
    end

    ArmoryRestore(profile);

    return numSlots, link, count, texture;
end


--[[
    BagnonDB:GetItemData(bag, slot, player)
        args:
            player (string)
                the name of the player we're looking at.  This is specific to the current realm we're on
            bag (number)
                the number of the bag we're looking at.
            itemSlot (number)
                the specific item slot we're looking at

        returns:
            hyperLink (string)
                The hyperLink of the item
            count (number)
                How many of there are of the specific item
            texture (string)
                The filepath of the item's texture
            quality (number)
                The numeric representation of the item's quality: from 0 (poor) to 7 (artifact)

--]]
function BagnonDB:GetItemData(bag, slot, player)
    local profile = ArmorySelect(player);
    local link, count, texture, quality;

    if ( profile ) then
        local _, size = Armory:GetInventoryContainerInfo(bag);
        if ( size and size > 0 ) then
            for i = 1, size do
                local itemTexture, itemCount, _, itemQuality, _, slotId = Armory:GetContainerItemInfo(bag, i);
                if ( slotId and slotId == slot ) then
                    texture = itemTexture;
                    count = itemCount;
                    quality = itemQuality;
                    link = Armory:GetContainerItemLink(bag, i);
                    break;
                end
            end
        end
    end

    ArmoryRestore(profile);

    return link, count, texture, quality;
end