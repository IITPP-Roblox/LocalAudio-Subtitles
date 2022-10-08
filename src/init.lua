--[[
TheNexusAvenger

Main module for LocalAudio Subtitles.
--]]

local SubtitleWindow = require(script:WaitForChild("UI"):WaitForChild("SubtitleWindow")).new()

local LocalAudioSubtitles = {}



--[[
Shows a subtitle in the window.
--]]
function LocalAudioSubtitles:ShowSubtitle(Message: string, Duration: number): nil
    SubtitleWindow:ShowSubtitle(Message, Duration)
end

--[[
Sets up the subtitles with LocalAudio.
--]]
function LocalAudioSubtitles:SetUp(LocalAudioModule: ModuleScript): nil
    --Parse the subtitles.
    local AudioData = require(LocalAudioModule:WaitForChild("AudioData"))
    --TODO

    --Connect the events.
    require(LocalAudioModule):OnEventFired("ShowSubtitle"):Connect(function(_, SubtitleEvent)
        self:ShowSubtitle(SubtitleEvent.Message, SubtitleEvent.Duration)
    end)
end



return LocalAudioSubtitles