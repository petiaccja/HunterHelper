SharpShooter_CFG = {}

function SharpShooter_CFG:OnLoad()
    SharpShooter_SF:OnLoad()

    SharpShooter_ConfigFrame:SetScript("OnEvent", SharpShooter_CFG.OnEvent);
    SharpShooter_ConfigFrame:RegisterEvent("VARIABLES_LOADED")

    SharpShooter_ConfigFrame:Hide()
    local configFrame = SharpShooter_ConfigFrame
    configFrame.name = "SharpShooter"
    InterfaceOptions_AddCategory(configFrame)

    SharpShooter_CFG.characterName = GetUnitName("player", true);
end


function SharpShooter_CFG:OnEvent(event, ...)
    if event == "VARIABLES_LOADED" then
        SharpShooter_CFG:OnVariablesLoaded()
    end
end


function SharpShooter_CFG:FirstLoginMessage()
    local playerClassName = UnitClass("player")
    local hunterColor = RAID_CLASS_COLORS["HUNTER"].colorStr
    local playerColor = RAID_CLASS_COLORS[string.upper(playerClassName)].colorStr
    local coloredPlayerClass = "\124c" .. playerColor .. playerClassName .."\124r"
    local coloredAddonName = "\124c" .. hunterColor .. "SharpShooter" .."\124r"

    local greeting = "Hi " .. coloredPlayerClass .. "! "
    local disabledMessage = coloredAddonName .. " cannot help you on your journey. "
        .. "It is now turned off for this character, however, you can enable it anytime in the AddOn options menu."
    local enabledMessage = coloredAddonName .. " is at your service, please check out the configuration in the AddOn options menu."

    if SharpShooter:IsPlayerHunter() then
        print(enabledMessage)
    else
        print(greeting .. disabledMessage)
    end
end


function SharpShooter_CFG:OptionsClearedMessage()
    local hunterColor = RAID_CLASS_COLORS["HUNTER"].colorStr
    local coloredAddonName = "\124c" .. hunterColor .. "SharpShooter" .."\124r"
    print("Unfortunately your settings for " .. coloredAddonName .. " had to be cleared due to a new version of the AddOn. Please reconfigure.")
end


function SharpShooter_CFG:OnVariablesLoaded()
    if not g_sharpShooterConfig then
        g_sharpShooterConfig = {}
    end
    local key = SharpShooter_CFG.characterName
    if g_sharpShooterConfig[key] == nil then
        g_sharpShooterConfig[key] = SharpShooter_CFG:CreateDefaultConfig()
        SharpShooter_CFG:FirstLoginMessage()
    end
    if not SharpShooter_CFG:VerifyConfig(g_sharpShooterConfig[key]) then
        g_sharpShooterConfig[key] = SharpShooter_CFG:CreateDefaultConfig()
        SharpShooter_CFG:OptionsClearedMessage()
    end
    SharpShooter_CFG:SetConfigToGui(g_sharpShooterConfig[key])
    SharpShooter_CFG:ApplyConfig(g_sharpShooterConfig[key])
    SharpShooter_CFG:SetScripts()
end


function SharpShooter_CFG:VerifyConfig(config)
    local default = SharpShooter_CFG:CreateDefaultConfig()
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


function SharpShooter_CFG:CreateDefaultConfig()
    local config = {}
    config.enableMove = false
    config.enableBar = SharpShooter:IsPlayerHunter()
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


function SharpShooter_CFG:SetScripts()
    SharpShooter_ConfigDraggable:SetScript("OnClick", SharpShooter_CFG.OnGuiUpdated)
    SharpShooter_ConfigToggleBar:SetScript("OnClick", SharpShooter_CFG.OnGuiUpdated)
    SharpShooter_ConfigScale:SetScript("OnMouseUp", SharpShooter_CFG.OnGuiUpdated)
    SharpShooter_ConfigCombatAlpha:SetScript("OnMouseUp", SharpShooter_CFG.OnGuiUpdated)
    SharpShooter_ConfigIdleAlpha:SetScript("OnMouseUp", SharpShooter_CFG.OnGuiUpdated)
    SharpShooter_ConfigNotargetAlpha:SetScript("OnMouseUp", SharpShooter_CFG.OnGuiUpdated)
    SharpShooter_ConfigEnablePoly:SetScript("OnClick", SharpShooter_CFG.OnGuiUpdated)
    SharpShooter_ConfigEnableFriendlyFire:SetScript("OnClick", SharpShooter_CFG.OnGuiUpdated)
end


function SharpShooter_CFG:SetConfigToGui(config)
    SharpShooter_ConfigDraggable:SetChecked(config.enableMove)
    SharpShooter_ConfigToggleBar:SetChecked(config.enableBar)
    SharpShooter_ConfigScale:SetValue(config.size)
    SharpShooter_ConfigCombatAlpha:SetValue(config.combatAlpha)
    SharpShooter_ConfigIdleAlpha:SetValue(config.idleAlpha)
    SharpShooter_ConfigNotargetAlpha:SetValue(config.notargetAlpha)
    SharpShooter_ConfigEnablePoly:SetChecked(config.warnPoly)
    SharpShooter_ConfigEnableFriendlyFire:SetChecked(config.warnFriendlyFire)
end


function SharpShooter_CFG:GetConfigFromGui()
    local config = {}
    config.enableMove = SharpShooter_ConfigDraggable:GetChecked()
    config.enableBar = SharpShooter_ConfigToggleBar:GetChecked()
    config.size = SharpShooter_ConfigScale:GetValue()
    config.combatAlpha = SharpShooter_ConfigCombatAlpha:GetValue()
    config.idleAlpha = SharpShooter_ConfigIdleAlpha:GetValue()
    config.notargetAlpha = SharpShooter_ConfigNotargetAlpha:GetValue()
    config.warnPoly = SharpShooter_ConfigEnablePoly:GetChecked()
    config.warnFriendlyFire = SharpShooter_ConfigEnableFriendlyFire:GetChecked()
    local xOffset, yOffset = SharpShooter_SF:GetConfigPosition()
    config.xPosition = xOffset
    config.yPosition = yOffset
    return config
end


function SharpShooter_CFG:OnGuiUpdated()
    local newConfig = SharpShooter_CFG:GetConfigFromGui()

    if g_sharpShooterConfig then
        local key = SharpShooter_CFG.characterName
        g_sharpShooterConfig[key] = newConfig
    end

    SharpShooter_CFG:ApplyConfig(newConfig)
end


function SharpShooter_CFG:ApplyConfig(config)
    SharpShooter_SF:SetConfigAlpha(config.combatAlpha, config.idleAlpha, config.notargetAlpha)
    SharpShooter_SF:SetConfigSize(config.size)
    SharpShooter_SF:SetConfigEnabled(config.enableBar)
    SharpShooter_SF:SetConfigPosition(config.xPosition, config.yPosition)
    SharpShooter_SF:SetConfigMovable(config.enableMove)
end