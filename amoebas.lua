-- amoebas consists of one or more amoeba objects
-- could there be more than one amoebas?
-- before refactoring boulderdash.lua: 300 lines
amoebas = {}

amoebas.present          = false
amoebas.max_size         = 200			-- change to rocks if larger
amoebas.growth_speed     = 4/128		-- chance of growing, changes after amoebatime passed (see cave data)
amoebas.grow_directions  = {}			-- amoebas can possibly grow in the directions
amoebas.amoebatime       = 0			-- from the cave data, denotes switch from slow to fast growth
amoebas.size             = 0
amoebas.events           = {}           -- what might happen to amoebas

-- events
local growth       = {}	    -- amoeba can grow?
local to_rocks     = {}	    -- change to rocks?
local to_diamonds  = {}     -- change to diamonds?
local change_speed = {}     -- change growth speed?

local function replaceAmoeba(with)
	audio:stop("amoeba")
	for i, object in pairs(boulderdash.objects) do
		if (object.type == "amoeba") then
			object:remove()
			boulderdash.Create( with, object.x, object.y )
		end
	end	
end

function growth.happens()
	return amoebas.present and (#amoebas.grow_directions > 0) 
end

function growth.execute()
	if (math.random(1, 1/amoebas.growth_speed)==1) then   			-- amoeba grows this frame, pick one
		local pick_amoeba = math.random(1,#amoebas.grow_directions)
		local x,y = boulderdash:ReplaceByID(amoebas.grow_directions[pick_amoeba].id, "amoeba")
		amoebas.size = amoebas.size + 1
	end
end

function to_diamonds.happens()
	return amoebas.present and (#amoebas.grow_directions==0)
end

function to_diamonds.execute()
	replaceAmoeba("diamond")
	amoebas.present = false
end

function to_rocks.happens()
	return amoebas.size >= amoebas.max_size
end

function to_rocks.execute()
	replaceAmoeba("rock")
	amoebas.present = false
end

local function change_speed()
	amoebas.growth_speed = 0.25
end
		
function amoebas:init(amoebatime)
	if amoebas.present then
		amoebas.events        = { to_rocks, to_diamonds, growth }	-- the order is important
		amoebas.amoebatime    = amoebatime or 0
		amoebas.amoeba_timer  = Moai:createTimer(amoebas.amoebatime, change_speed)
		amoebas.growth_speed  = 4/128
		amoebas.size          = 1
		audio:play("amoeba", true)
	end
end

function amoebas:clear()
	amoebas.grow_directions = {}
end

function amoebas:update()
	if amoebas.present then
		for i, amoeba_event in pairs(amoebas.events) do
			if amoeba_event.happens() then
				amoeba_event.execute()
			end
		end
	end
end
