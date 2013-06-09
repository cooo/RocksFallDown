local diamond = boulderdash.Derive("base")
diamond.hard = true
diamond.rounded = true
diamond.images = {}
diamond.strip = 8

function diamond:load( x, y )
	-- self:setImage(love.graphics.newImage( boulderdash.imgpath .. "diamonds_32.png"))
	-- for i=0, 32*(8-1), 32 do
	-- 	table.insert( self.images, love.graphics.newQuad(i, 0, 32, 32, 32*8, 32) )
	-- end
	-- self:setPos( x, y )

	local tileDeck = MOAITileDeck2D.new ()
	tileDeck:setTexture ( boulderdash.imgpath .. "diamonds_32.png" )
	tileDeck:setSize ( diamond.strip, 1 )	-- width, height
	tileDeck:setRect ( 0, 0, 32, 32 )


	diamond.prop = MOAIProp2D.new ()
	diamond.prop:setDeck ( tileDeck )
	diamond.prop:setLoc ( x*32 - (STAGE_WIDTH/2), -y*32 + (STAGE_HEIGHT/2) )
	
	local curve = MOAIAnimCurve.new ()

	curve:reserveKeys ( diamond.strip )
	for i=1, diamond.strip do
		curve:setKey ( i, (i-1)/diamond.strip, i, MOAIEaseType.FLAT )
	end

	local anim = MOAIAnim:new ()
	anim:reserveLinks ( 1 )
	anim:setLink ( 1, curve, diamond.prop, MOAIProp2D.ATTR_INDEX )
	anim:setMode ( MOAITimer.LOOP )
	anim:start ()
	layer:insertProp(self.prop)
	
end

function diamond:update(dt)
  	self:fall()

	local x,y = self:getPos()
	diamond.prop:setLoc ( x*32 - (STAGE_WIDTH/2), -y*32 + (STAGE_HEIGHT/2) )
end

function diamond:draw()
	-- local x, y = self:getPos()
	-- local img  = self:getImage()
	-- love.graphics.drawq(img, self.images[self.sprite_index or 1], x*self.scale, y*self.scale)

end

function diamond:consume()
	layer:removeProp(self.prop)
	boulderdash.diamonds = boulderdash.diamonds + 1
	if (boulderdash.diamonds < level_loader.games[menu.game_index].caves[menu.cave_index].diamonds_to_get) then
		scoreboard.score = scoreboard.score + scoreboard.diamonds_are_worth

--		audio:play("get_diamond")
	else
		scoreboard.score = scoreboard.score + scoreboard.extra_diamonds_are_worth
	end
	return true
end

return diamond