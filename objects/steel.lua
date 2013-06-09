local steel = boulderdash.Derive("base")
steel.hard     = true
steel.explodes = false

function steel:load( x, y )
	local quad = Moai:cachedTexture(boulderdash.imgpath .. "steel.png", steel.width, steel.height)
	self.prop  = Moai:createProp(quad, x, y)
end

return steel
