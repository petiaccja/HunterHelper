HunterHelper_WF = {}

local combatAlpha = 1.0
local iconSize = 64
local isEnabled = false


function HunterHelper_WF:OnLoad()
    HunterHelper_WF:Update(false, false, false)
end


function HunterHelper_WF:Update(warnMulti, blockSingle, blockMulti)
    HunterHelper_BlockSerpent:Hide()
    HunterHelper_BlockAimed:Hide()
    HunterHelper_BlockMulti:Hide()
    HunterHelper_WarnMulti:Hide()

    if not isEnabled then
        return
    end

    if blockSingle then
        HunterHelper_BlockSerpent:Show()
        HunterHelper_BlockAimed:Show()
        HunterHelper_BlockMulti:Show()
    elseif blockMulti then
        HunterHelper_BlockMulti:Show()
    elseif warnMulti then
        HunterHelper_WarnMulti:Show()
    end
end


function HunterHelper_WF:SetConfigAlpha(combatAlpha_, idleAlpha_, notargetAlpha_)
    combatAlpha = combatAlpha_
    HunterHelper_WF:UpdateAlpha()
end


function HunterHelper_WF:SetConfigSize(size)
    iconSize = size
    HunterHelper_WF:UpdateSize()
end


function HunterHelper_WF:SetConfigEnabled(enable)
    if not enable and isEnabled then
        HunterHelper_BlockSerpent:Hide()
        HunterHelper_BlockAimed:Hide()
        HunterHelper_BlockMulti:Hide()
        HunterHelper_WarnMulti:Hide()
    end
    isEnabled = enable
end


function HunterHelper_WF:UpdateAlpha()
    HunterHelper_WarningFrame:SetAlpha(combatAlpha)
end


function HunterHelper_WF:UpdateSize()
    local signSize = 0.75 * iconSize
    HunterHelper_WarningFrame:SetSize(4*iconSize, iconSize)
    HunterHelper_BlockSerpent:SetSize(signSize, signSize)
    HunterHelper_BlockAimed:SetSize(signSize, signSize)
    HunterHelper_BlockMulti:SetSize(signSize, signSize)
    HunterHelper_WarnMulti:SetSize(signSize, signSize)
end