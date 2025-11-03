--Entry for a subtitle in the subtitle window.
--!strict

local PLAYBACK_LOUDNESS_THRESHOLD = 100
local PLAYBACK_LOUDNESS_SILENCE_DELAY = 1

local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local Fusion = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("Fusion"))

local SubtitleEntry = {}
SubtitleEntry._TextService = TextService
SubtitleEntry.__index = SubtitleEntry

export type SubtitleEntry = {
    Message: string,
    ReferenceSound: Sound?,
    Multiple: Fusion.Value<number>,
    Clearing: Fusion.Value<boolean>,
    Visible: Fusion.UsedAs<boolean>,
    DisplayMessage: Fusion.UsedAs<string>,
    Height: Fusion.UsedAs<number>,
    _Scope: Fusion.Scope<typeof(Fusion)>,
    _PlaybackLoudnessEvents: {[Sound]: RBXScriptConnection},
    _LastReferenceSoundAudible: {[Sound]:  boolean},
} & typeof(setmetatable({}, SubtitleEntry))



--[[
Creates a subtitle entry.
--]]
function SubtitleEntry.new(Scope: Fusion.Scope<typeof(Fusion)>, Message: string, TextSize: Fusion.UsedAs<number>, MaxWidth: Fusion.UsedAs<number>, ReferenceSound: Sound?): SubtitleEntry
    --Create the values.
    local Multiple = Scope:Value(0)
    local Clearing = Scope:Value(false)
    local Visible = Scope:Computed(function(use)
        return not use(Clearing) and use(Multiple) > 0
    end) :: Fusion.UsedAs<boolean>
    local DisplayMessage = Scope:Computed(function(use)
        local CurrentMultiple = use(Multiple)
        if CurrentMultiple > 1 then
            return Message..` <font color="rgb(180,180,180)"><i>({CurrentMultiple}x)</i></font>`
        end
        return Message
    end) :: Fusion.UsedAs<string>
    local Height = Scope:Computed(function(use)
        local Parameters = Instance.new("GetTextBoundsParams")
        Parameters.Text = use(DisplayMessage)
        Parameters.Font = Font.fromEnum(Enum.Font.SourceSans)
        Parameters.RichText = true
        Parameters.Size = use(TextSize)
        Parameters.Width = use(MaxWidth)
        return SubtitleEntry._TextService:GetTextBoundsAsync(Parameters).Y
    end) :: Fusion.UsedAs<number>

    --Create the object.
    local self = setmetatable({
        Message = Message,
        ReferenceSound = ReferenceSound,
        Multiple = Multiple,
        Clearing = Clearing,
        Visible = Visible,
        DisplayMessage = DisplayMessage,
        Height = Height,
        _Scope = Scope,
        _PlaybackLoudnessEvents = {},
        _LastReferenceSoundAudible = {},
    }, SubtitleEntry) :: SubtitleEntry

    --Update the visibility based on the audio volume.
    if ReferenceSound then
        self:AddReferenceSound(ReferenceSound)
    else
        self:AddMultiple()
    end

    --Return the object.
    return self
end

--[[
Adds a multiple to the subtitle entry.
--]]
function SubtitleEntry.AddMultiple(self: SubtitleEntry): ()
    self.Multiple:set(Fusion.peek(self.Multiple) + 1)
end

--[[
Removes a multiple to the subtitle entry.
--]]
function SubtitleEntry.RemoveMultiple(self: SubtitleEntry): ()
    self.Multiple:set(Fusion.peek(self.Multiple) - 1)
end

--[[
Adds a sound to reference for managing the volume.
--]]
function SubtitleEntry.AddReferenceSound(self: SubtitleEntry, ReferenceSound: Sound): ()
    local LastLoudnessTime = 0
    local LastAudible = false
    self._PlaybackLoudnessEvents[ReferenceSound] = RunService.Stepped:Connect(function()
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
            self._LastReferenceSoundAudible[ReferenceSound] = NewAudible
        end
    end)
end

--[[
Removes a sound to reference for managing the volume.
--]]
function SubtitleEntry.RemoveReferenceSound(self: SubtitleEntry, ReferenceSound: Sound): ()
    if self._PlaybackLoudnessEvents[ReferenceSound] then
        self._PlaybackLoudnessEvents[ReferenceSound]:Disconnect()
        self._PlaybackLoudnessEvents[ReferenceSound] = nil
    end
    if self._LastReferenceSoundAudible[ReferenceSound] then
        self:RemoveMultiple()
    end
end

--[[
Destroys the entry.
--]]
function SubtitleEntry.Destroy(self: SubtitleEntry): ()
    if Fusion.peek(self.Clearing) then return end
    self.Clearing:set(true)
    self._Scope:doCleanup()

    for _, Event in self._PlaybackLoudnessEvents do
        Event:Disconnect()
    end
    self._PlaybackLoudnessEvents = {}
end



return SubtitleEntry