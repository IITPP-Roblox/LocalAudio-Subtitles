# LocalAudio-Subtitles
LocalAudio Subtitles is an extension to [LocalAudio](https://github.com/IITPP-Roblox/LocalAudio)
for showing subtitles when audios are played.

# Setup
## Project
This project uses [Rojo](https://github.com/rojo-rbx/rojo) for the project
structure. Four project files in included in the repository.
* `default.project.json` - Structure for just the module within Wally projects.
* `default-standalone.project.json` - Structure for just the module to
  be published as a standalone module outside of Wally.
* `demo.project.json` - Full Roblox place that can be synced into Roblox
  studio and ran with demo models.
* `demo-standalone.project.json` - Full Roblox place that can be synced
  into Roblox studio and ran with demo models, but with the standalone
  module setup.

To set up the project dependencies with types:
```bash
wally install
rojo sourcemap demo.project.json --output sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages/
```

## Game
### Loading
LocalAudio Subtitles has to be loaded on the client in order to run. It
is recommended to initialize the subtitles module before `LocalAudio`.
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalAudioSubtitles = require(ReplicatedStorage:WaitForChild("LocalAudioSubtitles"))
local LocalAudio = require(ReplicatedStorage:WaitForChild("LocalAudio"))
local SubtitlesData = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("Subtitles"))

LocalAudioSubtitles:SetUp(SubtitlesData)
LocalAudio:SetUp()
```

### Subtitle Entries
Subtitles for audios are stored as events in the data for `LocalAudio`.
Each audio can have either a single subtitle entry stored in `Subtitle`
or a list of subtitle entries stored in `Subtitles`. Each subtitle
entry can have the following entries:
- `Time: number?` - Time in seconds that the subtitle happens at.
  - If not defined, `0` will be used.
- `Duration: number?` - Time in seconds that the subtitle appears for.
  - If not defined, the subtitle will either go to the time of the next
    subtitle if there is one or the end of the audio.
- `Message: string` - Message to display for the subtitle. Can include
  rich text formatting.
- `MessageColor: Color3?` - Color to apply to the entire message.
  - If not defined, no color will be applied and the message will
    appear as white.
- `Speaker: String?` - Name of the speaker to display with the message.
  - If defined as a key in the `Speakers` in the subtitles data (next
    section), the data for the speaker will be used for additional
    properties.
- `SpeakerModifier: String?` - Name of the modifier of the speaker to
  apply on top of the `Speaker`.
  - This requires the modifier to be defined in `Modifiers` for the
    `Speaker` in `Speakers` (next section).
- `SpeakerDisplayName: string?` - Display name to use for the speaker.
  - If defined, this will override the displayed name for `Speaker`
    and any modifiers.
- `SpeakerColor: Color3?` - Color to use for the speaker.
  - If defined, this this will override the color for `Speaker`
    and any modifiers.
- `Level: string | number?` - Level that the subtitle will appear.
  - If a string is provided, it will be converted to a number
    using the subtitle data (next section).
  - The subtitles main module stores a minimum level of subtitles
    to show in order to allow filtering of dialogs and effects.
    Lower numbers should be used for higher priority subtitles,
    like dialogs.
- `Macro: string?` - Optioanl string that is used to store common
  values between multiple subtiltes. The next section covers the format.

### Subtitles Data
The main subtitle data refers to the common data shared between the
subtitles. Contained are up to 3 tables:
- `Speakers` - Table of speaker information referenced by `Speaker`
  in the subtitle entries. In each value can be.
  - `Color: Color3?` - Optional color of the speaker.
  - `DisplayName: string?` - Optional display name of the speaker.
  - `Modifiers: {[string]: {Color: Color3?, DisplayName: string?}}?` -
    Optional table of modifiers specified with `Modifier` in the
    subtitle data. Contained in each entry can be a `Color` and
    `DisplayName` that will override the speaker.
- `Macros` - List of common values used by multiple subtitle
  entries. They can contain any property in the subtitle entries,
  including other macros.
- `Levels` - Maps `Level`s that are strings to number values.

# Subtitle Data Examples
## Single subtitle
```lua
--ReplicationStore/Data/Audio
...
{
    Id = SOME_ID,
    Length = 10,
    Subtitle = {
        --No speaker, Time defaults to 0, Duration defaults to 10.
        Message = "Message",
    },
}
...
```

## Multiple Subtitles
```lua
--ReplicationStore/Data/Audio
...
{
    Id = SOME_ID,
    Length = 10,
    Subtitles = {
        {
            --No speaker, Time defaults to 0, Duration defaults to 4, color will be green.
            Message = "Message 1",
            MessageColor = Color3.fromRGB(0, 170, 0),
        },
        {
            --No speaker, Duration defaults to 6.
            Message = "Message 2",
            Time = 4,
        },
    },
}
...
```

## Speakers
```lua
--ReplicationStore/Data/Subtitles
{
    Speakers = {
        Speaker1 = {
            DisplayName = "Speaker 1",
            Color = Color3.fromRGB(0, 0, 255),
            Modifiers = {
                Modifier1 = {
                    DisplayName = "Speaker 1 (Modified 1)",
                    Color = Color3.fromRGB(0, 255, 0),
                },
                Modifier2 = {
                    DisplayName = "Speaker 1 (Modified 2)",
                },
                Modifier3 = {
                    Color = Color3.fromRGB(255, 0, 0),
                },
            },
        },
    },
}

--ReplicationStore/Data/Audio
...
{
    Id = SOME_ID,
    Length = 10,
    Subtitles = {
        {
            --Speaker will be "Speaker 1" with a color of 0, 0, 255
            Speaker = "Speaker1",
            Message = "Message",
        },
        {
            --Speaker will be "Speaker 1 (Modified 1)" with a color of 0, 255, 0
            Speaker = "Speaker1",
            Modifier = "Modifier1",
            Message = "Message",
            Time = 1,
        },
        {
            --Speaker will be "Speaker 1 (Modified 2)" with a color of 0, 0, 255
            Speaker = "Speaker1",
            Modifier = "Modifier2",
            Message = "Message",
            Time = 2,
        },
        {
            --Speaker will be "Speaker 1" with a color of 0, 255, 0
            Speaker = "Speaker1",
            Modifier = "Modifier3",
            Message = "Message",
            Time = 3,
        },
        {
            --Speaker will be "Speaker 1 (Display)" with a color of 255, 255, 0
            Speaker = "Speaker1",
            SpeakerDisplayName = "Speaker 1 (Display)",
            SpeakerColor = Color3.fromRGB(255, 255, 0),
            Message = "Message",
            Time = 4,
        },
        {
            --Speaker will be "Speaker 1 (Display)" with a color of 255, 255, 0
            Speaker = "Speaker1",
            Modifier = "Modifier1",
            SpeakerDisplayName = "Speaker 1 (Display)",
            SpeakerColor = Color3.fromRGB(255, 255, 0),
            Message = "Message",
            Time = 5,
        },
        {
            --Speaker will be "Speaker2"
            Speaker = "Speaker2",
            Message = "Message",
            Time = 6,
        },
    },
}
...
```

## Macros
```lua
--ReplicationStore/Data/Subtitles
{
    Macros = {
        Macro1 = {
            Duration = 2,
            Speaker = "Speaker",
        },
        Macro2 = {
            Duration = 3, --Overrides Duration in Macro1
            Macro = "Macro1",
        },
    },
}

--ReplicationStore/Data/Audio
...
{
    Id = SOME_ID,
    Length = 10,
    Subtitles = {
        {
            --Speaker will be "Speaker", Duration will be 2.
            Macro = "Macro1",
            Message = "Message",
        },
        {
            --Speaker will be "Speaker", Duration will be 3.
            Macro = "Macro2",
            Message = "Message",
            Time = 1,
        },
        {
            --Speaker will be "Speaker", Duration will be 4.
            Macro = "Macro2",
            Duration = 4, --Overrides Duration in Macro2
            Message = "Message",
            Time = 2,
        },
    },
}
...
```

## Levels
```lua
--ReplicationStore/Data/Subtitles
{
    Levels = {
        Announcement = 1
        AnnouncementChime = 2,
        Interruption = 2, --Levels can be non-unique.
    },
}

--ReplicationStore/Data/Audio
...
{
    Id = SOME_ID,
    Length = 10,
    Subtitles = {
        {
            --Level will be 2
            Level = 2,
            Message = "Message",
        },
        {
            --Level will be 1
            Level = "Announcement",
            Message = "Message",
            Time = 1,
        },
        {
            --Level will be 2
            Level = "AnnouncementChime",
            Message = "Message",
            Time = 2,
        },
    },
}
...
```

# Module API
- `LocalAudioSubtitles:ShowSubtitle(Message: string, Duration: number, Level: number?): nil` -
  Shows a subtitle in the window with the given message for
  the given duration. The message can be formatted with rich
  text. `Level` is optional for filtering the subtitle.
- `LocalAudioSubtitles:SetSubtitleLevel(MinimumSubtitleLevel: number): nil` - 
  Sets the minimum subtitle subtitle level to display. By
  default, `0` is set.
- `LocalAudioSubtitles:SetUp(SubtitlesData: SubtitleDataModule): nil` -
  Prepares the `LocalAudio` events with subtitles and connects
  listening for subtitles to be requested. The `SubtitlesData`
  has to be the table data (not `ModuleScript`) of the common
  subtitles data.

# License
This project is available under the terms of the MIT License. See [LICENSE](LICENSE)
for details.