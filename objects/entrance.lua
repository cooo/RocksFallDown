local entrance = boulderdash.Derive("base")
entrance.images = {}
entrance.sprite_index = 1
entrance.end_frame = 3
entrance.flash_delay = 0.5
entrance.flash_timer = 0

function entrance:load( x, y )
	self:setImage(love.graphics.newImage( boulderdash.imgpath .. "entrance.png" ))
	for i=0, 32*(3-1), 32 do
		table.insert( self.images, love.graphics.newQuad(i, 0, 32, 32, 32*3, 32) )
	end
	self:setPos( x, y )
	self.flash_timer = reset_time()
end

function entrance:update(dt)
	if (since(self.flash_timer) > self.flash_delay) then
		self.sprite_index = self.sprite_index + 1
		if (self.sprite_index >= self.end_frame) then
			self.sprite_index = self.end_frame
--			boulderdash:Replace("entrance", "rockford") Replace is deprecated
			audio:play("twang")
		end
		self.flash_timer = reset_time()
	end	
end

function entrance:draw()
	local x, y = self:getPos()	
	local img  = self:getImage()
	love.graphics.drawq(img, self.images[self.sprite_index or 1], x*self.scale, y*self.scale)
end

return entrance