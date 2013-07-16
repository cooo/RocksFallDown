local explode = boulderdash.Derive("base")

explode.strip = 5
explode.flash_delay = 0.1
explode.flash_timer = 0
explode.master = false

function explode:load( x, y )
	local tileDeck = Moai:cachedTileDeck( boulderdash.imgpath .. "explode.png", explode.strip, 1) --MOAITileDeck2D.new ()

	explode.prop = MOAIProp2D.new ()
	explode.prop:setDeck ( tileDeck )
	explode.prop:setLoc ( Moai:x_and_y(x,y) )
	
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
			boulderdash:ReplaceByID(explode.id, "diamond") 
			if self.callback then
				self.callback()
			end
	    end
	)
	anim:start ()
	layer:insertProp(self.prop)	
end

return explode