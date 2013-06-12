local number = boulderdash.Derive("base")

number.i = nil
number.strip = 10

function number:load(x,y,i)
	local path = boulderdash.imgpath .. "numbers_white.png"
	local tileDeck = Moai:cachedTileDeck(path, 1, number.strip)
	self.prop      = Moai:createProp(scoreboard_layer, tileDeck, x, y)
	self:set_index(i)		
end

function number:set_index(i)
	self.i = i + 1	-- so self.i is in [1..10]
end

function number:update()
	number.prop:setIndex(number.i)
end

return number
