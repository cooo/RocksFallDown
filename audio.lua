audio = {}

audio.path          = "sound/"
audio.sounds        = {}
audio.loopsounds    = { }
audio.master_switch = false

function audio:init()
	local sounds = love.filesystem.enumerate( audio.path )	
	for k, sound in ipairs(sounds) do
		if string.find(sound, ".ogg") then
			local sound_name = string.sub(sound,1,string.find(sound, ".ogg") - 1)
			audio.sounds[sound_name] = love.audio.newSource(audio.path .. sound, "static")
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


function audio:play(sound, loop)
	if audio.master_switch then
		audio.sounds[sound]:stop()
		audio.sounds[sound]:play()
	end
	if loop then
		audio.sounds[sound]:setLooping(true)
		if audio.loopsounds[sound] == nil then
			audio.loopsounds[sound] = true
		end
		
	end
end

function audio:stop(sound)
	audio.sounds[sound]:stop()
	audio.loopsounds[sound] = nil
end