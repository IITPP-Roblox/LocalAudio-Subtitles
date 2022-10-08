--[[
TheNexusAvenger

Sets up the LocalAudio Subtitles.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalAudioSubtitles = require(ReplicatedStorage:WaitForChild("LocalAudioSubtitles"))
local LocalAudioModule = ReplicatedStorage:WaitForChild("LocalAudio")

LocalAudioSubtitles:SetUp(LocalAudioModule)
require(LocalAudioModule):SetUp()

wait(5)
require(LocalAudioModule):PlayAudio("MultiSubtitleDemo")