--Tests SubtitleEntry.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
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
        SubtitleEntry._GuiService = GuiService
        SubtitleEntry._TextService = TextService
        TestSubtitleEntry:Destroy()
    end)

    describe("A SubtitleEntry", function()
        it("should be created correctly.", function()
            expect(Fusion.peek(TestSubtitleEntry.Multiple)).to.equal(1)
            expect(Fusion.peek(TestSubtitleEntry.VisibleState)).to.equal("Visible")
            expect(Fusion.peek(TestSubtitleEntry.DisplayMessage)).to.equal("Test message")
            expect(Fusion.peek(TestSubtitleEntry.Height)).to.equal(20)
        end)

        it("should handle multiples.", function()
            TestSubtitleEntry:AddMultiple()
            expect(Fusion.peek(TestSubtitleEntry.Multiple)).to.equal(2)
            expect(Fusion.peek(TestSubtitleEntry.VisibleState)).to.equal("Visible")
            expect(Fusion.peek(TestSubtitleEntry.DisplayMessage)).to.equal("Test message <font color=\"rgb(180,180,180)\"><i>(2x)</i></font>")
            expect(Fusion.peek(TestSubtitleEntry.Height)).to.equal(20)
        
            TestSubtitleEntry:RemoveMultiple()
            expect(Fusion.peek(TestSubtitleEntry.Multiple)).to.equal(1)
            expect(Fusion.peek(TestSubtitleEntry.VisibleState)).to.equal("Visible")
            expect(Fusion.peek(TestSubtitleEntry.DisplayMessage)).to.equal("Test message")
            expect(Fusion.peek(TestSubtitleEntry.Height)).to.equal(20)
        end)

        it("should start hiding when clearing.", function()
            SubtitleEntry._GuiService = {
                ReducedMotionEnabled = false,
            } :: any

            expect(Fusion.peek(TestSubtitleEntry.Multiple)).to.equal(1)
            
            TestSubtitleEntry:RemoveMultiple()
            expect(Fusion.peek(TestSubtitleEntry.Multiple)).to.equal(0)
            expect(Fusion.peek(TestSubtitleEntry.VisibleState)).to.equal("Hiding")
        end)

        it("should start hide when clearing.", function()
            SubtitleEntry._GuiService = {
                ReducedMotionEnabled = true,
            } :: any

            expect(Fusion.peek(TestSubtitleEntry.Multiple)).to.equal(1)
            
            TestSubtitleEntry:RemoveMultiple()
            expect(Fusion.peek(TestSubtitleEntry.Multiple)).to.equal(0)
            expect(Fusion.peek(TestSubtitleEntry.VisibleState)).to.equal("Hidden")
        end)
    end)
end