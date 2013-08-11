input = {}

input.partition = nil  -- a MOAIPartition
input.touching = nil
input.grab = false
input.key = nil

local ONE_STEP = 10
local RUNNING  = 35
local down_counter = 0

local startX, startY, endX, endY
local mouseX, mouseY --, posX, posY

local movements = {}

local function pointerCallback ( x, y )
	-- this function is called when the touch is registered (before clickCallback)
	-- or when the mouse cursor is moved
	mouseX, mouseY = hud_layer:wndToWorld ( x, y )

	-- posX = math.floor(mouseX/32 + (STAGE_WIDTH/2/32))
	-- posY = math.ceil(-(mouseY+32)/32 + (STAGE_HEIGHT/2/32))
	-- print ("mouse moved", x, y, mouseX, mouseY)		
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
		print(startX - endX)

		if (startX < endX) then
			move_to = "right"
		else
			move_to = "left"
		end
		
		if math.abs(moveX) < RUNNING then
			one_step = move_to
		else
			running  = move_to
			one_step = move_to
		end
	elseif math.abs(moveY) > ONE_STEP then 
		print(startY - endY)
		if (startY < endY) then
			move_to = "up"
		else
			move_to = "down"
		end
		
		if math.abs(moveY) < RUNNING then
			one_step = move_to
		else
			running  = move_to
			one_step = move_to
		end
	end
	input.touching = running    -- running
	input.rockford = one_step	-- one step
	print("move_to:", move_to, down_counter)
	
end
 
function clickCallback ( down )
	-- this function is called when touch/click 
	-- is registered
--	local pick = input.partition:propForPoint ( mouseX, mouseY )

	if down then
		down_counter = down_counter + 1
		startX, startY = mouseX, mouseY
		movements[down_counter] = { start_loc, end_loc }
		movements[down_counter].start_loc = {x=startX, y=startY}
		if down_counter > 1 then
			input.grab = true
		end
		
	else
		endX, endY = mouseX, mouseY
		movements[down_counter].end_loc = {x=endX, y=endY}
		
		swipe_direction(down_counter)
		down_counter = down_counter - 1
		
		if down_counter < 1 then
			print("setting grab to false on touching")
			input.grab = false
		else
			-- input.touching = nil
			-- input.rockford = nil
		end
	end
	
end

local function init_callbacks()
	
	if MOAIInputMgr.device.pointer then
		-- mouse input
		MOAIInputMgr.device.pointer:setCallback ( pointerCallback )
		MOAIInputMgr.device.mouseLeft:setCallback ( clickCallback )
	else
		-- touch input
		MOAIInputMgr.device.touch:setCallback ( 
			-- this is called on every touch event
			function ( eventType, idx, x, y, tapCount )
				pointerCallback ( x, y ) -- first set location of the touch
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
					self.key = key
					if key==32 then
						self.grab=true
					-- up,down=q (113),a (97), left,right=o (111), p (112)
					elseif (key==113 or key==357) then
						input.touching = "up"
					elseif (key==97 or key==359) then
						input.touching = "down"
					elseif (key==111 or key==356) then
						input.touching = "left"
					elseif (key==112 or key==358) then
						input.touching = "right"
					end
					input.rockford = input.touching
				else
					if key==32 then
						print("setting grab to false in keyboard")
						self.grab=false
					else
						if (self.key==key) then -- it might have changed with a quick move
							input.touching = nil
						end
					end
					
	            end
	        end
	    )
	end	
	
end

