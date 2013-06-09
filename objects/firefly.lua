local firefly = boulderdash.Derive("base")
local faces = { "left", "up", "right", "down" }
local directions = { {x=-1,y=0}, {x=0,y=-1}, {x=1,y=0}, {x=0,y=1} }
local orientation = 1
firefly.explode = true   -- can create an explosion
firefly.rounded = true
firefly.deadly  = true
firefly.images = {}
firefly.sprite_index = 1
firefly.flash_delay = 0.02
firefly.flash_timer = 0
firefly.facing = faces[orientation]

function firefly:rotateRight()
	orientation = orientation + 1
	if (orientation > 4) then orientation = 1 end
	firefly.facing = faces[orientation]
end

function firefly:rotateLeft()
	orientation = orientation - 1
	if (orientation < 1) then orientation = 4 end
	firefly.facing = faces[orientation]
end

function firefly:load( x, y )
	self:setImage(love.graphics.newImage( boulderdash.imgpath .. "firefly.png"))
	for i=0, 32*(8-1), 32 do
		table.insert( self.images, love.graphics.newQuad(i, 0, 32, 32, 32*8, 32) )
	end
	self:setPos( x, y )
end

function firefly:update(dt)
	self:move(dt)
--	if (since(self.flash_timer) > self.flash_delay) then
		self.sprite_index = self.sprite_index + 1
		self.flash_timer = reset_time()
		if (self.sprite_index == 9) then
			self.sprite_index = 1
		end
--	end
end

function firefly:draw()
	local x, y = self:getPos()	
	local img  = self:getImage()
	love.graphics.drawq(img, self.images[self.sprite_index or 1], x*self.scale, y*self.scale)
end

function firefly:space_is_empty_to_the(direction)
	if firefly:space_is_empty("left",  direction) then return true end
	if firefly:space_is_empty("down",  direction) then return true end
	if firefly:space_is_empty("right", direction) then return true end
	if firefly:space_is_empty("up",    direction) then return true end	
	return false
end

function firefly:space_is_empty(facing, d)
	return (self.facing==facing) and (boulderdash:find(self.x+d.x, self.y+d.y).type == "space")
end

function firefly:move(dt)
	local x, y = self:getPos()
	local left_orientation = orientation - 1 -- turn left
	if (left_orientation < 1) then left_orientation = 4 end
	local left = directions[left_orientation]
	local front = directions[orientation]
		
	if (firefly:space_is_empty_to_the(left)) then
		self:rotateLeft()
		self:doMove(left.x, left.y)
	elseif (firefly:space_is_empty_to_the(front)) then
		self:doMove(front.x, front.y)
	else
		self:rotateRight()
	end	
end

return firefly