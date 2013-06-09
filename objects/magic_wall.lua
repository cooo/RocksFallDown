local magic_wall = boulderdash.Derive("base")
magic_wall.hard = true
magic_wall.rounded = false
magic_wall.images = {}
magic_wall.sprite_index = nil
magic_wall.dormant_img = nil

function magic_wall:load( x, y )
	self.dormant_img = love.graphics.newImage( boulderdash.imgpath .. "wall.png")
	self:setImage(love.graphics.newImage( boulderdash.imgpath .. "magic_wall.png"))
	for i=0, 32*(4-1), 32 do
		table.insert( self.images, love.graphics.newQuad(i, 0, 32, 32, 32*4, 32) )
	end
	self:setPos( x, y )
end

function magic_wall:update(dt)
	if boulderdash.magicwall_dormant and not boulderdash.magicwall_expired then
		-- check for falling rocks or diamonds
		local x, y = self:getPos()
		local object = boulderdash:find(x,y-1)
		
		if (object.falling) then
			boulderdash.magicwall_dormant = false
		end

	-- it gets better
	elseif boulderdash:magic_wall_tingles() then

		local x, y = self:getPos()
		local object = boulderdash:find(x,y-1)

		if object.falling and boulderdash:find(x,y+1).type=="space" then
			if object.type=="rock" then
				boulderdash.Create( "space",   x, y-1 )
				boulderdash.Create( "diamond", x, y+1 )
			end
			if object.type=="diamond" then
				boulderdash.Create( "space",   x, y-1 )
				boulderdash.Create( "rock", x, y+1 )
			end

		end

		local timer = since(t_minus_zero) % 1
		self.sprite_index = 1 + math.floor(timer / (1/4))
			
	elseif boulderdash.magicwall_expired then
		local x, y = self:getPos()
		local object = boulderdash:find(x,y-1)

		if (object.falling) then
			object.falling = false
		end


	end
end

function magic_wall:draw()
	
	local x, y = self:getPos()
	if boulderdash.magicwall_dormant or boulderdash.magicwall_expired then
		-- normal rock
		local img  = self.dormant_img
		love.graphics.draw(img, x*self.scale, y*self.scale, 0, 2, 2)
	else		
		local img  = self:getImage()
		love.graphics.drawq(img, self.images[self.sprite_index or 1], x*self.scale, y*self.scale)
	end
end

-- function magic_wall:consume()
-- 	boulderdash.magic_walls = boulderdash.magic_walls + 1
-- 	if (boulderdash.magic_walls < level_loader.games[menu.game_index].caves[menu.cave_index].magic_walls_to_get) then
-- 		scoreboard.score = scoreboard.score + scoreboard.magic_walls_are_worth
-- 	else
-- 		scoreboard.score = scoreboard.score + scoreboard.extra_magic_walls_are_worth
-- 	end
-- 	return true
-- end

return magic_wall