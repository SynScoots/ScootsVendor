ScootsVendor.options = {}

ScootsVendor.options.load = function()
    local defaultOptions = {
        ['drag-window'] = true,
        ['bypass-items'] = {},
        ['default-filters'] = {
            ['can-afford'] = false,
            ['show-non-equipment'] = true,
            ['exclude-items-in-bag'] = true,
            ['exclude-learned'] = true,
            ['attuneable'] = 'character',
            ['attuned-level'] = -1,
        },
        ['auto-forge-batch-size'] = 1,
    }
    
    ScootsVendor.storage.options = ScootsVendor.storage.options or {}
    
    local options = {}
    
    for name, defaultValue in pairs(defaultOptions) do
        if(name == 'default-filters') then
            if(ScootsVendor.storage.options['default-filters'] == nil) then
                ScootsVendor.storage.options['default-filters'] = {}
            end
        
            options['default-filters'] = {}
            for optionName, optionValue in pairs(defaultValue) do
                if(ScootsVendor.storage.options['default-filters'][optionName] ~= nil) then
                    options['default-filters'][optionName] = ScootsVendor.storage.options['default-filters'][optionName]
                else
                    options['default-filters'][optionName] = defaultOptions['default-filters'][optionName]
                end
            end
        else
            options[name] = defaultValue
            
            if(ScootsVendor.storage.options[name] ~= nil) then
                options[name] = ScootsVendor.storage.options[name]
            else
                options[name] = defaultOptions[name]
            end
        end
    end
    
    local bypassItems = ScootsVendor.options.getItemsThatBypassFilters()
    for _, item in pairs(bypassItems) do
        if(options['bypass-items'][item.id] == nil) then
            options['bypass-items'][item.id] = true
        end
    end
    
    ScootsVendor.storage.options = options
    ScootsVendor.filters = {}
    
    for key, value in pairs(options['default-filters']) do
        ScootsVendor.filters[key] = value
    end
end

ScootsVendor.options.get = function(optionName)
    if(ScootsVendor.storage == nil
    or ScootsVendor.storage.options == nil) then
        return nil
    end
    
    return ScootsVendor.storage.options[optionName]
end

ScootsVendor.options.set = function(optionName, optionValue)
    if(ScootsVendor.storage.options == nil) then
        ScootsVendor.storage.options = {}
    end
    
    ScootsVendor.storage.options[optionName] = optionValue
    ScootsVendor.refreshPurchaseItemList()
end

ScootsVendor.options.open = function()
    if(ScootsVendor.frames.options ~= nil) then
        InterfaceOptionsFrame_OpenToCategory(ScootsVendor.frames.options)
    end
end

ScootsVendor.options.build = function()
    if(ScootsVendor.frames.options ~= nil) then
        return nil
    end

    ScootsVendor.frames.options = CreateFrame('Frame', 'ScootsVendor-Options', UIParent)
    ScootsVendor.frames.options.name = ScootsVendor.title
    InterfaceOptions_AddCategory(ScootsVendor.frames.options)
    
    ScootsVendor.frames.options:HookScript('OnShow', function()
        if(ScootsVendor.options.built ~= nil) then
            return nil
        end
        
        ScootsVendor.frames.optionsScrollFrame = CreateFrame('ScrollFrame', 'ScootsVendor-Options-ScrollFrame', ScootsVendor.frames.options, 'UIPanelScrollFrameTemplate')
        ScootsVendor.frames.optionsScrollFrame:SetWidth(663)
    
        ScootsVendor.frames.optionsScrollChild = CreateFrame('Frame', 'ScootsVendor-Options-Fields-ScrollChild', ScootsVendor.frames.optionsScrollFrame)
        ScootsVendor.frames.optionsScrollChild:SetWidth(ScootsVendor.frames.optionsScrollFrame:GetWidth())
        
        local scrollBarName = ScootsVendor.frames.optionsScrollFrame:GetName()
        local scrollBar = _G[scrollBarName .. 'ScrollBar']
        local scrollUpButton = _G[scrollBarName .. 'ScrollBarScrollUpButton']
        local scrollDownButton = _G[scrollBarName .. 'ScrollBarScrollDownButton']

        scrollUpButton:ClearAllPoints()
        scrollUpButton:SetPoint('TOPRIGHT', ScootsVendor.frames.optionsScrollFrame, 'TOPRIGHT', -2, -2)

        scrollDownButton:ClearAllPoints()
        scrollDownButton:SetPoint('BOTTOMRIGHT', ScootsVendor.frames.optionsScrollFrame, 'BOTTOMRIGHT', -2, 2)

        scrollBar:ClearAllPoints()
        scrollBar:SetPoint('TOP', scrollUpButton, 'BOTTOM', 0, -2)
        scrollBar:SetPoint('BOTTOM', scrollDownButton, 'TOP', 0, 2)

        ScootsVendor.frames.optionsScrollFrame:SetScrollChild(ScootsVendor.frames.optionsScrollChild)
        ScootsVendor.frames.optionsScrollFrame:SetPoint('TOPLEFT', ScootsVendor.frames.options, 'TOPLEFT', 0, -5)
        ScootsVendor.frames.optionsScrollFrame:SetHeight(419)
        
        local height = 0
        
        --
        
        ScootsVendor.frames.optionsScrollChild.titleText = ScootsVendor.frames.optionsScrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
        ScootsVendor.frames.optionsScrollChild.titleText:SetPoint('TOPLEFT', ScootsVendor.frames.optionsScrollChild, 'TOPLEFT', 16, -10)
        ScootsVendor.frames.optionsScrollChild.titleText:SetText(ScootsVendor.title)
    
        ScootsVendor.frames.optionsScrollChild.versionText = ScootsVendor.frames.optionsScrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        ScootsVendor.frames.optionsScrollChild.versionText:SetPoint('BOTTOMLEFT', ScootsVendor.frames.optionsScrollChild.titleText, 'BOTTOMRIGHT', 5, 1)
        ScootsVendor.frames.optionsScrollChild.versionText:SetText(ScootsVendor.version)
        ScootsVendor.frames.optionsScrollChild.versionText:SetTextColor(0.6, 0.98, 0.6)
        
        height = height + ScootsVendor.frames.optionsScrollChild.titleText:GetHeight()
        
        --
        
        ScootsVendor.frames.draggableOption = ScootsVendor.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsVendor-Options-Draggable',
            ['parent'] = ScootsVendor.frames.optionsScrollChild,
            ['prior'] = ScootsVendor.frames.optionsScrollChild.titleText,
            ['offset'] = -10,
            ['name'] = 'Allow dragging the window',
            ['defaultState'] = ScootsVendor.options.get('drag-window'),
            ['tooltip'] = 'With this option enabled, click and drag on the title bar to move the vendor window.',
            ['onClickEvent'] = function(self)
                ScootsVendor.options.set('drag-window', (self:GetChecked() and true) or false)
            end,
        })
        
        height = height + ScootsVendor.frames.draggableOption:GetHeight() + 5
        
        --
        
        local bypassItems = ScootsVendor.options.getItemsThatBypassFilters()
        ScootsVendor.frames.itemsBypassingFiltersOptions = {}
        local prior = ScootsVendor.frames.draggableOption
        local bypassFiltersItemsState = ScootsVendor.options.get('bypass-items') or {}
        
        for _, item in ipairs(bypassItems) do
            local bypassFilterItemOption = ScootsVendor.options.insertOptionsCheckbox({
                ['framename'] = 'ScootsVendor-Options-ItemBypassingFilters-' .. tostring(item.id),
                ['parent'] = ScootsVendor.frames.optionsScrollChild,
                ['prior'] = prior,
                ['offset'] = -5,
                ['name'] = item['option-name'],
                ['defaultState'] = (bypassFiltersItemsState[item.id] == true),
                ['tooltip'] = item['option-tooltip'],
                ['onClickEvent'] = function(self)
                    bypassFiltersItemsState[item.id] = ((self:GetChecked() and true) or false)
                    ScootsVendor.options.set('bypass-items', bypassFiltersItemsState)
                end,
            })
        
            table.insert(ScootsVendor.frames.itemsBypassingFiltersOptions, bypassFilterItemOption)
            prior = bypassFilterItemOption
            
            height = height + bypassFilterItemOption:GetHeight() + 5
        end
        
        --
        
        local groupHeight
        ScootsVendor.frames.optionsDefaultFiltersGroup, groupHeight = ScootsVendor.options.insertOptionsGroup({
            ['framename'] = 'ScootsVendor-Options-DefaultFilters',
            ['parent'] = ScootsVendor.frames.optionsScrollChild,
            ['width'] = 610,
            ['title'] = 'Default filter values'
        })
        
        ScootsVendor.frames.optionsDefaultFiltersGroup:SetPoint('TOPLEFT', ScootsVendor.frames.itemsBypassingFiltersOptions[#ScootsVendor.frames.itemsBypassingFiltersOptions], 'BOTTOMLEFT', 0, -10)
        
        local defaultFilters = ScootsVendor.options.get('default-filters')
        
        --
        
        ScootsVendor.frames.defaultFiltersOptionCanAffordOnly = ScootsVendor.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsVendor-Options-DefaultFilters-CanAffordOnly',
            ['parent'] = ScootsVendor.frames.optionsDefaultFiltersGroup,
            ['prior'] = ScootsVendor.frames.optionsDefaultFiltersGroup.title,
            ['offset'] = -5,
            ['name'] = 'Can afford only',
            ['defaultState'] = defaultFilters['can-afford'],
            ['onClickEvent'] = function(self)
                defaultFilters['can-afford'] = (self:GetChecked() and true) or false
                ScootsVendor.options.set('default-filters', defaultFilters)
            end,
        })
        
        groupHeight = groupHeight + ScootsVendor.frames.defaultFiltersOptionCanAffordOnly:GetHeight() + 5
        
        --
        
        ScootsVendor.frames.defaultFiltersOptionShowNonEquipment = ScootsVendor.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsVendor-Options-DefaultFilters-ShowNonEquipment',
            ['parent'] = ScootsVendor.frames.optionsDefaultFiltersGroup,
            ['prior'] = ScootsVendor.frames.defaultFiltersOptionCanAffordOnly,
            ['offset'] = -5,
            ['name'] = 'Show non-equipment',
            ['defaultState'] = defaultFilters['show-non-equipment'],
            ['onClickEvent'] = function(self)
                defaultFilters['show-non-equipment'] = (self:GetChecked() and true) or false
                ScootsVendor.options.set('default-filters', defaultFilters)
            end,
        })
        
        groupHeight = groupHeight + ScootsVendor.frames.defaultFiltersOptionShowNonEquipment:GetHeight() + 5
        
        --
        
        ScootsVendor.frames.defaultFiltersOptionExcludeItemsInBag = ScootsVendor.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsVendor-Options-DefaultFilters-ExcludeItemsInBag',
            ['parent'] = ScootsVendor.frames.optionsDefaultFiltersGroup,
            ['prior'] = ScootsVendor.frames.defaultFiltersOptionShowNonEquipment,
            ['offset'] = -5,
            ['name'] = 'Exclude items in bag',
            ['defaultState'] = defaultFilters['exclude-items-in-bag'],
            ['onClickEvent'] = function(self)
                defaultFilters['exclude-items-in-bag'] = (self:GetChecked() and true) or false
                ScootsVendor.options.set('default-filters', defaultFilters)
            end,
        })
        
        groupHeight = groupHeight + ScootsVendor.frames.defaultFiltersOptionExcludeItemsInBag:GetHeight() + 5
        
        --
        
        ScootsVendor.frames.defaultFiltersOptionExcludeLearned = ScootsVendor.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsVendor-Options-DefaultFilters-ExcludeLearned',
            ['parent'] = ScootsVendor.frames.optionsDefaultFiltersGroup,
            ['prior'] = ScootsVendor.frames.defaultFiltersOptionExcludeItemsInBag,
            ['offset'] = -5,
            ['name'] = 'Exclude learned',
            ['defaultState'] = defaultFilters['exclude-learned'],
            ['onClickEvent'] = function(self)
                defaultFilters['exclude-learned'] = (self:GetChecked() and true) or false
                ScootsVendor.options.set('default-filters', defaultFilters)
            end,
        })
        
        groupHeight = groupHeight + ScootsVendor.frames.defaultFiltersOptionExcludeLearned:GetHeight() + 5
        
        --
        
        ScootsVendor.frames.optionsScrollChild.defaultFiltersAttuneableHeader, ScootsVendor.frames.optionsDefaultFiltersAttuneable = ScootsVendor.options.insertOptionsRadio({
            ['framenameprefix'] = 'ScootsVendor-Options-DefaultFilters-Attuneable-',
            ['parent'] = ScootsVendor.frames.optionsDefaultFiltersGroup,
            ['prior'] = ScootsVendor.frames.defaultFiltersOptionExcludeLearned,
            ['offset'] = -5,
            ['internalOffset'] = 5,
            ['name'] = 'Show attuneable equipment',
            ['onClickEvent'] = function(choice)
                defaultFilters['attuneable'] = choice.value
                ScootsVendor.options.set('default-filters', defaultFilters)
            end,
            ['choices'] = {
                {
                    ['framenamesuffix'] = 'Character',
                    ['name'] = 'Character',
                    ['value'] = 'character',
                },
                {
                    ['framenamesuffix'] = 'Account',
                    ['name'] = 'Account + BoE',
                    ['value'] = 'account',
                },
                {
                    ['framenamesuffix'] = 'All',
                    ['name'] = 'All',
                    ['value'] = 'all',
                },
            },
            ['defaultState'] = defaultFilters['attuneable'],
        })
        
        groupHeight = groupHeight + ScootsVendor.frames.optionsScrollChild.defaultFiltersAttuneableHeader:GetHeight() + 5
        
        for checkboxIndex, checkbox in pairs(ScootsVendor.frames.optionsDefaultFiltersAttuneable) do
            groupHeight = groupHeight + checkbox:GetHeight()
            
            if(checkboxIndex > 1) then
                groupHeight = groupHeight - 5
            end
        end
        
        --
        
        ScootsVendor.frames.optionsScrollChild.defaultFiltersAttunedAtHeader, ScootsVendor.frames.optionsDefaultFiltersAttunedAt = ScootsVendor.options.insertOptionsRadio({
            ['framenameprefix'] = 'ScootsVendor-Options-DefaultFilters-AttunedAt-',
            ['parent'] = ScootsVendor.frames.optionsDefaultFiltersGroup,
            ['prior'] = ScootsVendor.frames.optionsDefaultFiltersAttuneable[#ScootsVendor.frames.optionsDefaultFiltersAttuneable],
            ['offset'] = -5,
            ['internalOffset'] = 5,
            ['name'] = 'Show equipment attuned at',
            ['onClickEvent'] = function(choice)
                defaultFilters['attuned-level'] = choice.value
                ScootsVendor.options.set('default-filters', defaultFilters)
            end,
            ['choices'] = {
                {
                    ['framenamesuffix'] = 'NotAttuned',
                    ['name'] = 'Unattuned',
                    ['value'] = -1,
                },
                {
                    ['framenamesuffix'] = 'Baseline',
                    ['name'] = 'Up to baseline',
                    ['value'] = 0,
                },
                {
                    ['framenamesuffix'] = 'Titanforged',
                    ['name'] = 'Up to titanforged',
                    ['value'] = 1,
                },
                {
                    ['framenamesuffix'] = 'Warforged',
                    ['name'] = 'Up to warforged',
                    ['value'] = 2,
                },
                {
                    ['framenamesuffix'] = 'Lightforged',
                    ['name'] = 'Up to lightforged',
                    ['value'] = 3,
                },
            },
            ['defaultState'] = defaultFilters['attuned-level'],
        })
        
        groupHeight = groupHeight + ScootsVendor.frames.optionsScrollChild.defaultFiltersAttunedAtHeader:GetHeight() + 5
        
        for checkboxIndex, checkbox in pairs(ScootsVendor.frames.optionsDefaultFiltersAttunedAt) do
            groupHeight = groupHeight + checkbox:GetHeight()
            
            if(checkboxIndex > 1) then
                groupHeight = groupHeight - 5
            end
        end
        
        ScootsVendor.frames.optionsDefaultFiltersGroup:SetHeight(groupHeight)
        
        height = height + groupHeight
        
        --
    
        ScootsVendor.frames.optionsScrollChild.defaultDisclaimer = ScootsVendor.frames.optionsScrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        ScootsVendor.frames.optionsScrollChild.defaultDisclaimer:SetPoint('TOPLEFT', ScootsVendor.frames.optionsDefaultFiltersGroup, 'BOTTOMLEFT', 0, 0)
        ScootsVendor.frames.optionsScrollChild.defaultDisclaimer:SetText('* Changes to default filter settings will apply after your next reload.' .. '\n ')
        
        height = height + ScootsVendor.frames.optionsScrollChild.defaultDisclaimer:GetHeight()
        
        --
    
        ScootsVendor.frames.optionsScrollChild:SetHeight(height)
        
        if(height <= ScootsVendor.frames.optionsScrollFrame:GetHeight()) then
            scrollBar:Hide()
        else
            scrollBar:Show()
        end
        
        ScootsVendor.options.built = true
    end)
end

ScootsVendor.options.insertOptionsGroup = function(data)
    local groupFrame = CreateFrame('Frame', data.framename, data.parent)
    
    groupFrame:SetWidth(data.width)
    groupFrame:SetBackdrop({
        bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
        edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {
            left = 5,
            right = 5,
            top = 5,
            bottom = 5,
        },
    })
    groupFrame:SetBackdropColor(0, 0, 0, 0.2)
    groupFrame:SetBackdropBorderColor(1, 1, 1, 0.5)
    
    groupFrame.title = groupFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    groupFrame.title:SetPoint('TOPLEFT', groupFrame, 'TOPLEFT', 10, -10)
    groupFrame.title:SetText(data.title)
    
    return groupFrame, groupFrame.title:GetHeight() + 20
end

ScootsVendor.options.insertOptionsCheckbox = function(data)
    local checkbox = CreateFrame('CheckButton', data.framename, data.parent, 'UICheckButtonTemplate')
    checkbox:SetSize(28, 28)
    checkbox:SetPoint('TOPLEFT', data.prior, 'BOTTOMLEFT', 0, data.offset)
    
    _G[checkbox:GetName() .. 'Text']:SetFontObject('GameFontNormal')
    _G[checkbox:GetName() .. 'Text']:SetText(data.name)
    _G[checkbox:GetName() .. 'Text']:ClearAllPoints()
    _G[checkbox:GetName() .. 'Text']:SetPoint('LEFT', checkbox, 'RIGHT', 0, 0)
    
    checkbox:SetHitRectInsets(0, 0 - _G[checkbox:GetName() .. 'Text']:GetWidth(), 0, 0)
    checkbox:SetChecked(data.defaultState)
    
    if(data.tooltip ~= nil) then
        checkbox:SetScript('OnEnter', function()
            GameTooltip:SetOwner(checkbox, 'ANCHOR_TOPLEFT')
            GameTooltip:SetText(data.tooltip, nil, nil, nil, nil, 1)
            GameTooltip:Show()
        end)
        
        checkbox:SetScript('OnLeave', GameTooltip_Hide)
    end
    
    checkbox:SetScript('OnClick', data.onClickEvent)
    
    return checkbox
end

ScootsVendor.options.insertOptionsRadio = function(data)
    local header = data.parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    header:SetPoint('TOPLEFT', data.prior, 'BOTTOMLEFT', 0, data.offset)
    header:SetJustifyH('LEFT')
    header:SetText(data.name)
    
    local prior = header
    local checkboxes = {}
    local index = 1
    for _, choice in ipairs(data.choices) do
        local offset = data.internalOffset
        if(index == 1) then
            offset = 0
        end
    
        local checkbox = ScootsVendor.options.insertOptionsCheckbox({
            ['framename'] = data.framenameprefix .. choice.framenamesuffix,
            ['parent'] = data.parent,
            ['prior'] = prior,
            ['offset'] = offset,
            ['name'] = choice.name,
            ['defaultState'] = choice.value == data.defaultState,
            ['onClickEvent'] = function(self)
                self:Disable()
            
                for _, otherCheckbox in pairs(checkboxes) do
                    if(otherCheckbox:GetName() ~= self:GetName()) then
                        otherCheckbox:SetChecked(false)
                        otherCheckbox:Enable()
                    end
                end
                
                data.onClickEvent(choice)
            end,
        })
        
        if(choice.value == data.defaultState) then
            checkbox:Disable()
        end
        
        prior = checkbox
        table.insert(checkboxes, checkbox)
        index = index + 1
    end
    
    return header, checkboxes
end

ScootsVendor.options.getItemsThatBypassFilters = function()
    return {
        {
            ['id'] = 47241, -- Emblem of Triumph
            ['option-name'] = 'Emblem of Triumph bypasses filters',
            ['option-tooltip'] = 'With this option enabled, the "Show non-equipment" filter will always allow Emblem of Triumph to show.',
        },
        {
            ['id'] = 44115, -- Wintergrasp Commendation
            ['option-name'] = 'Wintergrasp Commendation bypasses filters',
            ['option-tooltip'] = 'With this option enabled, the "Show non-equipment" and "Exclude items in bag" filters will always allow Wintergrasp Commendation to show.',
        },
        {
            ['id'] = 63646, -- Wintergrasp Commendation x10
            ['option-name'] = 'Wintergrasp Commendation x10 bypasses filters',
            ['option-tooltip'] = 'With this option enabled, the "Show non-equipment" and "Exclude items in bag" filters will always allow Wintergrasp Commendation x10 to show.',
        },
        {
            ['id'] = 60244, -- Commendation of Valor
            ['option-name'] = 'Commendation of Valor bypasses filters',
            ['option-tooltip'] = 'With this option enabled, the "Show non-equipment" and "Exclude items in bag" filters will always allow Commendation of Valor to show.',
        },
        {
            ['id'] = 63647, -- Commendation of Valor x10
            ['option-name'] = 'Commendation of Valor x10 bypasses filters',
            ['option-tooltip'] = 'With this option enabled, the "Show non-equipment" and "Exclude items in bag" filters will always allow Commendation of Valor x10 to show.',
        },
        {
            ['id'] = 60232, -- Mystery Box
            ['option-name'] = 'Mystery Box bypasses filters',
            ['option-tooltip'] = 'With this option enabled, the "Show non-equipment" and "Exclude items in bag" filters will always allow Mystery Box to show.',
        },
        {
            ['id'] = 21215, -- Graccu's Mince Meat Fruitcake
            ['option-name'] = 'Graccu\'s Mince Meat Fruitcake bypasses filters',
            ['option-tooltip'] = 'With this option enabled, the "Show non-equipment" and "Exclude items in bag" filters will always allow Graccu\'s Mince Meat Fruitcake to show.',
        },
        {
            ['id'] = 42225, -- Dragon's Eye
            ['option-name'] = 'Dragon\'s Eye bypasses filters',
            ['option-tooltip'] = 'With this option enabled, the "Show non-equipment" and "Exclude items in bag" filters will always allow Dragon\'s Eye to show.',
        },
    }
end