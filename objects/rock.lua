local rock = boulderdash.Derive("base")

rock.rounded = true
rock.hard = true
rock.falling = false

function rock:load( x, y )
	local quad = Moai:cachedTexture(boulderdash.imgpath .. "rock.png", rock.width, rock.height)
	self.prop  = Moai:createProp(layer, quad, x, y)
end

function rock:update()
  	self:fall()
	
	local x,y = self:getPos()
	rock.prop:setLoc ( Moai:x_and_y(x,y) )
end

-- only 1 out of 8 tries leads to a push
function rock:push(x)
	local xr,yr = self:getPos()
	local one = math.random(1,8)
	if ((one==1) and (boulderdash:find(xr+x,yr).type=="space")) then
		self:doMove( x, 0 )
	end
end


return rock
