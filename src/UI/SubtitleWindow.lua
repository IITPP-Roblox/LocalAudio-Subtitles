--[[
TheNexusAvenger

Main window for showing subtitles.
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Types = require(script.Parent.Parent:WaitForChild("LocalAudioSubtitlesTypes"))
local SubtitleEntry = require(script.Parent:WaitForChild("SubtitleEntry"))

local SubtitleWindow = {}
SubtitleWindow.__index = SubtitleWindow



--[[
Creates a subtitle window.
--]]
function SubtitleWindow.new(): Types.SubtitleWindow
    --Create the object.
    local self = {
        LastSize = 0,
        SubtitleEntries = {},
    }
    setmetatable(self, SubtitleWindow)

    --Create the user interface.
    local SubtitlesScreenGui = Instance.new("ScreenGui")
    SubtitlesScreenGui.Name = "LocalAudioSubtitles"
    SubtitlesScreenGui.DisplayOrder = 100
    SubtitlesScreenGui.ResetOnSpawn = false
    SubtitlesScreenGui.Enabled = false
    SubtitlesScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    self.ScreenGui = SubtitlesScreenGui

    local RowAdornFrame = Instance.new("Frame")
    RowAdornFrame.AnchorPoint = Vector2.new(0.5, 1)
    RowAdornFrame.BackgroundTransparency = 1
    RowAdornFrame.Position = UDim2.new(0.5, 0, 0.9, 0)
    RowAdornFrame.Size = UDim2.new(0.9, 0, 0.03, 0)
    RowAdornFrame.Parent = SubtitlesScreenGui
    self.RowAdornFrame = RowAdornFrame

    local BackgroundFrame = Instance.new("Frame")
    BackgroundFrame.AnchorPoint = Vector2.new(0, 1)
    BackgroundFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BackgroundFrame.BackgroundTransparency = 0.5
    BackgroundFrame.BorderSizePixel = 0
    BackgroundFrame.Position = UDim2.new(0, 0, 1, 0)
    BackgroundFrame.Size = UDim2.new(1, 0, 0, 0)
    BackgroundFrame.Parent = RowAdornFrame
    self.BackgroundFrame = BackgroundFrame

    local BackgroundUICorner = Instance.new("UICorner")
    BackgroundUICorner.CornerRadius = UDim.new(0.2, 0)
    BackgroundUICorner.Parent = BackgroundFrame
    self.BackgroundUICorner = BackgroundUICorner

    --Return the object.
    return self
end

--[[
Tweens the background to a specific size.
--]]
function SubtitleWindow:TweenBackground(Rows: number): nil
    TweenService:Create(self.BackgroundFrame, TweenInfo.new(0.1), {
        Size = UDim2.new(1, 0, Rows, 0),
    }):Play()
    TweenService:Create(self.BackgroundUICorner, TweenInfo.new(0.1), {
        CornerRadius = UDim.new(0.25 * (1 / math.max(1, Rows)), 0),
    }):Play()
end

--[[
Updates the size of the window.
--]]
function SubtitleWindow:UpdateSize(): nil
    --Update the entries.
    for _, Entry in self.SubtitleEntries do
        Entry:UpdatePosition()
    end

    --Update the background.
    local CurrentSize = #self.SubtitleEntries
    self:TweenBackground(CurrentSize)
    if CurrentSize >= self.LastSize then
        self.ScreenGui.Enabled = true
    elseif #self.SubtitleEntries == 0 then
        task.delay(0.1, function()
            if #self.SubtitleEntries ~= 0 then return end
            self.ScreenGui.Enabled = false
        end)
    end
	self.LastSize = CurrentSize
end

--[[
Shows a subtitle in the window.
--]]
function SubtitleWindow:ShowSubtitle(Message: string, Duration: number): nil
    --Create the entry.
    local Entry = SubtitleEntry.new(Message, self)

    --Remove the entry after the duration.
    task.delay(Duration, function()
        Entry:Destroy()
    end)
end



return SubtitleWindow