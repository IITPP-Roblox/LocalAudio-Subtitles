--[[
TheNexusAvenger

Tests the EventTransform class.
--]]

local EventTransform = require(game:GetService("ReplicatedStorage"):WaitForChild("LocalAudioSubtitles"):WaitForChild("EventTransform"))



return function()
    local function expectThatEventsMatch(SubtitleEntries, ExpectedEvents)
        local ActualEvents = EventTransform:Transform(SubtitleEntries, 10)
        expect(#ActualEvents).to.equal(#ActualEvents)
        for i = 1, #ExpectedEvents do
            expect(ActualEvents[i].Name).to.equal("ShowSubtitle")
            expect(ActualEvents[i].Time).to.be.near(ExpectedEvents[i].Time)
            expect(ActualEvents[i].Duration).to.be.near(ExpectedEvents[i].Duration)
            expect(ActualEvents[i].Message).to.equal(ExpectedEvents[i].Message)
        end
    end

    --Set the data.
    beforeAll(function()
        EventTransform:SetSubtitleData({
            Speakers = {
                Speaker4 = {
                    DisplayName = "Speaker",
                },
                Speaker5 = {
                    DisplayName = "Speaker",
                    Modifiers = {
                        Modifier = {},
                    },
                },
                Speaker6 = {
                    DisplayName = "Speaker",
                    Modifiers = {
                        Modifier = {
                            DisplayName = "ModifiedSpeaker",
                        },
                    },
                },
                Speaker8 = {
                    Color = Color3.fromRGB(50, 100, 150),
                },
                Speaker9 = {
                    Color = Color3.fromRGB(50, 100, 150),
                    Modifiers = {
                        Modifier = {},
                    },
                },
                Speaker10 = {
                    Color = Color3.fromRGB(50, 100, 150),
                    Modifiers = {
                        Modifier = {
                            Color = Color3.fromRGB(100, 150, 200),
                        },
                    },
                },
            },
            Macros = {
                Macro1 = {
                    Speaker = "Speaker",
                    Duration = 4,
                    Time = 2,
                },
                Macro2 = {
                    Time = 6,
                    Macro = "Macro1"
                },
                CyclicMacro1 = {
                    Macro = "CyclicMacro2"
                },
                CyclicMacro2 = {
                    Macro = "CyclicMacro3"
                },
                CyclicMacro3 = {
                    Macro = "CyclicMacro1"
                },
            },
        })
    end)

    --Run the tests.
    describe("Subtitle entry with no macros", function()
        it("should work with only a message.", function()
            expectThatEventsMatch({
                {
                    Message = "Test",
                },
            }, {
                {
                    Time = 0,
                    Duration = 10,
                    Message = "Test",
                },
            })
        end)

        it("should work with a time offset.", function()
            expectThatEventsMatch({
                {
                    Time = 2,
                    Message = "Test",
                },
            }, {
                {
                    Time = 2,
                    Duration = 8,
                    Message = "Test",
                },
            })
        end)

        it("should work with a time and duration.", function()
            expectThatEventsMatch({
                {
                    Time = 2,
                    Duration = 4,
                    Message = "Test",
                },
            }, {
                {
                    Time = 2,
                    Duration = 4,
                    Message = "Test",
                },
            })
        end)

        it("should work with a speaker.", function()
            expectThatEventsMatch({
                {
                    Speaker = "Speaker1",
                    Message = "Test",
                },
            }, {
                {
                    Time = 0,
                    Duration = 10,
                    Message = "Speaker1: Test",
                },
            })
        end)

        it("should work with a speaker display name.", function()
            expectThatEventsMatch({
                {
                    Speaker = "Speaker2",
                    SpeakerDisplayName = "Speaker",
                    Message = "Test",
                },
            }, {
                {
                    Time = 0,
                    Duration = 10,
                    Message = "Speaker: Test",
                },
            })
        end)

        it("should work with only a speaker display name.", function()
            expectThatEventsMatch({
                {
                    SpeakerDisplayName = "Speaker",
                    Message = "Test",
                },
            }, {
                {
                    Time = 0,
                    Duration = 10,
                    Message = "Speaker: Test",
                },
            })
        end)

        it("should work with speaker reference.", function()
            expectThatEventsMatch({
                {
                    Speaker = "Speaker4",
                    Message = "Test",
                },
            }, {
                {
                    Time = 0,
                    Duration = 10,
                    Message = "Speaker: Test",
                },
            })
        end)

        it("should work with speaker modifier but no modifier name.", function()
            expectThatEventsMatch({
                {
                    Speaker = "Speaker5",
                    SpeakerModifier = "Modifier",
                    Message = "Test",
                },
            }, {
                {
                    Time = 0,
                    Duration = 10,
                    Message = "Speaker: Test",
                },
            })
        end)

        it("should work with speaker modifier and modifier name.", function()
            expectThatEventsMatch({
                {
                    Speaker = "Speaker6",
                    SpeakerModifier = "Modifier",
                    Message = "Test",
                },
            }, {
                {
                    Time = 0,
                    Duration = 10,
                    Message = "ModifiedSpeaker: Test",
                },
            })
        end)

        it("should use a speaker color.", function()
            expectThatEventsMatch({
                {
                    Speaker = "Speaker7",
                    SpeakerColor = Color3.fromRGB(50, 100, 150),
                    Message = "Test",
                },
            }, {
                {
                    Time = 0,
                    Duration = 10,
                    Message = "<font color=\"rgb(50,100,150)\">Speaker7</font>: Test",
                },
            })
        end)

        it("should use a speaker color in a speaker reference.", function()
            expectThatEventsMatch({
                {
                    Speaker = "Speaker8",
                    Message = "Test",
                },
            }, {
                {
                    Time = 0,
                    Duration = 10,
                    Message = "<font color=\"rgb(50,100,150)\">Speaker8</font>: Test",
                },
            })
        end)

        it("should use a speaker color in a speaker reference with a modifier but no modifier color.", function()
            expectThatEventsMatch({
                {
                    Speaker = "Speaker9",
                    SpeakerModifier = "Modifier",
                    Message = "Test",
                },
            }, {
                {
                    Time = 0,
                    Duration = 10,
                    Message = "<font color=\"rgb(50,100,150)\">Speaker9</font>: Test",
                },
            })
        end)

        it("should use a speaker color in a speaker reference with a modifier.", function()
            expectThatEventsMatch({
                {
                    Speaker = "Speaker10",
                    SpeakerModifier = "Modifier",
                    Message = "Test",
                },
            }, {
                {
                    Time = 0,
                    Duration = 10,
                    Message = "<font color=\"rgb(100,150,200)\">Speaker10</font>: Test",
                },
            })
        end)

        it("should ignore SpeakerColor if there is no speaker.", function()
            expectThatEventsMatch({
                {
                    SpeakerColor = Color3.fromRGB(50, 100, 150),
                    Message = "Test",
                },
            }, {
                {
                    Time = 0,
                    Duration = 10,
                    Message = "Test",
                },
            })
        end)

        it("should use a message color.", function()
            expectThatEventsMatch({
                {
                    Speaker = "Speaker12",
                    Message = "Test",
                    MessageColor = Color3.fromRGB(50, 100, 150),
                },
            }, {
                {
                    Time = 0,
                    Duration = 10,
                    Message = "Speaker12: <font color=\"rgb(50,100,150)\">Test</font>",
                },
            })
        end)
    end)

    describe("2 subtitle entries with no macros", function()
        it("should set the duration right to the next entry.", function()
            expectThatEventsMatch({
                {
                    Message = "Test 1",
                },
                {
                    Time = 4,
                    Message = "Test 2",
                },
            }, {
                {
                    Time = 0,
                    Duration = 4,
                    Message = "Test 1",
                },
                {
                    Time = 4,
                    Duration = 6,
                    Message = "Test 2",
                },
            })
        end)
    end)

    describe("Subtitles entries with macros", function()
        it("should set the values.", function()
            expectThatEventsMatch({
                {
                    Message = "Test 1",
                    Macro = "Macro1",
                },
            }, {
                {
                    Time = 2,
                    Duration = 4,
                    Message = "Speaker: Test 1",
                },
            })
        end)

        it("should set the values with chained macros.", function()
            expectThatEventsMatch({
                {
                    Message = "Test 1",
                    Macro = "Macro2",
                },
            }, {
                {
                    Time = 6,
                    Duration = 4,
                    Message = "Speaker: Test 1",
                },
            })
        end)

        it("should check the time of a macro.", function()
            expectThatEventsMatch({
                {
                    Message = "Test 1",
                },
                {
                    Message = "Test 2",
                    Macro = "Macro2",
                },
            }, {
                {
                    Time = 0,
                    Duration = 6,
                    Message = "Test 1",
                },
                {
                    Time = 6,
                    Duration = 4,
                    Message = "Speaker: Test 2",
                },
            })
        end)

        it("should error on a cylic macro.", function()
            expect(function()
                EventTransform:Transform({
                    {
                        Macro = "CyclicMacro1",
                    }
                }, 10)
            end).to.throw("There is a cyclic reference of macros: CyclicMacro1->CyclicMacro2->CyclicMacro3->CyclicMacro1")
        end)
    end)

    describe("Populate events", function()
        it("should not add subtitles.", function()
            local AudioData = {
                Id = 1,
                Length = 2,
            }
            EventTransform:PopulateEvents(AudioData)
            expect(AudioData.Events).to.be.equal(nil)
        end)

        it("should add individual subtitles.", function()
            local AudioData = {
                Id = 1,
                Length = 2,
                Subtitle = {
                    Message = "Test",
                },
            }
            EventTransform:PopulateEvents(AudioData)
            expect(AudioData.Events[1].Message).to.be.equal("Test")
            expect(AudioData.Events[1].Time).to.be.near(0)
            expect(AudioData.Events[1].Duration).to.be.near(2)
        end)

        it("should add multiple subtitles.", function()
            local AudioData = {
                Id = 1,
                Length = 2,
                Subtitles = {
                    {
                        Message = "Test 1",
                    },
                    {
                        Time = 0.5,
                        Message = "Test 2",
                    },
                },
            }
            EventTransform:PopulateEvents(AudioData)
            expect(AudioData.Events[1].Message).to.be.equal("Test 1")
            expect(AudioData.Events[1].Time).to.be.near(0)
            expect(AudioData.Events[1].Duration).to.be.near(0.5)
            expect(AudioData.Events[2].Message).to.be.equal("Test 2")
            expect(AudioData.Events[2].Time).to.be.near(0.5)
            expect(AudioData.Events[2].Duration).to.be.near(1.5)
        end)

        it("should recursively add subtitles.", function()
            local AudioData = {
                Id = 1,
                Length = 2,
                Subtitle = {
                    Message = "Test 1",
                },
                SubEntry = {
                    Id = 1,
                    Length = 3,
                    Subtitle = {
                        Message = "Test 2",
                    },
                },
            }
            EventTransform:PopulateEvents(AudioData)
            expect(AudioData.Events[1].Message).to.be.equal("Test 1")
            expect(AudioData.Events[1].Time).to.be.near(0)
            expect(AudioData.Events[1].Duration).to.be.near(2)
            expect(AudioData.SubEntry.Events[1].Message).to.be.equal("Test 2")
            expect(AudioData.SubEntry.Events[1].Time).to.be.near(0)
            expect(AudioData.SubEntry.Events[1].Duration).to.be.near(3)
        end)
    end)
end