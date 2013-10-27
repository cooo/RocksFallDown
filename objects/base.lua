local base = {}

base.x = 0
base.y = 0
base.img = nil
base.type = nil
base.rounded = false
base.hard = false
base.moved = false
base.can_explode = false -- when something fall on top
base.explodes = true     -- explodes when something next to it explodes
base.debug = false
base.scale = 32
base.callback = nil


base.width  = 32
base.height = 32
base.prop   = nil


function id(x,y)
	return "x" .. x .. "y" .. y
end

function base:to_s()
	if base.falling then
		return frame_counter .. ": " .. base.type .. ": (" .. base.x .. ", " .. base.y .. ") falling"
	else
		return frame_counter .. ": " .. base.type .. ": (" .. base.x .. ", " .. base.y .. ") not falling"
	end
end

function base:setPos( x, y )
	base.x = x
	base.y = y
	if (x==13 and y==2) then
		base.debug=false
	end
end

function base:setImage(img)
	base.img = img
end

function base:getImage()
	return base.img
end

function base:getPos()
	return base.x, base.y
end

-- move something in x,y direction and put space where something was
function base:doMove(x,y)
	local xr,yr = base:getPos()
	base:setPos( xr+x, yr+y )
	base.id = id( base:getPos() )
	boulderdash.objects[base.id] = base
	base.moved = true
	base.prop:setLoc (Moai:x_and_y(xr+x, yr+y) )

	local space = boulderdash.Create( "space", xr, yr )
	boulderdash.objects[space.id] = space
end

-- swap base with whatever is at x,y
local function swap(base, x,y)
	base.falling = true
	
	-- swap base with whatever
	local whatever = boulderdash:find(x,y)
	whatever:setPos(base.x,base.y)
	whatever.id = base.id
	boulderdash.objects[whatever.id] = whatever
	
	-- move base
	base:setPos(x,y)
	base.id = id(x,y)
	boulderdash.objects[base.id] = base
end

function base:explode(callback)	
	local directions = { {x=1,y=0}, {x=-1,y=0}, {x=1,y=-1}, {x=0,y=-1}, {x=-1,y=-1}, {x=1,y=1}, {x=0,y=1}, {x=-1,y=1} }
	for i,d in ipairs(directions) do	
		local object = boulderdash:find(self.x+d.x, self.y+d.y)
		if object.explodes then
			object:remove()
			boulderdash.Create( "explode", base.x+d.x, base.y+d.y)  -- no callback
		end
	end
	x,y = base.x, base.y
	base:remove()
	boulderdash.Create( "explode", x, y, callback)	-- the center of the explosion
	audio:play("explosion")
end

function base:fall()
	
	local x,y = base:getPos()
	
	local object_under = boulderdash:find(x,y+1)

	-- fall straight down
	if (object_under.type == "space") then
		swap(base, x, y+1)
	-- fall of rounded object (to the left)
	elseif (object_under.rounded and boulderdash:find(x-1,y).type=="space" and boulderdash:find(x-1,y+1).type=="space") then
		swap(base, x-1, y+1)	
	-- fall of rounded object (to the right)
	elseif (object_under.rounded and boulderdash:find(x+1,y).type=="space" and boulderdash:find(x+1,y+1).type=="space") then
		swap(base, x+1, y+1)
	elseif (object_under.can_explode ) then
		object_under:explode()
		
	elseif (object_under.hard and not (object_under.type=="magic_wall") ) then
		if base.falling then
			audio:play("rock_fall")
	    	base.falling = false
		end
		-- magic wall is checked inside each magic wall object
	end
	
end

function base:remove()
	layer:removeProp(self.prop)
end


return base