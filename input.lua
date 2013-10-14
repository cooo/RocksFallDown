require "socket"

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
input.must_move = nil
input.touch_down = false
input.grab = false
input.key = nil
input.moved = false

local ONE_STEP = 10
local RUNNING  = 35
local down_counter = 0

local startX, startY, endX, endY
local joystick_x = 0
local joystick_y = 0
local mouseX, mouseY --, posX, posY

local delta_time = 0;
local ONE_STEP_TIME = 0.5

local movements = {}

-- someone 'points' at location x,y on the screen
local function pointCallback ( x, y )
	-- this function is called when the touch is registered (before clickCallback)
	-- or when the mouse cursor is moved
	mouseX, mouseY = hud_layer:wndToWorld ( x, y )
	if down_counter>0 then

		endX, endY = mouseX, mouseY
		movements[down_counter].end_loc = {x=endX, y=endY}
		
		swipe_direction(down_counter)
	end
	
end


function swipe_direction(down_counter)
	local running  = nil
	local one_step = nil
		
	local startX = movements[down_counter].start_loc.x
	local startY = movements[down_counter].start_loc.y
	local endX   = movements[down_counter].end_loc.x
	local endY   = movements[down_counter].end_loc.y
				
	local moveX = endX - startX
	local moveY = endY - startY
	if (math.abs(moveX) > ONE_STEP) and (math.abs(moveX) > math.abs(moveY)) then

		if (startX < endX) then
			move_to = "right"
			joystick_x = 10
		else
			move_to = "left"
			joystick_x = -10
		end
		joystick_y = 0

		print("swipe detected: ", moveX, "move to:", move_to, down_counter)
		
		-- movements[down_counter].start_loc.x = endX
		-- movements[down_counter].start_loc.y = endY
		
	elseif math.abs(moveY) > ONE_STEP then 
		if (startY < endY) then
			move_to = "up"
			joystick_y = 10
		else
			move_to = "down"
			joystick_y = -10
		end
		joystick_x = 0
		
		print("swipe detected: ", moveY, "move to:", move_to, down_counter)
		-- movements[down_counter].start_loc.x = endX
		-- movements[down_counter].start_loc.y = endY
		
	else
		-- not quite far enough
		print("no swipe:", moveX, moveY, down_counter)
		joystick_x = 0
		joystick_y = 0
	end
	input.must_move = move_to
end

function onDraw ( index, xOff, yOff, xFlip, yFlip )
	if (startX and startY) then
	    MOAIDraw.drawCircle ( startX+joystick_x, startY+joystick_y, 20)
	    MOAIDraw.drawCircle ( startX, startY, 64)
	end

end

function clickCallback ( down )
	-- this function is called when touch/click 
	-- is registered
--	local pick = input.partition:propForPoint ( mouseX, mouseY )

	if down then
		input.touch_down = true
		input.moved = false
		delta_time = socket.gettime()
		down_counter = down_counter + 1
		startX, startY = mouseX, mouseY
		movements[down_counter] = { start_loc, end_loc }
		movements[down_counter].start_loc = {x=startX, y=startY}
		if down_counter > 1 then
			input.grab = true
		end
		
		-- draw a circle
		
		scriptDeck = MOAIScriptDeck.new ()
		scriptDeck:setRect ( -64, -64, 64, 64 )
		scriptDeck:setDrawCallback ( onDraw )

		prop = MOAIProp2D.new ()
		prop:setDeck ( scriptDeck )
		hud_layer:insertProp ( prop )
		
	else
		down_counter = down_counter - 1
		
		if down_counter < 1 then
			print("setting grab to false on touching")
			input.grab = false
			input.touch_down = false
			
			if ((socket.gettime() - delta_time) < ONE_STEP_TIME) and input.moved then
				input.must_move = nil
				input.moved = false
				print("swipe time (stop moving)", socket.gettime() - delta_time)
			else
				print("swipe time (moving)", socket.gettime() - delta_time)
			end
			delta_time = 0
			
			joystick_x = 0
			joystick_y = 0

			hud_layer:removeProp(prop)
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
					input.touch_down = true
					self.key = key
					if key==32 then
						self.grab=true
					-- up,down=q (113),a (97), left,right=o (111), p (112)
					elseif (key==113 or key==357) then
						input.must_move = "up"
					elseif (key==97 or key==359) then
						input.must_move = "down"
					elseif (key==111 or key==356) then
						input.must_move = "left"
					elseif (key==112 or key==358) then
						input.must_move = "right"
					end
				else
					input.touch_down = false
					if key==32 then
						print("setting grab to false in keyboard")
						self.grab=false
					else
						if (self.key==key) then -- it might have changed with a quick move
			--				input.must_move = nil
						end
					end
					
	            end
	        end
	    )
	end	
	
end

