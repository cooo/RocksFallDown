local magic_wall = boulderdash.Derive("base")
magic_wall.hard    = true
magic_wall.rounded = false
magic_wall.strip   = 4

function magic_wall:load( x, y )
	magic_wall.sleepy = Moai:cachedTexture( boulderdash.imgpath .. "wall.png",       magic_wall.width, magic_wall.height)
	magic_wall.alive  = Moai:cachedTileDeck(boulderdash.imgpath .. "magic_wall.png", magic_wall.strip, 1)
	
	self.prop  = Moai:createProp(layer, magic_wall.sleepy, x, y)
	Moai:createAnimation(magic_wall.strip, magic_wall.prop)
end

function magic_wall:wakeUp()
	magic_wall.prop:setDeck(magic_wall.alive)
end

function magic_wall:goToSleep()
	magic_wall.prop:setDeck(magic_wall.sleepy)
end

function magic_wall:update()
	-- check for falling rocks or diamonds
	local x, y = self:getPos()
	local object = boulderdash:find(x,y-1)
	
	if magic_walls:sleeps() and object.falling then
		magic_walls.wakeUp()	-- tells other magic wall object to wakeup
	-- it gets better
	elseif magic_walls:tingles() and object.falling and boulderdash:find(x,y+1).type=="space" then
		if object.type=="rock" then
			object:remove()
			boulderdash.Create( "space",   x, y-1 )
			boulderdash.Create( "diamond", x, y+1 )
		end
		if object.type=="diamond" then
			object:remove()
			boulderdash.Create( "space",   x, y-1 )
			boulderdash.Create( "rock",    x, y+1 )
		end
	elseif magic_walls:finished() and object.falling then
		object.falling = false
	end
end

return magic_wall