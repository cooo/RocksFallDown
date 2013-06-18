local outbox = boulderdash.Derive("base")
outbox.hard = true
outbox.flash_delay = 0.15
outbox.strip = 4

-- the outbox looks like steel, until enough diamonds are collected,
-- then the outbox flashes with the outbox bitmap
function outbox:load( x, y )
	local tileDeck = Moai:cachedTileDeck(boulderdash.imgpath .. "outbox.png", outbox.strip, 1)
	outbox.prop  = Moai:createProp(layer, tileDeck, x, y)	

	local curve = MOAIAnimCurve.new ()
	curve:reserveKeys ( outbox.strip )
	for i=1, outbox.strip do
		curve:setKey ( i, (i-1)*outbox.flash_delay, i, MOAIEaseType.FLAT )
	end

	outbox.anim = MOAIAnim:new ()
	outbox.anim:reserveLinks ( 1 )
	outbox.anim:setLink ( 1, curve, outbox.prop, MOAIProp2D.ATTR_INDEX )
	outbox.anim:setMode ( MOAITimer.LOOP )
end

function outbox:consume()
	if not outbox.hard then
		boulderdash.setDone()
		outbox.anim:stop()
		outbox:remove()
		return true
	else
		return false
	end
end

function outbox:update(dt)	
	-- animation of the outbox starts now	
	if (boulderdash.diamonds >= level_loader.games[menu.game_index].caves[menu.cave_index].diamonds_to_get) then
		outbox.hard = false -- so rockford can enter
		outbox.anim:start ()
	end
end

return outbox