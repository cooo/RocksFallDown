-- create a LÖVE engine style load,update,draw
-- in gameloop.lua, use the following template
-- 
-- gameloop = {}
-- 
-- function gameloop:load()
-- end
-- 
-- function gameloop:update(dt)
-- end
-- 
-- function gameloop:draw()
-- end

FRAMES = 60
require("gameloop")

local function forever(dt)
	gameloop:update(dt)
	gameloop:draw()
end

local function newLoopingTimer ( spanTime, func )
	local timer = MOAITimer.new()
	timer:setSpan( spanTime )
	timer:setMode( MOAITimer.LOOP )
	timer:setListener( MOAITimer.EVENT_TIMER_LOOP, 
		function()
			func( spanTime )
		end
	)
	timer:start()
	return timer
end

-- do this once
gameloop:load()

-- do this forever
local gameLoopTimer = newLoopingTimer ( 1/FRAMES, forever )
