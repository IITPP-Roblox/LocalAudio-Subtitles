--[[
TheNexusAvenger

Data for the subtitles.
--]]

return {
    Speakers = {
        Keepsake = {
            Color = Color3.fromRGB(0, 170, 255),
            Modifiers = {
                Chorus = {
                    Color = Color3.fromRGB(30, 200, 255),
                },
                Background = {
                    Color = Color3.fromRGB(0, 140, 225),
                },
            },
        },
        ASAS = {
            Color = Color3.fromRGB(200, 200, 200),
        },
    },
    Macros = {
        NormalAnnouncementChime = {
            Time = 0,
            Duration = 1,
            Message = "*Announcement chime*",
            MessageColor = Color3.fromRGB(0, 170, 255),
            Level = "ExtraAnnouncement",
            TypeWriter = true,
        },
        WarningAnnouncement = {
            MessageColor = Color3.fromRGB(255, 170, 0),
            Level = "Dialog",
        },
        WarningAnnouncementChime = {
            Time = 0,
            Duration = 1,
            Message = "*Warning announcement chime*",
            MessageColor = Color3.fromRGB(255, 170, 0),
            Level = "ExtraAnnouncement",
            Macro = "WarningAnnouncement",
        },
    },
    Levels = {
        Dialog = 1,
        ExtraAnnouncement = 2,
    },
}