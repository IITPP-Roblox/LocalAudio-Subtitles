--Main window for showing subtitles.
--!strict

local MINIMUM_TEXT_SIZE = 12
local TEXT_SIZE_RELATIVE = 0.03
local TEXT_SIZE_RELATIVE_VR = 0.055
local UI_CORNER_RELATIVE = 0.2
local BOTTOM_MARGIN_PIXEL = 5

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local SubtitleEntry = require(script.Parent:WaitForChild("SubtitleEntry"))
local SubtitleEntryCollection = require(script.Parent:WaitForChild("SubtitleEntryCollection"))
local Fusion = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("Fusion"))
local NexusVRCore = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("NexusVRCore"))

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
    if UserInputService.VREnabled then
        --VR uses a custom container at a fixed size.
        ViewportSize:set(Vector2.new(1200, 800))
    else
        Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            ViewportSize:set(Workspace.CurrentCamera.ViewportSize)
        end)
    end

    local TextSize = Scope:Computed(function(use)
        return math.max(MINIMUM_TEXT_SIZE, (UserInputService.VREnabled and TEXT_SIZE_RELATIVE_VR or TEXT_SIZE_RELATIVE) * use(ViewportSize).Y)
    end) :: Fusion.UsedAs<number>
    local MaxTextWidth = Scope:Computed(function(use)
        return (0.9 * use(ViewportSize).X) - (2 * UI_CORNER_RELATIVE * use(TextSize))
    end) :: Fusion.UsedAs<number>

    --Prepare the TweenInfo.
    local ReducedMotionEnabled = Scope:Value(GuiService.ReducedMotionEnabled)
    GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(function()
        ReducedMotionEnabled:set(GuiService.ReducedMotionEnabled)
    end)
    local PropertyTween = Scope:Computed(function(use)
        return (use(ReducedMotionEnabled) and TweenInfo.new(0) or TweenInfo.new(SubtitleEntry.FadeAnimationTimeSeconds))
    end)

    --Create the object.
    local self = setmetatable({
        _Scope = Scope,
        _SubtitleEntries = SubtitleEntryCollection.new(TextSize, MaxTextWidth),
    }, SubtitleWindow) :: SubtitleWindow

    --Create the list of subtitle entry labels.
    --This is manually managed due to issues with Fusion re-rendering labels when the list indices change.
    --Using the entires as keys doesn't resolve the issue either.
    local SubtitleLabels = Scope:Value({})
    Scope:Observer(self._SubtitleEntries.DisplayedEntries):onBind(function()
        --Create the entries that don't exist.
        local CurrentSubtitleLabels = Fusion.peek(SubtitleLabels)
        local CurrentEntries = Fusion.peek(self._SubtitleEntries.DisplayedEntries)
        local ChangesMade = false
        for _, Entry in CurrentEntries do
            if CurrentSubtitleLabels[Entry] then continue end
            ChangesMade = true

            --Create the text label.
            --This is done to set the TextTransparency as 1 first, and then animate in.
            local LabelScope = Fusion.innerScope(Scope)
            local TextTransparency = LabelScope:Value(1)
            local SubtitleLabel = LabelScope:New("TextLabel")({
                AnchorPoint = Vector2.new(0, 1),
                Size = LabelScope:Computed(function(use)
                    return UDim2.new(1, -(2 * UI_CORNER_RELATIVE) * use(TextSize), 0, use(Entry.Height))
                end),
                Position = LabelScope:Tween(LabelScope:Computed(function(use)
                    return UDim2.new(0, UI_CORNER_RELATIVE * use(TextSize), 1, use(Entry.YOffset) - BOTTOM_MARGIN_PIXEL)
                end), PropertyTween),
                BackgroundTransparency = 1,
                Font = Enum.Font.SourceSans,
                Text = Entry.DisplayMessage,
                RichText = true,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextTransparency = LabelScope:Tween(TextTransparency, PropertyTween),
                TextSize = TextSize,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2,
            })
            CurrentSubtitleLabels[Entry] = {
                Scope = LabelScope,
                Label = SubtitleLabel,
            }

            --Set the text transparency afterwards for it to tween in.
            LabelScope:Observer(Entry.VisibleState):onBind(function()
                TextTransparency:set(Fusion.peek(Entry.VisibleState) == "Visible" and 0 or 1)
            end)
        end

        --Remove the cleared values.
        --Done in 2 steps to avoid modifying a table being iterated over.
        local EntriesToRemove = {}
        for Entry, _ in CurrentSubtitleLabels do
            if table.find(CurrentEntries, Entry :: SubtitleEntry.SubtitleEntry) then continue end
            table.insert(EntriesToRemove, Entry)
        end
        for _, Entry in EntriesToRemove do
            ChangesMade = true
            CurrentSubtitleLabels[Entry].Scope:doCleanup()
            CurrentSubtitleLabels[Entry] = nil
        end

        --Store the changes.
        if not ChangesMade then return end
        SubtitleLabels:set(CurrentSubtitleLabels)
    end)

    --Create the value for the background size.
    --This is used to toggle the ScreenGui being enabled.
    local BackgroundSize = Scope:Tween(Scope:Computed(function(use)
        local TotalHeight = 0
        for _, Entry in use(self._SubtitleEntries.DisplayedEntries) do
            TotalHeight += use(Entry.Height)
        end
        if TotalHeight > 0 then
            TotalHeight += BOTTOM_MARGIN_PIXEL
        end
        return UDim2.new(1, 0, 0, TotalHeight)
    end), PropertyTween)

    --Create the ScreenGui.
    local ScreenGui: Instance = nil
    if UserInputService.VREnabled then
        local NewScreenGui = NexusVRCore.ScreenGui3D.new()
        NewScreenGui.Name = "LocalAudioSubtitlesVR"
        NewScreenGui.ResetOnSpawn = false
        NewScreenGui.Enabled = false
        NewScreenGui.CanvasSize = Vector2.new(1200, 800)
        NewScreenGui.PointingEnabled = false
        NewScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        ScreenGui = NewScreenGui:GetContainer()

        Scope:Observer(BackgroundSize):onBind(function()
            NewScreenGui.Enabled = Fusion.peek(BackgroundSize).Y.Offset > 0
        end)
    else
        ScreenGui = Scope:New("ScreenGui")({
            Name = "LocalAudioSubtitles",
            DisplayOrder = 100,
            ResetOnSpawn = false,
            Enabled = Scope:Computed(function(use)
                return use(BackgroundSize).Y.Offset > 0
            end),
            Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
        })
    end


    --Create the user interface.
    Scope:Hydrate(ScreenGui)({
        [Children] = {
            --Row adorn.
            Scope:New("Frame")({
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.9, 0),
                Size = UDim2.new(0.9, 0, 0.03, 0),
                [Children] = {
                    --Subtitle entries.
                    Scope:ForValues(SubtitleLabels, function(use, Scope: Fusion.Scope<typeof(Fusion)>, Entry)
                        return Entry.Label
                    end) :: any,

                    --Background.
                    Scope:New("Frame")({
                        AnchorPoint = Vector2.new(0, 1),
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = BackgroundTransparency,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 1, 0),
                        Size = Scope:Tween(Scope:Computed(function(use)
                            local TotalHeight = 0
                            for _, Entry in use(self._SubtitleEntries.DisplayedEntries) do
                                TotalHeight += use(Entry.Height)
                            end
                            if TotalHeight > 0 then
                                TotalHeight += BOTTOM_MARGIN_PIXEL
                            end
                            return UDim2.new(1, 0, 0, TotalHeight)
                        end), PropertyTween),
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

    --Return the object.
    return self 
end

--[[
Shows a subtitle in the window.
--]]
function SubtitleWindow.ShowSubtitle(self: SubtitleWindow, Message: string, Duration: number, ReferenceSound: Sound?): ()
    self._SubtitleEntries:AddEntry(Message, Duration, ReferenceSound)
end



return SubtitleWindow