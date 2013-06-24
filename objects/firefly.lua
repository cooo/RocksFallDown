local firefly = boulderdash.Derive("base")
local faces = { "left", "up", "right", "down" }
local directions = { {x=-1,y=0}, {x=0,y=-1}, {x=1,y=0}, {x=0,y=1} }
local orientation = 1
firefly.can_explode = true   -- can create an explosion
firefly.rounded = true
firefly.deadly  = true
firefly.facing = faces[orientation]
firefly.strip = 8

function firefly:load( x, y )
	local tileDeck = Moai:cachedTileDeck(boulderdash.imgpath .. "firefly.png", firefly.strip, 1)
	firefly.prop  = Moai:createProp(layer, tileDeck, x, y)	
	Moai:createAnimation(firefly.strip, firefly.prop)	
end

function firefly:update(dt)
	self:move(dt)
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