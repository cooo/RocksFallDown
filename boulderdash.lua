require("levels/levels")

require("amoebas")
require("audio")
require("menu")

boulderdash = {}
boulderdash.objpath   = "objects/"
boulderdash.objects   = {}
boulderdash.imgpath   = "images/"
boulderdash.diamonds = 0
boulderdash.done = false
boulderdash.dead = false
boulderdash.start_over = false
boulderdash.flash = false
boulderdash.keypressed = {}

local register = {}

delay = 0.1
delay_dt = 0

function id(x,y)
	return "x" .. x .. "y" .. y
end

function boulderdash:magic_wall_tingles()
	return not boulderdash.magicwall_dormant and not boulderdash.magicwall_expired 
end


function boulderdash.Derive(name)
	return loadfile( boulderdash.objpath .. name .. ".lua" )()
end

function boulderdash:setDone()
	boulderdash.done = true
end

function boulderdash:find(x,y)
	return boulderdash.objects[id(x,y)]
end

function boulderdash:findByID(id)
	return boulderdash.objects[id]
end

function boulderdash:findRockford()
	for i, object in pairs(boulderdash.objects) do
		if (object.type == "rockford") then
			return object
		end
	end	
end

local function registerObjects()
	-- register everything in the boulderdash.objpath folder
	local files = MOAIFileSystem.listFiles( boulderdash.objpath )
	for k, file in ipairs(files) do
		if not (file == "base.lua") then
			local obj_name = string.sub(file,1,string.find(file, ".lua") - 1)
			register[obj_name] = loadfile( boulderdash.objpath .. file )
		end
	end
end

function boulderdash:Startup()
	registerObjects()
--	audio:init()
--	menu:load()
end



function boulderdash:LevelUp()
	layer:clear()
	self.objects = {}
	local xc,yc = camera:getLoc()
	camera:moveLoc(-xc, -yc, 2.0) 

	self.map = MOAIGrid.new()
	self.map:initRectGrid(1,1,32,32)
	
	menu.cave_index = menu.cave_index + 1
    level = level_loader.games[menu.game_index].caves[menu.cave_index].map
	for y,i in pairs(level) do
		for x,j in pairs(level[y]) do
			boulderdash.Create( lookup(level[y][x]), x-1, y )
		end
	end
	
	local rf = boulderdash:findRockford()
	local xc,yc = rf.x, rf.y
	-- 
	boulderdash.done = false
	-- boulderdash.flash = false
	boulderdash.dead = false
	-- boulderdash.died = false
	-- boulderdash.start_over = false
	boulderdash.diamonds = 0
	-- boulderdash.magictime = level_loader.games[menu.game_index].caves[menu.cave_index].magictime or 0
	-- boulderdash.magicwall_dormant = true
	-- boulderdash.magicwall_expired = false
	-- boulderdash.keypressed = {}
	-- amoebas:init(tonumber(level_loader.games[menu.game_index].caves[menu.cave_index].amoebatime))
	-- 
	delay = 0.1
	scoreboard:load()
	-- 
	if (xc<10)then
		xc = 0
	elseif (xc>27) then
		xc = 12
	elseif ((yc>=10) and (yc<=27)) then
		xc = xc - 9
	end
	
	if (yc<10)then
		yc = 0
	elseif (yc>=19) then
		yc = 6
	elseif ((yc>=10 and (yc<19))) then
		yc = yc - 11
	end
	
	camera:moveLoc(xc*32, -yc*32, 2.0) 
	
--	camera:setPosition(0,0)
--	    camera:moveLoc(xc*32,yc*32)
end

function boulderdash:ReplaceAll(find, replace)
	for i, object in pairs(boulderdash.objects) do
		if (object.type == find) then
			boulderdash.Create( replace, object.x, object.y )
		end
	end	
end

function boulderdash:ReplaceByID(id, replace)
	local object = boulderdash:findByID(id)
	boulderdash.Create( replace, object.x, object.y )
	return object.x, object.y
end

function boulderdash.Create(name, x, y, callback)
	x = x or 0
	y = y or 0
	if register[name] then
		local object = register[name]()
		object:load(x,y)
		object.type = name
		object.id = id(x,y)
		object.callback = callback
		object:setPos(x,y)
		boulderdash.objects[object.id] = object
		return object
	else
		print("Error: Entity " .. name .. " does not exist! ")
	end
end

function boulderdash:explode(find)
	local object = boulderdash:findByID(find)
	local explode_to = nil
	local x, y = object.x, object.y
	print("EXPLODE:", object.type)

	-- if object and object.explode_to_diamonds then
	-- 	-- usually butterflies
	-- 	explode_to = "diamond"
	-- 	object:remove()
	-- 	x, y = boulderdash:ReplaceByID(find, "space")
	-- elseif object then
	-- 	-- usually rockford, might be a firefly
	--     object:remove()
	-- --	boulderdash.Create( "space", object.x, object.y )
	-- 	x, y = object.x, object.y
	-- 	if object.type=="rockford" then
	-- 		boulderdash.dead = false -- to prevent starting the explode sequence again
	-- 		boulderdash.died = true  -- to signal rockford just died
	-- 	end
	-- end
	
--	audio:play("explosion")


	boulderdash:canExplode( x+1, y  , object.explode_to_diamonds )
	boulderdash:canExplode( x-1, y  , object.explode_to_diamonds )
	boulderdash:canExplode( x+1, y-1, object.explode_to_diamonds )
	boulderdash:canExplode( x  , y-1, object.explode_to_diamonds )
	boulderdash:canExplode( x-1, y-1, object.explode_to_diamonds )
	boulderdash:canExplode( x+1, y+1, object.explode_to_diamonds )
	boulderdash:canExplode( x  , y+1, object.explode_to_diamonds )
	boulderdash:canExplode( x-1, y+1, object.explode_to_diamonds )
	boulderdash:canExplode( x  , y  , object.explode_to_diamonds, true )
end

function boulderdash:canExplode(x,y, explode_to, master)
	local object = boulderdash:find(x,y)
	if object.explodes then
		object:remove()
		boulderdash.Create( "explode", x, y, explode_to, master )  -- default is explode_to space
	end
end

function boulderdash:startOver()
	
	print("startOver")
	menu.cave_index = menu.cave_index - 1

	boulderdash:LevelUp()
end


function boulderdash:update(dt)
	if delay_dt > delay then

		-- amoebas.grow_directions = {}

		for i, object in pairs(boulderdash.objects) do
			if object.update then
				if not object.moved then
					object:update(dt)
					object.moved = true
				end
			end
		end
		
		if boulderdash.done then
			-- audio:stop("twinkly_magic_wall")
			MOAIInputMgr.device.keyboard:setCallback(nil)
			scoreboard.one_second_timer:stop() -- let it run out through the gameloop timer
			delay = 0		
		end
		

--		if (boulderdash.diamonds >= self.diamonds_to_get) then
		-- 	if not boulderdash.flash then
		-- 		audio:play("twang")
		-- 		love.graphics.setBackgroundColor(255,255,255)
		-- 		boulderdash.flash=true
		-- 	end
--		end
		
		-- if boulderdash.flash then
		-- 	love.graphics.setBackgroundColor(0,0,0)
		-- end
		-- 
		-- amoebas:update(delay_dt)
		scoreboard:update(dt)
		-- menu:update(dt)
		
		delay_dt = 0		
    end
	delay_dt = delay_dt + dt
	

end

function boulderdash:default()
	idle_time = love.timer.getMicroTime()	-- the start of idle time
	for i, object in pairs(boulderdash.objects) do
		if object.default then
			object:default()
		end
	end
end

function boulderdash:draw()
	for i, object in pairs(boulderdash.objects) do
		if object.draw then
			object:draw()
			object.moved = false
		end
	end
	
--	menu:draw()
		
end

