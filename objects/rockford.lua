local rockford = boulderdash.Derive("base")

rockford.restless_timer = nil
rockford.smooth_scrolling = { x=0, y=0 }
rockford.config_animations = {
	entrance = {
		offset = 5,
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

local directions = { {x=-1,y=0}, {x=0,y=-1}, {x=1,y=0}, {x=0,y=1} }

function rockford:animateRockford(name, offset, length, time, mode)	-- lenght=number of frames, offset=start index
	local curve = MOAIAnimCurve.new()
	curve:reserveKeys (length)
	
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

function rockford:startAnimation(name, callback)
	if self.currentAnimation and self.currentAnimation.name==name then
	--	print("already " .. name)
	else
		self:stopCurrentAnimation()
		self.currentAnimation = self:getAnimation( name )
		
		if callback then
			self.currentAnimation:setListener ( MOAIAction.EVENT_STOP, callback )
		end
		self.currentAnimation:start()
		return self.currentAnimation
	end
end

function rockford:stopRunning()
	if self.currentAnimation and (self.currentAnimation.name=="left" or self.currentAnimation.name=="right") then
		self:stopCurrentAnimation()
		rockford.prop:setIndex(1)
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
	
	rockford.prop = Moai:createProp(layer, tileDeck, x, y)

	self.animations = {}
	for name, def in pairs ( rockford.config_animations ) do
		self:animateRockford ( name, def.offset, def.length, def.time, def.mode )
    end

    rockford.restless_timer = Moai:createLoopTimer(2.0, rockford.wink)
	rockford:startAnimation("entrance", audio:play("twang"))
end

function rockford:update(dt)
	local x,y = self:getPos()
	self.prop:setLoc (Moai:x_and_y(x,y) )
	
	self:move(dt)
	self:he_might_die()
end

-- move him around or grab something
function rockford:move(dt)
	if not (boulderdash.dead or boulderdash.done) then
		if (input.touching == "left" or input.rockford == "left") then
			rockford:LeftOrRight(-1)
		elseif (input.touching == "right" or input.rockford == "right") then
			rockford:LeftOrRight(1)
		elseif (input.touching == "up" or input.rockford == "up") then
			rockford:UpOrDown(-1)
		elseif (input.touching == "down" or input.rockford == "down") then
			rockford:UpOrDown(1)
		elseif input.touching == nil then
			rockford:stopRunning()
		end
	end
end

-- when a rock or diamond falls on his head rockford dies
function rockford:he_might_die()
	local xr,yr = self:getPos()
	
	self:time_is_up()
	self:dies_from_things_falling_on_his_head(xr, yr)
	self:dead_from_being_close_to_deadly_critters(xr, yr)
end

function rockford:time_is_up()
	if type(scoreboard.clock)=="number" and scoreboard.clock <= 0 then
		rockford:dies()
	end
end

function rockford:dies_from_things_falling_on_his_head(xr, yr)
	local object = boulderdash:find(xr,yr-1)

	if (object.falling) then
		rockford:dies()
	end
end

function rockford:dead_from_being_close_to_deadly_critters(xr, yr)
	for i,direction in ipairs(directions) do
		if rockford:deadly_critter_at(direction) then
			rockford:dies()
		end
	end
end

function rockford:deadly_critter_at(d)
	if boulderdash:find(self.x+d.x, self.y+d.y) then
		return boulderdash:find(self.x+d.x, self.y+d.y).deadly
	else
		return false
	end
end

function rockford:dies()
	if not boulderdash.done then		-- unless the level was finished
		scoreboard.one_second_timer:stop()
		boulderdash.dead = true -- to prevent starting the explode sequence again
		self.restless_timer:stop()
		self.currentAnimation = nil
		rockford:explode(boulderdash.startOver)
		audio:stopAll()
	end
end

function rockford:LeftOrRight(x)
	input.rockford = nil
	if self:canMove( x, 0 ) then
		if input.grab then
			print("grab!")
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
	input.rockford = nil
	if self:canMove( 0, y ) then
		if input.grab then
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
	
	if ((xr+x>10 and xr>10) and (xr<27 and xr+x<27)) then
		rockford.smooth_scrolling.x = rockford.smooth_scrolling.x + x
	end

	if ((yr>10 and yr+y>10) and (yr+y<19 and yr<19)) then
		rockford.smooth_scrolling.y = rockford.smooth_scrolling.y + y
	end
	
	if (rockford.smooth_scrolling.x > 4) or (rockford.smooth_scrolling.x < -4) then
		camera:moveLoc ( rockford.smooth_scrolling.x*self.scale, 0, 1.0 )
		rockford.smooth_scrolling.x = 0
	end
	
	if (rockford.smooth_scrolling.y > 2) or (rockford.smooth_scrolling.y < -2) then
		camera:moveLoc(0, -rockford.smooth_scrolling.y*self.scale, 1.0)
		rockford.smooth_scrolling.y = 0
	end
		
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