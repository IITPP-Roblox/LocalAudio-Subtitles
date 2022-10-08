--[[
TheNexusAvenger

Sets up the LocalAudio Subtitles.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalAudioSubtitles = require(ReplicatedStorage:WaitForChild("LocalAudioSubtitles"))
local LocalAudioModule = require(ReplicatedStorage:WaitForChild("LocalAudio"))

LocalAudioSubtitles:SetUp(LocalAudioModule)