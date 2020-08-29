HunterHelper_SF = {}


local inCombat = false
local eventHandlers = {}
local aimedCooldown = false
local multiCooldown = false
local combatAlpha = 1.0
local idleAlpha = 0.3
local notargetAlpha = 0.1


function HunterHelper_SF:OnLoad()
    HunterHelper_SuggestionFrame:SetScript("OnEvent", HunterHelper_SF.OnEvent);
    HunterHelper_SuggestionFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    HunterHelper_SuggestionFrame:RegisterEvent("UNIT_AURA")
    HunterHelper_SuggestionFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    HunterHelper_SuggestionFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    HunterHelper_SuggestionFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

    HunterHelper_SuggestionFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    HunterHelper_SuggestionFrame:RegisterEvent("ACTIONBAR_UPDATE_STATE")
end


function HunterHelper_SF:OnEvent(event, ...)
    if eventHandlers[event] ~= nil then
        eventHandlers[event](...)
    end
    HunterHelper_SF:UpdateSting()
    HunterHelper_SF:UpdateMark()
    HunterHelper_SF:UpdateAimed()
    HunterHelper_SF:UpdateMulti()
    HunterHelper:SetControlAlpha(HunterHelper_SuggestBackground, 0.6*HunterHelper_SF:GetAlpha())
end


function HunterHelper_SF:HasAttackableTarget()
    local isEnemy = UnitCanAttack("player","target")
    local exists = UnitExists("target")
    local isDead = UnitIsDead("target")
    return not isDead and isEnemy and exists
end


function HunterHelper_SF:SetConfig(config)
    if config.enableBar then
        combatAlpha = config.combatAlpha
        idleAlpha = config.idleAlpha
        notargetAlpha = config.notargetAlpha
    else
        combatAlpha = 0
        idleAlpha = 0
        notargetAlpha = 0
    end

    HunterHelper:SetControlAlpha(HunterHelper_SuggestBackground, 0.6*HunterHelper_SF:GetAlpha())
    HunterHelper:SetControlAlpha(HunterHelper_SuggestSerpent, HunterHelper_SF:GetAlpha())
    HunterHelper:SetControlAlpha(HunterHelper_SuggestMark, HunterHelper_SF:GetAlpha())
    HunterHelper:SetControlAlpha(HunterHelper_SuggestAimed, HunterHelper_SF:GetAlpha())
    HunterHelper:SetControlAlpha(HunterHelper_SuggestMulti, HunterHelper_SF:GetAlpha())    

    HunterHelper_SuggestionFrame:SetSize(4*config.size, config.size)
    HunterHelper_SuggestBackground:SetSize(4*config.size, config.size)
    HunterHelper_SuggestSerpent:SetSize(config.size, config.size)
    HunterHelper_SuggestMark:SetSize(config.size, config.size)
    HunterHelper_SuggestAimed:SetSize(config.size, config.size)
    HunterHelper_SuggestMulti:SetSize(config.size, config.size)
end


function HunterHelper_SF:GetAlpha()
    if inCombat then
        return combatAlpha
    elseif HunterHelper_SF:HasAttackableTarget() then
        return idleAlpha
    else
        return notargetAlpha
    end
end


function HunterHelper_SF:SuggestSerpent()
    if not GetSpellInfo("Serpent Sting") then
        return false
    end
    local activeSting = HunterHelper:GetSting()
    return not activeSting and HunterHelper_SF:HasAttackableTarget()
end


function HunterHelper_SF:SuggestMark()
    if not GetSpellInfo("Hunter's Mark") then
        return false
    end
    local hasMark = HunterHelper:GetMark()
    return not hasMark and HunterHelper_SF:HasAttackableTarget()
end


function HunterHelper_SF:SuggestAimed()
    if not GetSpellInfo("Aimed Shot") then
        return false
    end
    local start, duration, enabled = GetSpellCooldown("Aimed Shot", "BOOKTYPE_SPELL");
    local isReady = duration < 1.6 -- GCD also counts as cooldown.
    return isReady and HunterHelper_SF:HasAttackableTarget()
end


function HunterHelper_SF:SuggestMulti()
    if not GetSpellInfo("Multi-Shot") then
        return false
    end
    local start, duration, enabled = GetSpellCooldown("Multi-Shot", "BOOKTYPE_SPELL");
    local isReady = duration < 1.6 -- GCD also counts as cooldown.
    return isReady and HunterHelper_SF:HasAttackableTarget()
end


function HunterHelper_SF:UpdateSting()
    local suggest = HunterHelper_SF:SuggestSerpent()
    if suggest then
        HunterHelper_SuggestSerpent:Show()
        HunterHelper:SetControlAlpha(HunterHelper_SuggestSerpent, HunterHelper_SF:GetAlpha())
    else
        HunterHelper_SuggestSerpent:Hide()
    end
end


function HunterHelper_SF:UpdateMark()
    local suggest = HunterHelper_SF:SuggestMark()
    if suggest then
        HunterHelper_SuggestMark:Show()
        HunterHelper:SetControlAlpha(HunterHelper_SuggestMark, HunterHelper_SF:GetAlpha())
    else
        HunterHelper_SuggestMark:Hide()
    end
end


function HunterHelper_SF:UpdateAimed()
    local suggest = HunterHelper_SF:SuggestAimed()
    if suggest then
        HunterHelper_SuggestAimed:Show()
        HunterHelper:SetControlAlpha(HunterHelper_SuggestAimed, HunterHelper_SF:GetAlpha())
    else
        HunterHelper_SuggestAimed:Hide()
    end
end


function HunterHelper_SF:UpdateMulti()
    local suggest = HunterHelper_SF:SuggestMulti()
    if suggest then
        HunterHelper_SuggestMulti:Show()
        HunterHelper:SetControlAlpha(HunterHelper_SuggestMulti, HunterHelper_SF:GetAlpha())
    else
        HunterHelper_SuggestMulti:Hide()
    end
end


function eventHandlers:PLAYER_REGEN_DISABLED(...)
    inCombat = true
end


function eventHandlers:PLAYER_REGEN_ENABLED(...)
    inCombat = false
end


function HunterHelper_SF:OnCooldownFinish(spell, book, callback)
    if not GetSpellInfo(spell) then
        return
    end
    local start, duration, enabled = GetSpellCooldown(spell, book);
    if duration > 1.6 then
        local delay = math.max(0, start + duration - GetTime() + 0.1)
        C_Timer.After(delay, callback)
    end
end


function eventHandlers:SPELL_UPDATE_COOLDOWN(...)
    HunterHelper_SF:OnCooldownFinish("Aimed Shot", "BOOKTYPE_SPELL", HunterHelper_SF.UpdateAimed);
    HunterHelper_SF:OnCooldownFinish("Multi-Shot", "BOOKTYPE_SPELL", HunterHelper_SF.UpdateMulti);
end


