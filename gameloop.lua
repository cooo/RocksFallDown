require("lib/strings")
require("boulderdash")
require("camera")
require("moai_extensions")	-- helpful stuff
require("levels/load")
require("input")
require("scoreboard")
-- require("keyboard")


gameloop = {}
gamePaused = false
STAGE_WIDTH = 960/1.2 -- (iPhone4=960, iPhone5=1136, iPad3+=2048)
STAGE_HEIGHT = 640/1.2 -- (iPhone4=640, iPhone5=640, iPad3+=1536)


local function onDraw ( index, xOff, yOff, xFlip, yFlip )
        MOAIGfxDevice.setPenColor ( 1, 0, 0, 1 )
        MOAIDraw.drawRect(-64, 64, 64, -64)
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

	hud_layer = input:createHud(viewport)
	scoreboard_layer = scoreboard:createScoreboard(viewport)

	input:createButtons()
	
	camera:init(layer)
	
	
--	scoreboard_layer = scoreboard:create(viewport)

	
--	scoreboard_layer:setClearColor (0.53, 0.53, 0.53)
	


	-- 6.
	MOAIRenderMgr.setRenderTable ( { layer, hud_layer, scoreboard_layer } )
	
	level_loader:load()

	boulderdash:Startup()
	boulderdash:LevelUp()
	
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
