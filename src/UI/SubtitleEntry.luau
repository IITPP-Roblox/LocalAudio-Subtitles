--Entry for a subtitle in the subtitle window.
--!strict

local FADE_ANIMATION_TIME_SECONDS = 0.1
local PLAYBACK_LOUDNESS_THRESHOLD = 100
local PLAYBACK_LOUDNESS_SILENCE_DELAY = 1

local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")

local Fusion = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("Fusion"))

local SubtitleEntry = {}
SubtitleEntry.FadeAnimationTimeSeconds = FADE_ANIMATION_TIME_SECONDS
SubtitleEntry._GuiService = GuiService
SubtitleEntry._TextService = TextService
SubtitleEntry.__index = SubtitleEntry

export type SubtitleVisibleState = "Visible" | "Hiding" | "Hidden"
export type SubtitleEntry = {
    Message: string,
    ReferenceSound: Sound?,
    Multiple: Fusion.Value<number>,
    Clearing: Fusion.Value<boolean>,
    VisibleState: Fusion.Value<SubtitleVisibleState>,
    DisplayMessage: Fusion.UsedAs<string>,
    Height: Fusion.UsedAs<number>,
    YOffset: Fusion.Value<number>,
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
    local VisibleState = Scope:Value("Hidden" :: any) :: Fusion.Value<SubtitleVisibleState>
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
        VisibleState = VisibleState,
        DisplayMessage = DisplayMessage,
        Height = Height,
        YOffset = Scope:Value(0),
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
    
    --Update the visibility state.
    Scope:Observer(self.Multiple):onBind(function()
        self:UpdateVisibleState()
    end)
    Scope:Observer(self.Clearing):onBind(function()
        self:UpdateVisibleState()
    end)

    --Return the object.
    return self
end

--[[
Updates the visible state.
--]]
function SubtitleEntry.UpdateVisibleState(self: SubtitleEntry): ()
    if Fusion.peek(self.Multiple) > 0 and not Fusion.peek(self.Clearing) then
        --Set the state as visible.
        self.VisibleState:set("Visible")
    elseif Fusion.peek(self.VisibleState) ~= "Hidden" then
        --Hide the visible state.
        if self._GuiService.ReducedMotionEnabled then
            self.VisibleState:set("Hidden")
        else
            self.VisibleState:set("Hiding")
            task.wait(FADE_ANIMATION_TIME_SECONDS)
            if Fusion.peek(self.VisibleState) ~= "Hiding" then return end
            self.VisibleState:set("Hidden")
        end
    end
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
    --Start clearing the entry.
    if Fusion.peek(self.Clearing) then return end
    self.Clearing:set(true)

    --Disconnect any resources still in use.
    for _, Event in self._PlaybackLoudnessEvents do
        Event:Disconnect()
    end
    self._PlaybackLoudnessEvents = {}

    --After the animation fade delay, finally destroy the scope.
    task.delay(FADE_ANIMATION_TIME_SECONDS, function()
        self._Scope:doCleanup()
    end)
end



return SubtitleEntry