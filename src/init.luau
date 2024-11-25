--Main module for LocalAudio Subtitles.
--!strict

local EventTransform = require(script:WaitForChild("EventTransform"))
local Types = require(script:WaitForChild("LocalAudioSubtitlesTypes"))
local SubtitleWindow = require(script:WaitForChild("UI"):WaitForChild("SubtitleWindow")).new()

local LocalAudioSubtitles = {
    MinimumSubtitleLevel = 0,
}

export type LocalAudioSubtitles = typeof(LocalAudioSubtitles)



--[[
Shows a subtitle in the window.
--]]
function LocalAudioSubtitles.ShowSubtitle(self: LocalAudioSubtitles, Message: string, Duration: number, Level: number?, ReferenceSound: Sound?): ()
    if Level and self.MinimumSubtitleLevel < Level then return end
    SubtitleWindow:ShowSubtitle(Message, Duration, ReferenceSound)
end

--[[
Sets the minimum subtitle level to display.
--]]
function LocalAudioSubtitles.SetSubtitleLevel(self: LocalAudioSubtitles,MinimumSubtitleLevel: number): ()
    self.MinimumSubtitleLevel = MinimumSubtitleLevel
end

--[[
Sets up the subtitles with LocalAudio.
--]]
function LocalAudioSubtitles.SetUp(self: LocalAudioSubtitles,LocalAudioModule: ModuleScript, SubtitlesData: Types.SubtitleDataModule): ()
    --Transform the subtitles.
    local AudioData = require(LocalAudioModule:WaitForChild("AudioData")) :: any
    if SubtitlesData then
        EventTransform:SetSubtitleData(SubtitlesData)
    end
    EventTransform:PopulateEvents(AudioData.Sounds);

    --Connect the events.
    (require(LocalAudioModule) :: any):OnEventFired("ShowSubtitle"):Connect(function(_, SubtitleEvent, Parent: Instance?, Sound: Sound)
        self:ShowSubtitle(SubtitleEvent.Message, SubtitleEvent.Duration, SubtitleEvent.Level, Parent and Sound or nil)
    end)
end



return LocalAudioSubtitles