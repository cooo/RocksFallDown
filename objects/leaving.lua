local leaving = boulderdash.Derive("base")

function leaving:load()
	audio:stop("twinkly_magic_wall")
end

function leaving:update(dt)
	delay = 0
	scoreboard.countdown = scoreboard.countdown - 1
	scoreboard.score = scoreboard.score + 1
	if scoreboard.countdown <= 0 then
		scoreboard.countdown = 0
		boulderdash:LevelUp()
	end
	
end

function leaving:draw()
end

return leaving