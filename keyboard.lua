keyboard = {}


local suicide = {}

function suicide.pressed(key)
	return key=="d"
end

function suicide.execute()
	boulderdash.dead = true
end


keyboard.controls = { audio, suicide, menu }

function keyboard.keypressed(key)
	for i, action in pairs(keyboard.controls) do
		if action.pressed(key) then
			action.execute()
		end
	end
end
