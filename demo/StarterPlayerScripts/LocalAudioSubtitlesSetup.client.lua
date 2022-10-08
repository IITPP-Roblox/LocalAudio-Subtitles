--[[
TheNexusAvenger

Sets up the LocalAudio Subtitles.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalAudioSubtitles = require(ReplicatedStorage:WaitForChild("LocalAudioSubtitles"))
local LocalAudioModule = nil
local AudioDataModule = nil

LocalAudioSubtitles:SetUp()