--[[
TheNexusAvenger

Entry for a subtitle in the subtitle window.
--]]

local PLAYBACK_LOUDNESS_THRESHOLD = 50
local PLAYBACK_LOUDNESS_SILENCE_DELAY = 1

local RunService = game:GetService("RunService")

local Types = require(script.Parent.Parent:WaitForChild("LocalAudioSubtitlesTypes"))
local TweenServicePlay = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("TweenServicePlay"))
local TypeWriter = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("TypeWriter"))

local SubtitleEntry = {}
SubtitleEntry.__index = SubtitleEntry



--[[
Creates a subtitle entry.
--]]
function SubtitleEntry.new(Message: string, Window: Types.SubtitleWindow, TypeWriterEnabled: boolean, ReferenceSound: Sound?): Types.SubtitleEntry
    --Create the object.
    local self = {
        Message = Message,
        ReferenceSound = ReferenceSound,
        Multiple = 0,
        Window = Window,
        Visible = false,
        PlaybackLoudnessEvents = {},
        LastReferenceSoundAudible = {},
        TypeWriterEnabled = TypeWriterEnabled
    }
    setmetatable(self, SubtitleEntry)

    --Create the TextLabel.
    local TextLabel = Instance.new("TextLabel")
    TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    TextLabel.Size = UDim2.new(0.99, 0, 0.95, 0)
    TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.Text = Message
    TextLabel.RichText = true
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextTransparency = 1
    TextLabel.TextScaled = true
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
    TextLabel.ZIndex = 2
    TextLabel.Parent = Window.RowAdornFrame
    self.TextLabel = TextLabel
    table.insert(Window.SubtitleEntries, self :: any)

    --Update the visibility based on the audio volume.
    if ReferenceSound then
        self:AddReferenceSound(ReferenceSound)
    else
        self:AddMultiple()
    end

    --Return the object.
    return self :: any
end

--[[
Gets the index of the subtitle.
--]]
function SubtitleEntry:GetIndex(): number
    for i, Entry in self.Window.SubtitleEntries do
        if Entry ~= self then continue end
        return i
    end
    return 0
end

--[[
Gets the visible index of the subtitle.
--]]
function SubtitleEntry:GetVisibleIndex(): number
    local CurrentIndex = 1
    for _, Entry in self.Window:GetVisibleEntries() do
        if Entry == self then
            return CurrentIndex
        end
        if Entry.Visible then
            CurrentIndex += 1
        end
    end
    return 0
end

--[[
Updates the position of the entry.
--]]
function SubtitleEntry:UpdatePosition(): ()
    TweenServicePlay(self.TextLabel, TweenInfo.new(0.1), {
        Position = UDim2.new(0.5, 0, 0.5 - (#self.Window:GetVisibleEntries() - self:GetVisibleIndex()), 0),
    })
end

--[[
Updates the text shown for the multiple.
--]]
function SubtitleEntry:UpdateMultipleText(): ()
    --Update the message.
    local Message = self.Message
    if self.Multiple > 1 then
        Message ..= " <font color=\"rgb(180,180,180)\"><i>("..tostring(self.Multiple).."x)</i></font>"
    end
    self.TextLabel.Text = Message

    --Update the visible text.
    local CurrentMultiple = self.Multiple
    local Visible = (CurrentMultiple > 0)
    if Visible ~= self.Visible then
        if Visible then
            self.Visible = true
            TweenServicePlay(self.TextLabel, TweenInfo.new(0.25), {
                TextTransparency = 0,
            })
            self.Window:UpdateSize()
            if self.TypeWriterEnabled then
                task.spawn(TypeWriter, self.TextLabel, Message)
            end
        else
            TweenServicePlay(self.TextLabel, TweenInfo.new(0.25), {
                TextTransparency = 1,
            }, function()
                if CurrentMultiple ~= self.Visible then return end
                self.Visible = false
                self.Window:UpdateSize()
            end)
        end
    end
end

--[[
Adds a multiple to the subtitle entry.
--]]
function SubtitleEntry:AddMultiple(): ()
    self.Multiple += 1
    self:UpdateMultipleText()
end

--[[
Removes a multiple to the subtitle entry.
--]]
function SubtitleEntry:RemoveMultiple(): ()
    self.Multiple += -1
    self:UpdateMultipleText()
end

--[[
Adds a sound to reference for managing the volume.
--]]
function SubtitleEntry:AddReferenceSound(ReferenceSound: Sound): ()
    local LastLoudnessTime = 0
    local LastAudible = false
    self.PlaybackLoudnessEvents[ReferenceSound] = RunService.Stepped:Connect(function()
        local NewAudible = LastAudible
        if NewAudible then
            if ReferenceSound.PlaybackLoudness >= PLAYBACK_LOUDNESS_THRESHOLD then
                LastLoudnessTime = tick()
            elseif tick() - LastLoudnessTime > PLAYBACK_LOUDNESS_SILENCE_DELAY then
                NewAudible = false
            end
        else
            if ReferenceSound.PlaybackLoudness >= PLAYBACK_LOUDNESS_THRESHOLD then
                LastLoudnessTime = tick()
                NewAudible = true
            end
        end
        if NewAudible ~= LastAudible then
            if NewAudible then
                self:AddMultiple()
            else
                self:RemoveMultiple()
            end
            LastAudible = NewAudible
            self.LastReferenceSoundAudible[ReferenceSound] = NewAudible
        end
    end)
end

--[[
Removes a sound to reference for managing the volume.
--]]
function SubtitleEntry:RemoveReferenceSound(ReferenceSound: Sound): ()
    if self.PlaybackLoudnessEvents[ReferenceSound] then
        self.PlaybackLoudnessEvents[ReferenceSound]:Disconnect()
        self.PlaybackLoudnessEvents[ReferenceSound] = nil
    end
    if self.LastReferenceSoundAudible[ReferenceSound] then
        self:RemoveMultiple()
    end
end

--[[
Destroys the entry.
--]]
function SubtitleEntry:Destroy(): ()
    self.Clearing = true
    TweenServicePlay(self.TextLabel, TweenInfo.new(0.25), {
        TextTransparency = 1,
    }, function()
        table.remove(self.Window.SubtitleEntries, self:GetIndex())
        self.TextLabel:Destroy()
        self.Window:UpdateSize()
        for _, Event in self.PlaybackLoudnessEvents do
            Event:Disconnect()
        end
        self.PlaybackLoudnessEvents = {}
    end)
end



return SubtitleEntry