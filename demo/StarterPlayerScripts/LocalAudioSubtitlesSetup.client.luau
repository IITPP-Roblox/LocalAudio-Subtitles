--Sets up the LocalAudio Subtitles.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalAudioSubtitles = require(ReplicatedStorage:WaitForChild("LocalAudioSubtitles"))
local LocalAudioModule = ReplicatedStorage:WaitForChild("LocalAudio")
local SubtitlesData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("Subtitles"))

LocalAudioSubtitles:SetUp(LocalAudioModule, SubtitlesData :: any)
require(LocalAudioModule):SetUp()