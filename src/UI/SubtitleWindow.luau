--Main window for showing subtitles.
--!strict

local UI_CORNER_RELATIVE = 0.2
local BOTTOM_MARGIN_PIXEL = 5

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local SubtitleEntryCollection = require(script.Parent:WaitForChild("SubtitleEntryCollection"))
local Fusion = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("Fusion"))

local Children = Fusion.Children

local SubtitleWindow = {}
SubtitleWindow.__index = SubtitleWindow

export type SubtitleWindow = {
    _Scope: Fusion.Scope<typeof(Fusion)>,
    _SubtitleEntries: SubtitleEntryCollection.SubtitleEntryCollection,
} & typeof(setmetatable({}, SubtitleWindow))



--[[
Creates a subtitle window.
--]]
function SubtitleWindow.new(): SubtitleWindow
    --Create the values.
    local Scope = Fusion.scoped(Fusion) :: Fusion.Scope<typeof(Fusion)>
    local BackgroundTransparency = Scope:Value(0.5 * GuiService.PreferredTransparency)
    GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
        BackgroundTransparency:set(0.5 * GuiService.PreferredTransparency)
    end)

    local ViewportSize = Scope:Value(Workspace.CurrentCamera.ViewportSize)
    Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        ViewportSize:set(Workspace.CurrentCamera.ViewportSize)
    end)

    local TextSize = Scope:Computed(function(use)
        return math.max(12, (UserInputService.VREnabled and 0.055 or 0.03) * use(ViewportSize).Y)
    end) :: Fusion.UsedAs<number>
    local MaxTextWidth = Scope:Computed(function(use)
        return (0.9 * use(ViewportSize).X) - (2 * UI_CORNER_RELATIVE * use(TextSize))
    end) :: Fusion.UsedAs<number>

    --Create the object.
    local self = setmetatable({
        _Scope = Scope,
        _SubtitleEntries = SubtitleEntryCollection.new(Scope, TextSize, MaxTextWidth),
    }, SubtitleWindow) :: SubtitleWindow

    --Create the user interface.
    Scope:New("ScreenGui")({
        Name = "LocalAudioSubtitles",
        DisplayOrder = 100,
        ResetOnSpawn = false,
        Enabled = Scope:Computed(function(use)
            return #use(self._SubtitleEntries.DisplayedEntries) > 0
        end),
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
        [Children] = {
            --Row adorn.
            Scope:New("Frame")({
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.9, 0),
                Size = UDim2.new(0.9, 0, 0.03, 0),
                [Children] = {
                    --Subtitlte entries.
                    Scope:ForPairs(self._SubtitleEntries.DisplayedEntries, function(use, Scope: Fusion.Scope<typeof(Fusion)>, Index, Entry: SubtitleEntryCollection.SubtitleEntryData)
                        return Index, Scope:New("TextLabel")({
                            AnchorPoint = Vector2.new(0, 1),
                            Size = UDim2.new(1, -(2 * UI_CORNER_RELATIVE) * use(TextSize), 0, Entry.Height),
                            Position = UDim2.new(0, UI_CORNER_RELATIVE * use(TextSize), 1, Entry.YOffset - BOTTOM_MARGIN_PIXEL),
                            BackgroundTransparency = 1,
                            Font = Enum.Font.SourceSans,
                            Text = Entry.Message,
                            RichText = true,
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            --TODO: TextTransparency = 1,
                            TextSize = TextSize,
                            TextWrapped = true,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 2,
                        })
                    end) :: any,


                    --Background.
                    Scope:New("Frame")({
                        AnchorPoint = Vector2.new(0, 1),
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = BackgroundTransparency,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 1, 0),
                        Size = Scope:Computed(function(use)
                            local TotalHeight = 0
                            for _, Entry in use(self._SubtitleEntries.DisplayedEntries) do
                                TotalHeight += Entry.Height
                            end
                            if TotalHeight > 0 then
                                TotalHeight += BOTTOM_MARGIN_PIXEL
                            end
                            return UDim2.new(1, 0, 0, TotalHeight)
                        end),
                        [Children] = {
                            Scope:New("UICorner")({
                                CornerRadius = Scope:Computed(function(use)
                                    return UDim.new(0, UI_CORNER_RELATIVE * use(TextSize))
                                end),
                            }),
                        },
                    }),
                },
            }),
        },
    })

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
Shows a subtitle in the window.
--]]
function SubtitleWindow.ShowSubtitle(self: SubtitleWindow, Message: string, Duration: number, ReferenceSound: Sound?): ()
    self._SubtitleEntries:AddEntry(Message, Duration, ReferenceSound)
end



return SubtitleWindow