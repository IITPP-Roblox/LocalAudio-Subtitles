--Main window for showing subtitles.
--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local SubtitleEntry = require(script.Parent:WaitForChild("SubtitleEntry"))
local TweenServicePlay = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("TweenServicePlay"))

local SubtitleWindow = {}
SubtitleWindow.__index = SubtitleWindow

export type SubtitleWindow = {
    LastSize: number,
    SubtitleEntries: {SubtitleEntry.SubtitleEntry},
    ScreenGui: ScreenGui,
    RowAdornFrame: Frame,
    BackgroundFrame: Frame,
    BackgroundUICorner: UICorner,
} & typeof(setmetatable({}, SubtitleWindow))



--[[
Creates a subtitle window.
--]]
function SubtitleWindow.new(): SubtitleWindow
    --Create the object.
    local self = setmetatable({
        LastSize = 0,
        SubtitleEntries = {},
    }, SubtitleWindow) :: SubtitleWindow

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
    BackgroundFrame.BackgroundTransparency = 0.5 * GuiService.PreferredTransparency
    BackgroundFrame.BorderSizePixel = 0
    BackgroundFrame.Position = UDim2.new(0, 0, 1, 0)
    BackgroundFrame.Size = UDim2.new(1, 0, 0, 0)
    BackgroundFrame.Parent = RowAdornFrame
    self.BackgroundFrame = BackgroundFrame

    GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
        BackgroundFrame.BackgroundTransparency = 0.5 * GuiService.PreferredTransparency
    end)

    local BackgroundUICorner = Instance.new("UICorner")
    BackgroundUICorner.CornerRadius = UDim.new(0.2, 0)
    BackgroundUICorner.Parent = BackgroundFrame
    self.BackgroundUICorner = BackgroundUICorner

    --Connect Nexus VR Core being load.
    --Nexus VR Character Model is typically loaded from an id, so Nexus VR Core can appear at any time.
    if UserInputService.VREnabled then
        if ReplicatedStorage:FindFirstChild("NexusVRCore") then
            self:LoadNexusVRCore()
        else
            ReplicatedStorage.ChildAdded:Connect(function(Child)
                if Child.Name ~= "NexusVRCore" then return end
                self:LoadNexusVRCore()
            end)
        end
    end

    --Return the object.
    return self 
end

--[[
Sets up Nexus VR Core if it is loaded.
--]]
function SubtitleWindow.LoadNexusVRCore(self: SubtitleWindow): ()
    if not self.ScreenGui:IsA("ScreenGui") then return end

    --Replace the ScreenGui.
    local ScreenGui3D = require(ReplicatedStorage:WaitForChild("NexusVRCore"):WaitForChild("Container"):WaitForChild("ScreenGui3D")) :: any
    local NewScreenGui = ScreenGui3D.new()
    NewScreenGui.Name = "LocalAudioSubtitlesVR"
    NewScreenGui.DisplayOrder = 100
    NewScreenGui.ResetOnSpawn = false
    NewScreenGui.Enabled = self.ScreenGui.Enabled
    NewScreenGui.CanvasSize = Vector2.new(1200, 800)
	NewScreenGui.PointingEnabled = false
    NewScreenGui.Parent = self.ScreenGui.Parent

    --Resize the background container.
    self.RowAdornFrame.Size = UDim2.new(0.9, 0, 0.055, 0)
    self.RowAdornFrame.Parent = NewScreenGui:GetContainer()

    --Remove the existing ScreenGui.
    self.ScreenGui:Destroy()
    self.ScreenGui = NewScreenGui
end

--[[
Returns the entries that are visible.
--]]
function SubtitleWindow.GetVisibleEntries(self: SubtitleWindow): {SubtitleEntry.SubtitleEntry}
    local VisibleSubtitles = {}
    for _, Subtitle in self.SubtitleEntries do
        if not Subtitle.Visible then continue end
        table.insert(VisibleSubtitles, Subtitle)
    end
    return VisibleSubtitles
end

--[[
Tweens the background to a specific size.
--]]
function SubtitleWindow.TweenBackground(self: SubtitleWindow, Rows: number): ()
    TweenServicePlay(self.BackgroundFrame, TweenInfo.new(0.1), {
        Size = UDim2.new(1, 0, Rows, 0),
    })
    TweenServicePlay(self.BackgroundUICorner, TweenInfo.new(0.1), {
        CornerRadius = UDim.new(0.25 * (1 / math.max(1, Rows)), 0),
    })
end

--[[
Updates the size of the window.
--]]
function SubtitleWindow.UpdateSize(self: SubtitleWindow): ()
    --Update the entries.
    local SubtitleEntries = self:GetVisibleEntries()
    for _, Entry in SubtitleEntries do
        Entry:UpdatePosition()
    end

    --Update the background.
    local CurrentSize = #SubtitleEntries
    self:TweenBackground(CurrentSize)
    if CurrentSize >= self.LastSize then
        self.ScreenGui.Enabled = true
    elseif #SubtitleEntries == 0 then
        task.delay(0.1, function()
            if #self:GetVisibleEntries() ~= 0 then return end
            self.ScreenGui.Enabled = false
        end)
    end
	self.LastSize = CurrentSize
end

--[[
Shows a subtitle in the window.
--]]
function SubtitleWindow.ShowSubtitle(self: SubtitleWindow, Message: string, Duration: number, ReferenceSound: Sound?): ()
    --Add to an existing message if one exists.
    local Entry = nil
    for _, ExistingEntry in self.SubtitleEntries do
        if ExistingEntry.Message ~= Message then continue end
        if ExistingEntry.Clearing then continue end
        if ReferenceSound then
            ExistingEntry:AddReferenceSound(ReferenceSound)
        else
            ExistingEntry:AddMultiple()
        end
        Entry = ExistingEntry
        break
    end

    --Create the entry.
    if not Entry then
        Entry = SubtitleEntry.new(Message, self, ReferenceSound)
    end

    --Remove the entry after the duration.
    task.delay(Duration, function()
        if ReferenceSound then
            Entry:RemoveReferenceSound(ReferenceSound)
        else
            Entry:RemoveMultiple()
        end
        if Entry.Multiple ~= 0 then return end
        Entry:Destroy()
    end)
end



return SubtitleWindow