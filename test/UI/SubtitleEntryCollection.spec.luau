--Tests SubtitleEntryCollection.
--!strict


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")

local Fusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Fusion"))
local SubtitleEntry = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("LocalAudioSubtitles"):WaitForChild("UI"):WaitForChild("SubtitleEntry"))
local SubtitleEntryCollection = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("LocalAudioSubtitles"):WaitForChild("UI"):WaitForChild("SubtitleEntryCollection"))

return function()
    local TestScope, TestSubtitleEntryCollection = nil, nil
    beforeEach(function()
        SubtitleEntry._GuiService = {
            ReducedMotionEnabled = true,
        } :: any
        SubtitleEntry._TextService = {
            GetTextBoundsAsync = function()
                return Vector2.new(200, 20)
            end,
        } :: any

        TestScope = Fusion:scoped({})
        TestSubtitleEntryCollection = SubtitleEntryCollection.new(12, 300)
    end)

    afterEach(function()
        SubtitleEntry._GuiService = GuiService
        SubtitleEntry._TextService = TextService
        TestScope:doCleanup()
    end)

    describe("A SubtitleEntryCollection", function()
        it("should add entries.", function()
            TestSubtitleEntryCollection:AddEntry("Test message 1", 1)

            local Entries = Fusion.peek(TestSubtitleEntryCollection.DisplayedEntries)
            expect(#Entries).to.equal(1)
            expect(Fusion.peek(Entries[1].DisplayMessage)).to.equal("Test message 1")
            expect(Fusion.peek(Entries[1].Height)).to.equal(20)
            expect(Fusion.peek(Entries[1].YOffset)).to.equal(0)
            
            TestSubtitleEntryCollection:AddEntry("Test message 2", 1)

            Entries = Fusion.peek(TestSubtitleEntryCollection.DisplayedEntries)
            expect(#Entries).to.equal(2)
            expect(Fusion.peek(Entries[1].DisplayMessage)).to.equal("Test message 1")
            expect(Fusion.peek(Entries[1].Height)).to.equal(20)
            expect(Fusion.peek(Entries[1].YOffset)).to.equal(-20)
            expect(Fusion.peek(Entries[2].DisplayMessage)).to.equal("Test message 2")
            expect(Fusion.peek(Entries[2].Height)).to.equal(20)
            expect(Fusion.peek(Entries[2].YOffset)).to.equal(0)
        end)

        it("should add multiple entries.", function()
            TestSubtitleEntryCollection:AddEntry("Test message 1", 1)

            local Entries = Fusion.peek(TestSubtitleEntryCollection.DisplayedEntries)
            expect(#Entries).to.equal(1)
            expect(Fusion.peek(Entries[1].DisplayMessage)).to.equal("Test message 1")
            expect(Fusion.peek(Entries[1].Height)).to.equal(20)
            expect(Fusion.peek(Entries[1].YOffset)).to.equal(0)
            
            TestSubtitleEntryCollection:AddEntry("Test message 1", 1)

            Entries = Fusion.peek(TestSubtitleEntryCollection.DisplayedEntries)
            expect(#Entries).to.equal(1)
            expect(Fusion.peek(Entries[1].DisplayMessage)).to.equal("Test message 1 <font color=\"rgb(180,180,180)\"><i>(2x)</i></font>")
            expect(Fusion.peek(Entries[1].Height)).to.equal(20)
            expect(Fusion.peek(Entries[1].YOffset)).to.equal(0)
        end)

        it("should hide entries.", function()
            TestSubtitleEntryCollection:AddEntry("Test message 1", 1)
            expect(#Fusion.peek(TestSubtitleEntryCollection.DisplayedEntries)).to.equal(1)

            TestSubtitleEntryCollection._Entries[1].Multiple:set(0)
            expect(#Fusion.peek(TestSubtitleEntryCollection.DisplayedEntries)).to.equal(0)
        end)

        it("should remove entries with active multiples.", function()
            TestSubtitleEntryCollection:AddEntry("Test message 1", 0)
            TestSubtitleEntryCollection:AddEntry("Test message 1", 1)
            expect(#Fusion.peek(TestSubtitleEntryCollection.DisplayedEntries)).to.equal(1)

            task.wait()
            expect(#Fusion.peek(TestSubtitleEntryCollection.DisplayedEntries)).to.equal(1)
        end)

        it("should remove entries.", function()
            TestSubtitleEntryCollection:AddEntry("Test message 1", 0)
            expect(#Fusion.peek(TestSubtitleEntryCollection.DisplayedEntries)).to.equal(1)

            task.wait()
            expect(#Fusion.peek(TestSubtitleEntryCollection.DisplayedEntries)).to.equal(0)
        end)
    end)
end