-- since moai's getLoc gives you the camera position at real time,
-- it might be confusing when you move a camera with delay, and ask
-- for the camera's position one frame later, you will not get the
-- expected position, but somewhere in-between.
--
-- so,
-- let's abstract the camera, and return x and y positions of the
-- future position.
-- 
-- and,
-- let's do so in grid positions
camera = {}

camera.x = 0
camera.y = 0
camera.moai_camera = nil
camera.smooth_scrolling = { x=0, y=0 }

BOXCAM_X_MIN = 0
BOXCAM_X_MAX = 15
BOXCAM_Y_MIN = 0
BOXCAM_Y_MAX = 6


function camera:init(layer)
	camera.moai_camera = MOAICamera2D.new ()
	layer:setCamera(camera.moai_camera)
	camera.x, camera.y = camera.moai_camera:getLoc()
end

function camera:getLoc()
	return math.floor(camera.x/32 + 0.5), math.floor(camera.y/32 + 0.5)
end

function camera:moveLoc(dx,dy,time)
	time = time or 0
	camera.x, camera.y = camera.x + dx*32, camera.y + dy*32
	camera.moai_camera:moveLoc(dx*32, -dy*32, time) 
end

local function horizontal(xr, xc, x)
	if (xr > 10) and (xr<27) then
		camera.smooth_scrolling.x = camera.smooth_scrolling.x + x
	else
		if (xr<=10) then
			camera:moveLoc ( -xc, 0, 1.0 )
		elseif (xr>=27) then
			camera:moveLoc( BOXCAM_X_MAX - xc, 0, 1.0 )
		end
		camera.smooth_scrolling.x = 0
		return false
	end
	return (camera.smooth_scrolling.x > 4) or (camera.smooth_scrolling.x < -4)
end

local function vertical(yr, yc, dy)
	if (yr>10) and (yr<15) then
		camera.smooth_scrolling.y = camera.smooth_scrolling.y + dy
	else
		if (yr<=10) then
			camera:moveLoc ( 0, -yc, 1.0 )
		elseif (yr>=15) then
			camera:moveLoc( 0, BOXCAM_Y_MAX - yc, 1.0 )
		end
		camera.smooth_scrolling.y = 0
		return false
	end
	return (camera.smooth_scrolling.y > 3) or (camera.smooth_scrolling.y < -3)
end

function camera:movement(xr, yr, dx, dy)
	local xc, yc = camera:getLoc()
	if horizontal(xr, xc, dx) then
		local xc_new = xc + camera.smooth_scrolling.x
		if (xc_new > BOXCAM_X_MIN) and (xc_new < BOXCAM_X_MAX) then
			camera:moveLoc ( camera.smooth_scrolling.x, 0, 1.0 )
		end
		camera.smooth_scrolling.x = 0
	end

	if vertical(yr, yc, dy) then
		local yc_new = yc + camera.smooth_scrolling.y
		if (yc_new > BOXCAM_Y_MIN) and (yc_new < BOXCAM_Y_MAX) then
			camera:moveLoc ( 0, camera.smooth_scrolling.y, 1.0 )
		end
		camera.smooth_scrolling.y = 0
	end
end
