--Types for the LocalAudio Subtitles.
--!strict

export type SubtitleData = {
    Time: number?,
    Duration: number?,
    Message: string?,
    MessageColor: Color3?,
    Speaker: string?,
    SpeakerModifier: string?,
    SpeakerDisplayName: string?,
    SpeakerColor: Color3?,
    Level: string | number?,
    Macro: string?,
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

return {}