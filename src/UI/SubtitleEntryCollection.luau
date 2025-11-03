--Stores a collection of subtitle entires.
--!strict

local SubtitleEntry = require(script.Parent:WaitForChild("SubtitleEntry"))
local Fusion = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("Fusion"))

local SubtitleEntryCollection = {}
SubtitleEntryCollection.__index = SubtitleEntryCollection

export type SubtitleEntryCollection = {
    DisplayedEntries: Fusion.Value<{SubtitleEntry.SubtitleEntry}>,
    _Entries: {SubtitleEntry.SubtitleEntry},
    _Scope: Fusion.Scope<typeof(Fusion)>,
    _TextSize: Fusion.UsedAs<number>,
    _MaxWidth: Fusion.UsedAs<number>,
} & typeof(setmetatable({}, SubtitleEntryCollection))



--[[
Creates a subtitle entry collection.
--]]
function SubtitleEntryCollection.new(TextSize: Fusion.UsedAs<number>, MaxWidth: Fusion.UsedAs<number>): SubtitleEntryCollection
    local Scope = Fusion.scoped(Fusion) :: Fusion.Scope<typeof(Fusion)>
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
        if Fusion.peek(Entry.VisibleState) == "Hidden" then continue end
        table.insert(NewEntries, Entry)
        TotalHeight += Fusion.peek(Entry.Height)
    end

    --Update the Y offsets.
    for _, Entry in NewEntries do
        TotalHeight += -Fusion.peek(Entry.Height)
        Entry.YOffset:set(-TotalHeight)
    end

    --Store the entries.
    self.DisplayedEntries:set(NewEntries :: {SubtitleEntry.SubtitleEntry})
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

        --Add a function ran on destroy.
        table.insert(EntryScope, function()
            for i = #self._Entries, 1, -1 do
                if self._Entries[i] ~= Entry then continue end
                table.remove(self._Entries, i)
            end
            self:_UpdateDisplayedEntries()
        end)

        --Observe changes to the state.
        EntryScope:Observer(NewEntry.VisibleState):onChange(function()
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
        Entry:Destroy()
    end)
end



return SubtitleEntryCollection