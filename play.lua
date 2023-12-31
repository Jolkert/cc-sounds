local function get_next_chunk(handle, size)
	local sample = handle.read()
	if not sample then
		return nil
	end

	local i = 1
	local chunk = {}
	while sample and i <= size do
		chunk[i] = sample - 128
		i = i + 1
		sample = handle.read()
	end

	return chunk
end

local function execute(file_name, speaker, mode)
	local BUFFER_SIZE = 128 * 1024

	local file = fs.open(file_name, "rb")

	if mode == "bin" then
		local buffer = get_next_chunk(file, BUFFER_SIZE)
		while buffer do
			while not speaker.playAudio(buffer) do
				os.pullEvent("speaker_audio_empty")
			end

			buffer = get_next_chunk(file, BUFFER_SIZE)
		end
	elseif mode == "dfpwm" then
		local dfpwm = require("cc.audio.dfpwm")
		local decoder = dfpwm.make_decoder()
		for chunk in io.lines(file_name, 16 * 1024) do
			local buffer = decoder(chunk)
			while not speaker.playAudio(buffer) do
				os.pullEvent("speaker_audio_empty")
			end
		end
	end

	file.close()
end

local function print_red(text)
	local old_color = term.getTextColor()
	term.setTextColor(colors.red)
	print(text)
	term.setTextColor(old_color)
end

local speaker = peripheral.find("speaker")
if not speaker then
	print_red("could not find speaker peripheral!", colors.red, term.getBackgroundColor())
elseif not arg[1] then
	print_red("A file must be specified!", colors.red, term.getBackgroundColor())
else
	execute(arg[1], speaker, arg[2] or "dfpwm")
end
