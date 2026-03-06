ScootsVendor.utility = {}

ScootsVendor.utility.itemIsEquipment = function(itemId)
    local check = {
        ['INVTYPE_HEAD'] = true,
        ['INVTYPE_NECK'] = true,
        ['INVTYPE_SHOULDER'] = true,
        ['INVTYPE_BODY'] = true,
        ['INVTYPE_CHEST'] = true,
        ['INVTYPE_ROBE'] = true,
        ['INVTYPE_WAIST'] = true,
        ['INVTYPE_LEGS'] = true,
        ['INVTYPE_FEET'] = true,
        ['INVTYPE_WRIST'] = true,
        ['INVTYPE_HAND'] = true,
        ['INVTYPE_FINGER'] = true,
        ['INVTYPE_TRINKET'] = true,
        ['INVTYPE_WEAPON'] = true,
        ['INVTYPE_WEAPONOFFHAND'] = true,
        ['INVTYPE_SHIELD'] = true,
        ['INVTYPE_CLOAK'] = true,
        ['INVTYPE_2HWEAPON'] = true,
        ['INVTYPE_WEAPONMAINHAND'] = true,
        ['INVTYPE_HOLDABLE'] = true,
        ['INVTYPE_RANGED'] = true,
        ['INVTYPE_THROWN'] = true,
        ['INVTYPE_RANGEDRIGHT'] = true,
        ['INVTYPE_RELIC'] = true,
    }
    
    return check[(select(9, GetItemInfoCustom(itemId)))] or false
end

ScootsVendor.utility.itemIsBop = function(itemId)
    local _, itemTagsTwo = GetItemTagsCustom(itemId)
    return bit.band(itemTagsTwo or 0, 0x80) > 0
end

ScootsVendor.utility.getPlayerCurrencies = function()
    local playerCurrencies = {}
    local currencyListSize = GetCurrencyListSize()
    
    for currencyIndex = 1, currencyListSize, 1 do
        local _, _, _, _, _, currencyCount, _, _, currencyItemId = GetCurrencyListInfo(currencyIndex)
        
        if(currencyItemId) then
            playerCurrencies[currencyItemId] = currencyCount
        end
    end
    
    return playerCurrencies
end

ScootsVendor.utility.getBagContents = function(bagOnly)
    local bagContents = {}
    
    for bagIndex = 0, 4, 1 do
        for slotIndex = 1, GetContainerNumSlots(bagIndex), 1 do
            local _, itemCount, _, _, _, _, itemLink = GetContainerItemInfo(bagIndex, slotIndex)
            
            if(itemLink ~= nil) then
                local itemId = CustomExtractItemId(itemLink)
            
                if(bagContents[itemId] == nil) then
                    bagContents[itemId] = 0
                end
            
                bagContents[itemId] = bagContents[itemId] + itemCount
            end
        end
    end
    
    if(bagOnly ~= true) then
        for slotIndex = 1, 19, 1 do
            local itemId = GetInventoryItemID('player', slotIndex)
            
            if(itemId ~= nil) then
                if(bagContents[itemId] == nil) then
                    bagContents[itemId] = 0
                end
                
                bagContents[itemId] = bagContents[itemId] + 1
            end
        end
    end
    
    return bagContents
end

ScootsVendor.utility.getAffordableCount = function(merchantIndex)
    local _, _, copperPrice, _, _, _, extendedCost = GetMerchantItemInfo(merchantIndex)
    
    local canAfford = 999999
    
    if(copperPrice > 0) then
        canAfford = math.floor(GetMoney() / copperPrice)
        
        if(canAfford == 0) then
            return 0
        end
    end
    
    if(extendedCost == 1) then
        local playerCurrencies = ScootsVendor.utility.getPlayerCurrencies()
        
        local honourPoints, arenaPoints, otherCostCount = GetMerchantItemCostInfo(merchantIndex)
        
        if(honourPoints > 0) then
            if(playerCurrencies[43308] == nil) then
                return 0
            end
            
            canAfford = math.min(canAfford, math.floor(playerCurrencies[43308] / honourPoints))
            
            if(canAfford == 0) then
                return 0
            end
        end
        
        if(arenaPoints > 0) then
            if(playerCurrencies[43307] == nil) then
                return 0
            end
            
            canAfford = math.min(canAfford, math.floor(playerCurrencies[43307] / arenaPoints))
            
            if(canAfford == 0) then
                return 0
            end
        end
        
        if(otherCostCount > 0) then
            local bagContents = ScootsVendor.utility.getBagContents()
        
            for currencyIndex = 1, otherCostCount, 1 do
                local _, currencyCount, currencyItemLink = GetMerchantItemCostItem(merchantIndex, currencyIndex)
                
                if(currencyItemLink) then
                    local currencyId = CustomExtractItemId(currencyItemLink)
                    
                    if(playerCurrencies[currencyId] == nil and bagContents[currencyId] == nil) then
                        return 0
                    end
                    
                    if(playerCurrencies[currencyId] ~= nil) then
                        canAfford = math.min(canAfford, math.floor(playerCurrencies[currencyId] / currencyCount))
                    else
                        canAfford = math.min(canAfford, math.floor(bagContents[currencyId] / currencyCount))
                    end
            
                    if(canAfford == 0) then
                        return 0
                    end
                end
            end
        end
    end
    
    return canAfford
end

ScootsVendor.utility.ownItemAtForgeLevel = function(itemId, forgeLevel)
    for bagIndex = 0, 4, 1 do
        for slotIndex = 1, GetContainerNumSlots(bagIndex), 1 do
            local bagItemLink = select(7, GetContainerItemInfo(bagIndex, slotIndex))
            
            if(bagItemLink ~= nil) then
                local bagItemId = CustomExtractItemId(bagItemLink)
                
                if(bagItemId == itemId) then
                    if(GetItemLinkTitanforge(bagItemLink) >= forgeLevel) then
                        return true
                    end
                end
            end
        end
    end
    
    for slotIndex = 1, 19, 1 do
        local charItemId = GetInventoryItemID('player', slotIndex)
        
        if(charItemId == itemId) then
            if(GetItemLinkTitanforge(getInventoryItemLink('player', slotIndex)) >= forgeLevel) then
                return true
            end
        end
    end
    
    return false
end

ScootsVendor.utility.itemInBags = function(itemId)
    for bagIndex = 0, 4, 1 do
        for slotIndex = 1, GetContainerNumSlots(bagIndex), 1 do
            local bagItemLink = select(7, GetContainerItemInfo(bagIndex, slotIndex))
            
            if(bagItemLink ~= nil) then
                local bagItemId = CustomExtractItemId(bagItemLink)
                
                if(bagItemId == itemId) then
                    return true
                end
            end
        end
    end
    
    return false
end

ScootsVendor.utility.getFreeBagSlots = function()
    local freeSlots = 0

    for bagIndex = 0, 4 do
        local bagSlots = GetContainerNumSlots(bagIndex)
        for slotIndex = 1, bagSlots do
            local itemLink = select(7, GetContainerItemInfo(bagIndex, slotIndex))
            
            if(itemLink == nil) then
                freeSlots = freeSlots + 1
            end
        end
    end
    
    return freeSlots
end

ScootsVendor.utility.itemCanForge = function(itemId)
    if((itemId or 0) == 0) then
        return false
    end

    local itemRarity = select(3, GetItemInfoCustom(itemId))
    if(itemRarity == nil or itemRarity < 2 or itemRarity > 4) then
        return false
    end
    
    if((IsAttunableBySomeone(itemId) or 0) == 0) then
        return false
    end
    
    if(CanAttuneItemHelper(itemId) <= 0 and ScootsVendor.utility.itemIsBop(itemId)) then
        return false
    end
    
    return true
end
    
ScootsVendor.utility.applyDefaultFilters = function()
    local fieldMap = {
        ['can-afford'] = ScootsVendor.frames.canAffordFilter,
        ['show-non-equipment'] = ScootsVendor.frames.showNonEquipmentFilter,
        ['exclude-items-in-bag'] = ScootsVendor.frames.excludeItemsInBagFilter,
        ['exclude-learned'] = ScootsVendor.frames.hideLearnedFilter,
        ['attuneable'] = ScootsVendor.frames.attuneableFilter,
        ['attuned-level'] = ScootsVendor.frames.attunedAtLevelFilter,
    }
    
    local radioMap = {
        ['attuneable'] = {
            ['character'] = 1,
            ['account'] = 2,
            ['all'] = 3
        },
        ['attuned-level'] = {
            [-1] = 1,
            [0] = 2,
            [1] = 3,
            [2] = 4,
            [3] = 5,
        },
    }
    
    for key, value in pairs(ScootsVendor.filters) do
        ScootsVendor.filters[key] = value
        
        if(fieldMap[key] ~= nil) then
            if(radioMap[key] == nil) then
                fieldMap[key]:SetChecked(value)
            else
                fieldMap[key][radioMap[key][value]]:SetChecked(true)
                fieldMap[key][radioMap[key][value]]:Disable()
            end
        end
    end
end

ScootsVendor.utility.getItemLink = function(itemId)
    return (select(2, GetItemInfoCustom(itemId)))
end

ScootsVendor.utility.getGoldString = function(copper)
    local output = {}
    
    local gold = math.floor(copper / 10000)
    local silver = math.floor(copper / 100) % 100
    copper = copper % 100
    
    if(gold > 0) then
        table.insert(output, '|TInterface\\MoneyFrame\\UI-GoldIcon:14:14:2:0|t' .. tostring(gold))
    end
    
    if(silver > 0) then
        table.insert(output, '|TInterface\\MoneyFrame\\UI-SilverIcon:14:14:2:0|t' .. tostring(silver))
    end
    
    if(copper > 0) then
        table.insert(output, '|TInterface\\MoneyFrame\\UI-CopperIcon:14:14:2:0|t' .. tostring(copper))
    end
    
    return table.concat(output, ' ')
end

ScootsVendor.utility.itemIsAttuneable = function(itemId)
    return (CanAttuneItemHelper(itemId) > 0 or ((IsAttunableBySomeone(itemId) or 0) ~= 0 and not ScootsVendor.utility.itemIsBop(itemId)))
end

ScootsVendor.utility.s = function(quantity)
    if(quantity == 1) then
        return ''
    end
    
    return 's'
end

ScootsVendor.utility.getNoRefundPerkEnabled = function()
    if(PerkMgrPerks) then
        for perkId, perkData in pairs(PerkMgrPerks) do
            if(perkData.name == 'Disable Item Refund') then
                return GetPerkActive(perkId) == true
            end
        end
    end

    return false
end

ScootsVendor.utility.sellItemBelowForgeLevel = function(itemId, forgeLevel)
    local hasForgeAtLevel = false
    local countSold = 0

    for bagIndex = 0, 4, 1 do
        for slotIndex = 1, GetContainerNumSlots(bagIndex), 1 do
            local bagItemLink = select(7, GetContainerItemInfo(bagIndex, slotIndex))
            
            if(bagItemLink ~= nil) then
                local bagItemId = CustomExtractItemId(bagItemLink)
                
                if(bagItemId == itemId) then
                    if(GetItemLinkTitanforge(bagItemLink) >= forgeLevel) then
                        hasForgeAtLevel = true
                    else
                        UseContainerItem(bagIndex, slotIndex)
                        countSold = countSold + 1
                    end
                end
            end
        end
    end
    
    return countSold, hasForgeAtLevel
end