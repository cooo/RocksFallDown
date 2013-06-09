local wall = boulderdash.Derive("base")
wall.hard = true
wall.rounded = true

function wall:load( x, y )
	local quad = Moai:cachedTexture(boulderdash.imgpath .. "wall.png", wall.width, wall.height)
	self.prop  = Moai:createProp(quad, x, y)
end

return wall