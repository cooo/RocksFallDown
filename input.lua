input = {}
-- it goes a little something like this, one touch:
-- click:
-- on touch down:
-- o register a touch in movements (a movement consists of a start & end location)
-- o register the start_loc (x,y)
--
-- point:
-- o register an end_loc and check if we find a swipe according to minimum swipe lenght
-- o if there's a swipe, move rockford in that direction, and make end_loc the new start_loc
-- o repeat
--
-- click:
-- on touch up:
-- o stop rockford from moving
--
-- 
input.partition = nil  -- a MOAIPartition
input.key = nil
input.grab = false
input.subscribers       = {}	    -- entities can subscribe to input events

local ONE_STEP = 10
local tap_count = 0

local startX, startY, endX, endY
local mouseX, mouseY --, posX, posY

local ONE_STEP_TIME = 0.5

local movements = {}


local function move_to(direction)
	for i, subscriber in pairs(input.subscribers) do
		if not subscriber.moved then
			if (direction == "right") then
				subscriber:LeftOrRight(1)
			elseif (direction == "left") then
				subscriber:LeftOrRight(-1)
			elseif (direction == "up") then
				subscriber:UpOrDown(-1)
			elseif (direction == "down") then
				subscriber:UpOrDown(1)
			end
		end
	end
end

local function stop_running()
	input.key = nil
	for i, subscriber in pairs(input.subscribers) do
		subscriber:stopRunning()
	end
end

local function going_somewhere(key)
	input.key = key
	if key==32 then
		input.grab=true
	elseif (key==113 or key==357) then
		move_to("up")
	elseif (key==97 or key==359) then
		move_to("down")
	elseif (key==111 or key==356) then
		move_to("left")
	elseif (key==112 or key==358) then
		move_to("right")
	end
end


local function swipe_direction(tap_count)
	local startX = movements[tap_count].start_loc.x
	local startY = movements[tap_count].start_loc.y
	local endX   = movements[tap_count].end_loc.x
	local endY   = movements[tap_count].end_loc.y

	local moveX = endX - startX
	local moveY = endY - startY
	
	print("swipe_direction: ", startX, startY, endX, endY, tap_count)
	
	if (math.abs(moveX) > ONE_STEP) and (math.abs(moveX) > math.abs(moveY)) then

		if (startX < endX) then -- right
			
			going_somewhere(112)
			movements[tap_count].joystick.x = 10
		else -- left
			going_somewhere(111)
			movements[tap_count].joystick.x = -10
		end
		movements[tap_count].joystick.y = 0

		print("swipe detected: ", moveX, tap_count)
				
		-- movements[tap_count].start_loc.x = endX
		-- movements[tap_count].start_loc.y = endY
		
	elseif math.abs(moveY) > ONE_STEP then 
		if (startY < endY) then -- up
			going_somewhere(113)
			movements[tap_count].joystick.y = 10
		else -- down
			going_somewhere(97)
			movements[tap_count].joystick.y = -10
		end
		movements[tap_count].joystick.x = 0
		
		print("swipe detected: ", moveY, tap_count)
		-- movements[tap_count].start_loc.x = endX
		-- movements[tap_count].start_loc.y = endY
		
	else
		-- not quite far enough
		print("no swipe:", moveX, moveY, tap_count)
		movements[tap_count].joystick.x = 0
		movements[tap_count].joystick.y = 0
	end
end

-- someone 'points' at location x,y on the screen
local function pointCallback ( x, y )
	-- this function is called when the touch is registered (before clickCallback)
	-- or when the mouse cursor is moved
	mouseX, mouseY = hud_layer:wndToWorld ( x, y )
	if tap_count>0 then
		print("pointCallback, tap-count:", tap_count)
		endX, endY = mouseX, mouseY
		movements[tap_count].end_loc = {x=endX, y=endY}
		
		swipe_direction(tap_count)
	end
	
end


function onDraw ( index, xOff, yOff, xFlip, yFlip )
	if (startX and startY) then
	    MOAIDraw.drawCircle ( startX+movements[tap_count].joystick.x, startY+movements[tap_count].joystick.y, 20)
	    MOAIDraw.drawCircle ( startX, startY, 64)
	end

end

function clickCallback ( down )

	-- this function is called when touch/click 
	-- is registered
--	local pick = input.partition:propForPoint ( mouseX, mouseY )

	if MOAIInputMgr.device.touch:hasTouches() then
		local t1,t2,t3 = MOAIInputMgr.device.touch:getActiveTouches()
		
		if t1 then
			print("touch:", t1)
		end
		if t2 then
			print("touch:", t2)
		end
		if t3 then
			print("touch:", t3)
		end


	end
	
	if down then
		tap_count = tap_count + 1
		print("clickCallback down, tap-count:", tap_count)
		startX, startY = mouseX, mouseY
		movements[tap_count] = { start_loc, end_loc }
		movements[tap_count].start_loc = {x=startX, y=startY}
		if tap_count > 1 then
			input.grab = true
		end
		
		-- draw a joystick
		movements[tap_count].joystick = { x=0, y=0 }
		
		scriptDeck = MOAIScriptDeck.new ()
		scriptDeck:setRect ( -64, -64, 64, 64 )
		scriptDeck:setDrawCallback ( onDraw )

		movements[tap_count].prop = MOAIProp2D.new ()
		movements[tap_count].prop:setDeck ( scriptDeck )
		hud_layer:insertProp ( movements[tap_count].prop )
		
	else
		hud_layer:removeProp(movements[tap_count].prop)
		tap_count = tap_count - 1
		print("clickCallback up, tap-count:", tap_count)
		stop_running()
		if tap_count < 1 then
			print("setting grab to false on touching")
			input.grab = false
		end
	end
	
end

local function init_callbacks()
	
	if MOAIInputMgr.device.pointer then
		-- mouse input
		MOAIInputMgr.device.pointer:setCallback ( pointCallback )
		MOAIInputMgr.device.mouseLeft:setCallback ( clickCallback )
	else
		-- touch input
		MOAIInputMgr.device.touch:setCallback ( 
			-- this is called on every touch event
			function ( eventType, idx, x, y, tapCount )
				pointCallback ( x, y ) -- first set location of the touch
				if eventType == MOAITouchSensor.TOUCH_DOWN then
					clickCallback ( true )
				elseif eventType == MOAITouchSensor.TOUCH_UP then
					clickCallback ( false )
				end
			end
		)
	end	
	
end

function input:update()
	if input.key then
		print(frame_counter ..": update", input.key)
		going_somewhere(input.key)
	end
end

function input:createHud(viewport)
	
	init_callbacks()
	
	hud_layer = MOAILayer2D.new ()
	hud_layer:setViewport ( viewport )

	-- 5. catch user interactions
	input.partition = MOAIPartition.new ()
	hud_layer:setPartition ( input.partition )

	-- hud_layer:insertProp(Moai:createHudButton("left",  100,  -50, 200, -150))
	-- hud_layer:insertProp(Moai:createHudButton("right", 250,  -50, 350, -150))
	-- hud_layer:insertProp(Moai:createHudButton("up",    175,   50, 275,  -50))
	-- hud_layer:insertProp(Moai:createHudButton("down",  175, -150, 275, -250))
	-- hud_layer:insertProp(Moai:createHudButton("grab",  -375, -50, -275, -150))
	return hud_layer
end


function input:createButtons()

	if(MOAIInputMgr.device.keyboard) then
	
	    MOAIInputMgr.device.keyboard:setCallback(
	        function(key,down)
				
	            if down==true then
					going_somewhere(key)
				else
					stop_running()
					if key==32 then
						print("setting grab to false in keyboard")
						input.grab=false
					end
					
	            end
	        end
	    )
	end	
	
end

