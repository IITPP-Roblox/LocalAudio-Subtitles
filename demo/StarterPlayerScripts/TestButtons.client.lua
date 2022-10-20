--[[
TheNexusAvenger

Buttons used for testing subtitles.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalAudio = require(ReplicatedStorage:WaitForChild("LocalAudio"))
local LocalAudioSubtitles = require(ReplicatedStorage:WaitForChild("LocalAudioSubtitles"))
LocalAudioSubtitles:SetSubtitleLevel(2)

local ButtonsScreenGui = Instance.new("ScreenGui")
ButtonsScreenGui.Name = "TestButtons"
ButtonsScreenGui.ResetOnSpawn = false
ButtonsScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local WorldSpaceSoundPart = Instance.new("Part")
WorldSpaceSoundPart.CFrame = CFrame.new(0, 5, 200)
WorldSpaceSoundPart.Anchored = true
WorldSpaceSoundPart.BrickColor = BrickColor.new("Bright blue")
WorldSpaceSoundPart.Parent = Workspace

for i, ButtonName in {"ChangeLevel", "Announcement.Normal", "Announcement.Warning", "MultiSubtitleDemo"} do
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 200, 0, 50)
    Button.Position = UDim2.new(0.5, -100, 0, 50 * (i - 1))
    Button.Parent = ButtonsScreenGui

    if ButtonName == "ChangeLevel" then
        local CurrentLevel = 2
        Button.Text = "CurrentSubtitleLevel: 2"
        Button.MouseButton1Down:Connect(function()
            CurrentLevel = (CurrentLevel + 1) % 3
            Button.Text = "CurrentSubtitleLevel: "..tostring(CurrentLevel)
            LocalAudioSubtitles:SetSubtitleLevel(CurrentLevel)
        end)
    else
        Button.Text = "Play "..ButtonName
        Button.MouseButton1Down:Connect(function()
            LocalAudio:PlayAudio(ButtonName, ButtonName == "Announcement.Warning" and WorldSpaceSoundPart or nil)
        end)
    end
end