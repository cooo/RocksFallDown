audio = {}

audio.path          = "sound/"
audio.sounds        = {}
audio.master_switch = true
audio.loopsounds    = {}

function audio:init()
	MOAIUntzSystem.initialize()
	
	local files = MOAIFileSystem.listFiles( audio.path )
	for _, sound_file in ipairs(files) do
		if string.find(sound_file, ".ogg") then
			local sound_name = string.sub(sound_file, 1, string.find(sound_file, ".ogg") - 1)
			local sound = MOAIUntzSound.new ()
			sound:load(audio.path .. sound_file)
			audio.sounds[sound_name] = sound
			sound = nil
		end
	end
end

function audio.pressed(key)
	return key=="s"
end

function audio.execute()
	if audio.master_switch then
		audio.master_switch = false
		love.audio.stop( )
	else
		audio.master_switch = true
		for sound in pairs(audio.loopsounds) do
			audio:play(sound, true)
		end
	end
end


function audio:play(sound_name, loop, callbackFunction)
	if audio.master_switch then
		function threadFunc ()
			local sound = audio.sounds[sound_name]
			sound:setVolume ( 1 )
			sound:setLooping ( loop or false )
			sound:play()
			if loop then
				audio.loopsounds[sound_name] = true
			end
			if callbackFunction ~= nil then
				while sound:isPlaying() do 
					coroutine:yield() 
				end
				callbackFunction()
			end
		end
		thread = MOAICoroutine.new ()
		thread:run ( threadFunc )
	end
end

function audio:stop(sound_name)
	audio.sounds[sound_name]:stop()
	audio.loopsounds[sound_name] = nil
end

function audio:stopAll()
	for sound_name in pairs(audio.loopsounds) do
		audio.sounds[sound_name]:stop()
	end
end
