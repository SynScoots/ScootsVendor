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
        ['auto-sell-destroy-unsellable'] = false,
        ['auto-sell-grey-white'] = false,
        ['always-sell'] = {},
        ['never-sell'] = {
            [9149] = true, -- Philosopher's Stone
            [20406] = true, -- Twilight Cultist Mantle
            [20407] = true, -- Twilight Cultist Robe
            [20408] = true, -- Twilight Cultist Cowl
        },
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
    
    InterfaceOptionsFrame:SetWidth(math.max(900, InterfaceOptionsFrame:GetWidth()))
    
    ScootsVendor.options.buildGeneralOptions()
    ScootsVendor.options.buildDefaultFilterOptions()
    ScootsVendor.options.buildAutoSellOptions()
end

ScootsVendor.options.buildGeneralOptions = function()
    ScootsVendor.frames.options = CreateFrame('Frame', 'ScootsVendor-Options', UIParent)
    ScootsVendor.frames.options.name = ScootsVendor.title
    InterfaceOptions_AddCategory(ScootsVendor.frames.options)
    
    ScootsVendor.frames.options:HookScript('OnShow', function()
        if(ScootsVendor.options.builtGeneral ~= nil) then
            return nil
        end
        
        ScootsVendor.frames.optionsScrollFrame = CreateFrame('ScrollFrame', 'ScootsVendor-Options-ScrollFrame', ScootsVendor.frames.options, 'UIPanelScrollFrameTemplate')
        ScootsVendor.frames.optionsScrollFrame:SetWidth(663)
    
        ScootsVendor.frames.optionsScrollChild = CreateFrame('Frame', 'ScootsVendor-Options-ScrollChild', ScootsVendor.frames.optionsScrollFrame)
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
    
        ScootsVendor.frames.optionsScrollChild:SetHeight(height)
        
        if(height <= ScootsVendor.frames.optionsScrollFrame:GetHeight()) then
            scrollBar:Hide()
        else
            scrollBar:Show()
        end
        
        ScootsVendor.options.builtGeneral = true
    end)
end

ScootsVendor.options.buildDefaultFilterOptions = function()
    ScootsVendor.frames.defaultFilterOptions = CreateFrame('Frame', 'ScootsVendor-Options-DefaultFilters', UIParent)
    ScootsVendor.frames.defaultFilterOptions.parent = ScootsVendor.title
    ScootsVendor.frames.defaultFilterOptions.name = 'Default filters'
    InterfaceOptions_AddCategory(ScootsVendor.frames.defaultFilterOptions)
    
    ScootsVendor.frames.defaultFilterOptions:HookScript('OnShow', function()
        if(ScootsVendor.options.builtDefaultFilters ~= nil) then
            return nil
        end
        
        ScootsVendor.frames.defaultFilterOptionsScrollFrame = CreateFrame('ScrollFrame', 'ScootsVendor-Options-DefaultFilters-ScrollFrame', ScootsVendor.frames.defaultFilterOptions, 'UIPanelScrollFrameTemplate')
        ScootsVendor.frames.defaultFilterOptionsScrollFrame:SetWidth(663)
    
        ScootsVendor.frames.defaultFilterOptionsScrollChild = CreateFrame('Frame', 'ScootsVendor-Options-DefaultFilters-ScrollChild', ScootsVendor.frames.defaultFilterOptionsScrollFrame)
        ScootsVendor.frames.defaultFilterOptionsScrollChild:SetWidth(ScootsVendor.frames.defaultFilterOptionsScrollFrame:GetWidth())
        
        local scrollBarName = ScootsVendor.frames.defaultFilterOptionsScrollFrame:GetName()
        local scrollBar = _G[scrollBarName .. 'ScrollBar']
        local scrollUpButton = _G[scrollBarName .. 'ScrollBarScrollUpButton']
        local scrollDownButton = _G[scrollBarName .. 'ScrollBarScrollDownButton']

        scrollUpButton:ClearAllPoints()
        scrollUpButton:SetPoint('TOPRIGHT', ScootsVendor.frames.defaultFilterOptionsScrollFrame, 'TOPRIGHT', -2, -2)

        scrollDownButton:ClearAllPoints()
        scrollDownButton:SetPoint('BOTTOMRIGHT', ScootsVendor.frames.defaultFilterOptionsScrollFrame, 'BOTTOMRIGHT', -2, 2)

        scrollBar:ClearAllPoints()
        scrollBar:SetPoint('TOP', scrollUpButton, 'BOTTOM', 0, -2)
        scrollBar:SetPoint('BOTTOM', scrollDownButton, 'TOP', 0, 2)

        ScootsVendor.frames.defaultFilterOptionsScrollFrame:SetScrollChild(ScootsVendor.frames.defaultFilterOptionsScrollChild)
        ScootsVendor.frames.defaultFilterOptionsScrollFrame:SetPoint('TOPLEFT', ScootsVendor.frames.defaultFilterOptions, 'TOPLEFT', 0, -5)
        ScootsVendor.frames.defaultFilterOptionsScrollFrame:SetHeight(419)
        
        local height = 0
        
        --
        
        ScootsVendor.frames.defaultFilterOptionsScrollChild.titleText = ScootsVendor.frames.defaultFilterOptionsScrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
        ScootsVendor.frames.defaultFilterOptionsScrollChild.titleText:SetPoint('TOPLEFT', ScootsVendor.frames.defaultFilterOptionsScrollChild, 'TOPLEFT', 16, -10)
        ScootsVendor.frames.defaultFilterOptionsScrollChild.titleText:SetText(ScootsVendor.title)
    
        ScootsVendor.frames.defaultFilterOptionsScrollChild.versionText = ScootsVendor.frames.defaultFilterOptionsScrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        ScootsVendor.frames.defaultFilterOptionsScrollChild.versionText:SetPoint('BOTTOMLEFT', ScootsVendor.frames.defaultFilterOptionsScrollChild.titleText, 'BOTTOMRIGHT', 5, 1)
        ScootsVendor.frames.defaultFilterOptionsScrollChild.versionText:SetText(ScootsVendor.version)
        ScootsVendor.frames.defaultFilterOptionsScrollChild.versionText:SetTextColor(0.6, 0.98, 0.6)
        
        height = height + ScootsVendor.frames.defaultFilterOptionsScrollChild.titleText:GetHeight()
        
        --
        
        ScootsVendor.frames.defaultFilterOptionsScrollChild.subTitle = ScootsVendor.frames.defaultFilterOptionsScrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        ScootsVendor.frames.defaultFilterOptionsScrollChild.subTitle:SetPoint('TOPLEFT', ScootsVendor.frames.defaultFilterOptionsScrollChild.titleText, 'BOTTOMLEFT', 0, -2)
        ScootsVendor.frames.defaultFilterOptionsScrollChild.subTitle:SetText('Default filter values')
        
        height = height + ScootsVendor.frames.defaultFilterOptionsScrollChild.subTitle:GetHeight()
        
        --
    
        ScootsVendor.frames.defaultFilterOptionsScrollChild.defaultDisclaimer = ScootsVendor.frames.defaultFilterOptionsScrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        ScootsVendor.frames.defaultFilterOptionsScrollChild.defaultDisclaimer:SetPoint('TOPLEFT', ScootsVendor.frames.defaultFilterOptionsScrollChild.subTitle, 'BOTTOMLEFT', 0, -2)
        ScootsVendor.frames.defaultFilterOptionsScrollChild.defaultDisclaimer:SetText('* Changes to default filter settings will apply after your next reload.')
        
        height = height + ScootsVendor.frames.defaultFilterOptionsScrollChild.defaultDisclaimer:GetHeight()
        
        --
        
        local defaultFilters = ScootsVendor.options.get('default-filters')
        
        --
        
        ScootsVendor.frames.defaultFiltersOptionCanAffordOnly = ScootsVendor.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsVendor-Options-DefaultFilters-CanAffordOnly',
            ['parent'] = ScootsVendor.frames.defaultFilterOptions,
            ['prior'] = ScootsVendor.frames.defaultFilterOptionsScrollChild.defaultDisclaimer,
            ['offset'] = -5,
            ['name'] = 'Can afford only',
            ['defaultState'] = defaultFilters['can-afford'],
            ['onClickEvent'] = function(self)
                defaultFilters['can-afford'] = (self:GetChecked() and true) or false
                ScootsVendor.options.set('default-filters', defaultFilters)
            end,
        })
        
        height = height + ScootsVendor.frames.defaultFiltersOptionCanAffordOnly:GetHeight() + 5
        
        --
        
        ScootsVendor.frames.defaultFiltersOptionShowNonEquipment = ScootsVendor.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsVendor-Options-DefaultFilters-ShowNonEquipment',
            ['parent'] = ScootsVendor.frames.defaultFilterOptions,
            ['prior'] = ScootsVendor.frames.defaultFiltersOptionCanAffordOnly,
            ['offset'] = -5,
            ['name'] = 'Show non-equipment',
            ['defaultState'] = defaultFilters['show-non-equipment'],
            ['onClickEvent'] = function(self)
                defaultFilters['show-non-equipment'] = (self:GetChecked() and true) or false
                ScootsVendor.options.set('default-filters', defaultFilters)
            end,
        })
        
        height = height + ScootsVendor.frames.defaultFiltersOptionShowNonEquipment:GetHeight() + 5
        
        --
        
        ScootsVendor.frames.defaultFiltersOptionExcludeItemsInBag = ScootsVendor.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsVendor-Options-DefaultFilters-ExcludeItemsInBag',
            ['parent'] = ScootsVendor.frames.defaultFilterOptions,
            ['prior'] = ScootsVendor.frames.defaultFiltersOptionShowNonEquipment,
            ['offset'] = -5,
            ['name'] = 'Exclude items in bag',
            ['defaultState'] = defaultFilters['exclude-items-in-bag'],
            ['onClickEvent'] = function(self)
                defaultFilters['exclude-items-in-bag'] = (self:GetChecked() and true) or false
                ScootsVendor.options.set('default-filters', defaultFilters)
            end,
        })
        
        height = height + ScootsVendor.frames.defaultFiltersOptionExcludeItemsInBag:GetHeight() + 5
        
        --
        
        ScootsVendor.frames.defaultFiltersOptionExcludeLearned = ScootsVendor.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsVendor-Options-DefaultFilters-ExcludeLearned',
            ['parent'] = ScootsVendor.frames.defaultFilterOptions,
            ['prior'] = ScootsVendor.frames.defaultFiltersOptionExcludeItemsInBag,
            ['offset'] = -5,
            ['name'] = 'Exclude learned',
            ['defaultState'] = defaultFilters['exclude-learned'],
            ['onClickEvent'] = function(self)
                defaultFilters['exclude-learned'] = (self:GetChecked() and true) or false
                ScootsVendor.options.set('default-filters', defaultFilters)
            end,
        })
        
        height = height + ScootsVendor.frames.defaultFiltersOptionExcludeLearned:GetHeight() + 5
        
        --
        
        ScootsVendor.frames.defaultFilterOptionsScrollChild.defaultFiltersAttuneableHeader, ScootsVendor.frames.optionsDefaultFiltersAttuneable = ScootsVendor.options.insertOptionsRadio({
            ['framenameprefix'] = 'ScootsVendor-Options-DefaultFilters-Attuneable-',
            ['parent'] = ScootsVendor.frames.defaultFilterOptions,
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
        
        height = height + ScootsVendor.frames.defaultFilterOptionsScrollChild.defaultFiltersAttuneableHeader:GetHeight() + 5
        
        for checkboxIndex, checkbox in pairs(ScootsVendor.frames.optionsDefaultFiltersAttuneable) do
            height = height + checkbox:GetHeight()
            
            if(checkboxIndex > 1) then
                height = height - 5
            end
        end
        
        --
        
        ScootsVendor.frames.defaultFilterOptionsScrollChild.defaultFiltersAttunedAtHeader, ScootsVendor.frames.optionsDefaultFiltersAttunedAt = ScootsVendor.options.insertOptionsRadio({
            ['framenameprefix'] = 'ScootsVendor-Options-DefaultFilters-AttunedAt-',
            ['parent'] = ScootsVendor.frames.defaultFilterOptions,
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
        
        height = height + ScootsVendor.frames.defaultFilterOptionsScrollChild.defaultFiltersAttunedAtHeader:GetHeight() + 5
        
        for checkboxIndex, checkbox in pairs(ScootsVendor.frames.optionsDefaultFiltersAttunedAt) do
            height = height + checkbox:GetHeight()
            
            if(checkboxIndex > 1) then
                height = height - 5
            end
        end
        
        --
    
        ScootsVendor.frames.defaultFilterOptionsScrollChild:SetHeight(height)
        
        if(height <= ScootsVendor.frames.defaultFilterOptionsScrollFrame:GetHeight()) then
            scrollBar:Hide()
        else
            scrollBar:Show()
        end
        
        ScootsVendor.options.builtDefaultFilters = true
    end)
end

ScootsVendor.options.buildAutoSellOptions = function()
    ScootsVendor.frames.autoSellOptions = CreateFrame('Frame', 'ScootsVendor-Options-AutoSell', UIParent)
    ScootsVendor.frames.autoSellOptions.parent = ScootsVendor.title
    ScootsVendor.frames.autoSellOptions.name = 'Auto-sell'
    InterfaceOptions_AddCategory(ScootsVendor.frames.autoSellOptions)
    
    ScootsVendor.frames.autoSellOptions:HookScript('OnShow', function()
        if(ScootsVendor.options.builtAutoSell ~= nil) then
            return nil
        end
        
        ScootsVendor.frames.autoSellOptionsScrollFrame = CreateFrame('ScrollFrame', 'ScootsVendor-Options-AutoSell-ScrollFrame', ScootsVendor.frames.autoSellOptions, 'UIPanelScrollFrameTemplate')
        ScootsVendor.frames.autoSellOptionsScrollFrame:SetWidth(663)
    
        ScootsVendor.frames.autoSellOptionsScrollChild = CreateFrame('Frame', 'ScootsVendor-Options-AutoSell-ScrollChild', ScootsVendor.frames.autoSellOptionsScrollFrame)
        ScootsVendor.frames.autoSellOptionsScrollChild:SetWidth(ScootsVendor.frames.autoSellOptionsScrollFrame:GetWidth())
        
        local scrollBarName = ScootsVendor.frames.autoSellOptionsScrollFrame:GetName()
        local scrollBar = _G[scrollBarName .. 'ScrollBar']
        local scrollUpButton = _G[scrollBarName .. 'ScrollBarScrollUpButton']
        local scrollDownButton = _G[scrollBarName .. 'ScrollBarScrollDownButton']

        scrollUpButton:ClearAllPoints()
        scrollUpButton:SetPoint('TOPRIGHT', ScootsVendor.frames.autoSellOptionsScrollFrame, 'TOPRIGHT', -2, -2)

        scrollDownButton:ClearAllPoints()
        scrollDownButton:SetPoint('BOTTOMRIGHT', ScootsVendor.frames.autoSellOptionsScrollFrame, 'BOTTOMRIGHT', -2, 2)

        scrollBar:ClearAllPoints()
        scrollBar:SetPoint('TOP', scrollUpButton, 'BOTTOM', 0, -2)
        scrollBar:SetPoint('BOTTOM', scrollDownButton, 'TOP', 0, 2)

        ScootsVendor.frames.autoSellOptionsScrollFrame:SetScrollChild(ScootsVendor.frames.autoSellOptionsScrollChild)
        ScootsVendor.frames.autoSellOptionsScrollFrame:SetPoint('TOPLEFT', ScootsVendor.frames.autoSellOptions, 'TOPLEFT', 0, -5)
        ScootsVendor.frames.autoSellOptionsScrollFrame:SetHeight(419)
        
        local height = 0
        
        --
        
        ScootsVendor.frames.autoSellOptionsScrollChild.titleText = ScootsVendor.frames.autoSellOptionsScrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
        ScootsVendor.frames.autoSellOptionsScrollChild.titleText:SetPoint('TOPLEFT', ScootsVendor.frames.autoSellOptionsScrollChild, 'TOPLEFT', 16, -10)
        ScootsVendor.frames.autoSellOptionsScrollChild.titleText:SetText(ScootsVendor.title)
    
        ScootsVendor.frames.autoSellOptionsScrollChild.versionText = ScootsVendor.frames.autoSellOptionsScrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        ScootsVendor.frames.autoSellOptionsScrollChild.versionText:SetPoint('BOTTOMLEFT', ScootsVendor.frames.autoSellOptionsScrollChild.titleText, 'BOTTOMRIGHT', 5, 1)
        ScootsVendor.frames.autoSellOptionsScrollChild.versionText:SetText(ScootsVendor.version)
        ScootsVendor.frames.autoSellOptionsScrollChild.versionText:SetTextColor(0.6, 0.98, 0.6)
        
        height = height + ScootsVendor.frames.autoSellOptionsScrollChild.titleText:GetHeight()
        
        --
        
        ScootsVendor.frames.autoSellOptionsScrollChild.subTitle = ScootsVendor.frames.autoSellOptionsScrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        ScootsVendor.frames.autoSellOptionsScrollChild.subTitle:SetPoint('TOPLEFT', ScootsVendor.frames.autoSellOptionsScrollChild.titleText, 'BOTTOMLEFT', 0, -2)
        ScootsVendor.frames.autoSellOptionsScrollChild.subTitle:SetText('Auto-sell options')
        
        height = height + ScootsVendor.frames.autoSellOptionsScrollChild.subTitle:GetHeight()
        
        --
        
        if(AHIgnoreList ~= nil) then
            ScootsVendor.frames.importFromAttuneHelperButton = CreateFrame('Button', 'ScootsVendor-RemoveFromNeverSell', ScootsVendor.frames.autoSellOptionsScrollChild, 'UIPanelButtonTemplate')
            ScootsVendor.frames.importFromAttuneHelperButton:SetSize(100, 38)
            ScootsVendor.frames.importFromAttuneHelperButton:SetPoint('TOPRIGHT', ScootsVendor.frames.autoSellOptionsScrollChild, 'TOPRIGHT', -6, -2)
            ScootsVendor.frames.importFromAttuneHelperButton:SetText('Import from\nAttune Helper')
            
            ScootsVendor.frames.importFromAttuneHelperButton:SetScript('OnClick', ScootsVendor.options.importFromAttuneHelper)
        end
        
        --
        
        ScootsVendor.frames.autoSellDestroyUnsellable = ScootsVendor.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsVendor-Options-DefaultFilters-DestroyUnsellable',
            ['parent'] = ScootsVendor.frames.autoSellOptionsScrollChild,
            ['prior'] = ScootsVendor.frames.autoSellOptionsScrollChild.subTitle,
            ['offset'] = -5,
            ['name'] = 'Destroy relevant items which can\'t be sold',
            ['defaultState'] = ScootsVendor.options.get('auto-sell-destroy-unsellable'),
            ['onClickEvent'] = function(self)
                ScootsVendor.options.set('auto-sell-destroy-unsellable', (self:GetChecked() and true) or false)
            end,
        })
        
        height = height + ScootsVendor.frames.autoSellDestroyUnsellable:GetHeight() + 5
        
        --
        
        ScootsVendor.frames.autoSellGreyWhite = ScootsVendor.options.insertOptionsCheckbox({
            ['framename'] = 'ScootsVendor-Options-DefaultFilters-AutoSellGreyWhite',
            ['parent'] = ScootsVendor.frames.autoSellOptionsScrollChild,
            ['prior'] = ScootsVendor.frames.autoSellDestroyUnsellable,
            ['offset'] = -5,
            ['name'] = 'Auto-sell grey/white items',
            ['defaultState'] = ScootsVendor.options.get('auto-sell-grey-white'),
            ['onClickEvent'] = function(self)
                ScootsVendor.options.set('auto-sell-grey-white', (self:GetChecked() and true) or false)
            end,
        })
        
        height = height + ScootsVendor.frames.autoSellGreyWhite:GetHeight() + 5
        
        -- ########### --
        
        local leftGroupHeight
        ScootsVendor.frames.alwaysSellGroup, leftGroupHeight = ScootsVendor.options.insertOptionsGroup({
            ['framename'] = 'ScootsVendor-Options-AlwaysSellGroup',
            ['parent'] = ScootsVendor.frames.autoSellOptionsScrollChild,
            ['width'] = 310,
            ['title'] = 'Always sell items'
        })
        
        ScootsVendor.frames.alwaysSellGroup:SetPoint('TOPLEFT', ScootsVendor.frames.autoSellGreyWhite, 'BOTTOMLEFT', 0, -2)
        
        --
        
        ScootsVendor.frames.alwaysSellItemCatcher = ScootsVendor.options.insertItemCatcher({
            ['framename'] = 'ScootsVendor-Options-AlwaysSellCatcher',
            ['parent'] = ScootsVendor.frames.alwaysSellGroup,
            ['prior'] = ScootsVendor.frames.alwaysSellGroup.title,
            ['text'] = 'Drop item here to add to list',
            ['callback'] = function(id, link)
                local dropType, itemId, itemLink = GetCursorInfo()
                ClearCursor()
                
                if(dropType == 'item') then
                    local alwaysSellList = ScootsVendor.options.get('always-sell')
                    
                    if(alwaysSellList[itemId]) then
                        ScootsVendor.pushMessage(itemLink .. ' already in "always sell" list.')
                        return nil
                    end
                    
                    alwaysSellList[itemId] = true
                    ScootsVendor.options.set('always-sell', alwaysSellList)
                    ScootsVendor.pushMessage(itemLink .. ' added to "always sell" list.')
                    
                    local neverSellList = ScootsVendor.options.get('never-sell')
                    if(neverSellList[itemId]) then
                        neverSellList[itemId] = nil
                        ScootsVendor.options.set('never-sell', neverSellList)
                        ScootsVendor.pushMessage(itemLink .. ' removed from "never sell" list.')
                    end
                    
                    ScootsVendor.options.updateAutoSellLists()
                end
            end
        })
        
        leftGroupHeight = leftGroupHeight + ScootsVendor.frames.alwaysSellItemCatcher:GetHeight() + 10
        
        --
        
        ScootsVendor.frames.alwaysSellItemList = ScootsVendor.options.insertItemList({
            ['framename'] = 'ScootsVendor-Options-AlwaysSellList',
            ['parent'] = ScootsVendor.frames.alwaysSellGroup,
            ['prior'] = ScootsVendor.frames.alwaysSellItemCatcher,
            ['height'] = 200,
            ['childCount'] = 10,
            ['getItemsCallback'] = function()
                local alwaysSellObject = ScootsVendor.options.get('always-sell')
                local itemList = {}
                local clearSelected = true
                
                for itemId, _ in pairs(alwaysSellObject) do
                    table.insert(itemList, itemId)
                    
                    if(ScootsVendor.frames.alwaysSellItemList.selectedItemId == itemId) then
                        clearSelected = false
                    end
                end
                
                table.sort(itemList, function(itemIdA, itemIdB)
                    return (select(1, GetItemInfoCustom(itemIdA))) < (GetItemInfoCustom(itemIdB))
                end)
                
                if(clearSelected) then
                    ScootsVendor.frames.alwaysSellItemList.selectedItemId = nil
                    ScootsVendor.frames.removeFromAlwaysSell:Disable()
                end
                
                return itemList
            end,
            ['selectItemCallback'] = function()
                ScootsVendor.frames.removeFromAlwaysSell:Enable()
            end,
        })
        
        leftGroupHeight = leftGroupHeight + ScootsVendor.frames.alwaysSellItemList:GetHeight() + 12
        
        --
        
        ScootsVendor.frames.removeFromAlwaysSell = CreateFrame('Button', 'ScootsVendor-RemoveFromAlwaysSell', ScootsVendor.frames.alwaysSellGroup, 'UIPanelButtonTemplate')
        ScootsVendor.frames.removeFromAlwaysSell:SetSize(120, 19)
        ScootsVendor.frames.removeFromAlwaysSell:SetPoint('TOPLEFT', ScootsVendor.frames.alwaysSellItemList, 'BOTTOMLEFT', 0, -4)
        ScootsVendor.frames.removeFromAlwaysSell:SetText('Remove selected')
        ScootsVendor.frames.removeFromAlwaysSell:Disable()
        
        ScootsVendor.frames.removeFromAlwaysSell:SetScript('OnClick', function()
            local alwaysSellList = ScootsVendor.options.get('always-sell')
            local itemId = ScootsVendor.frames.alwaysSellItemList.selectedItemId
            
            if(alwaysSellList[itemId]) then
                local itemLink = select(2, GetItemInfoCustom(itemId))
            
                alwaysSellList[itemId] = nil
                ScootsVendor.options.set('always-sell', alwaysSellList)
                ScootsVendor.pushMessage(itemLink .. ' removed from "always sell" list.')
            end
            
            ScootsVendor.frames.removeFromAlwaysSell:Disable()
            ScootsVendor.frames.alwaysSellItemList.dataChanged()
        end)
        
        leftGroupHeight = leftGroupHeight + ScootsVendor.frames.removeFromAlwaysSell:GetHeight() + 3
        
        -- ########### --
        
        local rightGroupHeight
        ScootsVendor.frames.neverSellGroup, rightGroupHeight = ScootsVendor.options.insertOptionsGroup({
            ['framename'] = 'ScootsVendor-Options-NeverSellGroup',
            ['parent'] = ScootsVendor.frames.autoSellOptionsScrollChild,
            ['width'] = 310,
            ['title'] = 'Never sell items'
        })
        
        ScootsVendor.frames.neverSellGroup:SetPoint('TOPLEFT', ScootsVendor.frames.alwaysSellGroup, 'TOPRIGHT', 10, 0)
        
        --
        
        ScootsVendor.frames.neverSellItemCatcher = ScootsVendor.options.insertItemCatcher({
            ['framename'] = 'ScootsVendor-Options-NeverSellCatcher',
            ['parent'] = ScootsVendor.frames.neverSellGroup,
            ['prior'] = ScootsVendor.frames.neverSellGroup.title,
            ['text'] = 'Drop item here to add to list',
            ['callback'] = function(id, link)
                local dropType, itemId, itemLink = GetCursorInfo()
                ClearCursor()
                
                if(dropType == 'item') then
                    local neverSellList = ScootsVendor.options.get('never-sell')
                    
                    if(neverSellList[itemId]) then
                        ScootsVendor.pushMessage(itemLink .. ' already in "never sell" list.')
                        return nil
                    end
                    
                    neverSellList[itemId] = true
                    ScootsVendor.options.set('never-sell', neverSellList)
                    ScootsVendor.pushMessage(itemLink .. ' added to "never sell" list.')
                    
                    local alwaysSellList = ScootsVendor.options.get('always-sell')
                    if(alwaysSellList[itemId]) then
                        alwaysSellList[itemId] = nil
                        ScootsVendor.options.set('always-sell', alwaysSellList)
                        ScootsVendor.pushMessage(itemLink .. ' removed from "always sell" list.')
                    end
                    
                    ScootsVendor.options.updateAutoSellLists()
                end
            end
        })
        
        rightGroupHeight = rightGroupHeight + ScootsVendor.frames.neverSellItemCatcher:GetHeight() + 10
        
        --
        
        ScootsVendor.frames.neverSellItemList = ScootsVendor.options.insertItemList({
            ['framename'] = 'ScootsVendor-Options-NeverSellList',
            ['parent'] = ScootsVendor.frames.neverSellGroup,
            ['prior'] = ScootsVendor.frames.neverSellItemCatcher,
            ['height'] = 200,
            ['childCount'] = 10,
            ['getItemsCallback'] = function()
                local neverSellObject = ScootsVendor.options.get('never-sell')
                local itemList = {}
                local clearSelected = true
                
                for itemId, _ in pairs(neverSellObject) do
                    table.insert(itemList, itemId)
                    
                    if(ScootsVendor.frames.neverSellItemList.selectedItemId == itemId) then
                        clearSelected = false
                    end
                end
                
                table.sort(itemList, function(itemIdA, itemIdB)
                    return (select(1, GetItemInfoCustom(itemIdA))) < (GetItemInfoCustom(itemIdB))
                end)
                
                if(clearSelected) then
                    ScootsVendor.frames.neverSellItemList.selectedItemId = nil
                    ScootsVendor.frames.removeFromNeverSell:Disable()
                end
                
                return itemList
            end,
            ['selectItemCallback'] = function()
                ScootsVendor.frames.removeFromNeverSell:Enable()
            end,
        })
        
        rightGroupHeight = rightGroupHeight + ScootsVendor.frames.neverSellItemList:GetHeight() + 12
        
        --
        
        ScootsVendor.frames.removeFromNeverSell = CreateFrame('Button', 'ScootsVendor-RemoveFromNeverSell', ScootsVendor.frames.neverSellGroup, 'UIPanelButtonTemplate')
        ScootsVendor.frames.removeFromNeverSell:SetSize(120, 19)
        ScootsVendor.frames.removeFromNeverSell:SetPoint('TOPLEFT', ScootsVendor.frames.neverSellItemList, 'BOTTOMLEFT', 0, -4)
        ScootsVendor.frames.removeFromNeverSell:SetText('Remove selected')
        ScootsVendor.frames.removeFromNeverSell:Disable()
        
        ScootsVendor.frames.removeFromNeverSell:SetScript('OnClick', function()
            local neverSellList = ScootsVendor.options.get('never-sell')
            local itemId = ScootsVendor.frames.neverSellItemList.selectedItemId
            
            if(neverSellList[itemId]) then
                local itemLink = select(2, GetItemInfoCustom(itemId))
            
                neverSellList[itemId] = nil
                ScootsVendor.options.set('never-sell', neverSellList)
                ScootsVendor.pushMessage(itemLink .. ' removed from "never sell" list.')
            end
            
            ScootsVendor.frames.removeFromNeverSell:Disable()
            ScootsVendor.frames.neverSellItemList.dataChanged()
        end)
        
        rightGroupHeight = rightGroupHeight + ScootsVendor.frames.removeFromNeverSell:GetHeight() + 3
        
        -- ########### --
        
        ScootsVendor.options.updateAutoSellLists()
        ScootsVendor.frames.alwaysSellGroup:SetHeight(math.max(leftGroupHeight, rightGroupHeight))
        ScootsVendor.frames.neverSellGroup:SetHeight(math.max(leftGroupHeight, rightGroupHeight))
        height = height + math.max(leftGroupHeight, rightGroupHeight)
        
        --
    
        ScootsVendor.frames.autoSellOptionsScrollChild:SetHeight(height)
        
        if(height <= ScootsVendor.frames.autoSellOptionsScrollFrame:GetHeight()) then
            scrollBar:Hide()
        else
            scrollBar:Show()
        end
        
        ScootsVendor.options.builtAutoSell = true
    end)
end

ScootsVendor.options.updateAutoSellLists = function()
    ScootsVendor.frames.alwaysSellItemList.dataChanged()
    ScootsVendor.frames.neverSellItemList.dataChanged()
end

ScootsVendor.options.importFromAttuneHelper = function()
    if(AHIgnoreList ~= nil) then
        local alwaysSellList = ScootsVendor.options.get('always-sell')
        local neverSellList = ScootsVendor.options.get('never-sell')
        local doNameImport = false
        
        for ignoreItem, _ in pairs(AHIgnoreList) do
            local itemId = ignoreItem:match('^id:(%d+)$')
            
            if(itemId ~= nil) then
                alwaysSellList[itemId] = nil
                neverSellList[itemId] = true
            else
                doNameImport = true
            end
        end
    
        if(doNameImport) then
            for itemId = 1, MAX_ITEMID do
                local itemName = GetItemInfoCustom(itemId)
                
                if(AHIgnoreList[itemName] ~= nil) then
                    alwaysSellList[itemId] = nil
                    neverSellList[itemId] = true
                end
            end
        end
        
        ScootsVendor.options.set('always-sell', alwaysSellList)
        ScootsVendor.options.set('never-sell', neverSellList)
        ScootsVendor.options.updateAutoSellLists()
    end
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

ScootsVendor.options.insertItemCatcher = function(data)
    local catchFrame = CreateFrame('Frame', data.framename, data.parent)
    
    catchFrame:SetPoint('TOPLEFT', data.prior, 'BOTTOMLEFT', 0, -10)
    catchFrame:SetWidth(data.parent:GetWidth() - 20)
    
    catchFrame.background = catchFrame:CreateTexture(nil, 'BACKGROUND')
    catchFrame.background:SetTexture(0.25, 0.25, 0.25)
    catchFrame.background:SetAllPoints()
    
    for _, borderName in pairs({'borderTop', 'borderRight', 'borderBottom', 'borderLeft'}) do
        catchFrame[borderName] = catchFrame:CreateTexture(nil, 'BORDER')
        catchFrame[borderName]:SetTexture(0.5, 0.75, 1, 0.2)
    end
    
    catchFrame.borderTop:SetPoint('TOPLEFT', 0, 0)
    catchFrame.borderTop:SetPoint('TOPRIGHT', 0, 0)
    catchFrame.borderTop:SetHeight(1)
    
    catchFrame.borderRight:SetPoint('TOPRIGHT', 0, 0)
    catchFrame.borderRight:SetPoint('BOTTOMRIGHT', 0, 0)
    catchFrame.borderRight:SetWidth(1)
    
    catchFrame.borderBottom:SetPoint('BOTTOMLEFT', 0, 0)
    catchFrame.borderBottom:SetPoint('BOTTOMRIGHT', 0, 0)
    catchFrame.borderBottom:SetHeight(1)
    
    catchFrame.borderLeft:SetPoint('TOPLEFT', 0, 0)
    catchFrame.borderLeft:SetPoint('BOTTOMLEFT', 0, 0)
    catchFrame.borderLeft:SetWidth(1)
    
    catchFrame.text = catchFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    catchFrame.text:SetPoint('TOPLEFT', catchFrame, 'TOPLEFT', 10, -10)
    catchFrame.text:SetText(data.text)
    
    catchFrame:SetHeight(catchFrame.text:GetHeight() + 20)
    
    catchFrame:EnableMouse(true)
    catchFrame:RegisterForDrag('LeftButton')
    catchFrame:SetScript('OnReceiveDrag', data.callback)
    catchFrame:SetScript('OnMouseUp', data.callback)
    
    return catchFrame
end

ScootsVendor.options.insertItemList = function(data)
    local listFrame = CreateFrame('ScrollFrame', data.framename, data.parent, 'FauxScrollFrameTemplate')
    
    listFrame:SetPoint('TOPLEFT', data.prior, 'BOTTOMLEFT', 0, -11)
    listFrame:SetSize(data.parent:GetWidth() - 43, data.height)
    
    for _, borderName in pairs({'borderTop', 'borderRight', 'borderBottom', 'borderLeft'}) do
        listFrame[borderName] = listFrame:CreateTexture(nil, 'BORDER')
        listFrame[borderName]:SetTexture(0.5, 0.75, 1, 0.2)
    end
    
    listFrame.borderTop:SetPoint('TOPLEFT', 0, 1)
    listFrame.borderTop:SetPoint('TOPRIGHT', 23, 1)
    listFrame.borderTop:SetHeight(1)
    
    listFrame.borderRight:SetPoint('TOPRIGHT', 23, 1)
    listFrame.borderRight:SetPoint('BOTTOMRIGHT', 23, -1)
    listFrame.borderRight:SetWidth(1)
    
    listFrame.borderBottom:SetPoint('BOTTOMLEFT', 0, -1)
    listFrame.borderBottom:SetPoint('BOTTOMRIGHT', 23, -1)
    listFrame.borderBottom:SetHeight(1)
    
    listFrame.borderLeft:SetPoint('TOPLEFT', 0, 1)
    listFrame.borderLeft:SetPoint('BOTTOMLEFT', 0, -1)
    listFrame.borderLeft:SetWidth(1)
    
    local childHeight = data.height / data.childCount
    
    listFrame:SetScript('OnVerticalScroll', function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, childHeight, listFrame.updateView)
    end)
    
    listFrame.childFrames = {}
    for frameIndex = 1, data.childCount do
        local childFrame = CreateFrame('Button', data.framename .. '-Child' .. tostring(frameIndex), listFrame)
        childFrame:SetSize(listFrame:GetWidth(), childHeight)
        childFrame:SetPoint('TOPLEFT', listFrame, 'TOPLEFT', 1, 0 - (childHeight * (frameIndex - 1)))
        childFrame:EnableMouse(true)
        
        childFrame.highlight = childFrame:CreateTexture(nil, 'BACKGROUND')
        childFrame.highlight:SetAllPoints()
        childFrame.highlight:SetTexture(0.25, 0.5, 1, 0.4)
        childFrame.highlight:SetAlpha(0)
        
        childFrame.selected = childFrame:CreateTexture(nil, 'ARTWORK')
        childFrame.selected:SetAllPoints()
        childFrame.selected:SetTexture(1, 1, 1, 0.2)
        childFrame.selected:SetAlpha(0)
        
        childFrame.icon = childFrame:CreateTexture(nil, 'OVERLAY')
        childFrame.icon:SetSize(childHeight - 4, childHeight - 4)
        childFrame.icon:SetPoint('TOPLEFT', 2, -2)
    
        childFrame.text = childFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        childFrame.text:SetPoint('LEFT', 20, 0)
        childFrame.text:SetJustifyH('LEFT')
        
        childFrame:SetScript('OnEnter', function()
            if(childFrame.itemId ~= nil) then
                childFrame.highlight:SetAlpha(1)
                
                GameTooltip:SetOwner(childFrame, 'ANCHOR_RIGHT')
                GameTooltip:SetHyperlink(select(2, GetItemInfoCustom(childFrame.itemId)))
                GameTooltip:Show()
            end
        end)
        
        childFrame:SetScript('OnLeave', function()
            childFrame.highlight:SetAlpha(0)
            GameTooltip_Hide(childFrame)
        end)
        
        childFrame:SetScript('OnClick', function()
            listFrame.selectedItemId = childFrame.itemId
            listFrame.updateView()
            data.selectItemCallback()
        end)
        
        table.insert(listFrame.childFrames, childFrame)
    end
    
    listFrame.updateView = function()
        local itemIdList = data.getItemsCallback()
        local offset = FauxScrollFrame_GetOffset(listFrame)
        
        for childIndex = 1, 10 do
            local childFrame = listFrame.childFrames[childIndex]
            local itemIndex = childIndex + offset
            local itemId = itemIdList[itemIndex]
            
            childFrame.itemId = itemId
            
            if(itemId == nil) then
                childFrame:SetAlpha(0)
            else
                childFrame:SetAlpha(1)
                
                local itemName, _, itemRarity, _, _, _,
_, _, _, itemTexture = GetItemInfoCustom(itemId)

                childFrame.icon:SetTexture(itemTexture)
        
                local colourMap = {
                    [0] = {0.615, 0.615, 0.615},
                    [1] = {1.000, 1.000, 1.000},
                    [2] = {0.118, 1.000, 0.000},
                    [3] = {0.000, 0.439, 0.867},
                    [4] = {0.639, 0.208, 0.933},
                    [5] = {1.000, 0.502, 0.000},
                    [6] = {0.902, 0.800, 0.502},
                    [7] = {0.902, 0.800, 0.502},
                }
                
                childFrame.text:SetText(itemName)
                childFrame.text:SetTextColor(colourMap[itemRarity][1], colourMap[itemRarity][2], colourMap[itemRarity][3])
                
                if(childFrame.itemId == listFrame.selectedItemId) then
                    childFrame.selected:SetAlpha(1)
                else
                    childFrame.selected:SetAlpha(0)
                end
            end
        end
    end
    
    listFrame.dataChanged = function()
        FauxScrollFrame_Update(listFrame, #(data.getItemsCallback()), data.childCount, childHeight, nil, nil, nil, nil, nil, nil, true)
        FauxScrollFrame_SetOffset(listFrame, 0)
        listFrame.updateView()
    end
    
    return listFrame
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