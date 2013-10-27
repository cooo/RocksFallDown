local amoeba = boulderdash.Derive("base")
amoeba.hard    = true
amoeba.rounded = true
amoeba.strip   = 8

local directions = { {x=-1,y=0}, {x=0,y=-1}, {x=1,y=0}, {x=0,y=1} }

function amoeba:load( x, y )
	local tileDeck = Moai:cachedTileDeck(boulderdash.imgpath .. "amoeba.png", amoeba.strip, 1)
	amoeba.prop  = Moai:createProp(layer, tileDeck, x, y)	
	Moai:createAnimation(amoeba.strip, amoeba.prop)	
	amoebas.present = true
end

function amoeba:update()
	amoeba:grow()
end

function amoeba:grow()
	for i,d in ipairs(directions) do
		local neighbour = boulderdash:find(self.x+d.x, self.y+d.y)
		if (neighbour.type == "space" or neighbour.type == "dirt") then
			table.insert(amoebas.grow_directions, neighbour)
		end
	end
end

return amoeba