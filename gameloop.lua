require("lib/strings")
require("boulderdash")
require("moai_extensions")	-- helpful stuff


require("levels/load")
-- require("keyboard")


gameloop = {}
gamePaused = false
STAGE_WIDTH = 960/1.2 -- (iPhone4=960, iPhone5=1136, iPad3+=2048)
STAGE_HEIGHT = 640/1.2 -- (iPhone4=640, iPhone5=640, iPad3+=1536)

touching = nil


local mouseX, mouseY, posX, posY
-- this is to keep reference to what's being dragged
local currentlyTouchedProp 
 
local function dragObject ( object, x, y )
	print ("Dragging")
end

local function pointerCallback ( x, y )
	-- this function is called when the touch is registered (before clickCallback)
	-- or when the mouse cursor is moved
	mouseX, mouseY = layer:wndToWorld ( x, y )

	posX = math.floor(mouseX/32 + (STAGE_WIDTH/2/32))
	posY = math.ceil(-mouseY/32 + (STAGE_HEIGHT/2/32))
--	print ("mouse moved", x, y, mouseX, mouseY)	
	
end
 
function clickCallback ( down )
	-- this function is called when touch/click 
	-- is registered
	if down then
		local pick = partition:propForPoint ( mouseX, mouseY )
		if pick then
			touching = pick.tag
			MOAIDraw.drawRect ( 100,-50,200,-150 )
		end
	

		print ("Click!", posX, posY)
	
		for i, object in pairs(boulderdash.objects) do
			if (object.x==posX and object.y==posY) then
				print("DEBUG ",object.type, object.x, object.y)
			end
		end
	else
		touching = nil
	end
	-- local object = boulderdash:findByID(id(posX,posY))
	-- print("DEBUG ",object.type, object.x, object.y)
	
end

function gameloop:load()
		
	local SCREEN_WIDTH = MOAIEnvironment.verticalResolution or 960
	local SCREEN_HEIGHT = MOAIEnvironment.horizontalResolution or 640
	print ( "System: ", MOAIEnvironment.osBrand )
	print ( "Resolution: " .. SCREEN_WIDTH .. "x" .. SCREEN_HEIGHT )
	
	-- 2.
	MOAISim.openWindow ( "Rocks fall down", SCREEN_WIDTH, SCREEN_HEIGHT ) -- window/device size
	
	-- 3.
	local viewport = MOAIViewport.new ()
	viewport:setSize ( SCREEN_WIDTH, SCREEN_HEIGHT ) -- window/device size
	viewport:setScale ( STAGE_WIDTH, STAGE_HEIGHT ) -- size of the "app"
	
	-- 4. 
	layer = MOAILayer2D.new ()
	layer:setViewport ( viewport )
--	layer:setClearColor (0.53, 0.53, 0.53, 1)
	

	
	
	hud_layer = MOAILayer2D.new ()
	hud_layer:setViewport ( viewport )
	
	-- 5. catch user interactions
	partition = MOAIPartition.new ()
	hud_layer:setPartition ( partition )
	
	
	hud_layer:insertProp(Moai:createHudButton("left", 100,-50,200,-150))
	hud_layer:insertProp(Moai:createHudButton("right", 250,-50,350,-150))
	hud_layer:insertProp(Moai:createHudButton("up", 175,50,275,-50))
	hud_layer:insertProp(Moai:createHudButton("down", 175,-150,275,-250))	

	
	-- 6.
	MOAIRenderMgr.setRenderTable ( { layer, hud_layer } )
	
	level_loader:load()



	boulderdash:Startup()
	boulderdash:LevelUp()
	


	-- Here we register callback functions for input - both mouse and touch
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


function gameloop:update(dt)
	if gamePaused then return end
	
	if boulderdash.dead then
--		boulderdash:explode("rockford")
--		boulderdash.magicwall_dormant = true
--		audio:stop("twinkly_magic_wall")
	end

	if not boulderdash.start_over then
		boulderdash:update(dt)
	else
--		boulderdash:startOver()
	end
end

function gameloop:draw()
	boulderdash:draw()
end





-- function load()
-- 
-- 	t_minus_zero = reset_time()
-- 	idle_time = reset_time()
-- 	gamePaused = false
-- 	delay = 0.10
-- 	delay_dt = 0
-- 
-- 	love.graphics.setColorMode("replace")
-- 			
-- 	level_loader:load()
-- 		
-- 	boulderdash:Startup()
-- 	boulderdash:LevelUp()
-- end
-- 
-- 
-- function love.update(dt)
-- 	if gamePaused then return end
-- 	
-- 	if boulderdash.dead then
-- 		boulderdash:explode("rockford")
-- 		boulderdash.magicwall_dormant = true
-- 		audio:stop("twinkly_magic_wall")
-- 	end
-- 
-- 	if not boulderdash.start_over then
-- 		boulderdash:update(dt)
-- 	else
-- 		boulderdash:startOver()
-- 	end
-- end
-- 
-- function love.draw()
-- 	boulderdash:draw()
-- end
-- 
-- 
-- -- some ideas for keys:
-- -- cursor & space is taken care of in the rockford object
-- -- s : sound on/off
-- -- d : suicide (when rockford is stuck)
-- -- p : pause
-- -- q : quit (kill the complete game)
-- -- m : bring up a menu so you can change caves/levels
-- -- 
-- 
-- function love.keypressed(key, unicode)
-- 	idle_time = love.timer.getMicroTime()	-- the start of idle time
-- 	debug = {}
-- 	table.insert(boulderdash.keypressed, key)
-- 	if key=="d" then
-- 		-- print some debug stuff here
-- 	end
-- 
-- 	-- defer key to handler
-- 	keyboard.keypressed(key)
-- 
-- end
-- 
-- function love.keyreleased(key, unicode)
-- 	boulderdash:default()	
-- end
-- 
-- function love.focus(f)
--   if not f then
-- 	gamePaused = true
--     print("LOST FOCUS")
--   else
-- 	gamePaused = false
--     print("GAINED FOCUS")
--   end
-- end
-- 
-- function love.quit()
--   print("Thanks for playing! Come back soon!")
-- end
-- 
-- function since(t)
-- 	return love.timer.getMicroTime() - t
-- end
-- 
-- function reset_time()
-- 	return love.timer.getMicroTime()
-- end

