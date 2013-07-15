Moai = {}

local textureCache = {}

function Moai:cachedTexture( name, width, height )
	if textureCache[name] == nil then
		textureCache[name] = MOAIGfxQuad2D.new ()
		textureCache[name]:setTexture ( name )
		textureCache[name]:setRect ( 0, 0, width, height )
	end
	return textureCache[ name ]
end

function Moai:cachedTileDeck( name, strip_width, strip_height)
	if textureCache[name] == nil then
		textureCache[name] = MOAITileDeck2D.new ()
		textureCache[name]:setTexture ( name )
		textureCache[name]:setSize ( strip_width, strip_height )	-- width, height
		textureCache[name]:setRect ( 0, 0, 32, 32 )
	end
	return textureCache[name]
end

function Moai:x_and_y(x,y)
	return x*32 - (STAGE_WIDTH/2), -y*32 + (STAGE_HEIGHT/2) - 32
end

function Moai:createProp(this_layer, quad, x, y)
	local prop = MOAIProp2D.new()
	prop:setDeck( quad )
	prop:setLoc( Moai:x_and_y(x,y) )

	this_layer:insertProp(prop)
	return prop
end

function Moai:createAnimation(number_of_frames, prop)
	local curve = MOAIAnimCurve.new ()
	curve:reserveKeys ( number_of_frames )
	for i=1, number_of_frames do
		curve:setKey ( i, (i-1)/number_of_frames, i, MOAIEaseType.FLAT )
	end

	local anim = MOAIAnim:new ()
	anim:reserveLinks ( 1 )
	anim:setLink ( 1, curve, prop, MOAIProp2D.ATTR_INDEX )
	anim:setMode ( MOAITimer.LOOP )
	anim:start ()
	return anim
end

-- starts a timer and calls 'callbackFunction' every spanTime
function Moai:createLoopTimer ( spanTime, callbackFunction )
	local timer = MOAITimer.new ()
	timer:setSpan( spanTime )
	timer:setMode( MOAITimer.LOOP )
	timer:setListener( MOAITimer.EVENT_TIMER_LOOP, callbackFunction )
	timer:start()
	return timer
end

-- starts a timer and calls 'callbackFunction' once
function Moai:createTimer ( spanTime, callbackFunction )
	local timer = MOAITimer.new()
	timer:setSpan( spanTime )
	timer:setMode( MOAITimer.NORMAL )
	timer:setListener( MOAITimer.EVENT_TIMER_END_SPAN, callbackFunction)
	timer:start()	
	return timer
end

function Moai:createHudButton(tag, x0,y0,x1,y1) --250,-50,350,-150
		
	local scriptDeck = MOAIScriptDeck.new()
	scriptDeck:setRect(x0,y0,x1,y1)
	scriptDeck:setDrawCallback(
		function ()
			MOAIGfxDevice.setPenWidth(3)
			MOAIDraw.drawRect ( x0,y0,x1,y1 )
		end
	)

	local prop = MOAIProp2D.new()
	prop:setDeck(scriptDeck)
	prop.tag = tag
	
	-- curve = MOAIAnimCurve.new ()
	-- 
	-- curve:reserveKeys ( 5 )
	-- curve:setKey ( 1, 0.00, 1, MOAIEaseType.FLAT )
	-- curve:setKey ( 2, 0.25, 2, MOAIEaseType.FLAT )
	-- curve:setKey ( 3, 0.50, 3, MOAIEaseType.FLAT )
	-- curve:setKey ( 4, 0.75, 4, MOAIEaseType.FLAT )
	-- curve:setKey ( 5, 1.00, 5, MOAIEaseType.FLAT )
	-- 
	-- anim = MOAIAnim:new ()
	-- anim:reserveLinks ( 1 )
	-- anim:setLink ( 1, curve, prop, MOAIProp2D.ATTR_INDEX )
	
	return prop
end