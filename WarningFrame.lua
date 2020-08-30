SharpShooter_WF = {}

local combatAlpha = 1.0
local iconSize = 64
local isEnabled = false


function SharpShooter_WF:OnLoad()
    SharpShooter_WF:Update(false, false, false)
end


function SharpShooter_WF:Update(warnMulti, blockSingle, blockMulti)
    SharpShooter_BlockSerpent:Hide()
    SharpShooter_BlockAimed:Hide()
    SharpShooter_BlockMulti:Hide()
    SharpShooter_WarnMulti:Hide()

    if not isEnabled then
        return
    end

    if blockSingle then
        SharpShooter_BlockSerpent:Show()
        SharpShooter_BlockAimed:Show()
        SharpShooter_BlockMulti:Show()
    elseif blockMulti then
        SharpShooter_BlockMulti:Show()
    elseif warnMulti then
        SharpShooter_WarnMulti:Show()
    end
end


function SharpShooter_WF:SetConfigAlpha(combatAlpha_, idleAlpha_, notargetAlpha_)
    combatAlpha = combatAlpha_
    SharpShooter_WF:UpdateAlpha()
end


function SharpShooter_WF:SetConfigSize(size)
    iconSize = size
    SharpShooter_WF:UpdateSize()
end


function SharpShooter_WF:SetConfigEnabled(enable)
    if not enable and isEnabled then
        SharpShooter_BlockSerpent:Hide()
        SharpShooter_BlockAimed:Hide()
        SharpShooter_BlockMulti:Hide()
        SharpShooter_WarnMulti:Hide()
    end
    isEnabled = enable
end


function SharpShooter_WF:UpdateAlpha()
    SharpShooter_WarningFrame:SetAlpha(combatAlpha)
end


function SharpShooter_WF:UpdateSize()
    local signSize = 0.75 * iconSize
    SharpShooter_WarningFrame:SetSize(4*iconSize, iconSize)
    SharpShooter_BlockSerpent:SetSize(signSize, signSize)
    SharpShooter_BlockAimed:SetSize(signSize, signSize)
    SharpShooter_BlockMulti:SetSize(signSize, signSize)
    SharpShooter_WarnMulti:SetSize(signSize, signSize)
end