local space = boulderdash.Derive("base")

function space:load( x, y )
--	self:setImage(love.graphics.newImage( boulderdash.imgpath .. "space.png"))
	self:setPos( x, y )
end

function space:remove()
	-- remove space, really?
end

-- we need this empty function to prevent the base:draw call
function space:draw()
end


return space