local dirt = boulderdash.Derive("base")

dirt.hard   = true

function dirt:load( x, y )
	local quad = Moai:cachedTexture(boulderdash.imgpath .. "dirt.png", dirt.width, dirt.height)
	self.prop  = Moai:createProp(layer, quad, x, y)	
end

function dirt:update(dt)

end

function dirt:consume()
	layer:removeProp(self.prop)
	audio:play("eat_dirt")
	return true
end

return dirt