HunterHelper_SF = {}


local inCombat = false
local eventHandlers = {}
local aimedCooldown = false
local multiCooldown = false
local combatAlpha = 1.0
local standbyAlpha = 0.3


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
end


function HunterHelper_SF:HasAttackableTarget()
    local isEnemy = UnitCanAttack("player","target")
    local exists = UnitExists("target")
    local isDead = UnitIsDead("target")
    return not isDead and isEnemy and exists
end


function HunterHelper_SF:GetAlpha()
    if inCombat then
        return combatAlpha
    else
        return standbyAlpha
    end
end


function HunterHelper_SF:SuggestSerpent()
    local activeSting = HunterHelper:GetSting()
    return not activeSting and HunterHelper_SF:HasAttackableTarget()
end


function HunterHelper_SF:SuggestMark()
    local hasMark = HunterHelper:GetMark()
    return not hasMark and HunterHelper_SF:HasAttackableTarget()
end


function HunterHelper_SF:SuggestAimed()
    local start, duration, enabled = GetSpellCooldown("Aimed Shot", "BOOKTYPE_SPELL");
    local isReady = duration < 1.6 -- GCD also counts as cooldown.
    return isReady and HunterHelper_SF:HasAttackableTarget()
end


function HunterHelper_SF:SuggestMulti()
    local start, duration, enabled = GetSpellCooldown("Multi-Shot", "BOOKTYPE_SPELL");
    local isReady = duration < 1.6 -- GCD also counts as cooldown.
    return isReady and HunterHelper_SF:HasAttackableTarget()
end


function HunterHelper_SF:UpdateSting()
    local suggest = HunterHelper_SF:SuggestSerpent()
    if suggest then
        HunterHelper_SuggestSerpent:Show()
        HunterHelper_SuggestSerpent:SetVertexColor(1,1,1,HunterHelper_SF:GetAlpha())
    else
        HunterHelper_SuggestSerpent:Hide()
    end
end


function HunterHelper_SF:UpdateMark()
    local suggest = HunterHelper_SF:SuggestMark()
    if suggest then
        HunterHelper_SuggestMark:Show()
        HunterHelper_SuggestMark:SetVertexColor(1,1,1,HunterHelper_SF:GetAlpha())
    else
        HunterHelper_SuggestMark:Hide()
    end
end


function HunterHelper_SF:UpdateAimed()
    local suggest = HunterHelper_SF:SuggestAimed()
    if suggest then
        HunterHelper_SuggestAimed:Show()
        HunterHelper_SuggestAimed:SetVertexColor(1,1,1,HunterHelper_SF:GetAlpha())
    else
        HunterHelper_SuggestAimed:Hide()
    end
end


function HunterHelper_SF:UpdateMulti()
    local suggest = HunterHelper_SF:SuggestMulti()
    if suggest then
        HunterHelper_SuggestMulti:Show()
        HunterHelper_SuggestMulti:SetVertexColor(1,1,1,HunterHelper_SF:GetAlpha())
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


