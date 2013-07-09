local diamond = boulderdash.Derive("base")
diamond.hard = true
diamond.rounded = true
diamond.images = {}
diamond.strip = 8

function diamond:load( x, y )

	local tileDeck = Moai:cachedTileDeck(boulderdash.imgpath .. "diamonds_32.png", diamond.strip, 1)
	diamond.prop  = Moai:createProp(layer, tileDeck, x, y)	
	Moai:createAnimation(diamond.strip, diamond.prop)	
end

function diamond:update(dt)
  	self:fall()

	local x,y = self:getPos()
	diamond.prop:setLoc ( Moai:x_and_y(x,y) )
end

function diamond:draw()
	-- local x, y = self:getPos()
	-- local img  = self:getImage()
	-- love.graphics.drawq(img, self.images[self.sprite_index or 1], x*self.scale, y*self.scale)

end

function diamond:consume()
	layer:removeProp(self.prop)
	boulderdash.diamonds = boulderdash.diamonds + 1
	audio:play("get_diamond")
	if (boulderdash.diamonds < level_loader.games[menu.game_index].caves[menu.cave_index].diamonds_to_get) then
		scoreboard.score = scoreboard.score + scoreboard.diamonds_are_worth		
	else
		scoreboard.score = scoreboard.score + scoreboard.extra_diamonds_are_worth
	end
	return true
end

return diamond