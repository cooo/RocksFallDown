local number = boulderdash.Derive("base")

number.quads = {}
number.i = nil

function number:load(x,y,i)
	self:setImage(love.graphics.newImage( boulderdash.imgpath .. "numbers_white.png"))
	for j=0, 16*(10-1), 16 do
		table.insert( self.quads, love.graphics.newQuad(0, j, 32, 16, 32, 16*10) )
	end
	self:setPos( x, y )
	self:set_index( i )
end

function number:set_index(i)
	self.i = i + 1	-- so self.i is in [1..10]
end

function number:draw()
	local x, y = self:getPos()
	local img  = self:getImage()
	if number.i>0 then
		love.graphics.drawq(img, self.quads[number.i], x, y)
	end
end

return number
