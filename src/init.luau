--Main module for LocalAudio Subtitles.
--!strict

local EventTransform = require(script:WaitForChild("EventTransform"))
local Types = require(script:WaitForChild("LocalAudioSubtitlesTypes"))
local LocalAudio = require(script:WaitForChild("Packages"):WaitForChild("LocalAudio"))
local SubtitleWindow = require(script:WaitForChild("UI"):WaitForChild("SubtitleWindow")).new()

local LocalAudioSubtitles = {
    MinimumSubtitleLevel = 0,
}

export type SubtitleData = Types.SubtitleData
export type SubtitleSpeaker = Types.SubtitleSpeaker
export type SubtitleDataModule = Types.SubtitleDataModule
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
function LocalAudioSubtitles.SetUp(self: LocalAudioSubtitles, SubtitlesData: Types.SubtitleDataModule): ()
    --Transform the subtitles.
    local AudioData = LocalAudio.AudioData
    if SubtitlesData then
        EventTransform:SetSubtitleData(SubtitlesData)
    end
    EventTransform:PopulateEvents(AudioData.Sounds);

    --Connect the events.
    LocalAudio:OnEventFired("ShowSubtitle"):Connect(function(_, SubtitleEvent, Parent: Instance?, Sound: Sound)
        self:ShowSubtitle(SubtitleEvent.Message, SubtitleEvent.Duration, SubtitleEvent.Level, Parent and Sound or nil)
    end)
end



return LocalAudioSubtitles