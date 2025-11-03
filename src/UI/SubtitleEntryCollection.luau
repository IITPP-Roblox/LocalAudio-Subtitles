--Stores a collection of subtitle entires.
--Mainly used to flatten the structure for easier displaying.
--!strict

local SubtitleEntry = require(script.Parent:WaitForChild("SubtitleEntry"))
local Fusion = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("Fusion"))

local SubtitleEntryCollection = {}
SubtitleEntryCollection.__index = SubtitleEntryCollection

export type SubtitleEntryData = {
    Message: string,
    Height: number,
    YOffset: number,
}
export type SubtitleEntryCollection = {
    DisplayedEntries: Fusion.Value<{SubtitleEntryData}>,
    _Entries: {SubtitleEntry.SubtitleEntry},
    _Scope: Fusion.Scope<typeof(Fusion)>,
    _TextSize: Fusion.UsedAs<number>,
    _MaxWidth: Fusion.UsedAs<number>,
} & typeof(setmetatable({}, SubtitleEntryCollection))



--[[
Creates a subtitle entry collection.
--]]
function SubtitleEntryCollection.new(Scope: Fusion.Scope<typeof(Fusion)>, TextSize: Fusion.UsedAs<number>, MaxWidth: Fusion.UsedAs<number>): SubtitleEntryCollection
    return setmetatable({
        DisplayedEntries = Scope:Value({}),
        _Entries = {},
        _Scope = Scope,
        _TextSize = TextSize,
        _MaxWidth = MaxWidth,
    }, SubtitleEntryCollection) :: SubtitleEntryCollection
end

--[[
Updates the displayed entries.
--]]
function SubtitleEntryCollection._UpdateDisplayedEntries(self: SubtitleEntryCollection): ()
    --Create the initial entries.
    local NewEntries = {}
    local TotalHeight = 0
    for _, Entry in self._Entries do
        if not Fusion.peek(Entry.Visible) then continue end
        local Height = Fusion.peek(Entry.Height)
        table.insert(NewEntries, {
            Message = Fusion.peek(Entry.DisplayMessage),
            Height = Height,
            YOffset = 0,
        })
        TotalHeight += Height
    end

    --Update the Y offsets.
    for _, Entry in NewEntries do
        TotalHeight += -Entry.Height
        Entry.YOffset = -TotalHeight
    end

    --Store the entries.
    self.DisplayedEntries:set(NewEntries)
end

--[[
Adds a message to the collection.
--]]
function SubtitleEntryCollection.AddEntry(self: SubtitleEntryCollection, Message: string, Duration: number, ReferenceSound: Sound?): ()
    --Add to an existing message if one exists.
    local Entry: SubtitleEntry.SubtitleEntry = nil
    for _, ExistingEntry in self._Entries do
        local CurrentEntry = ExistingEntry :: SubtitleEntry.SubtitleEntry --Silences type check complaining about complexity.
        if ExistingEntry.Message ~= Message then continue end
        if Fusion.peek(ExistingEntry.Clearing) then continue end
        if ReferenceSound then
            CurrentEntry:AddReferenceSound(ReferenceSound)
        else
            CurrentEntry:AddMultiple()
        end
        Entry = CurrentEntry
        break
    end

    --Create the entry.
    if not Entry then
        local EntryScope = Fusion.innerScope(self._Scope)
        local NewEntry = SubtitleEntry.new(EntryScope, Message, self._TextSize, self._MaxWidth, ReferenceSound)
        table.insert(self._Entries, NewEntry)
        Entry = NewEntry

        EntryScope:Observer(NewEntry.Visible):onChange(function()
            self:_UpdateDisplayedEntries()
        end)
        EntryScope:Observer(NewEntry.DisplayMessage):onChange(function()
            self:_UpdateDisplayedEntries()
        end)
        EntryScope:Observer(NewEntry.Height):onChange(function()
            self:_UpdateDisplayedEntries()
        end)
    end
    self:_UpdateDisplayedEntries()

    --Remove the entry after the duration.
    task.delay(Duration, function()
        --Remove the sound.
        if ReferenceSound then
            Entry:RemoveReferenceSound(ReferenceSound)
        else
            Entry:RemoveMultiple()
        end

        --Remove the entry if no sounds exist.
        if Fusion.peek(Entry.Multiple) ~= 0 then return end
        for i = #self._Entries, 1, -1 do
            if self._Entries[i] ~= Entry then continue end
            table.remove(self._Entries, i)
        end
        Entry:Destroy()
        self:_UpdateDisplayedEntries()
    end)
end



return SubtitleEntryCollection