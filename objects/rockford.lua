local rockford = boulderdash.Derive("base")
rockford.images = {}
rockford.images.left = {}
rockford.images.right = {}
rockford.images.wink = {}
rockford.images.tap = {}
rockford.strip = 1
rockford.grab = false
rockford.key = nil
rockford.restless_timer = nil
rockford.config_animations = {
	entrance = {
		offset = 1,
        length = 4,
        time = 0.125,
        mode = MOAITimer.NORMAL
	},
	wink = {
		offset = 8,
        length = 8,
        time = 0.125,
        mode = MOAITimer.NORMAL
	},
	tap = {
        offset = 16,
        length = 8,
        time = 0.125,
        mode = MOAITimer.NORMAL
	},
	winktap = {
		offset = 24,
		length = 8,
		time = 0.125,
		mode = MOAITimer.NORMAL
	},
	left = {
		offset = 32,
		length = 8,
		time = 0.125,
		mode = MOAITimer.LOOP
	},
	right = {
		offset = 40,
		length = 8,
		time = 0.125,
		mode = MOAITimer.LOOP
	}
}

local local_delay = 0.05
local delay_dt = 0

local sprite_index
local directions = { {x=-1,y=0}, {x=0,y=-1}, {x=1,y=0}, {x=0,y=1} }


function rockford:animateRockford(name, offset, length, time, mode)	-- lenght=number of frames, offset=start index

	local curve = MOAIAnimCurve.new()
	curve:reserveKeys (length)
	-- curve:setKey (1, 0,           offset,        MOAIEaseType.FLAT)
	-- curve:setKey (2, time*length, offset+length, MOAIEaseType.FLAT)
	
	for i=1, length do
		curve:setKey (i, (i-1)/length, i+offset, MOAIEaseType.FLAT)
	end
	local anim = MOAIAnim:new()
	anim:reserveLinks(1)
	anim:setLink( 1, curve, self.prop, MOAIProp2D.ATTR_INDEX)
	anim:setMode(mode)
	anim.name = name

	self.animations[name] = anim
end

function rockford:getAnimation(name)
	return self.animations[name]
end

function rockford:stopCurrentAnimation()
	if self.currentAnimation then
		self.currentAnimation:stop()
	end
end

function rockford:startAnimation(name)
	if self.currentAnimation and self.currentAnimation.name==name then
	--	print("already " .. name)
	else
		self:stopCurrentAnimation()
		self.currentAnimation = self:getAnimation( name )
		self.currentAnimation:start()
		return self.currentAnimation
	end
end


-- he gets a little nervous when he doesn't have anything to do
function rockford:wink()
	local random   = math.random(1, 3)
	local twitches = { "wink", "tap", "winktap"}
	rockford:startAnimation(twitches[random])
end

function rockford:load( x, y )
	local tileDeck = MOAITileDeck2D.new ()
	tileDeck:setTexture ( boulderdash.imgpath .. "rockford.png" )
	tileDeck:setSize ( 8, 6 )	-- width, height
	tileDeck:setRect ( 0, 0, 32, 32 )
	
	rockford.prop = MOAIProp2D.new ()
	rockford.prop:setDeck ( tileDeck )
	rockford.prop:setLoc ( Moai:x_and_y(x,y) )

	layer:insertProp(rockford.prop)
		
	self.animations = {}
	for name, def in pairs ( rockford.config_animations ) do
		self:animateRockford ( name, def.offset, def.length, def.time, def.mode )
    end

    rockford.restless_timer = Moai:createLoopTimer(2.0, rockford.wink)

	rockford:startAnimation("entrance")
	
	if(MOAIInputMgr.device.keyboard) then

	    MOAIInputMgr.device.keyboard:setCallback(
	        function(key,down)
				
	            if down==true then
					self.key = key
					if key==32 then
						self.grab=true
					-- up,down=q (113),a (97), left,right=o (111), p (112)
					elseif (key==113 or key==357) then
						rockford:UpOrDown(-1)
					elseif (key==97 or key==359) then
						rockford:UpOrDown(1)
					elseif (key==111 or key==356) then
						rockford:LeftOrRight(-1)
					elseif (key==112 or key==358) then
						rockford:LeftOrRight(1)
					end
				else
					if key==32 then
						self.grab=false
					else
						self.key = nil
						self:stopCurrentAnimation()
						rockford.prop:setIndex(1)
					end
					
	            end
	        end
	    )
	end	

end

function rockford:update(dt)
	local x,y = self:getPos()
	self.prop:setLoc (Moai:x_and_y(x,y) )
	
	self:move(dt)
	self:he_might_die()
	-- self:wink()
end

function rockford:default()
	self:setImage(love.graphics.newImage( boulderdash.imgpath .. "rockford/rockford.png"))
end

function rockford:deadly_critter_at(d)
	if boulderdash:find(self.x+d.x, self.y+d.y) then
		return boulderdash:find(self.x+d.x, self.y+d.y).deadly
	else
		return false
	end
end

-- move him around or grab something
function rockford:move(dt)
--	if delay_dt > local_delay then
		if not boulderdash.dead then
			-- up,down=q (113),a (97), left,right=o (111), p (112)
			if (self.key==113 or self.key==357) then
				rockford:UpOrDown(-1)
			elseif (self.key==97 or self.key==359) then
				rockford:UpOrDown(1)
			elseif (self.key==111 or self.key==356) then
				rockford:LeftOrRight(-1)
			elseif (self.key==112 or self.key==358) then
				rockford:LeftOrRight(1)
			end
		
			if (input.touching == "left") then
				rockford:LeftOrRight(-1)
			elseif (input.touching == "right") then
				rockford:LeftOrRight(1)
			elseif (input.touching == "up") then
				rockford:UpOrDown(-1)
			elseif (input.touching == "down") then
				rockford:UpOrDown(1)
			end
		end
		delay_dt = 0		
  --  end
--	delay_dt = delay_dt + dt
	
	
	
	-- if not boulderdash.done and not rockford.moved then
	-- 	if     love.keyboard.isDown("right") then self:LeftOrRight( 1, love.keyboard.isDown(" ")) 
	-- 	elseif love.keyboard.isDown("down")  then self:UpOrDown   ( 1, love.keyboard.isDown(" ")) 
	-- 	elseif love.keyboard.isDown("left")  then self:LeftOrRight(-1, love.keyboard.isDown(" ")) 
	-- 	elseif love.keyboard.isDown("up")    then self:UpOrDown   (-1, love.keyboard.isDown(" "))
	-- 	elseif (#boulderdash.keypressed > 0) then
	-- 		local key = table.remove(boulderdash.keypressed, 1)
	-- 		if     (key=="right") then self:LeftOrRight( 1, love.keyboard.isDown(" ")) 
	-- 		elseif (key=="down")  then self:UpOrDown   ( 1, love.keyboard.isDown(" ")) 
	-- 		elseif (key=="left")  then self:LeftOrRight(-1, love.keyboard.isDown(" ")) 
	-- 		elseif (key=="up")    then self:UpOrDown   (-1, love.keyboard.isDown(" "))
	-- 		end
	-- 	end
	-- end
end


-- when a rock or diamond falls on his head rockford dies
function rockford:he_might_die()
	local xr,yr = self:getPos()
	
	self:time_is_up()
	self:dies_from_things_falling_on_his_head(xr, yr)
--	self:dead_from_being_close_to_deadly_critters(xr, yr)
end

function rockford:dies()
	scoreboard.one_second_timer:stop()
	boulderdash.dead = true -- to prevent starting the explode sequence again
	self.restless_timer:stop()
	self.currentAnimation = nil
	boulderdash:explode(self.id)
end

function rockford:time_is_up()
	if type(scoreboard.clock)=="number" and scoreboard.clock <= 0 then
		rockford:dies()
	end
end

function rockford:dies_from_things_falling_on_his_head(xr, yr)
	local object = boulderdash:find(xr,yr-1)

	if (object.falling and not boulderdash.done) then
		rockford:dies()
	end
end

function rockford:dead_from_being_close_to_deadly_critters(xr, yr)
	for i,direction in ipairs(directions) do
		if (rockford:deadly_critter_at(direction) and not boulderdash.done) then
			rockford:dies()
		end
	end
end

function rockford:LeftOrRight(x)

	table.remove(boulderdash.keypressed, 1)
	if self:canMove( x, 0 ) then
		if self.grab then
			self:doGrabRockford( x, 0 )
		else
			self:doMoveRockford( x, 0 )
		end
	end
	if (x<0) then
		rockford:startAnimation("left")
	else
		rockford:startAnimation("right")
	end
end

function rockford:UpOrDown(y)

	table.remove(boulderdash.keypressed, 1)
	if self:canMove( 0, y ) then
		if self.grab then
			self:doGrabRockford( 0, y )
		else
			self:doMoveRockford( 0, y )
		end
	end
end

function rockford:canMove(x,y)
	local xr,yr = self:getPos()
	
	-- get the object where rockford wants to go
	local object = boulderdash:find(xr+x,yr+y)

	if (object.hard and not object.consume) then
		if (object.push) then
			object:push(x)
		end
		return false
	end

	return rockford:consume(object)
end

function rockford:doMoveRockford(x,y)

	local xr,yr = self:getPos()
	self:doMove(x,y)
	-- xr -> xxr
	-- 10 -> 11 no move
	-- 11 -> 10 no move
	-- 11 -> 12 move camera
	-- 12 -> 11 move camera
	

	if ((xr+x>10 and xr>10) and (xr<27 and xr+x<27)) then
		camera:moveLoc ( x*self.scale, 0, 0.5 )
	end

	if ((yr>10 and yr+y>10) and (yr+y<19 and yr<19)) then
		camera:moveLoc(0, -y*self.scale, 0.5)
	end
	
	-- if ((yr>7 and yr+y>7) and (yr<13 and yr+y<13)) then
	-- 	camera:moveLoc(0, -y*self.scale, 0.25)
	-- end
	
end

function rockford:doGrabRockford(x,y)
	local xr,yr = self:getPos()
	local space = boulderdash.Create( "space", xr+x, yr+y )
	boulderdash.objects[space.id] = space
end

function rockford:consume(object)
	if object.consume then
		return object:consume()
	else
		return true
	end
end


return rockford