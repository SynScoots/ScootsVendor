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
    
    if(forgeLevel == nil) then
        forgeLevel = ScootsVendor.autoForgeLevel
        
        if(forgeLevel == nil) then
            forgeLevel = 0
        end
    end

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

ScootsVendor.utility.itemCanUpgradeToAttuneable = function(itemId)
    local map = {
        [2944] = {2943},
        [4243] = {4244},
        [4246] = {4249},
        [4255] = {3844},
        [4368] = {4385},
        [4385] = {10500},
        [5966] = {7938},
        [7387] = {10721},
        [9149] = {13503},
        [9362] = {9538, 9588},
        [10026] = {7189, 10724},
        [10500] = {10545, 16008},
        [10502] = {15999},
        [10543] = {10588},
        [13503] = {35748, 35749, 35750, 35751},
        [14044] = {15138},
        [16666] = {22102},
        [16667] = {22097},
        [16668] = {22100},
        [16669] = {22101},
        [16670] = {22096},
        [16671] = {22095},
        [16672] = {22099},
        [16673] = {22098},
        [16674] = {22060},
        [16675] = {22061},
        [16676] = {22015},
        [16677] = {22013},
        [16678] = {22017},
        [16679] = {22016},
        [16680] = {22010},
        [16681] = {22011},
        [16682] = {22064},
        [16683] = {22063},
        [16684] = {22066},
        [16685] = {22062},
        [16686] = {22065},
        [16687] = {22067},
        [16688] = {22069},
        [16689] = {22068},
        [16690] = {22083},
        [16691] = {22084},
        [16692] = {22081},
        [16693] = {22080},
        [16694] = {22085},
        [16695] = {22082},
        [16696] = {22078},
        [16697] = {22079},
        [16698] = {22074},
        [16699] = {22072},
        [16700] = {22075},
        [16701] = {22073},
        [16702] = {22070},
        [16703] = {22071},
        [16704] = {22076},
        [16705] = {22077},
        [16706] = {22113},
        [16707] = {22005},
        [16708] = {22008},
        [16709] = {22007},
        [16710] = {22004},
        [16711] = {22003},
        [16712] = {22006},
        [16713] = {22002},
        [16714] = {22108},
        [16715] = {22107},
        [16716] = {22106},
        [16717] = {22110},
        [16718] = {22112},
        [16719] = {22111},
        [16720] = {22109},
        [16721] = {22009},
        [16722] = {22088},
        [16723] = {22086},
        [16724] = {22090},
        [16725] = {22087},
        [16726] = {22089},
        [16727] = {22091},
        [16728] = {22092},
        [16729] = {22093},
        [16730] = {21997},
        [16731] = {21999},
        [16732] = {22000},
        [16733] = {22001},
        [16734] = {21995},
        [16735] = {21996},
        [16736] = {21994},
        [16737] = {21998},
        [17193] = {17182},
        [17204] = {17182},
        [18608] = {18609},
        [18706] = {19024},
        [21196] = {21197},
        [21197] = {21198},
        [21198] = {21199},
        [21199] = {21200},
        [21201] = {21202},
        [21202] = {21203},
        [21203] = {21204},
        [21204] = {21205},
        [21206] = {21207},
        [21207] = {21208},
        [21208] = {21209},
        [21209] = {21210},
        [23563] = {23564},
        [23564] = {23565},
        [28425] = {28426},
        [28426] = {28427},
        [28428] = {28429},
        [28429] = {28430},
        [28431] = {28432},
        [28432] = {28433},
        [28434] = {28435},
        [28435] = {28436},
        [28437] = {28438},
        [28438] = {28439},
        [28440] = {28441},
        [28441] = {28442},
        [28483] = {28484},
        [28484] = {28485},
        [29276] = {29277},
        [29277] = {29278},
        [29278] = {29279},
        [29280] = {29281},
        [29281] = {29282},
        [29282] = {29283},
        [29284] = {29285},
        [29285] = {29286},
        [29286] = {29287},
        [29288] = {29289},
        [29289] = {29291},
        [29291] = {29290},
        [29294] = {29295},
        [29295] = {29296},
        [29296] = {29297},
        [29298] = {29299},
        [29299] = {29300},
        [29300] = {29301},
        [29302] = {29303},
        [29303] = {29304},
        [29304] = {29305},
        [29306] = {29308},
        [29307] = {29306},
        [29308] = {29309},
        [32461] = {34354},
        [32472] = {35185},
        [32473] = {34357},
        [32474] = {34356},
        [32475] = {35184},
        [32476] = {34355},
        [32478] = {34353},
        [32479] = {35183},
        [32480] = {35182},
        [32494] = {34847},
        [32495] = {35181},
        [32649] = {32757},
        [34167] = {34382},
        [34169] = {34384},
        [34170] = {34386},
        [34180] = {34381},
        [34186] = {34383},
        [34188] = {34385},
        [34192] = {34388},
        [34193] = {34389},
        [34195] = {34392},
        [34202] = {34393},
        [34208] = {34390},
        [34209] = {34391},
        [34211] = {34397},
        [34212] = {34398},
        [34215] = {34394},
        [34216] = {34395},
        [34229] = {34396},
        [34233] = {34399},
        [34234] = {34408},
        [34243] = {34401},
        [34244] = {34404},
        [34245] = {34403},
        [34332] = {34402},
        [34339] = {34405},
        [34342] = {34406},
        [34345] = {34400},
        [34350] = {34409},
        [34351] = {34407},
        [40585] = {45691},
        [40586] = {45688},
        [41245] = {47589, 47590},
        [41355] = {47572, 47573},
        [41520] = {41544},
        [44934] = {45689},
        [44935] = {45690},
        [45688] = {48954},
        [45689] = {48955},
        [45690] = {48956},
        [45691] = {48957},
        [48954] = {51560},
        [48955] = {51558},
        [48956] = {51559},
        [48957] = {51557},
        [49302] = {49301},
        [49496] = {49497},
        [49888] = {49623},
        [50078] = {51214},
        [50079] = {51213},
        [50080] = {51212},
        [50081] = {51211},
        [50082] = {51210},
        [50087] = {51189},
        [50088] = {51188},
        [50089] = {51187},
        [50090] = {51186},
        [50094] = {51129},
        [50095] = {51128},
        [50096] = {51127},
        [50097] = {51126},
        [50098] = {51125},
        [50105] = {51185},
        [50106] = {51139},
        [50107] = {51138},
        [50108] = {51137},
        [50109] = {51136},
        [50113] = {51135},
        [50114] = {51154},
        [50115] = {51153},
        [50116] = {51152},
        [50117] = {51151},
        [50118] = {51150},
        [50240] = {51209},
        [50241] = {51208},
        [50242] = {51207},
        [50243] = {51206},
        [50244] = {51205},
        [50275] = {51159},
        [50276] = {51158},
        [50277] = {51157},
        [50278] = {51156},
        [50279] = {51155},
        [50324] = {51160},
        [50325] = {51161},
        [50326] = {51162},
        [50327] = {51163},
        [50328] = {51164},
        [50375] = {50388},
        [50376] = {50387},
        [50377] = {50384},
        [50378] = {50386},
        [50384] = {50397},
        [50386] = {50399},
        [50387] = {50401},
        [50388] = {50403},
        [50391] = {51183},
        [50392] = {51184},
        [50393] = {51181},
        [50394] = {51180},
        [50396] = {51182},
        [50397] = {50398},
        [50399] = {50400},
        [50401] = {50402},
        [50403] = {50404},
        [50765] = {51178},
        [50766] = {51179},
        [50767] = {51175},
        [50768] = {51176},
        [50769] = {51177},
        [50819] = {51147},
        [50820] = {51146},
        [50821] = {51149},
        [50822] = {51148},
        [50823] = {51145},
        [50824] = {51140},
        [50825] = {51142},
        [50826] = {51143},
        [50827] = {51144},
        [50828] = {51141},
        [50830] = {51195},
        [50831] = {51196},
        [50832] = {51197},
        [50833] = {51198},
        [50834] = {51199},
        [50835] = {51190},
        [50836] = {51191},
        [50837] = {51192},
        [50838] = {51193},
        [50839] = {51194},
        [50841] = {51200},
        [50842] = {51201},
        [50843] = {51202},
        [50844] = {51203},
        [50845] = {51204},
        [50846] = {51215},
        [50847] = {51216},
        [50848] = {51218},
        [50849] = {51217},
        [50850] = {51219},
        [50853] = {51130},
        [50854] = {51131},
        [50855] = {51133},
        [50856] = {51132},
        [50857] = {51134},
        [50860] = {51170},
        [50861] = {51171},
        [50862] = {51173},
        [50863] = {51172},
        [50864] = {51174},
        [50865] = {51166},
        [50866] = {51168},
        [50867] = {51167},
        [50868] = {51169},
        [50869] = {51165},
        [51125] = {51314},
        [51126] = {51313},
        [51127] = {51312},
        [51128] = {51311},
        [51129] = {51310},
        [51130] = {51309},
        [51131] = {51308},
        [51132] = {51307},
        [51133] = {51306},
        [51134] = {51305},
        [51135] = {51304},
        [51136] = {51303},
        [51137] = {51302},
        [51138] = {51301},
        [51139] = {51300},
        [51140] = {51299},
        [51141] = {51298},
        [51142] = {51297},
        [51143] = {51296},
        [51144] = {51295},
        [51145] = {51294},
        [51146] = {51293},
        [51147] = {51292},
        [51148] = {51291},
        [51149] = {51290},
        [51150] = {51289},
        [51151] = {51288},
        [51152] = {51287},
        [51153] = {51286},
        [51154] = {51285},
        [51155] = {51284},
        [51156] = {51283},
        [51157] = {51282},
        [51158] = {51281},
        [51159] = {51280},
        [51160] = {51279},
        [51161] = {51278},
        [51162] = {51277},
        [51163] = {51276},
        [51164] = {51275},
        [51165] = {51274},
        [51166] = {51273},
        [51167] = {51272},
        [51168] = {51271},
        [51169] = {51270},
        [51170] = {51269},
        [51171] = {51268},
        [51172] = {51267},
        [51173] = {51266},
        [51174] = {51265},
        [51175] = {51264},
        [51176] = {51263},
        [51177] = {51262},
        [51178] = {51261},
        [51179] = {51260},
        [51180] = {51259},
        [51181] = {51258},
        [51182] = {51257},
        [51183] = {51256},
        [51184] = {51255},
        [51185] = {51254},
        [51186] = {51253},
        [51187] = {51252},
        [51188] = {51251},
        [51189] = {51250},
        [51190] = {51249},
        [51191] = {51248},
        [51192] = {51247},
        [51193] = {51246},
        [51194] = {51245},
        [51195] = {51244},
        [51196] = {51243},
        [51197] = {51242},
        [51198] = {51241},
        [51199] = {51240},
        [51200] = {51239},
        [51201] = {51238},
        [51202] = {51237},
        [51203] = {51236},
        [51204] = {51235},
        [51205] = {51234},
        [51206] = {51233},
        [51207] = {51232},
        [51208] = {51231},
        [51209] = {51230},
        [51210] = {51229},
        [51211] = {51228},
        [51212] = {51227},
        [51213] = {51226},
        [51214] = {51225},
        [51215] = {51224},
        [51216] = {51223},
        [51217] = {51222},
        [51218] = {51221},
        [51219] = {51220},
        [52569] = {52570},
        [52570] = {52571},
        [52571] = {52572},
    }
    
    if(map[itemId] ~= nil) then
        for _, subItemId in pairs(map[itemId]) do
            if(GetItemAttuneForge(subItemId) < 0 and (CanAttuneItemHelper(subItemId) > 0 or ((IsAttunableBySomeone(subItemId) or 0) ~= 0 and not ScootsVendor.utility.itemIsBop(subItemId)))) then
                return true
            end
        end
    end
    
    return false
end