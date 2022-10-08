--[[
TheNexusAvenger

Main module for LocalAudio Subtitles.
--]]

local SubtitleWindow = require(script:WaitForChild("UI"):WaitForChild("SubtitleWindow")).new()

local LocalAudioSubtitles = {}



--[[
Sets up the subtitles with LocalAudio.
--]]
function LocalAudioSubtitles:SetUp(LocalAudioModule: ModuleScript, AudioDataModule: ModuleScript): nil
    
end

--[[
Shows a subtitle in the window.
--]]
function LocalAudioSubtitles:ShowSubtitle(Message: string, Duration: number): nil
    SubtitleWindow:ShowSubtitle(Message, Duration)
end




return LocalAudioSubtitles