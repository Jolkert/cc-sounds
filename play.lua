local function getNextChunk(handle, size)
    local sample = handle.read() - 128
    if not sample then
        return nil
    end

    local i = 1
    local chunk = {}
    while sample and i <= size do
        chunk[i] = sample
        i = i + 1
        sample = handle.read() - 128
    end

    return chunk
end

local function execute(file_name, speaker)
    local BUFFER_SIZE = 128 * 1024

    local file = fs.open(file_name "rb")

    local buffer = getNextChunk(file, BUFFER_SIZE)
    while buffer do
        while not speaker.playAudio(buffer) do
            os.pullEvent("speaker_audio_empty")
        end

        buffer = getNextChunk(file, BUFFER_SIZE)
    end

    file.close()
end

local speaker = peripheral.find("speaker")
if not speaker then
    term.blit("could not find speaker peripheral!", colors.red, term.getBackgroundColor())
elseif not arg[1] then
    term.blit("A file must be specified!", colors.red, term.getBackgroundColor())
else
    execute(arg[1], speaker)
end
