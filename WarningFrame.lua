HunterHelper_WF = {}

function HunterHelper_WF:OnLoad()
    HunterHelper_WF:Update(false, false, false)
end


function HunterHelper_WF:Update(warnMulti, blockSingle, blockMulti)
    HunterHelper_BlockSerpent:Hide()
    HunterHelper_BlockAimed:Hide()
    HunterHelper_BlockMulti:Hide()
    HunterHelper_WarnMulti:Hide()

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


function HunterHelper_WF:SetConfig(config)
    local size = config.size * 0.7
    HunterHelper_WarningFrame:SetSize(4*config.size, config.size)
    HunterHelper_BlockSerpent:SetSize(size, size)
    HunterHelper_BlockAimed:SetSize(size, size)
    HunterHelper_BlockMulti:SetSize(size, size)
    HunterHelper_WarnMulti:SetSize(size, size)
end