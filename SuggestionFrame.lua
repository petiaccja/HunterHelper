SharpShooter_SF = {}


local loaded = false
local inCombat = false
local eventHandlers = {}
local combatAlpha = 1.0
local idleAlpha = 0.3
local notargetAlpha = 0.1
local iconSize = 64;
local isEnabled = false

local warnMulti = false
local blockSingle = false
local blockMulti = false

local STATE_HIDDEN = 0
local STATE_COOLDOWN = 1
local STATE_APPLIED = 2
local STATE_READY = 3
local STATE_WARN = 4
local STATE_BLOCK = 5


local bar = {
    ["body"] = nil,
    ["buttons"] = {},
}

local spells = {}

function SharpShooter_SF:OnLoad()
    if loaded then
        return
    end

    spells = SharpShooter_SF:HunterSpellSuggestions()

    bar.body = SharpShooter_SF:CreateBarMainFrame()
    SharpShooter_SF:ResizeBar(#spells)
    for k,v in pairs(spells) do
        bar.buttons[k].texReady:SetTexture(v.icon)
    end

    bar.body:SetScript("OnEvent", SharpShooter_SF.OnEvent);
    loaded = true
end


function SharpShooter_SF:RegisterEvents()
    bar.body:RegisterEvent("PLAYER_ENTERING_WORLD")
    bar.body:RegisterEvent("UNIT_AURA")
    bar.body:RegisterEvent("PLAYER_TARGET_CHANGED")
    bar.body:RegisterEvent("PLAYER_REGEN_ENABLED")
    bar.body:RegisterEvent("PLAYER_REGEN_DISABLED")

    bar.body:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    bar.body:RegisterEvent("ACTIONBAR_UPDATE_STATE")
end


function SharpShooter_SF:UnregisterEvents()
    bar.body:UnregisterEvent("PLAYER_ENTERING_WORLD")
    bar.body:UnregisterEvent("UNIT_AURA")
    bar.body:UnregisterEvent("PLAYER_TARGET_CHANGED")
    bar.body:UnregisterEvent("PLAYER_REGEN_ENABLED")
    bar.body:UnregisterEvent("PLAYER_REGEN_DISABLED")

    bar.body:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
    bar.body:UnregisterEvent("ACTIONBAR_UPDATE_STATE")
end


function SharpShooter_SF:ResizeBar(numButtons)
    for k,v in pairs(bar.buttons) do
        v:Hide()
        v:SetParent(nil)
    end
    for i=1,numButtons - #bar.buttons do
        table.insert(bar.buttons, SharpShooter_SF:CreateSpellFrame())
    end
    local prevRelativeFrame = bar.body
    local prevRelativePoint = "LEFT"
    for i=1,numButtons do
        bar.buttons[i]:SetParent(bar.body)
        bar.buttons[i]:Show()
        bar.buttons[i]:ClearAllPoints()
        bar.buttons[i]:SetPoint("LEFT", prevRelativeFrame, prevRelativePoint, 0, 0)
        prevRelativeFrame = bar.buttons[i]
        prevRelativePoint = "RIGHT"
    end
    bar.body:SetWidth(bar.body:GetHeight() * numButtons)
end


function SharpShooter_SF:ShowBar()
    bar.body:Show()
end


function SharpShooter_SF:HideBar()
    bar.body:Hide()
end


function SharpShooter_SF:OnEvent(event, ...)
    if eventHandlers[event] ~= nil then
        eventHandlers[event](...)
    end
    SharpShooter_SF:UpdateSuggestions()
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


function SharpShooter_SF:SetConfigPosition(x, y)
    bar.body:ClearAllPoints()
    bar.body:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
end


function SharpShooter_SF:GetConfigPosition()
    return bar.body:GetCenter()
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


function SharpShooter_SF:SetConfigMovable(movable)
    if movable then
        bar.body:SetMovable(true)
        bar.body:EnableMouse(true)
        bar.body:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" and not self.isMoving then
                self:StartMoving();
                self.isMoving = true;
            end
        end)
        bar.body:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" and self.isMoving then
                self:StopMovingOrSizing();
                self.isMoving = false;
                local xOffset, yOffset = self:GetCenter(0)
                local key = SharpShooter_CFG.characterName
                g_sharpShooterConfig[key].xPosition = xOffset
                g_sharpShooterConfig[key].yPosition = yOffset
            end
        end)
        bar.body:SetScript("OnHide", function(self)
            if self.isMoving then
                self:StopMovingOrSizing();
                self.isMoving = false;
            end
        end)
    else
        bar.body:SetMovable(false)
        bar.body:EnableMouse(false)
    end
end


function SharpShooter_SF:UpdateAlpha()
    bar.body:SetAlpha(SharpShooter_SF:GetAlpha())
end


function SharpShooter_SF:UpdateSize()
    bar.body:SetSize(4*iconSize, iconSize)

    for k,v in pairs(bar.buttons) do
        v:SetSize(iconSize, iconSize)
    end
end


function SharpShooter_SF:UpdateSuggestions()
    for k,v in pairs(spells) do
        local newState = v.func()
        bar.buttons[k]:SetState(newState)
    end
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


function SharpShooter_SF:UpdateBlocks(warnMulti_, blockSingle_, blockMulti_)
    warnMulti = warnMulti_
    blockSingle = blockSingle_
    blockMulti = blockMulti_
end


function SharpShooter_SF:SpellSuggestion(spellIcon, suggestFunc)
    local spellSuggestion = {}
    spellSuggestion.icon = spellIcon
    spellSuggestion.func = suggestFunc
    return spellSuggestion
end


function SharpShooter_SF:HunterSpellSuggestions()
    local spells = {}
    if SharpShooter:HasPlayerSpell("Hunter's Mark") then
        table.insert(spells, SharpShooter_SF:SpellSuggestion("interface/icons/ability_hunter_snipershot.blp", SharpShooter_SF.SuggestMark))
    end
    if SharpShooter:HasPlayerSpell("Serpent Sting") then
        table.insert(spells, SharpShooter_SF:SpellSuggestion("interface/icons/ability_hunter_quickshot.blp", SharpShooter_SF.SuggestSerpent))
    end
    if SharpShooter:HasPlayerSpell("Aimed Shot") then
        table.insert(spells, SharpShooter_SF:SpellSuggestion("interface/icons/inv_spear_07.blp", SharpShooter_SF.SuggestAimed))
    end
    if SharpShooter:HasPlayerSpell("Multi-Shot") then
        table.insert(spells, SharpShooter_SF:SpellSuggestion("interface/icons/ability_upgrademoonglaive.blp", SharpShooter_SF.SuggestMulti))
    end
    return spells
end


function SharpShooter_SF:SuggestMark()
    local hasMark = SharpShooter:GetMark()
    local hasTarget = SharpShooter:HasAttackableTarget()

    if hasMark then
        return STATE_APPLIED
    elseif hasTarget then
        return STATE_READY
    else
        return STATE_HIDDEN
    end
end


function SharpShooter_SF:SuggestSerpent()
    local activeSting = SharpShooter:GetSting()
    local hasTarget = SharpShooter:HasAttackableTarget()

    if blockSingle then
        return STATE_BLOCK
    elseif hasTarget and not activeSting then
        return STATE_READY
    elseif hasTarget and activeSting == "Serpent Sting" then
        return STATE_APPLIED
    elseif hasTarget and activeSting ~= "Serpent Sting" then
        return STATE_COOLDOWN
    else
        return STATE_HIDDEN
    end
end


function SharpShooter_SF:SuggestAimed()
    local _, duration, _ = GetSpellCooldown("Aimed Shot", "BOOKTYPE_SPELL");
    local isCooldownReady = duration < 1.6 -- GCD also counts as cooldown.
    local hasTarget = SharpShooter:HasAttackableTarget()

    if blockSingle then
        return STATE_BLOCK
    elseif hasTarget and isCooldownReady then
        return STATE_READY
    elseif hasTarget then
        return STATE_COOLDOWN
    else
        return STATE_HIDDEN
    end
end


function SharpShooter_SF:SuggestMulti()
    local _, duration, _ = GetSpellCooldown("Multi-Shot", "BOOKTYPE_SPELL");
    local isCooldownReady = duration < 1.6 -- GCD also counts as cooldown.
    local hasTarget = SharpShooter:HasAttackableTarget()

    if blockMulti or blockSingle then
        return STATE_BLOCK
    elseif warnMulti then
        return STATE_WARN
    elseif hasTarget and isCooldownReady then
        return STATE_READY
    elseif hasTarget then
        return STATE_COOLDOWN
    else
        return STATE_HIDDEN
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
    SharpShooter_SF:OnCooldownFinish("Aimed Shot", "BOOKTYPE_SPELL", SharpShooter_SF.UpdateSuggestions);
    SharpShooter_SF:OnCooldownFinish("Multi-Shot", "BOOKTYPE_SPELL", SharpShooter_SF.UpdateSuggestions);
end



function SharpShooter_SF:CreateBarMainFrame()
    local frame = CreateFrame("Frame", "BarMain", UIParent)
    frame:SetPoint("CENTER", 0, 0)
    frame:SetWidth(256)
    frame:SetHeight(64)
    return frame;
end


function SharpShooter_SF:CreateSpellFrame(parent)
    if parent == nil then
        parent = UIParent
    end
    local frame = CreateFrame("Frame", "BarMain", parent)
    frame:SetWidth(64)
    frame:SetHeight(64)

    frame:SetPoint("CENTER", 0, 0)

    frame.texCooldown = frame:CreateTexture(nil, "BACKGROUND")
    frame.texApplied = frame:CreateTexture(nil, "BACKGROUND")
    frame.texReady = frame:CreateTexture(nil, "ARTWORK")
    frame.texWarn = frame:CreateTexture(nil, "OVERLAY")
    frame.texBlock = frame:CreateTexture(nil, "OVERLAY")

    frame.texCooldown:SetAllPoints(frame)
    frame.texApplied:SetAllPoints(frame)
    frame.texReady:SetAllPoints(frame)
    frame.texWarn:SetAllPoints(frame)
    frame.texBlock:SetAllPoints(frame)

    frame.texCooldown:SetTexture("Interface/Addons/SharpShooter/graphics/hourglass.blp")
    frame.texApplied:SetTexture("Interface/Addons/SharpShooter/graphics/tick.blp")
    frame.texReady:SetTexture("interface/icons/ability_upgrademoonglaive.blp")
    frame.texWarn:SetTexture("Interface/Addons/SharpShooter/graphics/warning_sign_2.blp")
    frame.texBlock:SetTexture("Interface/Addons/SharpShooter/graphics/block_sign_2.blp")

    function frame:SetState(state)
        frame.texCooldown:Hide()
        frame.texApplied:Hide()
        frame.texReady:Hide()
        frame.texWarn:Hide()
        frame.texBlock:Hide()
        if state == STATE_COOLDOWN then
            frame.texCooldown:Show()
        elseif state == STATE_APPLIED then
            frame.texApplied:Show()
        elseif state == STATE_READY then
            frame.texReady:Show()
        elseif state == STATE_WARN then
            frame.texReady:Show()
            frame.texWarn:Show()
        elseif state == STATE_BLOCK then
            frame.texReady:Show()
            frame.texBlock:Show()
        end
    end

    frame:SetState(STATE_WARN)

    return frame
end