local entrance = boulderdash.Derive("base")
entrance.flash_delay = 0.15
entrance.strip = 2

function entrance:flip_index()
	if entrance.prop:getIndex()==1 then
		entrance.prop:setIndex(2)
	else
		entrance.prop:setIndex(1)
	end
end

function entrance:create_rockford()
	entrance:remove()
	local x,y = entrance:getPos()
	boulderdash.Create( "rockford", x, y)
end

function entrance:load( x, y )
	local tileDeck = Moai:cachedTileDeck(boulderdash.imgpath .. "outbox.png", entrance.strip, 1)
	entrance.prop  = Moai:createProp(layer, tileDeck, x, y)	
	
	if not entrance.flash_timer then	-- start a timer only once
		entrance.flash_timer = Moai:createLoopTimer(entrance.flash_delay, entrance.flip_index)
	end
	
	local timer = MOAITimer.new()
	timer:setSpan( 2.0 )
	timer:setMode( MOAITimer.NORMAL )
	timer:setListener( MOAITimer.EVENT_TIMER_END_SPAN, entrance.create_rockford)
	timer:start()	
end

return entrance