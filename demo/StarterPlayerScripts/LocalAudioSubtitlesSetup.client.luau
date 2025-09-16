--Sets up the LocalAudio Subtitles.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalAudioSubtitles = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("LocalAudioSubtitles"))
local LocalAudio = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("LocalAudio"))
local SubtitlesData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("Subtitles"))

LocalAudioSubtitles:SetUp(SubtitlesData :: any)
LocalAudio:SetUp()