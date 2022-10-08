--[[
TheNexusAvenger

Sets up the LocalAudio Subtitles.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalAudioSubtitles = require(ReplicatedStorage:WaitForChild("LocalAudioSubtitles"))
local LocalAudioModule = ReplicatedStorage:WaitForChild("LocalAudio")
local SubtitlesData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("Subtitles"))

LocalAudioSubtitles:SetUp(LocalAudioModule, SubtitlesData)
require(LocalAudioModule):SetUp()

wait(2)
require(LocalAudioModule):PlayAudio("MultiSubtitleDemo")