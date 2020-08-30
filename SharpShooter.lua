SharpShooter = {}


SharpShooter.Aspects = {
    "Aspect of the Hawk",
    "Aspect of the Cheetah",
    "Aspect of the Pack",
    "Aspect of the Monkey",
    "Aspect of the Beast",
    "Aspect of the Wild",
}


SharpShooter.Stings = {
    "Scorpid Sting",
    "Serpent Sting",
    "Viper Sting",
    "Wyvern Sting",
}


function SharpShooter:GetAllAuras(unit, filter)
    local auras = {}
    for i=1,40 do 
        local name, _, _, _, duration, expirationTime, unitCaster, _, _, _, _ = UnitAura(unit, i, filter)
        if name then
            aura = {}
            aura.name = name
            aura.duration = duration
            aura.expirationTime = expirationTime
            aura.unitCaster = unitCaster
            table.insert(auras, aura)
        end
    end
    return auras
end


function SharpShooter:GetAspect()
    local auras = SharpShooter:GetAllAuras("player", "PLAYER")
    for k,aura in pairs(auras) do
        for l,aspect in pairs(SharpShooter.Aspects) do
            if aura.name == aspect then
                return aura.name
            end
        end
    end
    return nil
end


function SharpShooter:GetSting()
    local auras = SharpShooter:GetAllAuras("target", "PLAYER|HARMFUL")
    for k,aura in pairs(auras) do
        for l,aspect in pairs(SharpShooter.Stings) do
            if aura.name == aspect then
                return aura.name
            end
        end
    end
    return nil
end


function SharpShooter:GetMark()
    local auras = SharpShooter:GetAllAuras("target", "HARMFUL")
    for k,aura in pairs(auras) do
        if aura.name == "Hunter's Mark" then
            return true
        end
    end
    return nil
end


function SharpShooter:IsPlayerHunter()
    return UnitClass("player") == "Hunter"
end


function SharpShooter:HasPlayerSpell(spell)
    return GetSpellInfo(spell) ~= nil
end


function SharpShooter:HasAttackableTarget()
    local isEnemy = UnitCanAttack("player","target")
    local exists = UnitExists("target")
    local isDead = UnitIsDead("target")
    return not isDead and isEnemy and exists
end