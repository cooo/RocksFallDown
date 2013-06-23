local outbox = boulderdash.Derive("base")
outbox.hard = true
outbox.flash_delay = 0.15
outbox.strip = 2

-- the outbox looks like steel, until enough diamonds are collected,
-- then the outbox flashes with the outbox bitmap
function outbox:load( x, y )
	local tileDeck = Moai:cachedTileDeck(boulderdash.imgpath .. "outbox.png", outbox.strip, 1)
	outbox.prop  = Moai:createProp(layer, tileDeck, x, y)	
end

function outbox:flip_index()
	if outbox.prop:getIndex()==1 then
		outbox.prop:setIndex(2)
	else
		outbox.prop:setIndex(1)
	end
end

function outbox:consume()
	if not outbox.hard then
		boulderdash.setDone()
		outbox.flash_timer:stop()
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

		if not outbox.flash_timer then	-- start a timer only once
			outbox.flash_timer = Moai:createLoopTimer(outbox.flash_delay, outbox.flip_index)
		end
	end
end

return outbox