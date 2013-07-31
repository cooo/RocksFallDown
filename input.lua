input = {}

input.partition = nil  -- a MOAIPartition
input.touching = nil
input.grab = false
input.key = nil

local mouseX, mouseY, posX, posY
  
-- local function dragObject ( object, x, y )
-- 	print ("Dragging")
-- end

local function pointerCallback ( x, y )
	-- this function is called when the touch is registered (before clickCallback)
	-- or when the mouse cursor is moved
	mouseX, mouseY = hud_layer:wndToWorld ( x, y )

	posX = math.floor(mouseX/32 + (STAGE_WIDTH/2/32))
	posY = math.ceil(-(mouseY+32)/32 + (STAGE_HEIGHT/2/32))
--	print ("mouse moved", x, y, mouseX, mouseY)	
	
end

 
function clickCallback ( down )
	-- this function is called when touch/click 
	-- is registered
	if down then
		local pick = input.partition:propForPoint ( mouseX, mouseY )
		if pick then
			input.touching = pick.tag
			input.rockford = pick.tag
			print(os.date(), input.touching, "down")
--			MOAIDraw.drawRect ( 100,-50,200,-150 )
		end
	

--		print ("Click!", posX, posY)
	
		for i, object in pairs(boulderdash.objects) do
			if (object.x==posX and object.y==posY) then
--				print("DEBUG ",object.type, object.x, object.y)
			end
		end
	else
		print(os.date(), input.touching, "up")
		input.touching = nil
	end
	-- local object = boulderdash:findByID(id(posX,posY))
	-- print("DEBUG ",object.type, object.x, object.y)
	
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

	hud_layer:insertProp(Moai:createHudButton("left",  100,  -50, 200, -150))
	hud_layer:insertProp(Moai:createHudButton("right", 250,  -50, 350, -150))
	hud_layer:insertProp(Moai:createHudButton("up",    175,   50, 275,  -50))
	hud_layer:insertProp(Moai:createHudButton("down",  175, -150, 275,- 250))	
	
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

