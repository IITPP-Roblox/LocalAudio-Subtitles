--Tests SubtitleEntry.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Fusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Fusion"))
local SubtitleEntry = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("LocalAudioSubtitles"):WaitForChild("UI"):WaitForChild("SubtitleEntry"))

return function()
    local TestScope, TestSubtitleEntry = nil, nil
    beforeEach(function()
        SubtitleEntry._TextService = {
            GetTextBoundsAsync = function()
                return Vector2.new(200, 20)
            end,
        } :: any

        TestScope = Fusion:scoped({})
        TestSubtitleEntry = SubtitleEntry.new(TestScope, "Test message", 12, 300)
    end)

    afterEach(function()
        SubtitleEntry._TextService = TextService
        TestSubtitleEntry:Destroy()
    end)

    describe("A SubtitleEntry", function()
        it("should be created correctly.", function()
            expect(Fusion.peek(TestSubtitleEntry.Multiple)).to.equal(1)
            expect(Fusion.peek(TestSubtitleEntry.Visible)).to.equal(true)
            expect(Fusion.peek(TestSubtitleEntry.DisplayMessage)).to.equal("Test message")
            expect(Fusion.peek(TestSubtitleEntry.Height)).to.equal(20)
        end)

        it("should handle multiples.", function()
            TestSubtitleEntry:AddMultiple()
            expect(Fusion.peek(TestSubtitleEntry.Multiple)).to.equal(2)
            expect(Fusion.peek(TestSubtitleEntry.Visible)).to.equal(true)
            expect(Fusion.peek(TestSubtitleEntry.DisplayMessage)).to.equal("Test message <font color=\"rgb(180,180,180)\"><i>(2x)</i></font>")
            expect(Fusion.peek(TestSubtitleEntry.Height)).to.equal(20)
        
            TestSubtitleEntry:RemoveMultiple()
            expect(Fusion.peek(TestSubtitleEntry.Multiple)).to.equal(1)
            expect(Fusion.peek(TestSubtitleEntry.Visible)).to.equal(true)
            expect(Fusion.peek(TestSubtitleEntry.DisplayMessage)).to.equal("Test message")
            expect(Fusion.peek(TestSubtitleEntry.Height)).to.equal(20)
        end)
    end)
end