HunterHelper_CFG = {}

function HunterHelper_CFG:OnLoad()
    HunterHelper_ConfigFrame:SetScript("OnEvent", HunterHelper_CFG.OnEvent);
    HunterHelper_ConfigFrame:RegisterEvent("VARIABLES_LOADED")

    HunterHelper_ConfigFrame:Hide()
    local configFrame = HunterHelper_ConfigFrame
    configFrame.name = "HunterHelper"
    InterfaceOptions_AddCategory(configFrame)

    HunterHelper_CFG.characterName = GetUnitName("player", true);
end


function HunterHelper_CFG:OnEvent(event, ...)
    if event == "VARIABLES_LOADED" then
        HunterHelper_CFG:OnVariablesLoaded()
    end
end


function HunterHelper_CFG:FirstLoginMessage()
    local playerClassName = UnitClass("player")
    local hunterColor = RAID_CLASS_COLORS["HUNTER"].colorStr
    local playerColor = RAID_CLASS_COLORS[string.upper(playerClassName)].colorStr
    local coloredPlayerClass = "\124c" .. playerColor .. playerClassName .."\124r"
    local coloredAddonName = "\124c" .. hunterColor .. "HunterHelper" .."\124r"

    local greeting = "Hi " .. coloredPlayerClass .. "! "
    local disabledMessage = coloredAddonName .. " cannot help you on your journey. "
        .. "It is now turned off for this character, however, you can enable it anytime in the AddOn options menu."
    local enabledMessage = coloredAddonName .. " is at your service, please check out the configuration in the AddOn options menu."

    if HunterHelper:IsPlayerHunter() then
        print(enabledMessage)
    else
        print(greeting .. disabledMessage)
    end
end


function HunterHelper_CFG:OptionsClearedMessage()
    local hunterColor = RAID_CLASS_COLORS["HUNTER"].colorStr
    local coloredAddonName = "\124c" .. hunterColor .. "HunterHelper" .."\124r"
    print("Unfortunately your settings for " .. coloredAddonName .. " had to be cleared due to a new version of the AddOn. Please reconfigure.")
end


function HunterHelper_CFG:OnVariablesLoaded()
    if not g_hunterHelperConfig then
        g_hunterHelperConfig = {}
    end
    local key = HunterHelper_CFG.characterName
    if g_hunterHelperConfig[key] == nil then
        g_hunterHelperConfig[key] = HunterHelper_CFG:CreateDefaultConfig()
        HunterHelper_CFG:FirstLoginMessage()
    end
    if not HunterHelper_CFG:VerifyConfig(g_hunterHelperConfig[key]) then
        g_hunterHelperConfig[key] = HunterHelper_CFG:CreateDefaultConfig()
        HunterHelper_CFG:OptionsClearedMessage()
    end
    HunterHelper_CFG:SetConfigToGui(g_hunterHelperConfig[key])
    HunterHelper_CFG:ApplyConfig(g_hunterHelperConfig[key])
    HunterHelper_CFG:SetScripts()
end


function HunterHelper_CFG:VerifyConfig(config)
    local default = HunterHelper_CFG:CreateDefaultConfig()
    if type(config) ~= type({}) then
        return false
    end
    for k,v in pairs(default) do
        if config[k] == nil or type(config[k]) ~= type(default[k]) then
            return false
        end
    end
    return true
end


function HunterHelper_CFG:CreateDefaultConfig()
    local config = {}
    config.enableMove = false
    config.enableBar = HunterHelper:IsPlayerHunter()
    config.size = 64
    config.combatAlpha = 1.0
    config.idleAlpha = 0.3
    config.notargetAlpha = 0.0
    config.warnPoly = true
    config.warnFriendlyFire = true
    config.xPosition = GetScreenWidth()/2
    config.yPosition = GetScreenHeight()/2
    return config
end


function HunterHelper_CFG:SetScripts()
    HunterHelper_ConfigDraggable:SetScript("OnClick", HunterHelper_CFG.OnGuiUpdated)
    HunterHelper_ConfigToggleBar:SetScript("OnClick", HunterHelper_CFG.OnGuiUpdated)
    HunterHelper_ConfigScale:SetScript("OnMouseUp", HunterHelper_CFG.OnGuiUpdated)
    HunterHelper_ConfigCombatAlpha:SetScript("OnMouseUp", HunterHelper_CFG.OnGuiUpdated)
    HunterHelper_ConfigIdleAlpha:SetScript("OnMouseUp", HunterHelper_CFG.OnGuiUpdated)
    HunterHelper_ConfigNotargetAlpha:SetScript("OnMouseUp", HunterHelper_CFG.OnGuiUpdated)
    HunterHelper_ConfigEnablePoly:SetScript("OnClick", HunterHelper_CFG.OnGuiUpdated)
    HunterHelper_ConfigEnableFriendlyFire:SetScript("OnClick", HunterHelper_CFG.OnGuiUpdated)
end


function HunterHelper_CFG:SetConfigToGui(config)
    HunterHelper_ConfigDraggable:SetChecked(config.enableMove)
    HunterHelper_ConfigToggleBar:SetChecked(config.enableBar)
    HunterHelper_ConfigScale:SetValue(config.size)
    HunterHelper_ConfigCombatAlpha:SetValue(config.combatAlpha)
    HunterHelper_ConfigIdleAlpha:SetValue(config.idleAlpha)
    HunterHelper_ConfigNotargetAlpha:SetValue(config.notargetAlpha)
    HunterHelper_ConfigEnablePoly:SetChecked(config.warnPoly)
    HunterHelper_ConfigEnableFriendlyFire:SetChecked(config.warnFriendlyFire)
end


function HunterHelper_CFG:GetConfigFromGui()
    local config = {}
    config.enableMove = HunterHelper_ConfigDraggable:GetChecked()
    config.enableBar = HunterHelper_ConfigToggleBar:GetChecked()
    config.size = HunterHelper_ConfigScale:GetValue()
    config.combatAlpha = HunterHelper_ConfigCombatAlpha:GetValue()
    config.idleAlpha = HunterHelper_ConfigIdleAlpha:GetValue()
    config.notargetAlpha = HunterHelper_ConfigNotargetAlpha:GetValue()
    config.warnPoly = HunterHelper_ConfigEnablePoly:GetChecked()
    config.warnFriendlyFire = HunterHelper_ConfigEnableFriendlyFire:GetChecked()
    local xOffset, yOffset = HunterHelper_SuggestionFrame:GetCenter()
    config.xPosition = xOffset
    config.yPosition = yOffset
    return config
end


function HunterHelper_CFG:OnGuiUpdated()
    local newConfig = HunterHelper_CFG:GetConfigFromGui()

    if g_hunterHelperConfig then
        local key = HunterHelper_CFG.characterName
        g_hunterHelperConfig[key] = newConfig
    end

    HunterHelper_CFG:ApplyConfig(newConfig)
end


function HunterHelper_CFG:ApplyConfig(config)
    HunterHelper_SF:SetConfigAlpha(config.combatAlpha, config.idleAlpha, config.notargetAlpha)
    HunterHelper_SF:SetConfigSize(config.size)
    HunterHelper_SF:SetConfigEnabled(config.enableBar)

    HunterHelper_WF:SetConfigAlpha(config.combatAlpha, config.idleAlpha, config.notargetAlpha)
    HunterHelper_WF:SetConfigSize(config.size)
    HunterHelper_WF:SetConfigEnabled(config.enableBar)

    if config.enableMove then
        HunterHelper_CFG:EnableMove()
    else
        HunterHelper_CFG:DisableMove()
    end

    HunterHelper_SuggestionFrame:ClearAllPoints()
    HunterHelper_SuggestionFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", config.xPosition, config.yPosition)
end


function HunterHelper_CFG:EnableMove()
    HunterHelper_SuggestionFrame:SetMovable(true)
    HunterHelper_SuggestionFrame:EnableMouse(true)
    HunterHelper_SuggestionFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and not self.isMoving then
            self:StartMoving();
            self.isMoving = true;
        end
    end)
    HunterHelper_SuggestionFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.isMoving then
            self:StopMovingOrSizing();
            self.isMoving = false;
            local xOffset, yOffset = self:GetCenter(0)
            local key = HunterHelper_CFG.characterName
            g_hunterHelperConfig[key].xPosition = xOffset
            g_hunterHelperConfig[key].yPosition = yOffset
        end
    end)
    HunterHelper_SuggestionFrame:SetScript("OnHide", function(self)
        if self.isMoving then
            self:StopMovingOrSizing();
            self.isMoving = false;
        end
    end)
end


function HunterHelper_CFG:DisableMove()
    HunterHelper_SuggestionFrame:SetMovable(false)
    HunterHelper_SuggestionFrame:EnableMouse(false)
end