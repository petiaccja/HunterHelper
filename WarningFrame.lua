HunterHelper_WF = {}


local inCombat = false
local eventHandlers = {}
local aimedCooldown = false
local multiCooldown = false
local combatAlpha = 1.0
local standbyAlpha = 0.3


function HunterHelper_WF:OnLoad()
    HunterHelper_WarningFrame:SetScript("OnEvent", HunterHelper_WF.OnEvent);
    HunterHelper_WarningFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    HunterHelper_WarningFrame:RegisterEvent("UNIT_AURA")
    HunterHelper_WarningFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    HunterHelper_WarningFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    HunterHelper_WarningFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

    HunterHelper_WarningFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    HunterHelper_WarningFrame:RegisterEvent("ACTIONBAR_UPDATE_STATE")
end


function HunterHelper_WF:OnEvent(event, ...)
    if eventHandlers[event] ~= nil then
        eventHandlers[event](...)
    end
    HunterHelper_WF:UpdateSting()
    HunterHelper_WF:UpdateMark()
    HunterHelper_WF:UpdateAimed()
    HunterHelper_WF:UpdateMulti()
end


function HunterHelper_WF:HasAttackableTarget()
    local isEnemy = UnitCanAttack("player","target")
    local exists = UnitExists("target")
    local isDead = UnitIsDead("target")
    return not isDead and isEnemy and exists
end


function HunterHelper_WF:GetAlpha()
    if inCombat then
        return combatAlpha
    else
        return standbyAlpha
    end
end


function HunterHelper_WF:SuggestSerpent()
    local activeSting = HunterHelper:GetSting()
    return not activeSting and HunterHelper_WF:HasAttackableTarget()
end


function HunterHelper_WF:SuggestMark()
    local hasMark = HunterHelper:GetMark()
    return not hasMark and HunterHelper_WF:HasAttackableTarget()
end


function HunterHelper_WF:SuggestAimed()
    local start, duration, enabled = GetSpellCooldown("Aimed Shot", "BOOKTYPE_SPELL");
    local isReady = duration < 1.6 -- GCD also counts as cooldown.
    return isReady and HunterHelper_WF:HasAttackableTarget()
end


function HunterHelper_WF:SuggestMulti()
    local start, duration, enabled = GetSpellCooldown("Multi-Shot", "BOOKTYPE_SPELL");
    local isReady = duration < 1.6 -- GCD also counts as cooldown.
    return isReady and HunterHelper_WF:HasAttackableTarget()
end


function HunterHelper_WF:UpdateSting()
    local suggest = HunterHelper_WF:SuggestSerpent()
    if suggest then
        HunterHelper_SuggestSerpent:Show()
        HunterHelper_SuggestSerpent:SetVertexColor(1,1,1,HunterHelper_WF:GetAlpha())
    else
        HunterHelper_SuggestSerpent:Hide()
    end
end


function HunterHelper_WF:UpdateMark()
    local suggest = HunterHelper_WF:SuggestMark()
    if suggest then
        HunterHelper_SuggestMark:Show()
        HunterHelper_SuggestMark:SetVertexColor(1,1,1,HunterHelper_WF:GetAlpha())
    else
        HunterHelper_SuggestMark:Hide()
    end
end


function HunterHelper_WF:UpdateAimed()
    local suggest = HunterHelper_WF:SuggestAimed()
    if suggest then
        HunterHelper_SuggestAimed:Show()
        HunterHelper_SuggestAimed:SetVertexColor(1,1,1,HunterHelper_WF:GetAlpha())
    else
        HunterHelper_SuggestAimed:Hide()
    end
end


function HunterHelper_WF:UpdateMulti()
    local suggest = HunterHelper_WF:SuggestMulti()
    if suggest then
        HunterHelper_SuggestMulti:Show()
        HunterHelper_SuggestMulti:SetVertexColor(1,1,1,HunterHelper_WF:GetAlpha())
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


function HunterHelper_WF:OnCooldownFinish(spell, book, callback)
    local start, duration, enabled = GetSpellCooldown(spell, book);
    if duration > 1.6 then
        local delay = math.max(0, start + duration - GetTime() + 0.1)
        C_Timer.After(delay, callback)
    end
end


function eventHandlers:SPELL_UPDATE_COOLDOWN(...)
    HunterHelper_WF:OnCooldownFinish("Aimed Shot", "BOOKTYPE_SPELL", HunterHelper_WF.UpdateAimed);
    HunterHelper_WF:OnCooldownFinish("Multi-Shot", "BOOKTYPE_SPELL", HunterHelper_WF.UpdateMulti);
end


