--[[
TheNexusAvenger

Entry for a subtitle in the subtitle window.
--]]

local TweenService = game:GetService("TweenService")

local Types = require(script.Parent.Parent:WaitForChild("LocalAudioSubtitlesTypes"))

local SubtitleEntry = {}
SubtitleEntry.__index = SubtitleEntry



--[[
Creates a subtitle entry.
--]]
function SubtitleEntry.new(Message: string, Window: Types.SubtitleWindow): Types.SubtitleEntry
    --Create the object.
    local self = {
        Window = Window,
    }
    setmetatable(self, SubtitleEntry)

    --Create the TextLabel.
    local TextLabel = Instance.new("TextLabel")
    TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    TextLabel.Size = UDim2.new(0.99, 0, 0.95, 0)
    TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.Text = Message
    TextLabel.RichText = true
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextTransparency = 1
    TextLabel.TextScaled = true
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
    TextLabel.ZIndex = 2
    TextLabel.Parent = Window.RowAdornFrame
    self.TextLabel = TextLabel
    TweenService:Create(TextLabel, TweenInfo.new(0.25), {
		TextTransparency = 0,
	}):Play()

    --Store and update the entry.
    table.insert(Window.SubtitleEntries, self)
    Window:UpdateSize()

    --Return the object.
    return self
end

--[[
Gets the index of the subtitle.
--]]
function SubtitleEntry:GetIndex(): number
    for i, Entry in self.Window.SubtitleEntries do
        if Entry ~= self then continue end
        return i
    end
    return 0
end

--[[
Updates the position of the entry.
--]]
function SubtitleEntry:UpdatePosition(): nil
    TweenService:Create(self.TextLabel, TweenInfo.new(0.1), {
        Position = UDim2.new(0.5, 0, 0.5 - (#self.Window.SubtitleEntries - self:GetIndex()), 0),
    }):Play()
end

--[[
Destroys the entry.
--]]
function SubtitleEntry:Destroy(): nil
    game:GetService("TweenService"):Create(self.TextLabel, TweenInfo.new(0.25), {
        TextTransparency = 1,
    }):Play()
    task.delay(0.25, function()
        table.remove(self.Window.SubtitleEntries, self:GetIndex())
        self.TextLabel:Destroy()
        self.Window:UpdateSize()
    end)
end



return SubtitleEntry