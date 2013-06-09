local explode = boulderdash.Derive("base")

explode.strip = 5
explode.flash_delay = 0.1
explode.flash_timer = 0
explode.to = "space"
explode.master = false

function explode:load( x, y )
	-- self:setImage(love.graphics.newImage( boulderdash.imgpath .. "explode.png" ))
	-- for i=0, 32*(5-1), 32 do
	-- 	table.insert( self.images, love.graphics.newQuad(i, 0, 32, 32, 32*5, 32) )
	-- end
	-- self:setPos( x, y )
	-- self.flash_timer = reset_time()
	
	
	local tileDeck = MOAITileDeck2D.new ()
	tileDeck:setTexture ( boulderdash.imgpath .. "explode.png" )
	tileDeck:setSize ( explode.strip, 1 )	-- width, height
	tileDeck:setRect ( 0, 0, 32, 32 )


	explode.prop = MOAIProp2D.new ()
	explode.prop:setDeck ( tileDeck )
	explode.prop:setLoc ( x*32 - (STAGE_WIDTH/2), -y*32 + (STAGE_HEIGHT/2) )
	
	local curve = MOAIAnimCurve.new ()

	curve:reserveKeys ( explode.strip )
	for i=1, explode.strip do
		curve:setKey ( i, (i-1)/explode.strip, i, MOAIEaseType.FLAT )
	end

	local anim = MOAIAnim:new ()
	anim:reserveLinks ( 1 )
	anim:setLink ( 1, curve, explode.prop, MOAIProp2D.ATTR_INDEX )
	anim:setMode ( MOAITimer.NORMAL )
	anim:setListener ( MOAITimer.EVENT_TIMER_END_SPAN, 
		function ()
			
			
		   layer:removeProp(self.prop) -- remove the explosion
--			boulderdash.Create( explode.to, x, y )
	       boulderdash:ReplaceByID(explode.id, explode.to) -- create space or diamonds
	
			if self.master then
				print("master done")
				boulderdash:startOver()
			else
				print("done")
			end
	
	    end
	)
	anim:start ()
	layer:insertProp(self.prop)	
end

function explode:update(dt)
-- 	-- if (since(self.flash_timer) > self.flash_delay) then
-- 	-- 	self.sprite_index = self.sprite_index + 1
-- 	-- 	if (self.sprite_index >= self.end_frame) then
-- 	-- 		self.sprite_index = self.end_frame
-- 	-- 		boulderdash:ReplaceByID(self.id, explode.to)
-- 	-- 		if (boulderdash.died) then boulderdash.start_over = true end
-- 	-- 	end
-- 	-- 	self.flash_timer = reset_time()
-- 	-- end	
end
-- 
-- function explode:draw()
-- 	-- local x, y = self:getPos()	
-- 	-- local img  = self:getImage()
-- 	-- love.graphics.drawq(img, self.images[self.sprite_index or 1], x*self.scale, y*self.scale)
-- end

return explode