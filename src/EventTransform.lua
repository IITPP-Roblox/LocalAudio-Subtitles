--[[
TheNexusAvenger

Transforms subtitle data to events.
--]]

local Types = require(script.Parent:WaitForChild("LocalAudioSubtitlesTypes"))

local EventTransform = {
    SubtitleData = {},
}



--[[
Applies a color to a string.
--]]
local function ApplyColor(Message: string, Color: Color3): nil
    return "<font color=\"rgb("..tostring(math.floor(Color.R * 255))..","..tostring(math.floor(Color.G * 255))..","..tostring(math.floor(Color.B * 255))..")\">"..Message.."</font>"
end

--[[
Sets the subtitle data to use for filling in event data.
--]]
function EventTransform:SetSubtitleData(Data: Types.SubtitleDataModule): nil
    self.SubtitleData = {
        Speakers = Data.Speakers or {},
        Macros = Data.Macros or {},
        Levels = Data.Levels or {},
    }
end

--[[
Transform a list of subtitle entries for an audio.
--]]
function EventTransform:Transform(Entries: {Types.SubtitleData}, AudioDuration: number)
    --Apply the macros for the entries.
    --This must be done before iterating over the entries because of the references to Time.
    local ProcessedEntries = {}
    for _, Entry in Entries do
        --Determine the order of macros.
        local Macros = {}
        local CurrentEntry = Entry
        while CurrentEntry and CurrentEntry.Macro and self.SubtitleData.Macros[CurrentEntry.Macro] do
            for _, OtherMacro in Macros do
                if OtherMacro == CurrentEntry.Macro then
                    error("There is a cyclic reference of macros: "..table.concat(Macros, "->").."->"..CurrentEntry.Macro)
                end
            end
            table.insert(Macros, CurrentEntry.Macro)
            CurrentEntry = self.SubtitleData.Macros[CurrentEntry.Macro]
        end

        --Build the entry from the macros and origianl entry.
        local NewEntry = {}
        for i = #Macros, 1, -1 do
            for Key, Value in self.SubtitleData.Macros[Macros[i]] do
                if Key ~= "Macro" then
                    NewEntry[Key] = Value
                end
            end
        end
        for Key, Value in Entry do
            if Key ~= "Macro" then
                NewEntry[Key] = Value
            end
        end
        table.insert(ProcessedEntries, NewEntry)
    end

    --Transform the entries.
    local Events = {}
    for i, Entry in ProcessedEntries do
        --Apply the overrides.
        for Key, Value in Entry do
            Entry[Key] = Value
        end

        --Build the speaker name.
        local SpeakerName = Entry.Speaker
        if Entry.SpeakerDisplayName then
            SpeakerName = Entry.SpeakerDisplayName
        elseif SpeakerName then
            local Speaker = self.SubtitleData.Speakers[SpeakerName]
            if Speaker then
                if Entry.SpeakerModifier and Speaker.Modifiers[Entry.SpeakerModifier] and Speaker.Modifiers[Entry.SpeakerModifier].DisplayName then
                    SpeakerName = Speaker.Modifiers[Entry.SpeakerModifier].DisplayName
                elseif Speaker.DisplayName then
                    SpeakerName = Speaker.DisplayName
                end
            end
        end
        if SpeakerName then
            if Entry.SpeakerColor then
                SpeakerName = ApplyColor(SpeakerName, Entry.SpeakerColor)
            elseif Entry.Speaker then
                local Speaker = self.SubtitleData.Speakers[Entry.Speaker]
                if Speaker then
                    if Entry.SpeakerModifier and Speaker.Modifiers[Entry.SpeakerModifier] and Speaker.Modifiers[Entry.SpeakerModifier].Color then
                        SpeakerName = ApplyColor(SpeakerName, Speaker.Modifiers[Entry.SpeakerModifier].Color)
                    elseif Speaker.Color then
                        SpeakerName = ApplyColor(SpeakerName, Speaker.Color)
                    end
                end
            end
        end

        --Build the message.
        local Message = Entry.Message
        if Entry.MessageColor then
            Message = ApplyColor(Message, Entry.MessageColor)
        end
        if SpeakerName then
            Message = SpeakerName..": "..Message 
        end

        --Build the duration.
        local Time = Entry.Time or 0
        local Duration = Entry.Duration
        if not Duration then
            if ProcessedEntries[i + 1] then
                Duration = (ProcessedEntries[i + 1].Time or 0) - Time
            else
                Duration = AudioDuration - Time
            end
        end

        --Build the level.
        local Level = Entry.Level
        if typeof(Level) == "string" then
            if not self.SubtitleData.Levels[Level] then
                error("Unknown subtitle level: "..Level)
            end
            Level = self.SubtitleData.Levels[Level]
        end

        --Add the event.
        table.insert(Events, {
            Name = "ShowSubtitle",
            Time = Time,
            Duration = Duration,
            Message = Message,
            Level = Level,
        })
    end

    --Return the events.
    return Events
end

--[[
Populates events for an audio data entry.
--]]
function EventTransform:PopulateEvents(Entry: table): nil
    --Iterate over the tables.
    for _, SubEntry in Entry do
        if typeof(SubEntry) == "table" then
            self:PopulateEvents(SubEntry)
        end
    end

    --Add the events.
    if Entry.Id and Entry.Length then
        if Entry.Subtitle then
            Entry.Subtitles = {Entry.Subtitle}
        end
        if Entry.Subtitles then
            if not Entry.Events then
                Entry.Events = {}
            end
            for _, Event in self:Transform(Entry.Subtitles, Entry.Length) do
                table.insert(Entry.Events, Event)
            end
        end
    end
end



return EventTransform