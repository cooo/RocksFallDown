audio = {}

audio.path          = "sound/"
audio.sounds        = {}
audio.master_switch = true

function audio:init()
	MOAIUntzSystem.initialize()
	
	local files = MOAIFileSystem.listFiles( audio.path )
	for _, sound_file in ipairs(files) do
		if string.find(sound_file, ".ogg") then
			local sound_name = string.sub(sound_file, 1, string.find(sound_file, ".ogg") - 1)
			print(sound_name)
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
		for i, sound in ipairs(audio.loopsounds) do
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

function audio:stop(sound)
	audio.sounds[sound]:stop()
	audio.loopsounds[sound] = nil
end
