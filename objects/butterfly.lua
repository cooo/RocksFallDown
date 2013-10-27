local butterfly               = boulderdash.Derive("base")
local faces                   = { "left", "up", "right", "down" }
local directions              = { {x=-1,y=0}, {x=0,y=-1}, {x=1,y=0}, {x=0,y=1} }
local orientation             = 1
butterfly.can_explode         = true	-- can create an explosion
butterfly.explode_to_diamonds = true 
butterfly.rounded             = true
butterfly.deadly              = true
butterfly.facing              = faces[orientation]
butterfly.strip               = 8

function butterfly:load( x, y )
	local tileDeck = Moai:cachedTileDeck(boulderdash.imgpath .. "butterfly.png", butterfly.strip, 1)
	butterfly.prop  = Moai:createProp(layer, tileDeck, x, y)	
	Moai:createAnimation(butterfly.strip, butterfly.prop)	
end

function butterfly:update()
	self:move()
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

function butterfly:move()
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
