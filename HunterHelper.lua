HunterHelper = {}


HunterHelper.Aspects = {
    "Aspect of the Hawk",
    "Aspect of the Cheetah",
    "Aspect of the Pack",
    "Aspect of the Monkey",
    "Aspect of the Beast",
    "Aspect of the Wild",
}


HunterHelper.Stings = {
    "Scorpid Sting",
    "Serpent Sting",
    "Viper Sting",
    "Wyvern Sting",
}


function HunterHelper:GetAllAuras(unit, filter)
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


function HunterHelper:GetAspect()
    local auras = HunterHelper:GetAllAuras("player", "PLAYER")
    for k,aura in pairs(auras) do
        for l,aspect in pairs(HunterHelper.Aspects) do
            if aura.name == aspect then
                return aura.name
            end
        end
    end
    return nil
end


function HunterHelper:GetSting()
    local auras = HunterHelper:GetAllAuras("target", "PLAYER|HARMFUL")
    for k,aura in pairs(auras) do
        for l,aspect in pairs(HunterHelper.Stings) do
            if aura.name == aspect then
                return aura.name
            end
        end
    end
    return nil
end


function HunterHelper:GetMark()
    local auras = HunterHelper:GetAllAuras("target", "HARMFUL")
    for k,aura in pairs(auras) do
        if aura.name == "Hunter's Mark" then
            return true
        end
    end
    return nil
end


function HunterHelper:SetControlAlpha(control, alpha)
    control:SetVertexColor(1,1,1,alpha)
end