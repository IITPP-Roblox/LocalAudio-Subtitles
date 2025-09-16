--Passthrough of LocalAudio for Wally distribution.
--!strict

local LocalAudio = require(script.Parent.Parent.Parent:WaitForChild("LocalAudio"))

export type SoundDataEntryEvent = LocalAudio.SoundDataEntryEvent
export type SoundDataEntry = LocalAudio.SoundDataEntry
export type SoundData = LocalAudio.SoundData
export type LocalAudio = LocalAudio.LocalAudio

return LocalAudio