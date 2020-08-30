SharpShooter_SF = {}


local inCombat = false
local eventHandlers = {}
local combatAlpha = 1.0
local idleAlpha = 0.3
local notargetAlpha = 0.1
local iconSize = 64;
local isEnabled = false


function SharpShooter_SF:OnLoad()
    SharpShooter_SuggestionFrame:SetScript("OnEvent", SharpShooter_SF.OnEvent);
end


function SharpShooter_SF:RegisterEvents()
    SharpShooter_SuggestionFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    SharpShooter_SuggestionFrame:RegisterEvent("UNIT_AURA")
    SharpShooter_SuggestionFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    SharpShooter_SuggestionFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    SharpShooter_SuggestionFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

    SharpShooter_SuggestionFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    SharpShooter_SuggestionFrame:RegisterEvent("ACTIONBAR_UPDATE_STATE")
end


function SharpShooter_SF:UnregisterEvents()
    SharpShooter_SuggestionFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    SharpShooter_SuggestionFrame:UnregisterEvent("UNIT_AURA")
    SharpShooter_SuggestionFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
    SharpShooter_SuggestionFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    SharpShooter_SuggestionFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")

    SharpShooter_SuggestionFrame:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
    SharpShooter_SuggestionFrame:UnregisterEvent("ACTIONBAR_UPDATE_STATE")
end


function SharpShooter_SF:ShowBar()
    SharpShooter_SuggestionFrame:Show()

    SharpShooter_SuggestSerpent:Show()
    SharpShooter_SuggestMark:Show()
    SharpShooter_SuggestAimed:Show()
    SharpShooter_SuggestMulti:Show()

    SharpShooter_BackgroundSerpent:Show()
    SharpShooter_BackgroundMark:Show()
    SharpShooter_BackgroundAimed:Show()
    SharpShooter_BackgroundMulti:Show()
end


function SharpShooter_SF:HideBar()
    SharpShooter_SuggestionFrame:Hide()

    SharpShooter_SuggestSerpent:Hide()
    SharpShooter_SuggestMark:Hide()
    SharpShooter_SuggestAimed:Hide()
    SharpShooter_SuggestMulti:Hide()

    SharpShooter_BackgroundSerpent:Hide()
    SharpShooter_BackgroundMark:Hide()
    SharpShooter_BackgroundAimed:Hide()
    SharpShooter_BackgroundMulti:Hide()
end


function SharpShooter_SF:OnEvent(event, ...)
    if eventHandlers[event] ~= nil then
        eventHandlers[event](...)
    end
    SharpShooter_SF:UpdateSting()
    SharpShooter_SF:UpdateMark()
    SharpShooter_SF:UpdateAimed()
    SharpShooter_SF:UpdateMulti()
    SharpShooter_SF:UpdateAlpha()
end


function SharpShooter_SF:SetConfigAlpha(combatAlpha_, idleAlpha_, notargetAlpha_)
    combatAlpha = combatAlpha_
    idleAlpha = idleAlpha_
    notargetAlpha = notargetAlpha_
    SharpShooter_SF:UpdateAlpha()
end


function SharpShooter_SF:SetConfigSize(size)
    iconSize = size
    SharpShooter_SF:UpdateSize()
end


function SharpShooter_SF:SetConfigEnabled(enable)
    if enable and not isEnabled then
        SharpShooter_SF:RegisterEvents()
        SharpShooter_SF:ShowBar()
    elseif not enable and isEnabled then
        SharpShooter_SF:UnregisterEvents()
        SharpShooter_SF:HideBar()
    end
    isEnabled = enable
end


function SharpShooter_SF:UpdateAlpha()
    SharpShooter_SuggestionFrame:SetAlpha(SharpShooter_SF:GetAlpha())
end


function SharpShooter_SF:UpdateSize()
    SharpShooter_SuggestionFrame:SetSize(4*iconSize, iconSize)

    SharpShooter_SuggestSerpent:SetSize(iconSize, iconSize)
    SharpShooter_SuggestMark:SetSize(iconSize, iconSize)
    SharpShooter_SuggestAimed:SetSize(iconSize, iconSize)
    SharpShooter_SuggestMulti:SetSize(iconSize, iconSize)

    SharpShooter_BackgroundSerpent:SetSize(iconSize, iconSize)
    SharpShooter_BackgroundMark:SetSize(iconSize, iconSize)
    SharpShooter_BackgroundAimed:SetSize(iconSize, iconSize)
    SharpShooter_BackgroundMulti:SetSize(iconSize, iconSize)
end


function SharpShooter_SF:GetAlpha()
    if inCombat then
        return combatAlpha
    elseif SharpShooter:HasAttackableTarget() then
        return idleAlpha
    else
        return notargetAlpha
    end
end


function SharpShooter_SF:SuggestSerpent()
    if not SharpShooter:HasPlayerSpell("Serpent Sting") then
        return false
    end
    local activeSting = SharpShooter:GetSting()
    return not activeSting and SharpShooter:HasAttackableTarget()
end


function SharpShooter_SF:SuggestMark()
    if not SharpShooter:HasPlayerSpell("Hunter's Mark") then
        return false
    end
    local hasMark = SharpShooter:GetMark()
    return not hasMark and SharpShooter:HasAttackableTarget()
end


function SharpShooter_SF:SuggestAimed()
    if not SharpShooter:HasPlayerSpell("Aimed Shot") then
        return false
    end
    local start, duration, enabled = GetSpellCooldown("Aimed Shot", "BOOKTYPE_SPELL");
    local isReady = duration < 1.6 -- GCD also counts as cooldown.
    return isReady and SharpShooter:HasAttackableTarget()
end


function SharpShooter_SF:SuggestMulti()
    if not SharpShooter:HasPlayerSpell("Multi-Shot") then
        return false
    end
    local start, duration, enabled = GetSpellCooldown("Multi-Shot", "BOOKTYPE_SPELL");
    local isReady = duration < 1.6 -- GCD also counts as cooldown.
    return isReady and SharpShooter:HasAttackableTarget()
end


function SharpShooter_SF:UpdateSting()
    local suggest = SharpShooter_SF:SuggestSerpent()
    if suggest then
        SharpShooter_SuggestSerpent:Show()
        SharpShooter_BackgroundSerpent:Hide()
    else
        SharpShooter_SuggestSerpent:Hide()
        SharpShooter_BackgroundSerpent:Show()
    end
end


function SharpShooter_SF:UpdateMark()
    local suggest = SharpShooter_SF:SuggestMark()
    if suggest then
        SharpShooter_SuggestMark:Show()
        SharpShooter_BackgroundMark:Hide()
    else
        SharpShooter_SuggestMark:Hide()
        SharpShooter_BackgroundMark:Show()
    end
end


function SharpShooter_SF:UpdateAimed()
    local suggest = SharpShooter_SF:SuggestAimed()
    if suggest then
        SharpShooter_SuggestAimed:Show()
        SharpShooter_BackgroundAimed:Hide()
    else
        SharpShooter_SuggestAimed:Hide()
        SharpShooter_BackgroundAimed:Show()
    end
end


function SharpShooter_SF:UpdateMulti()
    local suggest = SharpShooter_SF:SuggestMulti()
    if suggest then
        SharpShooter_SuggestMulti:Show()
        SharpShooter_BackgroundMulti:Hide()
    else
        SharpShooter_SuggestMulti:Hide()
        SharpShooter_BackgroundMulti:Show()
    end
end


function SharpShooter_SF:OnCooldownFinish(spell, book, callback)
    if not SharpShooter:HasPlayerSpell(spell) then
        return
    end
    local start, duration, enabled = GetSpellCooldown(spell, book);
    if duration > 1.6 then
        local delay = math.max(0, start + duration - GetTime() + 0.1)
        C_Timer.After(delay, callback)
    end
end


function eventHandlers:PLAYER_REGEN_DISABLED(...)
    inCombat = true
end


function eventHandlers:PLAYER_REGEN_ENABLED(...)
    inCombat = false
end


function eventHandlers:SPELL_UPDATE_COOLDOWN(...)
    SharpShooter_SF:OnCooldownFinish("Aimed Shot", "BOOKTYPE_SPELL", SharpShooter_SF.UpdateAimed);
    SharpShooter_SF:OnCooldownFinish("Multi-Shot", "BOOKTYPE_SPELL", SharpShooter_SF.UpdateMulti);
end