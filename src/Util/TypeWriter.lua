return function(Label: TextLabel, Text: string, DelayBetweenCharacters: number?)
	local DisplayText = Text

	-- Replace line break tags so grapheme loop will not miss those characters
	DisplayText = string.gsub(DisplayText, "<br%s*/>", "\n")
	DisplayText = string.gsub(DisplayText, "<[^<>]->", "")

	-- Set modified text on parent
	Label.Text = DisplayText

	local index = 0
	for _ in utf8.graphemes(DisplayText) do
		index = index + 1
		Label.MaxVisibleGraphemes = index
		task.wait(DelayBetweenCharacters)
	end
end