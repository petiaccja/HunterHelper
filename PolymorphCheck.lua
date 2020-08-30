SharpShooter_PC = {}

local function AuraInfo(duration)
    local auraInfo = {}
    auraInfo.duration = duration
    return auraInfo
end

local eventHandlers = {}
local unitTracker = {}

local polyStatus_Log = false
local polyStatus_Raid = false
local polyStatus_Party = false
local polyStatus_Target = false

local trackedSpells = {
    -- druid
    -- hunter
    ["Freezing Trap Effect"] = AuraInfo(20),
    ["Scare Beast"] = AuraInfo(20),
    -- mage
    ["Polymorph"] = AuraInfo(50),
    -- paladin
    -- rogue
    ["Sap"] = AuraInfo(45),
    -- shaman
    -- warlock
    -- warrior
    -- DEBUG:
    -- ["Hunter's Mark"] = AuraInfo(120),
}


local COMBATLOG_OBJECT_REACTION_HOSTILE	= 0x00000040
local COMBATLOG_OBJECT_REACTION_NEUTRAL	= 0x00000020
local COMBATLOG_OBJECT_REACTION_FRIENDLY = 0x00000010


function SharpShooter_PC:OnLoad()
    SharpShooter_PolyFrame:SetScript("OnEvent", SharpShooter_PC.OnEvent)
    SharpShooter_PolyFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    SharpShooter_PolyFrame:RegisterEvent("UNIT_AURA")
    SharpShooter_PolyFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    SharpShooter_PC.sweepTicker = C_Timer.NewTicker(0.5, SharpShooter_PC.SweepExpired)
end


function SharpShooter_PC:OnEvent(event, ...)
    if eventHandlers[event] ~= nil then
        eventHandlers[event](...)
    end
end


function SharpShooter_PC:OnAuraApplied(destGUID, destName, destFlags, spellName)
    local isDestAttackable = bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE
    or bit.band(destFlags, COMBATLOG_OBJECT_REACTION_NEUTRAL) == COMBATLOG_OBJECT_REACTION_NEUTRAL
    local isSpellTracked = trackedSpells[spellName] ~= nil
    if isDestAttackable and isSpellTracked then
        if unitTracker[destGUID] == nil then
            unitTracker[destGUID] = {}
        end
        unitTracker[destGUID][spellName] = GetTime() + trackedSpells[spellName].duration;
    end
end


function SharpShooter_PC:OnAuraRemoved(destGUID, destName, destFlags, spellName)
    if unitTracker[destGUID] ~= nil then
        if unitTracker[destGUID][spellName] ~= nil then
            unitTracker[destGUID][spellName] = nil
        end
        if next(unitTracker[destGUID]) == nil then
            unitTracker[destGUID] = nil
        end
    end
end


function SharpShooter_PC:SweepExpired()
    local time = GetTime()
    for unitGUID, trackedSpells in pairs(unitTracker) do
        for spellName, expirationTime in pairs(trackedSpells) do
            if time > expirationTime then
                trackedSpells[spellName] = nil
            end
        end
        if next(trackedSpells) == nil then
            unitTracker[unitGUID] = nil
            polyStatus_Log = next(unitTracker) ~= nil
        end
    end

    polyStatus_Log = next(unitTracker) ~= nil
end


function SharpShooter_PC:IsRaidMemberAttackable()
    for i=1,40 do
        local unitId = "raid" .. i
        local isAttackable = UnitCanAttack("player",unitId)
        local isInRange = IsSpellInRange("Multi-Shot", "target")
        if isAttackable and isInRange then
            return true
        end
    end
    return false
end


function SharpShooter_PC:IsPartyMemberAttackable()
    for i=1,4 do
        local unitId = "party" .. i
        local isAttackable = UnitCanAttack("player",unitId)
        local isInRange = IsSpellInRange("Multi-Shot", "target")
        if isAttackable and isInRange then
            return true
        end
    end
    return false
end


function SharpShooter_PC:IsTargetPolymorphed()
    local attackable = UnitCanAttack("player","target")
    if not attackable then
        return false
    end
    local auras = SharpShooter:GetAllAuras("target", "HARMFUL")
    for k,aura in pairs(auras) do
        if trackedSpells[aura.name] ~= nil then
            return true
        end
    end
    return false
end


function SharpShooter_PC:UpdateWarningFrame()
    local warnMulti = polyStatus_Log
    local blockSingle = polyStatus_Target
    local blockMulti = polyStatus_Raid or polyStatus_Party
    SharpShooter_WF:Update(warnMulti, blockSingle, blockMulti)
end


function eventHandlers:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, event, hiding, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellID, spellName, spellSchool,
          sp1, sp2, sp3, sp4, sp5, sp6, sp7, sp8, sp9 
        = CombatLogGetCurrentEventInfo()

    if (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH") then
        SharpShooter_PC:OnAuraApplied(destGUID, destName, destFlags, spellName)
    elseif (event == "SPELL_AURA_REMOVED" or event == "SPELL_AURA_BROKEN") then
        SharpShooter_PC:OnAuraRemoved(destGUID, destName, destFlags, spellName)
    end
    
    polyStatus_Log = next(unitTracker) ~= nil    
    SharpShooter_PC:UpdateWarningFrame()
end


function eventHandlers:UNIT_AURA()
    polyStatus_Target = SharpShooter_PC:IsTargetPolymorphed()
    polyStatus_Party = SharpShooter_PC:IsPartyMemberAttackable()
    polyStatus_Raid = SharpShooter_PC:IsRaidMemberAttackable()

    SharpShooter_PC:UpdateWarningFrame()
end


function eventHandlers:PLAYER_TARGET_CHANGED()
    polyStatus_Target = SharpShooter_PC:IsTargetPolymorphed()

    SharpShooter_PC:UpdateWarningFrame()
end