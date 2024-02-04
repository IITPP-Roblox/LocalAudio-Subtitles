return function(label: TextLabel, text: string, delayBetweenChars: number?)
	local displayText = text

	-- Replace line break tags so grapheme loop will not miss those characters
	displayText = displayText:gsub("<br%s*/>", "\n")
	displayText:gsub("<[^<>]->", "")

	-- Set modified text on parent
	label.Text = displayText

	local index = 0
	for _ in utf8.graphemes(displayText) do
		index = index + 1
		label.MaxVisibleGraphemes = index
		task.wait(delayBetweenChars)
	end
end