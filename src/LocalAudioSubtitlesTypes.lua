--[[
TheNexusAvenger

Types for the LocalAudio Subtitles.
--]]

--Classes
export type SubtitleWindow = {
    new: () -> (SubtitleWindow),
    SubtitleEntries: {SubtitleEntry},
    RowAdornFrame: Frame,
    UpdateSize: (SubtitleWindow) -> (),
    ShowSubtitle: (SubtitleWindow, Message: string, Duration: number) -> (),
}

export type SubtitleEntry = {
    new: (Message: string, Window: SubtitleWindow) -> (SubtitleWindow),
    UpdatePosition: (SubtitleEntry) -> (),
    Destroy: (SubtitleEntry) -> (),
}



return {}