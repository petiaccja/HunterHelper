HunterHelper_SF = {}


local inCombat = false
local eventHandlers = {}
local combatAlpha = 1.0
local idleAlpha = 0.3
local notargetAlpha = 0.1
local iconSize = 64;
local isEnabled = false


function HunterHelper_SF:OnLoad()
    HunterHelper_SuggestionFrame:SetScript("OnEvent", HunterHelper_SF.OnEvent);
end


function HunterHelper_SF:RegisterEvents()
    HunterHelper_SuggestionFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    HunterHelper_SuggestionFrame:RegisterEvent("UNIT_AURA")
    HunterHelper_SuggestionFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    HunterHelper_SuggestionFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    HunterHelper_SuggestionFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

    HunterHelper_SuggestionFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    HunterHelper_SuggestionFrame:RegisterEvent("ACTIONBAR_UPDATE_STATE")
end


function HunterHelper_SF:UnregisterEvents()
    HunterHelper_SuggestionFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    HunterHelper_SuggestionFrame:UnregisterEvent("UNIT_AURA")
    HunterHelper_SuggestionFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
    HunterHelper_SuggestionFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    HunterHelper_SuggestionFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")

    HunterHelper_SuggestionFrame:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
    HunterHelper_SuggestionFrame:UnregisterEvent("ACTIONBAR_UPDATE_STATE")
end


function HunterHelper_SF:ShowBar()
    HunterHelper_SuggestionFrame:Show()

    HunterHelper_SuggestSerpent:Show()
    HunterHelper_SuggestMark:Show()
    HunterHelper_SuggestAimed:Show()
    HunterHelper_SuggestMulti:Show()

    HunterHelper_BackgroundSerpent:Show()
    HunterHelper_BackgroundMark:Show()
    HunterHelper_BackgroundAimed:Show()
    HunterHelper_BackgroundMulti:Show()
end


function HunterHelper_SF:HideBar()
    HunterHelper_SuggestionFrame:Hide()

    HunterHelper_SuggestSerpent:Hide()
    HunterHelper_SuggestMark:Hide()
    HunterHelper_SuggestAimed:Hide()
    HunterHelper_SuggestMulti:Hide()

    HunterHelper_BackgroundSerpent:Hide()
    HunterHelper_BackgroundMark:Hide()
    HunterHelper_BackgroundAimed:Hide()
    HunterHelper_BackgroundMulti:Hide()
end


function HunterHelper_SF:OnEvent(event, ...)
    if eventHandlers[event] ~= nil then
        eventHandlers[event](...)
    end
    HunterHelper_SF:UpdateSting()
    HunterHelper_SF:UpdateMark()
    HunterHelper_SF:UpdateAimed()
    HunterHelper_SF:UpdateMulti()
    HunterHelper_SF:UpdateAlpha()
end


function HunterHelper_SF:SetConfigAlpha(combatAlpha_, idleAlpha_, notargetAlpha_)
    combatAlpha = combatAlpha_
    idleAlpha = idleAlpha_
    notargetAlpha = notargetAlpha_
    HunterHelper_SF:UpdateAlpha()
end


function HunterHelper_SF:SetConfigSize(size)
    iconSize = size
    HunterHelper_SF:UpdateSize()
end


function HunterHelper_SF:SetConfigEnabled(enable)
    if enable and not isEnabled then
        HunterHelper_SF:RegisterEvents()
        HunterHelper_SF:ShowBar()
    elseif not enable and isEnabled then
        HunterHelper_SF:UnregisterEvents()
        HunterHelper_SF:HideBar()
    end
    isEnabled = enable
end


function HunterHelper_SF:UpdateAlpha()
    HunterHelper_SuggestionFrame:SetAlpha(HunterHelper_SF:GetAlpha())
end


function HunterHelper_SF:UpdateSize()
    HunterHelper_SuggestionFrame:SetSize(4*iconSize, iconSize)

    HunterHelper_SuggestSerpent:SetSize(iconSize, iconSize)
    HunterHelper_SuggestMark:SetSize(iconSize, iconSize)
    HunterHelper_SuggestAimed:SetSize(iconSize, iconSize)
    HunterHelper_SuggestMulti:SetSize(iconSize, iconSize)

    HunterHelper_BackgroundSerpent:SetSize(iconSize, iconSize)
    HunterHelper_BackgroundMark:SetSize(iconSize, iconSize)
    HunterHelper_BackgroundAimed:SetSize(iconSize, iconSize)
    HunterHelper_BackgroundMulti:SetSize(iconSize, iconSize)
end


function HunterHelper_SF:GetAlpha()
    if inCombat then
        return combatAlpha
    elseif HunterHelper:HasAttackableTarget() then
        return idleAlpha
    else
        return notargetAlpha
    end
end


function HunterHelper_SF:SuggestSerpent()
    if not HunterHelper:HasPlayerSpell("Serpent Sting") then
        return false
    end
    local activeSting = HunterHelper:GetSting()
    return not activeSting and HunterHelper:HasAttackableTarget()
end


function HunterHelper_SF:SuggestMark()
    if not HunterHelper:HasPlayerSpell("Hunter's Mark") then
        return false
    end
    local hasMark = HunterHelper:GetMark()
    return not hasMark and HunterHelper:HasAttackableTarget()
end


function HunterHelper_SF:SuggestAimed()
    if not HunterHelper:HasPlayerSpell("Aimed Shot") then
        return false
    end
    local start, duration, enabled = GetSpellCooldown("Aimed Shot", "BOOKTYPE_SPELL");
    local isReady = duration < 1.6 -- GCD also counts as cooldown.
    return isReady and HunterHelper:HasAttackableTarget()
end


function HunterHelper_SF:SuggestMulti()
    if not HunterHelper:HasPlayerSpell("Multi-Shot") then
        return false
    end
    local start, duration, enabled = GetSpellCooldown("Multi-Shot", "BOOKTYPE_SPELL");
    local isReady = duration < 1.6 -- GCD also counts as cooldown.
    return isReady and HunterHelper:HasAttackableTarget()
end


function HunterHelper_SF:UpdateSting()
    local suggest = HunterHelper_SF:SuggestSerpent()
    if suggest then
        HunterHelper_SuggestSerpent:Show()
        HunterHelper_BackgroundSerpent:Hide()
    else
        HunterHelper_SuggestSerpent:Hide()
        HunterHelper_BackgroundSerpent:Show()
    end
end


function HunterHelper_SF:UpdateMark()
    local suggest = HunterHelper_SF:SuggestMark()
    if suggest then
        HunterHelper_SuggestMark:Show()
        HunterHelper_BackgroundMark:Hide()
    else
        HunterHelper_SuggestMark:Hide()
        HunterHelper_BackgroundMark:Show()
    end
end


function HunterHelper_SF:UpdateAimed()
    local suggest = HunterHelper_SF:SuggestAimed()
    if suggest then
        HunterHelper_SuggestAimed:Show()
        HunterHelper_BackgroundAimed:Hide()
    else
        HunterHelper_SuggestAimed:Hide()
        HunterHelper_BackgroundAimed:Show()
    end
end


function HunterHelper_SF:UpdateMulti()
    local suggest = HunterHelper_SF:SuggestMulti()
    if suggest then
        HunterHelper_SuggestMulti:Show()
        HunterHelper_BackgroundMulti:Hide()
    else
        HunterHelper_SuggestMulti:Hide()
        HunterHelper_BackgroundMulti:Show()
    end
end


function HunterHelper_SF:OnCooldownFinish(spell, book, callback)
    if not HunterHelper:HasPlayerSpell(spell) then
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
    HunterHelper_SF:OnCooldownFinish("Aimed Shot", "BOOKTYPE_SPELL", HunterHelper_SF.UpdateAimed);
    HunterHelper_SF:OnCooldownFinish("Multi-Shot", "BOOKTYPE_SPELL", HunterHelper_SF.UpdateMulti);
end