menu = {}

menu.show       = false
menu.game       = {}
menu.game_index = 1
menu.cave       = {}
menu.cave_index = 0
menu.cursor     = "game"
menu.img        = nil
menu.sprites    = {}
menu.tiles      = {}

function menu:load()
	menu.img = love.graphics.newImage( boulderdash.imgpath .. "all.png" )
	for i=0, 32*(11-1), 32 do
		table.insert( menu.sprites, love.graphics.newQuad(0, i, 32, 32, 32, 32*11) )
	end
end

function menu:write(board, str,  y, cursor)
	if (menu.cursor == cursor) then
		str = "x " .. str .. " x"
	end
	
	local offset_x = (love.graphics.getWidth()/2) - (str:len()*32 / 2)
	letter_lua = love.filesystem.load( boulderdash.objpath .. "letter.lua" )

	for i, digit in pairs(string.dice(str)) do
		local d = string.byte(str, i)

		local object = letter_lua()
		object:load(((i-1)*32 + offset_x), y, d)
		object.type = "letter"
		object.id = id((i*32), 0)

		board[object.id] = object
	end
end


function menu:update(dt)
	if menu.show then
		menu.game = {}
		local changed = false
		if love.keyboard.isDown("right") and menu.cursor=="game" then 
			menu.game_index	= menu.game_index + 1
			changed = true
		elseif love.keyboard.isDown("left") and menu.cursor=="game" then
			menu.game_index	= menu.game_index - 1
			changed = true
		elseif love.keyboard.isDown("right") and menu.cursor=="cave" then 
			menu.cave_index	= menu.cave_index + 1
			changed = true
		elseif love.keyboard.isDown("left") and menu.cursor=="cave" then
			menu.cave_index	= menu.cave_index - 1
			changed = true
		elseif love.keyboard.isDown("down") then 
			menu.cursor = "cave"
			changed = true
		elseif love.keyboard.isDown("up") then
			menu.cursor = "game"
			changed = true
		end
	
		if (menu.game_index > #level_loader.games) then
			menu.game_index = #level_loader.games
		end
		if menu.game_index < 1 then
			 menu.game_index = 1
		end
		if (menu.cave_index > #level_loader.games[menu.game_index].caves) then
			menu.cave_index = #level_loader.games[menu.game_index].caves
		end
		if menu.cave_index < 1 then
			 menu.cave_index = 1
		end

		if changed then
			
			boulderdash.objects = {}
		    local level = level_loader.games[menu.game_index].caves[menu.cave_index].map
		
			menu.tiles = {}
			for y,i in pairs(level) do
				for x,j in pairs(level[y]) do
					menu.tiles[id(x,y)] = { x=x-1, y=y, sprite=preview_lookup(level[y][x]) }
				end
			end
			
		end	
	end	
end

function menu:draw()
	if menu.show then
		for i, tile in pairs(menu.tiles) do
			love.graphics.drawq(menu.img, menu.sprites[tile.sprite], tile.x*32, tile.y*32)
		end

		love.graphics.setColor(0,0,0, 128)
		round_rect( 50, 50, scoreboard.screen_width - 100, 200, 20)

		str = level_loader.games[menu.game_index].name
		menu:write(menu.game, str, 100, "game")

		str = level_loader.games[menu.game_index].caves[menu.cave_index].name
		menu:write(menu.cave, str, 150, "cave")

		for i, letter in pairs(menu.game) do
			if letter.draw then
				letter:draw()
			end
		end
		for i, letter in pairs(menu.cave) do
			if letter.draw then
				letter:draw()
			end
		end

	end
end

function menu.pressed(key)
	return key=="m"
end

function menu.execute()
	if menu.show then
		menu.show = false
		menu.cave_index = menu.cave_index - 1
		boulderdash:LevelUp()
	else
		menu.show = true
	end
end

local right = 0
local left = math.pi
local bottom = math.pi * 0.5
local top = math.pi * 1.5

function round_rect(x, y, w, h, r)
   r = r or 15
   love.graphics.rectangle("fill", x, y+r, w, h-r*2)
   love.graphics.rectangle("fill", x+r, y, w-r*2, r)
   love.graphics.rectangle("fill", x+r, y+h-r, w-r*2, r)
   love.graphics.arc("fill", x+r, y+r, r, left, top)
   love.graphics.arc("fill", x + w-r, y+r, r, -bottom, right)
   love.graphics.arc("fill", x + w-r, y + h-r, r, right, bottom)
   love.graphics.arc("fill", x+r, y + h-r, r, bottom, left)
end

return menu