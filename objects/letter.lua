local letter = boulderdash.Derive("base")

letter.quads = {} -- quads are as follows [space, {a-z}, {0-9}]
letter.i = nil

-- ' ' : 32
-- A   : 65 -  90
-- a   : 97 - 122
-- 0-9 : 48 -  57

function letter:load(x,y,i)
	self:setImage(love.graphics.newImage( boulderdash.imgpath .. "letters_white.png"))
	for j=0, 16*(37-1), 16 do
		table.insert( self.quads, love.graphics.newQuad(0, j, 32, 16, 32, 16*37) )
	end
		
	self:setPos( x, y )
	self:set_index( i )
end

function letter:set_index(i)
	if (i==32) then
		self.i = 1      -- set space to pos 1
	else
		if (i>47 and i<58) then
			i = i - 20 + 63  -- adjust numbers from [48..57] to [28..37] 
		elseif (i>96) then
			i = i - 32  -- adjust caps
		end
		self.i = i - 63	-- set alphabet to [2..27] 
	end
end

function letter:draw()
	local x, y = self:getPos()
	local img  = self:getImage()

	if letter.i>0 then
		love.graphics.drawq(img, self.quads[letter.i], x, y)
	end
end

return letter
