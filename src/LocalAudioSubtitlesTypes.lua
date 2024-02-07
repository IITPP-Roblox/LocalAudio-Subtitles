--[[
TheNexusAvenger

Types for the LocalAudio Subtitles.
--]]

--Data
export type SubtitleData = {
    Time: number?,
    Duration: number?,
    Message: string,
    MessageColor: Color3?,
    Speaker: string?,
    SpeakerModifier: string?,
    SpeakerDisplayName: string?,
    SpeakerColor: Color3?,
    Level: string | number?,
    Macro: string?,
    TypeWriter: boolean?,
}

export type SubtitleSpeaker = {
    Color: Color3?,
    DisplayName: string?,
    Modifiers: {[string]: {Color: Color3?, DisplayName: string?}}?,
}

export type SubtitleDataModule = {
    Speakers: {[string]: SubtitleSpeaker},
    Macros: {[string]: SubtitleData},
    Levels: {[string]: number},
}

--Classes
export type SubtitleWindow = {
    Visible: boolean,
    new: () -> (SubtitleWindow),
    SubtitleEntries: {SubtitleEntry},
    RowAdornFrame: Frame,
    UpdateSize: (SubtitleWindow) -> (),
    ShowSubtitle: (SubtitleWindow, Message: string, Duration: number, TypeWriterEnabled: boolean, ReferenceSound: Sound?) -> (),
}

export type SubtitleEntry = {
    new: (Message: string, Window: SubtitleWindow, TypeWriterEnabled: boolean, ReferenceSound: Sound?) -> (SubtitleWindow),
    UpdatePosition: (SubtitleEntry) -> (),
    AddMultiple: (SubtitleEntry) -> (),
    RemoveMultiple: (SubtitleEntry) -> (),
    AddReferenceSound: (SubtitleEntry, ReferenceSound: Sound) -> (),
    RemoveReferenceSound: (SubtitleEntry, ReferenceSound: Sound) -> (),
    Destroy: (SubtitleEntry) -> (),
}



return {}