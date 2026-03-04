ScootsVendor.interface = {}

ScootsVendor.interface.toggle = function()
    if(ScootsVendor.interface.built ~= true and ScootsVendor.preBuildChecks()) then
        ScootsVendor.interface.build(true)
    end
    
    if(ScootsVendor.interface.built == true) then
        if(ScootsVendor.frames.master:IsVisible()) then
            CloseMerchant()
            HideUIPanel(ScootsVendor.frames.master)
            ScootsVendor.isOpen = false
        else
            ScootsVendor.isOpen = true
        
            if(ScootsVendor.suppressTextChange == nil) then
                ScootsVendor.suppressTextChange = true
            end
            
            ShowUIPanel(ScootsVendor.frames.master)
            OpenBackpack()
        end
    end
end

ScootsVendor.interface.forceClosed = function()
    if(ScootsVendor.interface.built == true) then
        if(ScootsVendor.frames.master:IsVisible()) then
            HideUIPanel(ScootsVendor.frames.master)
            ScootsVendor.isOpen = false
        end
    end
end

ScootsVendor.interface.build = function(toggleAction)
    if(ScootsVendor.interface.built ~= nil) then
        return nil
    end
    
    if(UnitAffectingCombat('player')) then
        if(toggleAction == true) then
            ScootsVendor.pushMessage('Unable to create ' .. ScootsVendor.title .. ' window in combat. Showing default vendor.')
        end
        
        return nil
    end
    
    MerchantFrame_OnEvent = function() end
    MerchantFrame_OnLoad = function() end
    _G['MerchantFrame']:UnregisterAllEvents()

    ScootsVendor.interface.buildMainWindow()
    ScootsVendor.interface.buildTitle()
    ScootsVendor.interface.buildHeader()
    ScootsVendor.interface.buildItemList()
    ScootsVendor.interface.buildSidePanel()
    ScootsVendor.interface.buildFooter()
    
    ScootsVendor.frames.tooltip = CreateFrame('GameTooltip', 'ScootsVendor-Tooltip', UIParent, 'GameTooltipTemplate')
    ScootsVendor.frames.tooltip:Hide()
    
    ScootsVendor.frames.tooltipParser = CreateFrame('GameTooltip', 'ScootsVendor-TooltipParser', UIParent, 'GameTooltipTemplate')
    ScootsVendor.frames.tooltipParser:Hide()
    
    ScootsVendor.options.load()
    ScootsVendor.utility.applyDefaultFilters()
    
    ScootsVendor.frames.autoForgeBatchSize:SetNumber(ScootsVendor.options.get('auto-forge-batch-size'))
    
    ScootsVendor.interface.built = true
end

ScootsVendor.interface.buildMainWindow = function()
    UIPanelWindows[ScootsVendor.frames.master:GetName()] = {
        ['area'] = 'left',
        ['pushable'] = 1,
        ['whileDead'] = false,
        ['width'] = 512
    }
    
    ScootsVendor.frames.master:SetToplevel(true)
    ScootsVendor.frames.master:SetMovable(true)
    ScootsVendor.frames.master:EnableMouse(true)
    ScootsVendor.frames.master:SetAttribute('UIPanelLayout-enabled', true)
    ScootsVendor.frames.master:SetAttribute('UIPanelLayout-area', 'left')
    ScootsVendor.frames.master:SetAttribute('UIPanelLayout-pushable', 1)
    
    ScootsVendor.frames.master:SetSize(UIPanelWindows[ScootsVendor.frames.master:GetName()].width, 438)
    ScootsVendor.frames.master:SetFrameStrata('MEDIUM')
    
    -- Not a mistake: fixes issue with overlapping frames
    ShowUIPanel(ScootsVendor.frames.master)
    HideUIPanel(ScootsVendor.frames.master)
    
    ScootsVendor.frames.master.portrait = ScootsVendor.frames.master:CreateTexture(nil, 'OVERLAY')
    ScootsVendor.frames.master.portrait:SetPoint('TOPLEFT', 8, -4)
    ScootsVendor.frames.master.portrait:SetSize(60, 60)
    
    ScootsVendor.frames.master.background = ScootsVendor.frames.master:CreateTexture(nil, 'BACKGROUND')
    ScootsVendor.frames.master.background:SetTexture('Interface\\AddOns\\ScootsVendor\\Textures\\Background')
    ScootsVendor.frames.master.background:SetPoint('TOPLEFT', 0, 0)
    ScootsVendor.frames.master.background:SetSize(512, 512)
    
    ScootsVendor.frames.master:HookScript('OnHide', function()
        CloseMerchant()
    end)
end

ScootsVendor.interface.buildTitle = function()
    ScootsVendor.frames.title = CreateFrame('Frame', 'ScootsVendor-Title', ScootsVendor.frames.master)
    ScootsVendor.frames.title:SetSize(351, 21)
    ScootsVendor.frames.title:SetPoint('TOPLEFT', ScootsVendor.frames.master, 'TOPLEFT', 68, -11)
    ScootsVendor.frames.title:EnableMouse(true)
    ScootsVendor.frames.title:RegisterForDrag('LeftButton')
    
    ScootsVendor.frames.title.addonName = ScootsVendor.frames.title:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    ScootsVendor.frames.title.addonName:SetPoint('LEFT', 8, 0)
    ScootsVendor.frames.title.addonName:SetJustifyH('LEFT')
    ScootsVendor.frames.title.addonName:SetText(ScootsVendor.title)

    ScootsVendor.frames.title.version = ScootsVendor.frames.title:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    ScootsVendor.frames.title.version:SetTextColor(0.6, 0.98, 0.6)
    ScootsVendor.frames.title.version:SetPoint('BOTTOMLEFT', ScootsVendor.frames.title.addonName, 'BOTTOMRIGHT', 1, 0)
    ScootsVendor.frames.title.version:SetJustifyH('LEFT')
    ScootsVendor.frames.title.version:SetText(ScootsVendor.version)

    ScootsVendor.frames.title.vendorName = ScootsVendor.frames.title:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    ScootsVendor.frames.title.vendorName:SetPoint('BOTTOMLEFT', ScootsVendor.frames.title.version, 'BOTTOMRIGHT', 1, 0)
    ScootsVendor.frames.title.vendorName:SetJustifyH('LEFT')
    
    ScootsVendor.frames.title:SetScript('OnDragStart', function()
        if(ScootsVendor.options.get('drag-window')) then
            ScootsVendor.frames.master:StartMoving()
        end
    end)
    
    ScootsVendor.frames.title:SetScript('OnDragStop', function()
        ScootsVendor.frames.master:StopMovingOrSizing()
    end)
    
    --
    
    ScootsVendor.frames.optionsButton = CreateFrame('Button', 'ScootsVendor-OptionsButton', ScootsVendor.frames.master, 'UIPanelButtonTemplate')
    ScootsVendor.frames.optionsButton:SetSize(64, 19)
    ScootsVendor.frames.optionsButton:SetPoint('TOPLEFT', ScootsVendor.frames.master, 'TOPLEFT', 419, -12)
    ScootsVendor.frames.optionsButton:SetText('Options')
    
    ScootsVendor.frames.optionsButton:SetScript('OnClick', function()
        ScootsVendor.options.open()
    end)
    
    --
    
    ScootsVendor.frames.closeButton = CreateFrame('Button', 'ScootsVendor-CloseButton', ScootsVendor.frames.master, 'UIPanelCloseButton')
    ScootsVendor.frames.closeButton:SetPoint('TOPLEFT', ScootsVendor.frames.master, 'TOPLEFT', 480, -6)
    ScootsVendor.frames.closeButton:SetScript('OnClick', ScootsVendor.interface.toggle)
end

ScootsVendor.interface.buildHeader = function()
    -- Buyback
    ScootsVendor.frames.quickBuyback = CreateFrame('Frame', 'ScootsVendor-QuickBuyback', ScootsVendor.frames.master)
    
    ScootsVendor.frames.quickBuyback:SetSize(200, 38)
    ScootsVendor.frames.quickBuyback:SetBackdrop({
        bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
        edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {
            left = 3,
            right = 3,
            top = 3,
            bottom = 3,
        },
    })
    ScootsVendor.frames.quickBuyback:SetBackdropColor(0, 0, 0, 0.35)
    ScootsVendor.frames.quickBuyback:SetBackdropBorderColor(1, 1, 1, 0.5)
    ScootsVendor.frames.quickBuyback:SetPoint('TOPLEFT', ScootsVendor.frames.master, 'TOPLEFT', 70, -32)
    ScootsVendor.frames.quickBuyback:EnableMouse(true)
    
    ScootsVendor.frames.quickBuyback.title = ScootsVendor.frames.quickBuyback:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    local fontFile, fontSize, fontFlags = ScootsVendor.frames.quickBuyback.title:GetFont()
    
    ScootsVendor.frames.quickBuyback.title:SetFont(fontFile, fontSize - 2, fontFlags)
    ScootsVendor.frames.quickBuyback.title:SetPoint('TOPLEFT', 6, -4)
    ScootsVendor.frames.quickBuyback.title:SetText('Buyback')
        
    ScootsVendor.frames.quickBuyback.icon = ScootsVendor.frames.quickBuyback:CreateTexture(nil, 'ARTWORK')
    ScootsVendor.frames.quickBuyback.icon:SetSize(ScootsVendor.frames.quickBuyback:GetHeight() - 19, ScootsVendor.frames.quickBuyback:GetHeight() - 19)
    ScootsVendor.frames.quickBuyback.icon:SetPoint('TOPLEFT', 6, -14)
    
    ScootsVendor.frames.quickBuyback.quantity = ScootsVendor.frames.quickBuyback:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    local fontFile, fontSize = ScootsVendor.frames.quickBuyback.quantity:GetFont()
    
    ScootsVendor.frames.quickBuyback.quantity:SetFont(fontFile, fontSize - 2, 'OUTLINE')
    ScootsVendor.frames.quickBuyback.quantity:SetPoint('BOTTOMRIGHT', ScootsVendor.frames.quickBuyback.icon, 'BOTTOMRIGHT', 0, 1)
    
    ScootsVendor.frames.quickBuyback.name = ScootsVendor.frames.quickBuyback:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    ScootsVendor.frames.quickBuyback.name:SetPoint('TOPLEFT', ScootsVendor.frames.quickBuyback.icon, 'TOPRIGHT', 2, 1)
    ScootsVendor.frames.quickBuyback.name:SetWidth(ScootsVendor.frames.quickBuyback:GetWidth() - (ScootsVendor.frames.quickBuyback.icon:GetWidth() + 10))
    ScootsVendor.frames.quickBuyback.name:SetJustifyH('LEFT')
    ScootsVendor.frames.quickBuyback.name:SetWordWrap(true)
    
    ScootsVendor.frames.quickBuyback:SetScript('OnEnter', function()
        ScootsVendor.frames.quickBuyback:SetBackdropColor(1, 1, 1, 0.35)
        
        if(ScootsVendor.frames.quickBuyback.itemId) then
            GameTooltip:SetOwner(ScootsVendor.frames.quickBuyback, 'ANCHOR_NONE')
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint('TOPLEFT', ScootsVendor.frames.quickBuyback, 'TOPRIGHT', 0, 0)
            GameTooltip:SetHyperlink(ScootsVendor.utility.getItemLink(ScootsVendor.frames.quickBuyback.itemId))
            GameTooltip:Show()
        end
    end)
    
    ScootsVendor.frames.quickBuyback:SetScript('OnLeave', function()
        ScootsVendor.frames.quickBuyback:SetBackdropColor(0, 0, 0, 0.35)
        GameTooltip_Hide(ScootsVendor.frames.quickBuyback)
        SetCursor(nil)
    end)
    
    ScootsVendor.frames.quickBuyback:SetScript('OnMouseDown', function()
        BuybackItem(ScootsVendor.frames.quickBuyback.index)
    end)
    
    ScootsVendor.frames.quickBuyback:SetScript('OnUpdate', function()
        if(ScootsVendor.frames.quickBuyback:IsMouseOver()) then
            SetCursor('BUY_CURSOR')
        end
    end)
    
    -- Showing total
    ScootsVendor.frames.master.showingTotal = ScootsVendor.frames.master:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    ScootsVendor.frames.master.showingTotal:SetPoint('TOPRIGHT', -34, -56)
end

ScootsVendor.interface.buildSidePanel = function()
    -- Search
    ScootsVendor.frames.searchFilter = ScootsVendor.interface.insertSidePanelTextInput({
        ['framename'] = 'ScootsVendor-Filters-Search',
        ['parent'] = ScootsVendor.frames.master,
        ['label'] = 'Search',
        ['width'] = 140,
        ['justify'] = 'LEFT',
        ['tooltip'] = 'Only show items where the name contains what you type in this field.',
        ['setValueCallback'] = function(value)
            ScootsVendor.setFilter('search', value)
        end
    })
    
    ScootsVendor.frames.searchFilter:SetPoint('TOPLEFT', ScootsVendor.frames.master, 'TOPLEFT', 26, -76)
    
    -- Can afford
    ScootsVendor.frames.canAffordFilter = ScootsVendor.interface.insertSidePanelCheckbox({
        ['framename'] = 'ScootsVendor-Filters-CanAfford',
        ['parent'] = ScootsVendor.frames.master,
        ['prior'] = ScootsVendor.frames.searchFilter,
        ['offset'] = 0,
        ['name'] = 'Can afford only',
        ['filterkey'] = 'can-afford',
        ['tooltip'] = 'Only show items you can afford to purchase.',
    })
    
    -- Show non-equipment
    ScootsVendor.frames.showNonEquipmentFilter = ScootsVendor.interface.insertSidePanelCheckbox({
        ['framename'] = 'ScootsVendor-Filters-ShowNonEquipment',
        ['parent'] = ScootsVendor.frames.master,
        ['prior'] = ScootsVendor.frames.canAffordFilter,
        ['offset'] = 1,
        ['name'] = 'Show non-equipment',
        ['filterkey'] = 'show-non-equipment',
        ['tooltip'] = 'Include items that cannot be equipped.',
    })
    
    -- Item not in bags
    ScootsVendor.frames.excludeItemsInBagFilter = ScootsVendor.interface.insertSidePanelCheckbox({
        ['framename'] = 'ScootsVendor-Filters-ExcludeItemsInBag',
        ['parent'] = ScootsVendor.frames.master,
        ['prior'] = ScootsVendor.frames.showNonEquipmentFilter,
        ['offset'] = 1,
        ['name'] = 'Exclude items in bag',
        ['filterkey'] = 'exclude-items-in-bag',
        ['tooltip'] = 'Exclude items in your bags, or that you have equipped.',
    })
    
    -- Hide learned recipes/mounts/pets
    ScootsVendor.frames.hideLearnedFilter = ScootsVendor.interface.insertSidePanelCheckbox({
        ['framename'] = 'ScootsVendor-Filters-HideLearnedItems',
        ['parent'] = ScootsVendor.frames.master,
        ['prior'] = ScootsVendor.frames.excludeItemsInBagFilter,
        ['offset'] = 1,
        ['name'] = 'Exclude learned',
        ['filterkey'] = 'exclude-learned',
        ['tooltip'] = 'Exclude recipes / mounts / pets you have already learned.',
    })
    
    -- Show attuneable equipment (character/account+boe/all)
    local divider = ScootsVendor.interface.insertSidePanelDivider(ScootsVendor.frames.hideLearnedFilter)
    
    ScootsVendor.frames.attuneableFilter = ScootsVendor.interface.insertSidePanelRadioFilter({
        ['framenameprefix'] = 'ScootsVendor-Filters-Attuneable-',
        ['parent'] = ScootsVendor.frames.master,
        ['prior'] = divider,
        ['offset'] = -2,
        ['name'] = 'Show attuneable equipment',
        ['filterkey'] = 'attuneable',
        ['choices'] = {
            {
                ['framenamesuffix'] = 'Character',
                ['name'] = 'Character',
                ['value'] = 'character',
                ['tooltip'] = 'Show equipment items that can be attuned by the current character.',
            },
            {
                ['framenamesuffix'] = 'Account',
                ['name'] = 'Account + BoE',
                ['value'] = 'account',
                ['tooltip'] = 'Show equipment items that can be attuned either by the current character, or are bind-on-equip and attuneable at all.',
            },
            {
                ['framenamesuffix'] = 'All',
                ['name'] = 'All',
                ['value'] = 'all',
                ['tooltip'] = 'Show all equipment items.',
            },
        },
    })
    
    -- Show attuned equipment (Unattuned/baseline/TFed/WFed/LFed)
    divider = ScootsVendor.interface.insertSidePanelDivider(ScootsVendor.frames.attuneableFilter[#ScootsVendor.frames.attuneableFilter])
    
    ScootsVendor.frames.attunedAtLevelFilter = ScootsVendor.interface.insertSidePanelRadioFilter({
        ['framenameprefix'] = 'ScootsVendor-Filters-AttunedAt-',
        ['parent'] = ScootsVendor.frames.master,
        ['prior'] = divider,
        ['offset'] = -2,
        ['name'] = 'Show equipment attuned at',
        ['filterkey'] = 'attuned-level',
        ['choices'] = {
            {
                ['framenamesuffix'] = 'NotAttuned',
                ['name'] = 'Unattuned',
                ['value'] = -1,
                ['tooltip'] = 'Only show equipment you have not attuned at all.',
            },
            {
                ['framenamesuffix'] = 'Baseline',
                ['name'] = 'Up to baseline',
                ['value'] = 0,
                ['tooltip'] = 'Only show equipment you have not attuned at all, or only attuned at a baseline level.',
            },
            {
                ['framenamesuffix'] = 'Titanforged',
                ['name'] = 'Up to titanforged',
                ['value'] = 1,
                ['tooltip'] = 'Only show equipment you have not attuned at all, or only attuned up to and including at a titanforged level.',
            },
            {
                ['framenamesuffix'] = 'Warforged',
                ['name'] = 'Up to warforged',
                ['value'] = 2,
                ['tooltip'] = 'Only show equipment you have not attuned at all, or only attuned up to and including at a warforged level.',
            },
            {
                ['framenamesuffix'] = 'Lightforged',
                ['name'] = 'Up to lightforged',
                ['value'] = 3,
                ['tooltip'] = 'Show all equipment items.',
            },
        },
    })
    
    -- Auto-forge
    divider = ScootsVendor.interface.insertSidePanelDivider(ScootsVendor.frames.attunedAtLevelFilter[#ScootsVendor.frames.attunedAtLevelFilter])
    
    ScootsVendor.frames.autoForgeLevel = ScootsVendor.interface.insertSidePanelDropdown({
        ['framename'] = 'ScootsVendor-AutoForge-Level',
        ['parent'] = ScootsVendor.frames.master,
        ['tooltip'] = 'Repeatedly automatically purchase forgeable items until it reaches the selected forge level. Failed attempts will be sold.',
        ['choicesCallback'] = function()
            return {
                {
                    ['id'] = 0,
                    ['name'] = 'Auto-forge: off',
                },
                {
                    ['id'] = 1,
                    ['name'] = 'Auto-titanforge',
                },
                {
                    ['id'] = 2,
                    ['name'] = 'Auto-Warforge',
                },
                {
                    ['id'] = 3,
                    ['name'] = 'Auto-Lightforge',
                },
            }
        end,
        ['actionCallback'] = function(value)
            if(value == 0) then
                ScootsVendor.autoForgeLevel = nil
                ScootsVendor.activeAutoForge = nil
                ScootsVendor.autoForgeAttempts = nil
                ScootsVendor.waitingForAutoForgeAttempts = nil
                
                ScootsVendor.frames.master.autoForgeBatchHeader:Hide()
                ScootsVendor.frames.autoForgeBatchDecrement:Hide()
                ScootsVendor.frames.autoForgeBatchSize:Hide()
                ScootsVendor.frames.autoForgeBatchIncrement:Hide()
            else
                ScootsVendor.autoForgeLevel = value
                
                ScootsVendor.frames.master.autoForgeBatchHeader:Show()
                ScootsVendor.frames.autoForgeBatchDecrement:Show()
                ScootsVendor.frames.autoForgeBatchSize:Show()
                ScootsVendor.frames.autoForgeBatchIncrement:Show()
            end
        end,
    })
    
    ScootsVendor.frames.autoForgeLevel:SetPoint('TOPLEFT', divider, 'BOTTOMLEFT', -16, -2)
    
    --
    
    ScootsVendor.frames.master.autoForgeBatchHeader = ScootsVendor.frames.master:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    ScootsVendor.frames.master.autoForgeBatchHeader:SetPoint('TOPLEFT', ScootsVendor.frames.autoForgeLevel, 'BOTTOMLEFT', 16, 0)
    ScootsVendor.frames.master.autoForgeBatchHeader:SetJustifyH('LEFT')
    ScootsVendor.frames.master.autoForgeBatchHeader:SetText('Batch size:')
    ScootsVendor.frames.master.autoForgeBatchHeader:Hide()
    
    --
    
    ScootsVendor.frames.autoForgeBatchDecrement = CreateFrame('Button', 'ScootsVendor-AutoForgeBatchSize-DecrementButton', ScootsVendor.frames.master)
    ScootsVendor.frames.autoForgeBatchDecrement:SetSize(19, 19)
    ScootsVendor.frames.autoForgeBatchDecrement:SetPoint('LEFT', ScootsVendor.frames.master.autoForgeBatchHeader, 'RIGHT', 12, -1)
    ScootsVendor.frames.autoForgeBatchDecrement:Hide()
    
    ScootsVendor.frames.autoForgeBatchDecrement:SetNormalTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up')
    ScootsVendor.frames.autoForgeBatchDecrement:SetPushedTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down')
    ScootsVendor.frames.autoForgeBatchDecrement:SetDisabledTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled')
    ScootsVendor.frames.autoForgeBatchDecrement:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight', 'ADD')
    
    ScootsVendor.frames.autoForgeBatchDecrement:SetScript('OnClick', function()
        local check = ScootsVendor.frames.autoForgeBatchSize:GetNumber()
        
        if(check > 1) then
            ScootsVendor.frames.autoForgeBatchSize:SetNumber(check - 1)
        end
    end)
    
    --
    
    ScootsVendor.frames.autoForgeBatchSize = ScootsVendor.interface.insertSidePanelTextInput({
        ['framename'] = 'ScootsVendor-AutoForgeBatchSize',
        ['parent'] = ScootsVendor.frames.master,
        ['value'] = ScootsVendor.options.get('auto-forge-batch-size'),
        ['width'] = 30,
        ['justify'] = 'CENTER',
        ['tooltip'] = 'Auto-forge will purchase this many items each forge attempt.',
        ['setValueCallback'] = function(value)
            ScootsVendor.options.set('auto-forge-batch-size', tonumber(value))
            ScootsVendor.autoForgeBatchSize = tonumber(value)
        end
    })
    
    ScootsVendor.frames.autoForgeBatchSize:SetPoint('LEFT', ScootsVendor.frames.autoForgeBatchDecrement, 'RIGHT', 0, 0)
    ScootsVendor.frames.autoForgeBatchSize:SetText(ScootsVendor.autoForgeBatchSize)
    ScootsVendor.frames.autoForgeBatchSize:SetNumeric(true)
    ScootsVendor.frames.autoForgeBatchSize:SetMaxLetters(2)
    ScootsVendor.frames.autoForgeBatchSize:Hide()
    
    --
    
    ScootsVendor.frames.autoForgeBatchIncrement = CreateFrame('Button', 'ScootsVendor-AutoForgeBatchSize-DecrementButton', ScootsVendor.frames.master)
    ScootsVendor.frames.autoForgeBatchIncrement:SetSize(19, 19)
    ScootsVendor.frames.autoForgeBatchIncrement:SetPoint('LEFT', ScootsVendor.frames.autoForgeBatchSize, 'RIGHT', 0, 0)
    ScootsVendor.frames.autoForgeBatchIncrement:Hide()
    
    ScootsVendor.frames.autoForgeBatchIncrement:SetNormalTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up')
    ScootsVendor.frames.autoForgeBatchIncrement:SetPushedTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down')
    ScootsVendor.frames.autoForgeBatchIncrement:SetDisabledTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled')
    ScootsVendor.frames.autoForgeBatchIncrement:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight', 'ADD')
    
    ScootsVendor.frames.autoForgeBatchIncrement:SetScript('OnClick', function()
        local check = ScootsVendor.frames.autoForgeBatchSize:GetNumber()
        
        if(check < 99) then
            ScootsVendor.frames.autoForgeBatchSize:SetNumber(check + 1)
        end
    end)
end

ScootsVendor.interface.insertSidePanelTextInput = function(data)
    local textInput = CreateFrame('EditBox', data.framename, data.parent)
    textInput:SetSize(data.width, 19)
    textInput:SetAutoFocus(false)
    textInput:SetFontObject('GameFontHighlightSmall')
    textInput:SetJustifyH(data.justify)
    textInput:SetTextInsets(5, 5, 0, 0)

    if(data.label) then
        textInput.label = textInput:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
        textInput.label:SetPoint('LEFT', 5, 0)
        textInput.label:SetJustifyH(data.justify)
        textInput.label:SetText(data.label)
    end
    
    if(data.value) then
        textInput:SetText(data.value)
    end
    
    if(data.tooltip ~= nil) then
        textInput:SetScript('OnEnter', function()
            GameTooltip:SetOwner(textInput, 'ANCHOR_TOPLEFT')
            GameTooltip:SetText(data.tooltip, nil, nil, nil, nil, 1)
            GameTooltip:Show()
        end)
        
        textInput:SetScript('OnLeave', GameTooltip_Hide)
    end
    
    textInput:SetScript('OnEnterPressed', EditBox_ClearFocus)
    textInput:SetScript('OnEscapePressed', EditBox_ClearFocus)
    textInput:SetScript('OnEditFocusGained', EditBox_HighlightText)
    
    if(data.label) then
        textInput:SetScript('OnEditFocusLost', function()
            if(textInput:GetText() == '') then
                textInput.label:Show()
            end
        end)
    end
    
    textInput:SetScript('OnTextChanged', function()
        if(ScootsVendor.suppressTextChange ~= true) then
            data.setValueCallback(textInput:GetText())
        else
            ScootsVendor.suppressTextChange = false
        end
        
        if(textInput.label) then
            if(textInput:GetText() == '') then
                textInput.label:Show()
            else
                textInput.label:Hide()
            end
        end
    end)
    
    textInput.bgLeft = textInput:CreateTexture(nil, 'BACKGROUND')
    textInput.bgLeft:SetTexture('Interface\\Common\\Common-Input-Border')
    textInput.bgLeft:SetSize(8, 19)
    textInput.bgLeft:SetPoint('LEFT', 0, 0)
    textInput.bgLeft:SetTexCoord(0, 0.0625, 0, 0.625)
    
    textInput.bgRight = textInput:CreateTexture(nil, 'BACKGROUND')
    textInput.bgRight:SetTexture('Interface\\Common\\Common-Input-Border')
    textInput.bgRight:SetSize(8, 19)
    textInput.bgRight:SetPoint('RIGHT', 0, 0)
    textInput.bgRight:SetTexCoord(0.9375, 1.0, 0, 0.625)
    
    textInput.bgMiddle = textInput:CreateTexture(nil, 'BACKGROUND')
    textInput.bgMiddle:SetTexture('Interface\\Common\\Common-Input-Border')
    textInput.bgMiddle:SetSize(10, 19)
    textInput.bgMiddle:SetPoint('LEFT', textInput.bgLeft, 'RIGHT', 0, 0)
    textInput.bgMiddle:SetPoint('RIGHT', textInput.bgRight, 'LEFT', 0, 0)
    textInput.bgMiddle:SetTexCoord(0.0625, 0.9375, 0, 0.625)
    
    return textInput
end

ScootsVendor.interface.insertSidePanelDivider = function(priorElement, offset)
    if(offset == nil) then
        offset = 0
    end

    local divider = ScootsVendor.frames.master:CreateTexture(nil, 'OVERLAY')
    divider:SetSize(142, 1)
    divider:SetPoint('TOPLEFT', priorElement, 'BOTTOMLEFT', 0, offset)
    divider:SetTexture(1, 1, 1, 0.1)
    
    return divider
end

ScootsVendor.interface.insertSidePanelCheckbox = function(data)
    local checkbox = CreateFrame('CheckButton', data.framename, data.parent, 'UICheckButtonTemplate')
    checkbox:SetSize(22, 22)
    checkbox:SetPoint('TOPLEFT', data.prior, 'BOTTOMLEFT', 0, data.offset)
    
    _G[checkbox:GetName() .. 'Text']:SetText(data.name)
    _G[checkbox:GetName() .. 'Text']:ClearAllPoints()
    _G[checkbox:GetName() .. 'Text']:SetPoint('TOPLEFT', checkbox, 'TOPRIGHT', -2, -5)
    
    checkbox:SetHitRectInsets(0, 0 - _G[checkbox:GetName() .. 'Text']:GetWidth(), 0, 0)
    
    checkbox:SetScript('OnClick', function(self)
        ScootsVendor.setFilter(data.filterkey, self:GetChecked() == 1)
    end)
    
    checkbox:SetScript('OnEnter', function()
        GameTooltip:SetOwner(checkbox, 'ANCHOR_TOPLEFT')
        GameTooltip:SetText(data.tooltip, nil, nil, nil, nil, 1)
        GameTooltip:Show()
    end)
    
    checkbox:SetScript('OnLeave', GameTooltip_Hide)
    
    return checkbox
end

ScootsVendor.interface.insertSidePanelRadioFilter = function(data)
    local header = data.parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    header:SetPoint('TOPLEFT', data.prior, 'BOTTOMLEFT', 0, data.offset)
    header:SetJustifyH('LEFT')
    header:SetText(data.name)
    
    local prior = header
    local checkboxes = {}
    local index = 1
    for _, choice in ipairs(data.choices) do
        local offset = 5
        if(index == 1) then
            offset = 0
        end
    
        local checkbox = ScootsVendor.interface.insertSidePanelCheckbox({
            ['framename'] = data.framenameprefix .. choice.framenamesuffix,
            ['parent'] = data.parent,
            ['prior'] = prior,
            ['offset'] = offset,
            ['name'] = choice.name,
            ['filterkey'] = data.filterkey,
            ['tooltip'] = choice.tooltip,
        })
        
        checkbox.filterValue = choice.value
    
        checkbox:SetScript('OnClick', function(self)
            ScootsVendor.setFilter(data.filterkey, choice.value)
            self:Disable()
            
            for _, otherCheckbox in pairs(checkboxes) do
                if(otherCheckbox:GetName() ~= self:GetName()) then
                    otherCheckbox:SetChecked(false)
                    otherCheckbox:Enable()
                end
            end
        end)
        
        prior = checkbox
        table.insert(checkboxes, checkbox)
        index = index + 1
    end
    
    return checkboxes
end

ScootsVendor.interface.insertSidePanelDropdown = function(data)
    local dropdown = CreateFrame('Frame', data.framename, data.parent, 'UIDropDownMenuTemplate')
    local choices = data.choicesCallback()
    
    dropdown.initFunc = function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        
        for index, choice in ipairs(choices) do
            info.text = choice.name
            info.func = function()
                UIDropDownMenu_SetText(dropdown, choice.name)
                data.actionCallback(choice.id)
            end
            
            UIDropDownMenu_AddButton(info, level)
        end
    end
    
    UIDropDownMenu_Initialize(dropdown, dropdown.initFunc)
    UIDropDownMenu_SetText(dropdown, choices[1].name)
    
    local button = _G[dropdown:GetName() .. 'Button']
    button:SetHitRectInsets(-105, 0, 0, 0)
    
    if(data.tooltip ~= nil) then
        button:SetScript('OnEnter', function()
            GameTooltip:SetOwner(button, 'ANCHOR_NONE')
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint('BOTTOMLEFT', button, 'TOPLEFT', -109, 0)
            GameTooltip:SetText(data.tooltip, nil, nil, nil, nil, 1)
            GameTooltip:Show()
        end)
        
        button:SetScript('OnLeave', GameTooltip_Hide)
    end
    
    return dropdown
end

ScootsVendor.interface.buildItemList = function()
    ScootsVendor.frames.itemList = CreateFrame('ScrollFrame', 'ScootsVendor-ItemList', ScootsVendor.frames.master, 'FauxScrollFrameTemplate')
    ScootsVendor.frames.itemList:SetSize(301, 334)
    ScootsVendor.frames.itemList:SetPoint('TOPLEFT', ScootsVendor.frames.master, 'TOPLEFT', 176, -72)
    
    ScootsVendor.itemsVisible = 10
    ScootsVendor.itemFrameHeight = (ScootsVendor.frames.itemList:GetHeight() - (ScootsVendor.itemsVisible - 1)) / ScootsVendor.itemsVisible
    
    ScootsVendor.frames.itemList:SetScript('OnVerticalScroll', function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ScootsVendor.itemFrameHeight, ScootsVendor.renderItemList)
    end)
    
    ScootsVendor.frames.items = {}
    for itemIndex = 1, ScootsVendor.itemsVisible do
        local itemFrame = CreateFrame('Button', 'ScootsVendor-itemFrame-' .. tostring(itemIndex), ScootsVendor.frames.itemList)
        itemFrame:SetSize(ScootsVendor.frames.itemList:GetWidth(), ScootsVendor.itemFrameHeight)
        itemFrame:SetPoint('TOPLEFT', ScootsVendor.frames.itemList, 'TOPLEFT', 0, 0 - ((ScootsVendor.itemFrameHeight * (itemIndex - 1)) + (itemIndex - 1)))
        itemFrame:EnableMouse(true)
        
        itemFrame.background = itemFrame:CreateTexture(nil, 'BACKGROUND')
        itemFrame.background:SetAllPoints()
        itemFrame.background:SetTexture(1, 1, 1)
        itemFrame.background:SetAlpha(0.05)
        
        itemFrame.icon = itemFrame:CreateTexture(nil, 'ARTWORK')
        itemFrame.icon:SetSize(ScootsVendor.itemFrameHeight - 6, ScootsVendor.itemFrameHeight - 6)
        itemFrame.icon:SetPoint('TOPLEFT', 4, -3)
        
        itemFrame.stock = itemFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        local fontFile, fontSize = itemFrame.stock:GetFont()

        itemFrame.stock:SetFont(fontFile, fontSize, 'OUTLINE')
        itemFrame.stock:SetPoint('TOPLEFT', itemFrame.icon, 'TOPLEFT', 2, -2)
        itemFrame.stock:SetJustifyH('LEFT')
        
        itemFrame.quantity = itemFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
        local fontFile, fontSize = itemFrame.quantity:GetFont()

        itemFrame.quantity:SetFont(fontFile, fontSize, 'OUTLINE')
        itemFrame.quantity:SetPoint('BOTTOMRIGHT', itemFrame.icon, 'BOTTOMRIGHT', -1, 2)
        itemFrame.quantity:SetJustifyH('RIGHT')
        
        itemFrame.name = itemFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
        itemFrame.name:SetPoint('TOPLEFT', ScootsVendor.itemFrameHeight + 4, -2)
        itemFrame.name:SetJustifyH('LEFT')
        
        if(itemIndex > 1) then
            itemFrame.divider = itemFrame:CreateTexture(nil, 'BORDER')
            itemFrame.divider:SetTexture(0.2, 0.2, 0.2, 1)
            itemFrame.divider:SetSize(ScootsVendor.frames.itemList:GetWidth(), 1)
            itemFrame.divider:SetPoint('TOPLEFT', ScootsVendor.frames.itemList, 'TOPLEFT', 0, 0 - ((ScootsVendor.itemFrameHeight * (itemIndex - 1)) + (itemIndex - 2)))
        end
        
        itemFrame.mouseEnterEvent = function()
            itemFrame.background:SetAlpha(0.1)
            
            if(itemFrame.itemId) then
                GameTooltip:SetOwner(itemFrame, 'ANCHOR_NONE')
                GameTooltip:ClearAllPoints()
                GameTooltip:SetPoint('TOPLEFT', itemFrame, 'TOPRIGHT', 0, 0)
                GameTooltip:SetHyperlink(ScootsVendor.utility.getItemLink(itemFrame.itemId))
                GameTooltip:Show()
            end
        end
        
        itemFrame:SetScript('OnEnter', function()
            itemFrame.mouseEnterEvent()
        end)
        
        itemFrame.mouseLeaveEvent = function()
            itemFrame.background:SetAlpha(0.05)
            GameTooltip_Hide(itemFrame)
        end
        
        itemFrame:SetScript('OnLeave', function()
            itemFrame.mouseLeaveEvent()
            ScootsVendor.frames.tooltip:Hide()
            SetCursor(nil)
        end)
        
        itemFrame:SetScript('OnUpdate', function()
            if(itemFrame:IsMouseOver()) then
                if(IsModifiedClick('DRESSUP')) then
                    ShowInspectCursor()
                else
                    if(ScootsVendor.mode == 'purchase') then
                        ShowMerchantSellCursor(itemFrame.index)
                    elseif(ScootsVendor.mode == 'buyback') then
                        SetCursor('BUY_CURSOR')
                    end
                end
            end
        end)
        
        itemFrame.mouseDownEvent = function(button)
            if(IsModifiedClick('DRESSUP') or (IsModifiedClick('SPLITSTACK') and ScootsVendor.activeChatFrame ~= nil)) then
                HandleModifiedItemClick(ScootsVendor.utility.getItemLink(itemFrame.itemId))
            elseif(IsModifiedClick('SPLITSTACK')) then
                OpenStackSplitFrame(math.min(GetMerchantItemMaxStack(itemFrame.index), ScootsVendor.utility.getAffordableCount(itemFrame.index)), itemFrame, 'BOTTOMLEFT', 'TOPLEFT')
            elseif(button == 'LeftButton') then
                if(ScootsVendor.autoForgeLevel ~= nil) then
                    ScootsVendor.handleAutoForge(itemFrame.itemId, itemFrame.index)
                else
                    if(ScootsVendor.mode == 'purchase') then
                        PickupMerchantItem(itemFrame.index)
                    elseif(ScootsVendor.mode == 'buyback') then
                        BuybackItem(itemFrame.index)
                    end
                end
            elseif(button == 'RightButton') then
                if(ScootsVendor.autoForgeLevel ~= nil) then
                    ScootsVendor.handleAutoForge(itemFrame.itemId, itemFrame.index)
                else
                    if(ScootsVendor.mode == 'purchase') then
                        BuyMerchantItem(itemFrame.index, 1)
                    elseif(ScootsVendor.mode == 'buyback') then
                        BuybackItem(itemFrame.index)
                    end
                end
            end
        end
        
        itemFrame:SetScript('OnMouseDown', function(_, button)
            itemFrame.mouseDownEvent(button)
        end)
        
        itemFrame.SplitStack = function(_, split)
            BuyMerchantItem(itemFrame.index, split)
        end
        
        table.insert(ScootsVendor.frames.items, itemFrame)
        itemFrame:Hide()
    end
end

ScootsVendor.interface.buildFooter = function()
    -- Player currencies holder
    ScootsVendor.frames.playerCurrencies = CreateFrame('Frame', 'ScootsVendor-PlayerCurrencyHolder', ScootsVendor.frames.master)
    ScootsVendor.frames.playerCurrencies:SetSize(413, 19)
    ScootsVendor.frames.playerCurrencies:SetPoint('TOPLEFT', ScootsVendor.frames.master, 'TOPLEFT', 18, -410)
    
    -- Total cost
    ScootsVendor.frames.totalCost = CreateFrame('Button', 'ScootsVendor-OptionsButton', ScootsVendor.frames.master, 'UIPanelButtonTemplate')
    ScootsVendor.frames.totalCost:SetSize(74, 19)
    ScootsVendor.frames.totalCost:SetPoint('TOPLEFT', ScootsVendor.frames.master, 'TOPLEFT', 430, -410)
    ScootsVendor.frames.totalCost:SetText('Total cost')
    
    ScootsVendor.frames.totalCost:SetScript('OnLeave', GameTooltip_Hide)
    
    -- Tabs
    ScootsVendor.frames.switchToPurchase = CreateFrame('Button', 'ScootsVendor-PurchaseTab', ScootsVendor.frames.master, 'CharacterFrameTabButtonTemplate')
    ScootsVendor.frames.switchToPurchase:SetPoint('TOPLEFT', ScootsVendor.frames.master, 'TOPLEFT', 15, -434)
    ScootsVendor.frames.switchToPurchase:SetText(MERCHANT)
    PanelTemplates_SelectTab(ScootsVendor.frames.switchToPurchase)
    
    ScootsVendor.frames.switchToPurchase:SetScript('OnClick', function()
        if(ScootsVendor.mode ~= 'purchase') then
            PanelTemplates_SelectTab(ScootsVendor.frames.switchToPurchase)
            PanelTemplates_DeselectTab(ScootsVendor.frames.switchToBuyback)
            ScootsVendor.mode = 'purchase'
            ScootsVendor.refreshPurchaseItemList()
            ScootsVendor.updateQuickBuyback()
            ScootsVendor.forceMouseEnterEvents()
    
            FauxScrollFrame_SetOffset(ScootsVendor.frames.itemList, 0)
            ScootsVendor.frames.itemList:SetVerticalScroll(0)
            
            ScootsVendor.frames.switchToPurchase:SetPoint('TOPLEFT', ScootsVendor.frames.master, 'TOPLEFT', 15, -434)
            ScootsVendor.frames.switchToBuyback:SetPoint('TOPLEFT', ScootsVendor.frames.master, 'TOPLEFT', 92, -432)
        end
    end)
    
    --
    
    ScootsVendor.frames.switchToBuyback = CreateFrame('Button', 'ScootsVendor-BuybackTab', ScootsVendor.frames.master, 'CharacterFrameTabButtonTemplate') 
    ScootsVendor.frames.switchToBuyback:SetPoint('TOPLEFT', ScootsVendor.frames.master, 'TOPLEFT', 92, -432)
    ScootsVendor.frames.switchToBuyback:SetText(BUYBACK)
    PanelTemplates_DeselectTab(ScootsVendor.frames.switchToBuyback)
    
    ScootsVendor.frames.switchToBuyback:SetScript('OnClick', function()
        if(ScootsVendor.mode ~= 'buyback') then
            PanelTemplates_SelectTab(ScootsVendor.frames.switchToBuyback)
            PanelTemplates_DeselectTab(ScootsVendor.frames.switchToPurchase)
            ScootsVendor.mode = 'buyback'
            ScootsVendor.refreshBuybackItemList()
            ScootsVendor.updateQuickBuyback()
            ScootsVendor.forceMouseEnterEvents()
    
            FauxScrollFrame_SetOffset(ScootsVendor.frames.itemList, 0)
            ScootsVendor.frames.itemList:SetVerticalScroll(0)
            
            ScootsVendor.frames.switchToPurchase:SetPoint('TOPLEFT', ScootsVendor.frames.master, 'TOPLEFT', 15, -432)
            ScootsVendor.frames.switchToBuyback:SetPoint('TOPLEFT', ScootsVendor.frames.master, 'TOPLEFT', 92, -434)
        end
    end)
end

ScootsVendor.interface.getCurrencyFrame = function(protected)
    local frameType = 'free'
    if(protected) then
        frameType = 'protected'
    end
    
    local consumedFrames = ScootsVendor.consumedFrames.currency[frameType]
    consumedFrames = consumedFrames + 1
    ScootsVendor.consumedFrames.currency[frameType] = consumedFrames
    
    if(ScootsVendor.frames.currency[frameType][consumedFrames] == nil) then
        local currencyFrame = CreateFrame('Frame', 'ScootsVendor-CurrencyFrame-' .. tostring(consumedFrames) .. '-' .. frameType, ScootsVendor.frames.master)
        currencyFrame:SetBackdrop({
            bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
            edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
            tile = true,
            tileSize = 16,
            edgeSize = 8,
            insets = {
                left = 2,
                right = 2,
                top = 2,
                bottom = 2,
            },
        })
        currencyFrame:SetBackdropColor(0, 0, 0, 0.35)
        currencyFrame:SetBackdropBorderColor(1, 1, 1, 0.5)
        currencyFrame:EnableMouse(true)
        
        currencyFrame.icon = currencyFrame:CreateTexture(nil, 'ARTWORK')
        currencyFrame.icon:SetSize(10, 10)
        currencyFrame.icon:SetPoint('LEFT', 4, 0)
        
        currencyFrame.text = currencyFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
        currencyFrame.text:SetPoint('RIGHT', -4, 0)
        
        ScootsVendor.frames.currency[frameType][consumedFrames] = currencyFrame
    end
    
    ScootsVendor.frames.currency[frameType][consumedFrames]:Show()
    return ScootsVendor.frames.currency[frameType][consumedFrames]
end

ScootsVendor.interface.attachCurrencyFrame = function(parentFrame, price, itemId, protected)
    local currencyFrame = ScootsVendor.interface.getCurrencyFrame(protected)
    currencyFrame:SetParent(parentFrame)
    
    local _, itemLink, _, _, _, _, _, _, _, texture = GetItemInfoCustom(itemId)
    
    if(itemId == 43307) then
        texture = 'Interface\\PVPFrame\\PVP-ArenaPoints-Icon'
    elseif(itemId == 43308) then
        texture = ScootsVendor.pvpIcon
    end
    
    currencyFrame.icon:SetTexture(texture)
    currencyFrame.text:SetText(price)
    currencyFrame:SetSize(currencyFrame.icon:GetWidth() + currencyFrame.text:GetWidth() + 8, currencyFrame.text:GetHeight() + 6)
        
    currencyFrame:SetScript('OnEnter', function()
        if(parentFrame.itemId ~= nil) then
            parentFrame.mouseEnterEvent()
        end
        
        local tooltip
        if(protected) then
            GameTooltip:SetOwner(currencyFrame, 'ANCHOR_TOPLEFT')
            GameTooltip:SetHyperlink(itemLink)
            GameTooltip:Show()
        else
            ScootsVendor.frames.tooltip:SetOwner(currencyFrame, 'ANCHOR_TOPRIGHT')
            ScootsVendor.frames.tooltip:SetHyperlink(itemLink)
            ScootsVendor.frames.tooltip:Show()
        end
    end)
        
    currencyFrame:SetScript('OnLeave', function()
        if(protected) then
            GameTooltip:Hide()
        else
            ScootsVendor.frames.tooltip:Hide()
        end
        
        if(parentFrame.itemId ~= nil and not parentFrame:IsMouseOver()) then
            parentFrame.mouseLeaveEvent()
        end
    end)
    
    currencyFrame:SetScript('OnMouseDown', function(_, button)
        if(parentFrame.itemId ~= nil) then
            parentFrame.mouseDownEvent(button)
        end
    end)
    
    return currencyFrame
end

ScootsVendor.interface.getGoldFrame = function(protected)
    local frameType = 'free'
    if(protected) then
        frameType = 'protected'
    end
    
    local consumedFrames = ScootsVendor.consumedFrames.gold[frameType]
    consumedFrames = consumedFrames + 1
    ScootsVendor.consumedFrames.gold[frameType] = consumedFrames
    
    if(ScootsVendor.frames.gold[frameType][consumedFrames] == nil) then
        local currencyFrame = CreateFrame('Frame', 'ScootsVendor-CurrencyFrame-' .. tostring(consumedFrames) .. '-' .. frameType, ScootsVendor.frames.master)
        currencyFrame:SetBackdrop({
            bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
            edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
            tile = true,
            tileSize = 16,
            edgeSize = 8,
            insets = {
                left = 2,
                right = 2,
                top = 2,
                bottom = 2,
            },
        })
        currencyFrame:SetBackdropColor(0, 0, 0, 0.35)
        currencyFrame:SetBackdropBorderColor(1, 1, 1, 0.5)
        
        currencyFrame.goldIcon = currencyFrame:CreateTexture(nil, 'ARTWORK')
        currencyFrame.goldIcon:SetTexture('Interface\\MoneyFrame\\UI-GoldIcon')
        currencyFrame.goldIcon:SetSize(10, 10)
        currencyFrame.goldIcon:SetPoint('LEFT', 4, 0)
        
        currencyFrame.goldText = currencyFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
        currencyFrame.goldText:SetPoint('LEFT', currencyFrame.goldIcon, 'RIGHT', 0, 0)
        
        currencyFrame.silverIcon = currencyFrame:CreateTexture(nil, 'ARTWORK')
        currencyFrame.silverIcon:SetTexture('Interface\\MoneyFrame\\UI-SilverIcon')
        currencyFrame.silverIcon:SetSize(10, 10)
        
        currencyFrame.silverText = currencyFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
        currencyFrame.silverText:SetPoint('LEFT', currencyFrame.silverIcon, 'RIGHT', 0, 0)
        
        currencyFrame.copperIcon = currencyFrame:CreateTexture(nil, 'ARTWORK')
        currencyFrame.copperIcon:SetTexture('Interface\\MoneyFrame\\UI-CopperIcon')
        currencyFrame.copperIcon:SetSize(10, 10)
        
        currencyFrame.copperText = currencyFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
        currencyFrame.copperText:SetPoint('LEFT', currencyFrame.copperIcon, 'RIGHT', 0, 0)
        
        ScootsVendor.frames.gold[frameType][consumedFrames] = currencyFrame
    end
    
    ScootsVendor.frames.gold[frameType][consumedFrames]:Show()
    return ScootsVendor.frames.gold[frameType][consumedFrames]
end

ScootsVendor.interface.attachGoldFrame = function(parentFrame, copper, protected)
    local currencyFrame = ScootsVendor.interface.getGoldFrame(protected)
    currencyFrame:SetParent(parentFrame)
    
    local prior
    local width = 0
    local height
    local gold = math.floor(copper / 10000)
    local silver = math.floor(copper / 100) % 100
    copper = copper % 100
    
    if(gold > 0) then
        currencyFrame.goldIcon:Show()
        currencyFrame.goldText:Show()
        currencyFrame.goldText:SetText(gold)
        
        width = width + currencyFrame.goldIcon:GetWidth() + currencyFrame.goldText:GetWidth()
        height = currencyFrame.goldText:GetHeight()
        prior = currencyFrame.goldText
    else
        currencyFrame.goldIcon:Hide()
        currencyFrame.goldText:Hide()
    end
    
    if(silver > 0) then
        currencyFrame.silverIcon:Show()
        currencyFrame.silverText:Show()
        currencyFrame.silverText:SetText(silver)
        
        width = width + currencyFrame.silverIcon:GetWidth() + currencyFrame.silverText:GetWidth()
        height = currencyFrame.silverText:GetHeight()
        
        if(prior ~= nil) then
            currencyFrame.silverIcon:SetPoint('LEFT', prior, 'RIGHT', 2, 0)
            width = width + 2
        else
            currencyFrame.silverIcon:SetPoint('LEFT', 4, 0)
        end
        
        prior = currencyFrame.silverText
    else
        currencyFrame.silverIcon:Hide()
        currencyFrame.silverText:Hide()
    end
    
    if(copper > 0 or (gold == 0 and silver == 0)) then
        currencyFrame.copperIcon:Show()
        currencyFrame.copperText:Show()
        currencyFrame.copperText:SetText(copper)
        
        width = width + currencyFrame.copperIcon:GetWidth() + currencyFrame.copperText:GetWidth()
        height = currencyFrame.copperText:GetHeight()
        
        if(prior ~= nil) then
            currencyFrame.copperIcon:SetPoint('LEFT', prior, 'RIGHT', 2, 0)
            width = width + 2
        else
            currencyFrame.copperIcon:SetPoint('LEFT', 4, 0)
        end
    else
        currencyFrame.copperIcon:Hide()
        currencyFrame.copperText:Hide()
    end
    
    currencyFrame:SetSize(width + 8, height + 6)
    
    return currencyFrame
end