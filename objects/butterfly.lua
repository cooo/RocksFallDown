local butterfly = boulderdash.Derive("base")
local faces = { "left", "up", "right", "down" }
local directions = { {x=-1,y=0}, {x=0,y=-1}, {x=1,y=0}, {x=0,y=1} }
local orientation = 1
butterfly.explode = true	-- can create an explosion
butterfly.explode_to_diamonds = true 
butterfly.rounded = true
butterfly.deadly  = true
butterfly.images = {}
butterfly.sprite_index = 1
butterfly.flash_delay = 0.02
butterfly.flash_timer = 0
butterfly.facing = faces[orientation]


function butterfly:rotateRight()
	orientation = orientation + 1
	if (orientation > 4) then orientation = 1 end
	butterfly.facing = faces[orientation]
end

function butterfly:rotateLeft()
	orientation = orientation - 1
	if (orientation < 1) then orientation = 4 end
	butterfly.facing = faces[orientation]
end

function butterfly:load( x, y )
	self:setImage(love.graphics.newImage( boulderdash.imgpath .. "butterfly.png"))
	for i=0, 32*(8-1), 32 do
		table.insert( self.images, love.graphics.newQuad(i, 0, 32, 32, 32*8, 32) )
	end
	self:setPos( x, y )
end

function butterfly:update(dt)
	self:move(dt)
--	if (since(self.flash_timer) > self.flash_delay) then
		self.sprite_index = self.sprite_index + 1
		self.flash_timer = reset_time()
		if (self.sprite_index == 9) then
			self.sprite_index = 1
		end
--	end
end

function butterfly:draw()
	local x, y = self:getPos()	
	local img  = self:getImage()
	love.graphics.drawq(img, self.images[self.sprite_index or 1], x*self.scale, y*self.scale)
end

function butterfly:space_is_empty_to_the(direction)
	if butterfly:space_is_empty("left",  direction) then return true end
	if butterfly:space_is_empty("down",  direction) then return true end
	if butterfly:space_is_empty("right", direction) then return true end
	if butterfly:space_is_empty("up",    direction) then return true end	
	return false
end

function butterfly:space_is_empty(facing, d)
	return (self.facing==facing) and (boulderdash:find(self.x+d.x, self.y+d.y).type == "space")
end

function butterfly:move(dt)
	local x, y = self:getPos()
	local right_orientation = orientation + 1 -- turn left
	if (right_orientation > 4 ) then right_orientation = 1 end
	local right = directions[right_orientation]
	local front = directions[orientation]
		
	if (butterfly:space_is_empty_to_the(right)) then
		self:rotateRight()
		self:doMove(right.x, right.y)
	elseif (butterfly:space_is_empty_to_the(front)) then
		self:doMove(front.x, front.y)
	else
		self:rotateLeft()
	end	
end



return butterfly