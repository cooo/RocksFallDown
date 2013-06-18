scoreboard = {}
scoreboard.one_second_timer = nil
scoreboard.clock = 0
scoreboard.diamonds_to_get = 0
scoreboard.diamonds_are_worth = 0
scoreboard.extra_diamonds_are_worth = 0
scoreboard.score = 0
scoreboard.number_lua = nil
scoreboard.matrix = {}


function scoreboard:createScoreboard(viewport)
	local scoreboard_layer = MOAILayer2D.new ()
	scoreboard_layer:setViewport ( viewport )
	
	return scoreboard_layer
end

function scoreboard:countdown()
	scoreboard.clock = scoreboard.clock - 1
end

function scoreboard:load()
	self.clock	                  = level_loader.games[menu.game_index].caves[menu.cave_index].time
	self.diamonds_to_get          = level_loader.games[menu.game_index].caves[menu.cave_index].diamonds_to_get
	self.diamonds_are_worth       = level_loader.games[menu.game_index].caves[menu.cave_index].diamonds_are_worth
	self.extra_diamonds_are_worth = level_loader.games[menu.game_index].caves[menu.cave_index].extra_diamonds_are_worth
	self.one_second_timer         = Moai:createLoopTimer(1.0, scoreboard.countdown)
		
	scoreboard.number_lua = loadfile( boulderdash.objpath .. "number.lua" )
	scoreboard:diamonds()
end


function scoreboard.Create(name, x, y, i)
	x = x or 0
	y = y or 0

	local object = scoreboard.number_lua()
	object:load(x,y,i)
	object.type = name
	object.id = id(x,y)
	scoreboard.matrix[object.id] = object
	return object
end


function scoreboard:update(dt)
	
	if boulderdash.done then
		scoreboard.countdown()
		scoreboard.score = scoreboard.score + 1
		if scoreboard.clock <= 0 then
			scoreboard.clock = 0
			boulderdash:LevelUp()
		end
	end

	scoreboard:diamonds()

	-- update the matrix
	for i, digit in pairs(self.matrix) do
		digit:update()
	end
	
	-- if boulderdash:magic_wall_tingles() then
	-- 	audio:play("twinkly_magic_wall", true)
	-- end
end

-- finds a digit on the scoreboard and change it to i, create it if not found
local function find_or_create(name, x, y, i)
	if scoreboard.matrix[id( x,y )] then
		local number = scoreboard.matrix[id( x,y )]
		number:set_index( i )
	else
		scoreboard.Create( name, x, y, i )
	end
end

local function draw_on_board(str, x)
	
	if (x>=0) then
		local board_to_get = {}
		string.gsub(str, "(.)", function(x) table.insert(board_to_get, x) end)
		
		for i, digit in pairs(board_to_get) do
			find_or_create( "number", x+i, 0, digit )
		end
	end
end

function scoreboard:diamonds()
	draw_on_board(string.rjust(self.diamonds_to_get,    2, "0"),  0)
	draw_on_board(string.rjust(self.diamonds_are_worth, 2, "0"),  3)
	draw_on_board(string.rjust(boulderdash.diamonds,    2, "0"),  8)
	draw_on_board(string.rjust(self.clock,		        3, "0"), 13)
	draw_on_board(string.rjust(self.score,              6, "0"), 17) -- format with 6 positions
end






