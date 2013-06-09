local base = {}

base.x = 0
base.y = 0
base.img = nil
base.type = nil
base.rounded = false
base.hard = false
base.moved = false
base.explodes = true
base.debug = false
base.scale = 32


base.width  = 32
base.height = 32
base.prop   = nil


function id(x,y)
	return "x" .. x .. "y" .. y
end

function base:to_s()
	if base.falling then
		print(base.type .. ": (" .. base.x .. ", " .. base.y .. ") falling")
	else
		print(base.type .. ": (" .. base.x .. ", " .. base.y .. ") not falling")
	end
end

function base:setPos( x, y )
--	print("base:setPos (" .. x .. ", " .. y .. ")" )
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

function base:fall()
	local x,y = base:getPos()

	-- fall straight down
	if (boulderdash:find(x,y+1).type == "space") then
		swap(base, x, y+1)
	-- fall of rounded object (to the left)
	elseif (boulderdash:find(x,y+1).rounded and boulderdash:find(x-1,y).type=="space" and boulderdash:find(x-1,y+1).type=="space") then
		swap(base, x-1, y+1)	
	-- fall of rounded object (to the right)
	elseif (boulderdash:find(x,y+1).rounded and boulderdash:find(x+1,y).type=="space" and boulderdash:find(x+1,y+1).type=="space") then
		swap(base, x+1, y+1)
	elseif (boulderdash:find(x,y+1).explode ) then
		boulderdash:explode(id(x,y+1))
	elseif (boulderdash:find(x,y+1).hard and not (boulderdash:find(x,y+1).type=="magic_wall") ) then
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


function base:draw()	
	-- local x, y = self:getPos()	
	-- local img = self:getImage()

	
	-- love.graphics.draw(img, x*self.scale, y*self.scale, 0, 2, 2)
	-- 
	-- if (base.debug) then
	-- 	print(base.type)
	-- 	print(base.x .. ", " .. base.y)
	-- 	print(base.falling)
	-- end
end

return base