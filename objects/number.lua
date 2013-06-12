local number = boulderdash.Derive("base")

number.quads = {}
number.i = nil
number.strip = 10

function number:load(x,y,i)
	-- self:setImage(love.graphics.newImage( boulderdash.imgpath .. "numbers_white.png"))
	-- for j=0, 16*(10-1), 16 do
	-- 	table.insert( self.quads, love.graphics.newQuad(0, j, 32, 16, 32, 16*10) )
	-- end
	-- self:setPos( x, y )
	
	self:set_index( i )
	
	
	local tileDeck = MOAITileDeck2D.new ()
	tileDeck:setTexture ( boulderdash.imgpath .. "numbers_white.png" )
	tileDeck:setSize ( 1, number.strip )	-- width, height
	tileDeck:setRect ( 0, 0, 32, 16 )

	print(x,y)

	number.prop = MOAIProp2D.new ()
	number.prop:setDeck ( tileDeck )
	number.prop:setLoc ( Moai:x_and_y(x,y) )
	number.prop:setIndex(number.i)	
	scoreboard_layer:insertProp(number.prop)
	
end

function number:set_index(i)
	self.i = i + 1	-- so self.i is in [1..10]
end

function number:draw()
	-- local x, y = self:getPos()
	-- local img  = self:getImage()
	-- if number.i>0 then
	-- 	love.graphics.drawq(img, self.quads[number.i], x, y)
	-- end
end

return number
