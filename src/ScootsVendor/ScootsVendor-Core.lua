ScootsVendor = {
    ['version'] = '1.0.0',
    ['title'] = 'ScootsVendor',
    ['storage'] = {},
    ['mode'] = 'purchase',
    ['frames'] = {
        ['master'] = CreateFrame('Frame', 'ScootsVendor-Master', UIParent),
        ['currency'] = {
            ['protected'] = {},
            ['free'] = {},
        },
        ['gold'] = {
            ['protected'] = {},
            ['free'] = {},
        },
    },
    ['consumedFrames'] = {
        ['currency'] = {
            ['protected'] = 0,
            ['free'] = 0,
        },
        ['gold'] = {
            ['protected'] = 0,
            ['free'] = 0,
        },
    },
    ['autoForgeBatchSize'] = 1,
    ['queueTimer'] = 0,
    ['delayedEvents'] = {},
}

ScootsVendor.preBuildChecks = function()
    return (ScootsVendor.synastriaApiLoaded == true)
end

ScootsVendor.openVendor = function()
    ScootsVendor.interface.build()
    
    if(not ScootsVendor.frames.master:IsVisible()) then
        ScootsVendor.interface.toggle()
    end
    
    ScootsVendor.mode = 'purchase'
    
	ScootsVendor.frames.title.vendorName:SetText('- ' .. UnitName('NPC'))
	SetPortraitTexture(ScootsVendor.frames.master.portrait, 'NPC')
    
    FauxScrollFrame_SetOffset(ScootsVendor.frames.itemList, 0)
    ScootsVendor.frames.itemList:SetVerticalScroll(0)
    
    ScootsVendor.refreshPurchaseItemList()
    ScootsVendor.updatePlayerCurrencies()
    ScootsVendor.updateQuickBuyback()
    ScootsVendor.forceMouseEnterEvents()
end

ScootsVendor.refreshPurchaseItemList = function()
    local itemTotals, costTotals, bagContents = ScootsVendor.getPurchaseItemList()
    
    if(itemTotals.itemsReceived == itemTotals.totalItems) then
        ScootsVendor.vendorLoadAttempts = nil
        
        ScootsVendor.updateTotal(itemTotals, costTotals, bagContents)
        ScootsVendor.renderItemList()
    else
        ScootsVendor.vendorLoadAttempts = (ScootsVendor.vendorLoadAttempts or 1) + 1
        
        ScootsVendor.frames.master.showingTotal:SetText('Loading items attempt ' .. ScootsVendor.vendorLoadAttempts)
    
        ScootsVendor.registerDelayedEvent(0.25, function()
            ScootsVendor.refreshPurchaseItemList()
        end)
    end
end

ScootsVendor.refreshBuybackItemList = function()
    local itemTotals = ScootsVendor.getBuybackItemList()
    ScootsVendor.updateTotal(itemTotals)
    ScootsVendor.renderItemList()
end

ScootsVendor.setFilter = function(key, value)
    if(ScootsVendor.interface.built == true) then
        ScootsVendor.filters[key] = value
        
        if(ScootsVendor.mode == 'purchase') then
            ScootsVendor.refreshPurchaseItemList()
        end
    end
end

ScootsVendor.getFilter = function(key)
    return ScootsVendor.filters[key]
end

ScootsVendor.getPurchaseItemList = function()
    ScootsVendor.itemList = {}
    ScootsVendor.currenciesInUse = {}
    local itemTotals = {}
    local costTotals = {}
    
    itemTotals.totalItems = GetMerchantNumItems()
    itemTotals.itemsReceived = 0
    
    local playerCurrencies = ScootsVendor.utility.getPlayerCurrencies()
    local bagContents = ScootsVendor.utility.getBagContents()
    
    for merchantItemIndex = 1, itemTotals.totalItems, 1 do
        local name, _, price, _, _, _, extendedCost = GetMerchantItemInfo(merchantItemIndex)
        local itemLink = GetMerchantItemLink(merchantItemIndex)
        
        if((name or '') == '' or (itemLink or '') == '') then
            break
        end
        
        local itemId = CustomExtractItemId(itemLink)
        local otherCosts = {}
            
        if(price > 0) then
            ScootsVendor.currenciesInUse['__GOLD'] = true
        end
        
        if(extendedCost == 1) then
            local honourPoints, arenaPoints, otherCostCount = GetMerchantItemCostInfo(merchantItemIndex)
            
            if(honourPoints > 0) then
                table.insert(otherCosts, {
                    ['count'] = honourPoints,
                    ['id'] = 43308
                })
                
                ScootsVendor.currenciesInUse[43308] = true
            end
            
            if(arenaPoints > 0) then
                table.insert(otherCosts, {
                    ['count'] = arenaPoints,
                    ['id'] = 43307
                })
                
                ScootsVendor.currenciesInUse[43307] = true
            end
            
            if(otherCostCount > 0) then
                for currencyIndex = 1, otherCostCount, 1 do
                    local _, currencyCount, currencyItemLink = GetMerchantItemCostItem(merchantItemIndex, currencyIndex)
                    
                    if(currencyItemLink ~= nil) then
                        local currencyId = CustomExtractItemId(currencyItemLink)
                    
                        table.insert(otherCosts, {
                            ['count'] = currencyCount,
                            ['id'] = currencyId
                        })
                        
                        ScootsVendor.currenciesInUse[currencyId] = true
                    end
                end
            end
        end
        
        itemTotals.itemsReceived = itemTotals.itemsReceived + 1
        
        if( ScootsVendor.filterName(name)
        and ScootsVendor.filterNonEquipment(itemId)
        and ScootsVendor.filterCanAttune(itemId)
        and ScootsVendor.filterAttunedAt(itemId)
        and ScootsVendor.filterInBag(itemId, bagContents)
        and ScootsVendor.filterCanAfford(price, otherCosts, playerCurrencies, bagContents)
        and ScootsVendor.filterLearned(itemId)
        ) then
            table.insert(ScootsVendor.itemList, {
                ['index'] = merchantItemIndex,
                ['id'] = itemId,
            })
            
            if(ScootsVendor.utility.itemIsAttuneable(itemId)) then
                if(price > 0) then
                    costTotals['__GOLD'] = costTotals['__GOLD'] or 0
                    costTotals['__GOLD'] = costTotals['__GOLD'] + price
                end
                
                for _, currency in pairs(otherCosts) do
                    costTotals[currency.id] = costTotals[currency.id] or 0
                    costTotals[currency.id] = costTotals[currency.id] + currency.count
                end
            end
        end
    end
    
    itemTotals.filteredItems = #ScootsVendor.itemList
    
    return itemTotals, costTotals, bagContents
end

ScootsVendor.getBuybackItemList = function()
    ScootsVendor.itemList = {}
    
    local numBuybackItems = GetNumBuybackItems()
    
    for buybackIndex = 1, numBuybackItems, 1 do
        local itemLink = GetBuybackItemLink(buybackIndex)
        
        if(itemLink) then
            table.insert(ScootsVendor.itemList, {
                ['index'] = buybackIndex,
                ['id'] = CustomExtractItemId(itemLink)
            })
        end
    end
    
    return {
        ['totalItems'] = #ScootsVendor.itemList,
    }
end

ScootsVendor.filterName = function(itemName)
    local check = ScootsVendor.getFilter('search')
    
    if((check or '') == '') then
        return true
    end
    
    check = string.lower(check)
    itemName = string.lower(itemName)
    
    if(itemName:find(check, 1, true)) then
        return true
    end
    
    return false
end

ScootsVendor.filterCanAfford = function(price, otherCosts, playerCurrencies, bagContents)
    local check = ScootsVendor.getFilter('can-afford')
    
    if(check == false) then
        return true
    end

    if(price > 0 and price > GetMoney()) then
        return false
    end
    
    if(#otherCosts > 0) then
        for _, cost in pairs(otherCosts) do
            if(cost.count > 0 and (playerCurrencies[cost.id] == nil or cost.count > playerCurrencies[cost.id])) then
                return false
            end
        end
    end
    
    return true
end

ScootsVendor.filterNonEquipment = function(itemId)
    local check = ScootsVendor.getFilter('show-non-equipment')
    
    if(check == true) then
        return true
    end
    
    if(itemId == 47241 and ScootsVendor.options.get('filter-bypass-emblemoftriumph')) then
        return true
    end
    
    if(itemId == 44115 and ScootsVendor.options.get('filter-bypass-wintergraspcommendation')) then
        return true
    end
    
    if(itemId == 63646 and ScootsVendor.options.get('filter-bypass-wintergraspcommendationx10')) then
        return true
    end
    
    if(itemId == 60244 and ScootsVendor.options.get('filter-bypass-commendationofvalor')) then
        return true
    end
    
    if(itemId == 63647 and ScootsVendor.options.get('filter-bypass-commendationofvalorx10')) then
        return true
    end
    
    if(itemId == 60232 and ScootsVendor.options.get('filter-bypass-mysterybox')) then
        return true
    end
    
    return ScootsVendor.utility.itemIsEquipment(itemId)
end

ScootsVendor.filterInBag = function(itemId, bagContents)
    local check = ScootsVendor.getFilter('exclude-items-in-bag')
    
    if(check == false) then
        return true
    end
    
    if(itemId == 44115 and ScootsVendor.options.get('filter-bypass-wintergraspcommendation')) then
        return true
    end
    
    if(itemId == 63646 and ScootsVendor.options.get('filter-bypass-wintergraspcommendationx10')) then
        return true
    end
    
    if(itemId == 60244 and ScootsVendor.options.get('filter-bypass-commendationofvalor')) then
        return true
    end
    
    if(itemId == 63647 and ScootsVendor.options.get('filter-bypass-commendationofvalorx10')) then
        return true
    end
    
    if(itemId == 60232 and ScootsVendor.options.get('filter-bypass-mysterybox')) then
        return true
    end
    
    return bagContents[itemId] == nil
end

ScootsVendor.filterLearned = function(itemId)
    local check = ScootsVendor.getFilter('exclude-learned')
    
    if(check == false) then
        return true
    end
    
    local _, itemLink, _, _, _, itemType, itemSubType = GetItemInfoCustom(itemId)
    
    local recipeStrings = {
        ['Recipe'] = true,
        ['Rezept'] = true,
        ['Recette'] = true,
        ['Receta'] = true,
        ['Рецепт'] = true,
        ['제조법'] = true,
        ['配方'] = true,
    }
    
    if(itemType ~= MISCELLANEOUS and recipeStrings[itemType] == nil) then
        return true
    end
    
    if(itemType == MISCELLANEOUS and itemSubType ~= PET and itemSubType ~= MOUNT) then
        return true
    end
    
    ScootsVendor.frames.tooltipParser:ClearLines()
    ScootsVendor.frames.tooltipParser:SetOwner(ScootsVendor.frames.master)
    ScootsVendor.frames.tooltipParser:SetHyperlink(itemLink)
    ScootsVendor.frames.tooltipParser:Show()
    local tooltipLines = {ScootsVendor.frames.tooltipParser:GetRegions()}
    
    for _, line in pairs(tooltipLines) do
        if(line:IsObjectType('FontString') and (line:GetText() or '') == ITEM_SPELL_KNOWN) then
            ScootsVendor.frames.tooltipParser:Hide()
            return false
        end
    end
    
    ScootsVendor.frames.tooltipParser:Hide()
    
    return true
end

ScootsVendor.filterCanAttune = function(itemId)
    local check = ScootsVendor.getFilter('attuneable')
    
    if(not ScootsVendor.utility.itemIsEquipment(itemId)) then
        return true
    end

    if(check == 'character') then
        return CanAttuneItemHelper(itemId) > 0
    elseif(check == 'account') then
        if((IsAttunableBySomeone(itemId) or 0) == 0) then
            return false
        end
        
        if(CanAttuneItemHelper(itemId) <= 0 and ScootsVendor.utility.itemIsBop(itemId)) then
            return false
        end
    end
    
    return true
end

ScootsVendor.filterAttunedAt = function(itemId)
    local check = ScootsVendor.getFilter('attuned-level')
    
    if(not ScootsVendor.utility.itemIsEquipment(itemId)) then
        return true
    end
    
    if(check == 3) then
        return true
    end
    
    return GetItemAttuneForge(itemId) <= check
end

ScootsVendor.renderItemList = function()
    FauxScrollFrame_Update(ScootsVendor.frames.itemList, #ScootsVendor.itemList, ScootsVendor.itemsVisible, ScootsVendor.itemFrameHeight, nil, nil, nil, nil, nil, nil, true)
    local offset = FauxScrollFrame_GetOffset(ScootsVendor.frames.itemList)
    ScootsVendor.consumedCurrencyFrames = 0
    local currencyFrame
    
    for _, frameGroup in pairs({
        ScootsVendor.frames.currency.free,
        ScootsVendor.frames.gold.free,
    }) do
        for _, currencyFrame in pairs(frameGroup) do
            currencyFrame:Hide()
        end
    end
    
    for itemFrameIndex = 1, ScootsVendor.itemsVisible, 1 do
        local itemIndex = itemFrameIndex + offset
        local itemFrame = ScootsVendor.frames.items[itemFrameIndex]
        
        if(ScootsVendor.itemList[itemIndex] == nil) then
            itemFrame.mouseLeaveEvent()
            itemFrame:Hide()
        else
            local item = ScootsVendor.itemList[itemIndex]
            
            local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfoCustom(item.id)
            local price, quantity, stock, isUseable, extendedCost
            
            if(ScootsVendor.mode == 'purchase') then
                _, _, price, quantity, stock, isUseable, extendedCost = GetMerchantItemInfo(item.index)
            elseif(ScootsVendor.mode == 'buyback') then
                _, _, price, quantity, stock, isUseable = GetBuybackItemInfo(item.index)
            end
            
            itemFrame.index = item.index
            itemFrame.itemId = item.id
            
            itemFrame.icon:SetTexture(itemTexture)
            itemFrame.name:SetText(itemName)
            
            if(stock > 0) then
                itemFrame.stock:Show()
                itemFrame.stock:SetText('(' .. stock .. ')')
            else
                itemFrame.stock:Hide()
            end
            
            if(quantity > 1) then
                itemFrame.quantity:Show()
                itemFrame.quantity:SetText(quantity)
            else
                itemFrame.quantity:Hide()
            end
            
            if(isUseable == nil) then
                itemFrame.icon:SetVertexColor(1, 0, 0)
            else
                itemFrame.icon:SetVertexColor(1, 1, 1)
            end
            
            local attunedAt = GetItemAttuneForge(item.id)
            if(attunedAt == -1) then
                itemFrame.name:SetTextColor(1, 1, 1)
            
                if(CanAttuneItemHelper(item.id) > 0) then
                    itemFrame.background:SetTexture(1, 1, 1)
                else
                    itemFrame.background:SetTexture(0.5, 0.5, 0.5)
                end
            elseif(attunedAt == 0) then
                itemFrame.name:SetTextColor(0.65, 1, 0.5)
                itemFrame.background:SetTexture(0.65, 1, 0.5)
            elseif(attunedAt == 1) then
                itemFrame.name:SetTextColor(0.5, 0.5, 1)
                itemFrame.background:SetTexture(0.5, 0.5, 1)
            elseif(attunedAt == 2) then
                itemFrame.name:SetTextColor(1, 0.65, 0.5)
                itemFrame.background:SetTexture(1, 0.65, 0.5)
            elseif(attunedAt == 3) then
                itemFrame.name:SetTextColor(1, 1, 0.65)
                itemFrame.background:SetTexture(1, 1, 0.65)
            end
            
            local prior, currencyFrame
            
            if(price > 0) then
                currencyFrame = ScootsVendor.interface.attachGoldFrame(itemFrame, price)
                currencyFrame:ClearAllPoints()
                currencyFrame:SetPoint('TOPLEFT', itemFrame.name, 'BOTTOMLEFT', 0, -1)
                
                prior = currencyFrame
            end
            
            if(extendedCost == 1) then
                local honourPoints, arenaPoints, otherCostCount = GetMerchantItemCostInfo(item.index)
                
                local currencyList = {}
                
                if(honourPoints > 0) then
                    table.insert(currencyList, {
                        ['count'] = honourPoints,
                        ['id'] = 43308
                    })
                end
                
                if(arenaPoints > 0) then
                    table.insert(currencyList, {
                        ['count'] = arenaPoints,
                        ['id'] = 43307
                    })
                end
                
                if(otherCostCount > 0) then
                    for currencyIndex = 1, otherCostCount, 1 do
                        local _, currencyCount, currencyItemLink = GetMerchantItemCostItem(item.index, currencyIndex)
                        
                        if(currencyItemLink ~= nil) then
                            table.insert(currencyList, {
                                ['count'] = currencyCount,
                                ['id'] = CustomExtractItemId(currencyItemLink)
                            })
                        end
                    end
                end
                
                if(#currencyList > 0) then
                    for _, currency in ipairs(currencyList) do
                        currencyFrame = ScootsVendor.interface.attachCurrencyFrame(itemFrame, currency.count, currency.id)
                        currencyFrame:ClearAllPoints()
                        
                        if(prior == nil) then
                            currencyFrame:SetPoint('TOPLEFT', itemFrame.name, 'BOTTOMLEFT', 0, -1)
                        else
                            currencyFrame:SetPoint('LEFT', prior, 'RIGHT', 2, 0)
                        end
                        
                        prior = currencyFrame
                    end
                end
            end
            
            itemFrame:Show()
        end
    end
    
    return true
end

ScootsVendor.updateTotal = function(itemTotals, costTotals, bagContents)
    if(ScootsVendor.mode == 'purchase') then
        ScootsVendor.frames.master.showingTotal:SetText(string.format('Showing %d of %d item%s', itemTotals.filteredItems, itemTotals.totalItems, ScootsVendor.utility.s(itemTotals.totalItems)))
    elseif(ScootsVendor.mode == 'buyback') then
        ScootsVendor.frames.master.showingTotal:SetText(string.format('Showing %d item%s', itemTotals.totalItems, ScootsVendor.utility.s(itemTotals.totalItems)))
    end
    
    --
    
    if(ScootsVendor.mode == 'buyback') then
        ScootsVendor.frames.totalCost:Hide()
    elseif(ScootsVendor.mode == 'purchase') then
        ScootsVendor.frames.totalCost:Show()
        costTotalsSorted = {}
        
        for key, value in pairs(costTotals) do
            if(key ~= '__GOLD') then
                table.insert(costTotalsSorted, {
                    ['key'] = key,
                    ['name'] = (select(1, GetItemInfoCustom(key))),
                    ['amount'] = value
                })
            end
        end
        
        table.sort(costTotalsSorted, function(a, b)
            return a.amount > b.amount
        end)
        
        if(costTotals['__GOLD'] ~= nil and costTotals['__GOLD']) then
            table.insert(costTotalsSorted, 1, {
                ['key'] = '__GOLD',
                ['name'] = MONEY,
                ['amount'] = ScootsVendor.utility.getGoldString(costTotals['__GOLD'])
            })
        end
        
        ScootsVendor.frames.totalCost:SetScript('OnEnter', function()
            GameTooltip:SetOwner(ScootsVendor.frames.totalCost, 'ANCHOR_TOPRIGHT')
            GameTooltip:SetText('Total cost')
            GameTooltip:AddLine('This is the total cost to buy one of every visible attuneable item.', HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
            GameTooltip:AddLine(' ')
            
            if(#costTotalsSorted == 0) then
                GameTooltip:AddLine('No visible attuneable items.', nil, nil, nil, true)
            else
                for _, currency in ipairs(costTotalsSorted) do
                    GameTooltip:AddDoubleLine(
                        currency.name,
                        currency.amount,
                        NORMAL_FONT_COLOR.r,
                        NORMAL_FONT_COLOR.g,
                        NORMAL_FONT_COLOR.b,
                        HIGHLIGHT_FONT_COLOR.r,
                        HIGHLIGHT_FONT_COLOR.g,
                        HIGHLIGHT_FONT_COLOR.b
                    )
                end
            end
            
            GameTooltip:Show()
        end)
    end
end

ScootsVendor.updatePlayerCurrencies = function()
    local playerCurrencies = ScootsVendor.utility.getPlayerCurrencies()
    local bagContents = ScootsVendor.utility.getBagContents()
    
    for _, frameGroup in pairs({
        ScootsVendor.frames.currency.protected,
        ScootsVendor.frames.gold.protected,
    }) do
        for _, currencyFrame in pairs(frameGroup) do
            currencyFrame:Hide()
        end
    end
    
    if(not ScootsVendor.currenciesInUse) then
        return nil
    end
    
    local costTotalsSorted = {}
    for currency, _ in pairs(ScootsVendor.currenciesInUse) do
        local currencyName
        if(currency == '__GOLD') then
            currencyName = '__GOLD'
        else
            currencyName = (select(1, GetItemInfoCustom(currency)))
        end
    
        table.insert(costTotalsSorted, {
            ['key'] = currency,
            ['name'] = currencyName,
        })
    end
    
    table.sort(costTotalsSorted, function(a, b)
        if(a == nil and b == nil) then
            return false
        elseif(a == nil and b ~= nil) then
            return false
        elseif(a ~= nil and b == nil) then
            return true
        elseif(playerCurrencies[a.key] ~= nil and playerCurrencies[b.key] == nil) then
            return true
        elseif(playerCurrencies[a.key] == nil and playerCurrencies[b.key] ~= nil) then
            return false
        elseif(bagContents[a.key] ~= nil and bagContents[b.key] ~= nil and bagContents[a.key] > bagContents[b.key]) then
            return true
        elseif(bagContents[a.key] ~= nil and bagContents[b.key] ~= nil and bagContents[a.key] < bagContents[b.key]) then
            return false
        elseif(bagContents[a.key] ~= nil and bagContents[b.key] == nil) then
            return true
        elseif(bagContents[a.key] == nil and bagContents[b.key] ~= nil) then
            return false
        end
        
        return a.name < b.name
    end)
    
    local prior
    local width = 0
    for _, currency in ipairs(costTotalsSorted) do
        if((width + 50) >= ScootsVendor.frames.playerCurrencies:GetWidth()) then
            break
        end
        
        local currencyFrame
        
        if(currency.key == '__GOLD') then
            currencyFrame = ScootsVendor.interface.attachGoldFrame(ScootsVendor.frames.playerCurrencies, GetMoney(), true)
        else
            if(playerCurrencies[currency.key] ~= nil) then
                currencyFrame = ScootsVendor.interface.attachCurrencyFrame(ScootsVendor.frames.playerCurrencies, playerCurrencies[currency.key], currency.key, true)
            elseif(bagContents[currency.key] ~= nil) then
                currencyFrame = ScootsVendor.interface.attachCurrencyFrame(ScootsVendor.frames.playerCurrencies, bagContents[currency.key], currency.key, true)
            else
                currencyFrame = ScootsVendor.interface.attachCurrencyFrame(ScootsVendor.frames.playerCurrencies, 0, currency.key, true)
            end
        end
        
        if(currencyFrame ~= nil) then
            if(prior == nil) then
                currencyFrame:SetPoint('LEFT', ScootsVendor.frames.playerCurrencies, 'LEFT', 0, 0)
            else
                currencyFrame:SetPoint('LEFT', prior, 'RIGHT', 2, 0)
            end
            
            prior = currencyFrame
            width = width + currencyFrame:GetWidth()
        end
    end
end

ScootsVendor.updateQuickBuyback = function()
    if(ScootsVendor.mode == 'buyback') then
        ScootsVendor.frames.quickBuyback:Hide()
        return nil
    end
    
    local numBuybackItems = GetNumBuybackItems()
    
    if((numBuybackItems or 0) < 1) then
        ScootsVendor.frames.quickBuyback:Hide()
        return nil
    end
    
    local itemLink = GetBuybackItemLink(numBuybackItems)
    
    if(not itemLink) then
        ScootsVendor.frames.quickBuyback:Hide()
        return nil
    end
    
    local itemId = CustomExtractItemId(itemLink)
    local itemName, itemTexture, _, itemQuantity = GetBuybackItemInfo(numBuybackItems)
    
    ScootsVendor.frames.quickBuyback:Show()
    ScootsVendor.frames.quickBuyback.itemId = itemId
    ScootsVendor.frames.quickBuyback.index = numBuybackItems
    
    ScootsVendor.frames.quickBuyback.icon:SetTexture(itemTexture)
    ScootsVendor.frames.quickBuyback.name:SetText(itemName)
    
    if((itemQuantity or 1) > 1) then
        ScootsVendor.frames.quickBuyback.quantity:Show()
        ScootsVendor.frames.quickBuyback.quantity:SetText(itemQuantity)
    else
        ScootsVendor.frames.quickBuyback.quantity:Hide()
    end
end

ScootsVendor.forceMouseEnterEvents = function()
    for _, itemFrame in pairs(ScootsVendor.frames.items) do
        if(itemFrame:IsMouseOver()) then
            itemFrame.mouseEnterEvent()
            break
        end
    end
end

ScootsVendor.refreshPurchaseItemList = function()
    local itemTotals, costTotals, bagContents = ScootsVendor.getPurchaseItemList()
    ScootsVendor.updateTotal(itemTotals, costTotals, bagContents)
    ScootsVendor.renderItemList()
end

ScootsVendor.registerDelayedEvent = function(delay, callback)
    table.insert(ScootsVendor.delayedEvents, {
        ['when'] = ScootsVendor.queueTimer + delay,
        ['callback'] = callback,
    })
end

ScootsVendor.handleAutoForge = function(itemId, merchantIndex)
    if(not ScootsVendor.utility.getNoRefundPerkEnabled()) then
        ScootsVendor.pushMessage('Perk "Disable Item Refund" must be enabled to auto-forge.')
        return nil
    end
    
    if(not ScootsVendor.utility.itemCanForge(itemId)) then
        ScootsVendor.pushMessage(string.format('%s cannot forge.', ScootsVendor.utility.getItemLink(itemId)))
        return nil
    end
    
    if(ScootsVendor.utility.ownItemAtForgeLevel(itemId, ScootsVendor.autoForgeLevel)) then
        ScootsVendor.pushMessage(string.format('You already have a %s at or above this forge level.', ScootsVendor.utility.getItemLink(itemId)))
        return nil
    end
    
    if(ScootsVendor.utility.getFreeBagSlots() < ScootsVendor.autoForgeBatchSize) then
        ScootsVendor.pushMessage(string.format('You have fewer than %d free bag slots.', ScootsVendor.autoForgeBatchSize))
        return nil
    end
    
    if(ScootsVendor.utility.getAffordableCount(merchantIndex) < ScootsVendor.autoForgeBatchSize) then
        ScootsVendor.pushMessage(string.format('You cannot afford %d of %s.', ScootsVendor.autoForgeBatchSize, ScootsVendor.utility.getItemLink(itemId)))
        return nil
    end
    
    ScootsVendor.utility.sellItemBelowForgeLevel(itemId, ScootsVendor.autoForgeLevel)
    
    ScootsVendor.activeAutoForge = {
        ['id'] = itemId,
        ['index'] = merchantIndex,
    }
    
    ScootsVendor.waitingForAutoForgeAttempts = ScootsVendor.autoForgeBatchSize
    ScootsVendor.autoForgeAttempts = 0
    BuyMerchantItem(merchantIndex, ScootsVendor.autoForgeBatchSize)
end

ScootsVendor.doAutoForgeLoop = function(bypassSold)
    local countSold, forgeAchieved = ScootsVendor.utility.sellItemBelowForgeLevel(ScootsVendor.activeAutoForge.id, ScootsVendor.autoForgeLevel)
    
    if(countSold == 0 and bypassSold ~= true) then
        return nil
    end
    
    ScootsVendor.autoForgeAttempts = ScootsVendor.autoForgeAttempts + countSold
    
    if(ScootsVendor.autoForgeAttempts < ScootsVendor.waitingForAutoForgeAttempts) then
        return nil
    end
    
    if(forgeAchieved) then
        local itemId = ScootsVendor.activeAutoForge.id
        ScootsVendor.activeAutoForge = nil
        ScootsVendor.autoForgeAttempts = nil
        ScootsVendor.waitingForAutoForgeAttempts = nil
        
        ScootsVendor.registerDelayedEvent(0.25, function()
            ScootsVendor.utility.sellItemBelowForgeLevel(itemId, ScootsVendor.autoForgeLevel)
        end)
        
        return nil
    end
    
    if(ScootsVendor.utility.getAffordableCount(ScootsVendor.activeAutoForge.index) < ScootsVendor.autoForgeBatchSize) then
        ScootsVendor.pushMessage(string.format('Funds depleted. You cannot afford %d of %s.', ScootsVendor.autoForgeBatchSize, ScootsVendor.utility.getItemLink(ScootsVendor.activeAutoForge.id)))
        return nil
    end
    
    if(not ScootsVendor.utility.itemInBags(ScootsVendor.activeAutoForge.id)) then
        ScootsVendor.waitingForAutoForgeAttempts = ScootsVendor.autoForgeBatchSize
        ScootsVendor.autoForgeAttempts = 0
        BuyMerchantItem(ScootsVendor.activeAutoForge.index, ScootsVendor.autoForgeBatchSize)
    else
        ScootsVendor.registerDelayedEvent(0.05, function()
            ScootsVendor.doAutoForgeLoop(true)
        end)
    end
end

ScootsVendor.pushMessage = function(message)
    print('\124cff' .. '98fb98' .. ScootsVendor.title .. ' ' .. ScootsVendor.version .. '\124r')
    print(message)
end

ScootsVendor.updateLoop = function(_, elapsed)
    ScootsVendor.queueTimer = ScootsVendor.queueTimer + elapsed
    
    if(#ScootsVendor.delayedEvents > 0) then
        for queueIndex = 1, #ScootsVendor.delayedEvents, 1 do
            if(ScootsVendor.delayedEvents[queueIndex].when <= ScootsVendor.queueTimer) then
                ScootsVendor.delayedEvents[queueIndex].callback()
                table.remove(ScootsVendor.delayedEvents, queueIndex)
                break
            end
        end
    end
    
    if(ScootsVendor.checkAutoForge == true and ScootsVendor.activeAutoForge ~= nil) then
        ScootsVendor.checkAutoForge = nil
        ScootsVendor.doAutoForgeLoop()
    end
end

ScootsVendor.eventHandler = function(self, event)
    if(event == 'MERCHANT_SHOW') then
        ScootsVendor.openVendor()
    elseif(event == 'MERCHANT_UPDATE') then
        if(ScootsVendor.mode == 'purchase') then
            ScootsVendor.refreshPurchaseItemList()
        elseif(ScootsVendor.mode == 'buyback') then
            ScootsVendor.refreshBuybackItemList()
        end
        
        ScootsVendor.updateQuickBuyback()
        ScootsVendor.forceMouseEnterEvents()
    elseif(event == 'BAG_UPDATE') then
        if(ScootsVendor.isOpen) then
            if(ScootsVendor.mode == 'purchase') then
                ScootsVendor.refreshPurchaseItemList()
            elseif(ScootsVendor.mode == 'buyback') then
                ScootsVendor.refreshBuybackItemList()
            end
            
            if(ScootsVendor.activeAutoForge ~= nil) then
                ScootsVendor.checkAutoForge = true
            end
            
            ScootsVendor.updatePlayerCurrencies()
            ScootsVendor.forceMouseEnterEvents()
        end
    elseif(event == 'PLAYER_MONEY' or event == 'CURRENCY_DISPLAY_UPDATE' or event == 'CHAT_MSG_COMBAT_HONOR_GAIN') then
        if(ScootsVendor.interface.built == true and ScootsVendor.frames.master:IsVisible()) then
            ScootsVendor.updatePlayerCurrencies()
        end
    elseif(event == 'MERCHANT_CLOSED') then
        ScootsVendor.interface.forceClosed()
    elseif(event == 'ADDON_LOADED') then
        SynastriaSafeInvoke('ScootsVendor__init')
    elseif(event == 'PLAYER_LOGOUT') then
        _G['SCOOTSVENDOR_STORAGE'] = ScootsVendor.storage
    end
end

function ScootsVendor__init()
    ScootsVendor.synastriaApiLoaded = true
    
    local storage = _G['SCOOTSVENDOR_STORAGE']
    
    if(storage ~= nil) then
        ScootsVendor.storage = storage
    end
    
    ScootsVendor.interface.build()
    ScootsVendor.options.build()
    
    if(UnitFactionGroup('player') == 'Alliance') then
        ScootsVendor.pvpIcon = 'Interface\\PVPFrame\\PVP-Currency-Alliance'
    else
        ScootsVendor.pvpIcon = 'Interface\\PVPFrame\\PVP-Currency-Horde'
    end
    
    ScootsVendor.activeChatFrame = nil
    for chatFrameIndex = 1, 10 do
        _G['ChatFrame' .. chatFrameIndex .. 'EditBox']:HookScript('OnEditFocusGained', function()
            ScootsVendor.activeChatFrame = chatFrameIndex
        end)

        _G['ChatFrame' .. chatFrameIndex .. 'EditBox']:HookScript('OnEditFocusLost', function()
            ScootsVendor.activeChatFrame = nil
        end)
    end
end

ScootsVendor.frames.master:SetScript('OnUpdate', ScootsVendor.updateLoop)
ScootsVendor.frames.master:SetScript('OnEvent', ScootsVendor.eventHandler)

ScootsVendor.frames.master:RegisterEvent('MERCHANT_SHOW')
ScootsVendor.frames.master:RegisterEvent('MERCHANT_UPDATE')
ScootsVendor.frames.master:RegisterEvent('MERCHANT_CLOSED')
ScootsVendor.frames.master:RegisterEvent('PLAYER_MONEY')
ScootsVendor.frames.master:RegisterEvent('BAG_UPDATE')
ScootsVendor.frames.master:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
ScootsVendor.frames.master:RegisterEvent('CHAT_MSG_COMBAT_HONOR_GAIN')
ScootsVendor.frames.master:RegisterEvent('ADDON_LOADED')
ScootsVendor.frames.master:RegisterEvent('PLAYER_LOGOUT')