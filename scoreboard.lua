scoreboard = {}
scoreboard.countdown = nil
scoreboard.one_second_timer = 0
scoreboard.one_second = 1
scoreboard.diamonds_to_get = 0
scoreboard.diamonds_are_worth = 0
scoreboard.extra_diamonds_are_worth = 0
scoreboard.score = 0
scoreboard.numbers_white_img = nil -- move this to a numbers.lua
scoreboard.number_lua = nil
scoreboard.matrix = {}

function scoreboard:load()
	self.countdown                = level_loader.games[menu.game_index].caves[menu.cave_index].time
	self.diamonds_to_get          = level_loader.games[menu.game_index].caves[menu.cave_index].diamonds_to_get
	self.diamonds_are_worth       = level_loader.games[menu.game_index].caves[menu.cave_index].diamonds_are_worth
	self.extra_diamonds_are_worth = level_loader.games[menu.game_index].caves[menu.cave_index].extra_diamonds_are_worth
	self.one_second_timer         = reset_time()
		
	scoreboard.number_lua = love.filesystem.load( boulderdash.objpath .. "number.lua" )
	scoreboard:diamonds()
	
	scoreboard.screen_width = love.graphics.getWidth()
end

-- finds a digit on the scoreboard and change it to i, create it if not found
function scoreboard:find_or_create(name, x, y, i)
	if scoreboard.matrix[id( x,y )] then
		local number = scoreboard.matrix[id( x,y )]
		number:setPos( x, y )
		number:set_index( i )
		number.id = id( x,y )
	else
		scoreboard.Create( name, x, y, i )
	end
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
	if (since(self.one_second_timer) > self.one_second) then
		self.countdown = self.countdown - 1
		if (self.countdown <= 0) then
			-- explode too?
			self.countdown = 0
			boulderdash.dead = true -- to prevent starting the explode sequence again
		end

		if boulderdash:magic_wall_tingles() then
			boulderdash.magictime = boulderdash.magictime - 1

			if (boulderdash.magictime <= 0) then
				boulderdash.magicwall_expired = true
				audio:stop("twinkly_magic_wall")
			end
		end
		self.one_second_timer = reset_time()
	end
	scoreboard:diamonds()
	if boulderdash:magic_wall_tingles() then
		audio:play("twinkly_magic_wall", true)
	end
end

function scoreboard:draw_on_board(str, x)
	
	if (x>=0) then
		local board_to_get = {}
		string.gsub(str, "(.)", function(x) table.insert(board_to_get, x) end)
	
		for i, digit in pairs(board_to_get) do
			scoreboard:find_or_create( "number", x+(i*36), 5, digit )
		end
	end
end


function scoreboard:diamonds()
		
	scoreboard:draw_on_board(string.rjust(self.diamonds_to_get,    2, "0"),  10)
	scoreboard:draw_on_board(string.rjust(self.diamonds_are_worth, 2, "0"), 100)
	scoreboard:draw_on_board(string.rjust(boulderdash.diamonds,    2, "0"), 250)
	scoreboard:draw_on_board(string.rjust(self.countdown,          3, "0"), 350)
	scoreboard:draw_on_board(string.rjust(self.score,              6, "0"), 500) -- format with 6 positions
	
end

function scoreboard:draw()

	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", 0, 0, scoreboard.screen_width, 32 )

	-- draw the matrix
	for i, object in pairs(self.matrix) do
		object:draw()
	end

	-- draw a scoreboard on top
	-- 
	love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 750, 10)

	if (boulderdash.diamonds >= self.diamonds_to_get) then
		if not boulderdash.flash then
			audio:play("twang")
			love.graphics.setBackgroundColor(255,255,255)
			boulderdash.flash=true
		end
	end
		
end