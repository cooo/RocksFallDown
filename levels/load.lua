level_loader = {}
level_loader.folder = "levels/bdcff/"
level_loader.games = {}
debug = false


level_loader.object_map2 = {
	W     = "steel",
	w     = "wall",
	r     = "rock",
	d     = "diamond",
	["."] = "dirt",
	P     = "rockford",
	X     = "outbox",
	q     = "firefly",
	c     = "butterfly",
	[" "] = "space",
	M	  = "magic_wall",
	a     = "amoeba"
}

level_loader.object_map3 = {
	P     = 1,  -- "rockford",
	W     = 2,  -- "steel",
	X     = 3,  -- "outbox",
	H     = 3,  -- "hidden outbox"
	M	  = 4,  -- "wall",
	x	  = 4,  -- "wall",
	w     = 4,  -- "wall",
	c     = 5,  --"butterfly",
	["."] = 6,  -- "dirt",
	[" "] = 7,  -- "space",
	r     = 8,  -- "rock",
	a     = 9,  -- "amoeba"
	q     = 10, -- "firefly",
	d     = 11, -- "diamond",
}

local start_sections = { "[BDCFF]", "[game]", "[cave]", "[map]" }
local end_sections = { "[/BDCFF]", "[/game]", "[/cave]", "[/map]" }

local function print_d(s)
	if debug then
		print(s)
	end
end

function remove_eols(s)
    return s
        :gsub('\r\n','')
        :gsub('\r', '')
end

local function parse(file)
	local game = {}
	local cave = {}
	cave.map = {}
	local sections = {}
	local current_section = nil
	local line_number = 0
	for line in io.lines(file) do
		line = remove_eols(line)

		line_number = line_number + 1
	  	if (#line==0) or line:starts_with(";") then
			-- skip empty lines or lines that start with ;
			print_d("skip " .. line)
			
		elseif line:is_found_in(start_sections) then

			table.insert(sections, line)
			print_d(line .. " starts")
			current_section = line
			if (current_section == "[game]") then
				game.caves = {}
			end
			
		elseif line:is_found_in(end_sections) then
			local section = table.remove(sections)
			print_d(section .. " ends")
			if (section == "[game]") then
				table.insert(level_loader.games, game)
				game = {}
			elseif (section == "[cave]") then
				table.insert(game.caves, cave)
				cave = {}
				cave.map = {}
			elseif (section == "[map]") then
				-- do nothing
			end

		elseif (current_section == "[game]") then
			print_d(current_section .. ": " .. line)
			if line:starts_with("Name") then
				game.name = line:get_after("Name=")
			elseif line:starts_with("Author") then
				game.by = line:get_after("Author=")
			elseif line:starts_with("Date") then
				game.year = line:get_after("Date=")
			end

		elseif (current_section == "[cave]") then
			print_d(current_section .. ": " .. line)
			if line:starts_with("Name") then
				cave.name = line:get_after("Name=")
			elseif line:starts_with("CaveTime") then
				cave.time = line:get_after("CaveTime=")
			elseif line:starts_with("DiamondsRequired") then
				cave.diamonds_to_get = tonumber(line:get_after("DiamondsRequired="))
			elseif line:starts_with("DiamondValue") then
				local diamond_values = line:get_after("DiamondValue=")
				cave.diamonds_are_worth       = string.split(diamond_values, " ")[1] or 0
				cave.extra_diamonds_are_worth = string.split(diamond_values, " ")[2] or 0
			elseif line:starts_with("MagicWallTime") then
				cave.magictime = line:get_after("MagicWallTime=")
			elseif line:starts_with("AmoebaTime") then
				cave.amoebatime = line:get_after("AmoebaTime=")
			end

		elseif (current_section == "[map]") then
			table.insert(cave.map, line:dice())
		end
		
	end
	
	for i, game in pairs(level_loader.games) do
		print_d(game.name .. " by " .. game.by .. " (" .. game.year .. ")")
		for i,cave in pairs(game.caves) do
			print_d(cave.name)
			print_d(cave.diamonds_are_worth .. ", " .. cave.extra_diamonds_are_worth)

		end
	end
	
end


function level_loader:load()
	files = MOAIFileSystem.listFiles( level_loader.folder )
	for k, file in ipairs(files) do
		if not (file == "levels.lua") then
			parse(level_loader.folder .. file)
			-- stream = MOAIFileStream.new ()
			-- stream:open(level_loader.folder..file, MOAIFileStream.READ)
			-- 
			-- print(stream:getLength())
			-- print(stream:read())
		end
	end
end

function lookup(letter)
	object = level_loader.object_map2[letter]
	if object and (object=="dirt" or object=="rock" or object=="steel" or object=="wall" or object=="diamond" or object=="rockford" or object=="outbox" or object=="firefly" or object=="butterfly") then
		return object
	else
		print("cannot find " .. letter)
		return "space"
	end
end

function preview_lookup(letter)
	object = level_loader.object_map3[letter]
	if object then
		return object
	else
		print("cannot find " .. letter)
		return "space"
	end
end
