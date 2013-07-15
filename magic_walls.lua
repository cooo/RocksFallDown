magic_walls = {}

magic_walls.magictime = 0
magic_walls.dormant   = nil
magic_walls.expired   = nil

local goToSleep	-- forward declaration, so things are in order
	
function magic_walls:init(magictime)
	magic_walls.magictime = magictime
	magic_walls.dormant   = true
	magic_walls.expired   = false
end

function magic_walls:sleeps()
	return magic_walls.dormant and not magic_walls.expired
end

function magic_walls:tingles()
	return not magic_walls.dormant and not magic_walls.expired 
end

function magic_walls:finished()
	return magic_walls.dormant and magic_walls.expired 
end

function magic_walls:wakeUp()
	magic_walls.dormant = false
	Moai:createTimer(magic_walls.magictime, goToSleep)	-- call goToSleep when the magic wall runs out of magic
	for i, object in pairs(boulderdash.objects) do
		if object.type=="magic_wall" then
			object:wakeUp()
		end
	end
	audio:play("twinkly_magic_wall", true)
end

function goToSleep()
	magic_walls.dormant = true
	magic_walls.expired = true

	for i, object in pairs(boulderdash.objects) do
		if object.type=="magic_wall" then
			object:goToSleep()
		end
	end		
	audio:stop("twinkly_magic_wall")
end
