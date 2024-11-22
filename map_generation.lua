local map_size = 500             -- in studs
local ROOMS = 10                 -- amount of rooms (10 is usually fine)
local ROBLOX = true              -- enable if using in roblox studio

local branching_chance = 1/5     -- chance that a room being generated will have branches off of it
local BRANCHES_MIN = 4           -- minimum branch partitions
local BRANCHES_MAX = 8           -- maximum branch partitions

local render_empty_space = false -- whether or not to render empty floorspace in roblox

local start_time = os.clock()    -- timer
math.randomseed(os.time())       -- make sure math.random is actually random

local function carve_and_trim_map(game_map)
	local temp = {}
	
	for x = 1, map_size do
		temp[x] = {}
		for y = 1, map_size do
			temp[x][y] = {game_map[x][y][1], game_map[x][y][2], game_map[x][y][3]}
		end
	end

	for x = 1, map_size do
		for y = 1, map_size do
			local curr = game_map[x][y][3]

			local above = y > 1 and game_map[x][y - 1][3] or nil
			local below = y < map_size and game_map[x][y + 1][3] or nil
			local left = x > 1 and game_map[x - 1][y][3] or nil
			local right = x < map_size and game_map[x + 1][y][3] or nil

			if above == "#" and below == "#" and left == "#" and right == "#" then
				temp[x][y][3] = "/"
			end
		end
	end

	for i = 1, map_size do
		temp[i][1][3] = "#"
		temp[1][i][3] = "#"
		temp[i][map_size][3] = "#"
		temp[map_size][i][3] = "#"
	end

	return temp
end

local function get_quadrant(x, y)
	local midpoint = math.floor(map_size / 2)

	local rightmost = x > midpoint
	local uppermost = y < midpoint

	if rightmost then
		if uppermost then
			-- Top right
			return 1 -- Q1
		else -- y > midpoint
			-- Bottom right
			return 4 -- Q4
		end
	else -- x <= midpoint
		if uppermost then
			-- Top left
			return 2 -- Q2
		else -- y > midpoint
			-- Bottom left
			return 3 -- Q3
		end
	end
end

local function enum_map_quadrants(map_array) 
	local quadrants = {0, 0, 0, 0}

	for x = 1, #map_array do
		for y = 1, #map_array[x] do
			if map_array[x][y][3] ~= "." then
				local q = get_quadrant(x, y)
				quadrants[q] = quadrants[q] + 1
			end
		end
	end

	return quadrants
end

local function enum_vector_quadrants(vector_array)
	local quadrants = {0, 0, 0, 0}

	for i = 1, #vector_array do
		local vec_val = vector_array[i][3]

		local q = get_quadrant(vector_array[i][1], vector_array[i][2])
		quadrants[q] = quadrants[q] + 1
	end

	return quadrants
end

function returnMin(t)
	local k
	for i, v in pairs(t) do
		k = k or i
		if v < t[k] then
			k = i
		end
	end
	return k
end

function returnMax(t)
	if next(t) == nil then
		return nil
	end

	local k
	for i, v in pairs(t) do
		if type(v) == "number" then
			k = k or i
			if v > t[k] then
				k = i
			end
		end
	end
	return k
end

local function draw_vectors(game_map, vector_array)
	if vector_array == nil then
		return print("Vector array is nil")
	end

	for _, vector in ipairs(vector_array) do
		if vector[1] >= 1 and vector[1] <= map_size and vector[2] >= 1 and vector[2] <= map_size then
			game_map[vector[1]][vector[2]][3] = vector[3]
		else
			print("Out of bounds vector: ", vector[1], vector[2])
		end
	end
end

local function add_branch(game_map, vector_list, room_size_x, room_size_y, room_origin_x, room_origin_y, i)
	for _ = 1, 10 do
		local branch_size_x = math.random(math.floor(map_size / 20), room_size_x)
		local branch_size_y = math.random(math.floor(map_size / 20), room_size_y)

		local branch_origin_x =
			math.random(
				math.max(1, room_origin_x - branch_size_x), 
				math.min(map_size, room_origin_x + room_size_x)
			)

		local branch_origin_y =
			math.random(
				math.max(1, room_origin_y - branch_size_y), 
				math.min(map_size, room_origin_y + room_size_y)
			)

		if branch_origin_x >= 1 and branch_origin_x <= map_size and branch_origin_y >= 1 and branch_origin_y <= map_size then
			local overlap = false
			for x = branch_origin_x, branch_origin_x + branch_size_x - 1 do
				for y = branch_origin_y, branch_origin_y + branch_size_y - 1 do
					if x >= 1 and x <= map_size and y >= 1 and y <= map_size then
						overlap = game_map[y][x][3] == "#" or game_map[y][x][3] == "/"
						if overlap then break end
					end
				end

				if overlap then break end
			end

			if not overlap then
				for x = branch_origin_x, branch_origin_x + branch_size_x - 1 do
					for y = branch_origin_y, branch_origin_y + branch_size_y - 1 do
						if x >= 1 and x <= map_size and y >= 1 and y <= map_size then
							table.insert(vector_list, {x, y, "#"})
						end
					end
				end
				return vector_list
			end
		end
	end

	return vector_list
end

function safe_index(table, x, y, z)
	return table[x] and table[x][y] and table[x][y][z] or nil
end

local function generate_room_vectors(game_map, room_size, priority, ignore_priority, room_iter, room_contents)
	local found = false

	while not found do
		local vector_list = {}
		local branches = 0

		local has_branches = math.random(0, 1) < branching_chance

		if has_branches then
			branches = math.random(BRANCHES_MIN, BRANCHES_MAX)
		end

		local room_size_x = room_size[1]
		local room_size_y = room_size[2]
		local min_x = 1
		local min_y = 1
		local max_x = map_size - room_size[1]
		local max_y = map_size - room_size[2]
		local origin_x = math.random(min_x, max_x)
		local origin_y = math.random(min_y, max_y)

		for x = origin_x, origin_x + room_size_x - 1 do
			for y = origin_y, origin_y + room_size_y - 1 do
				if x >= 1 and x <= map_size and y >= 1 and y <= map_size then
					if not ((game_map[y][x][3] == "#" or game_map[y][x][3] == "/") and not has_branches)then
						table.insert(vector_list, {x, y, "#"})
					end
				end
			end
		end

		for i = 1, branches do
			vector_list = add_branch(game_map, vector_list, room_size_x, room_size_y, origin_x, origin_y, i)
		end

		local quadrants = enum_vector_quadrants(vector_list)


		found = returnMax(quadrants) == priority or ignore_priority == true

		if found then
			room_contents[room_iter] = {}

			for v = 1, #vector_list do
				if vector_list[v][3] == "#" then

					local x = vector_list[v][1]
					local y = vector_list[v][2]


					table.insert(room_contents[room_iter], {x, y})


				end
			end

			return vector_list
		end
	end
end

local function rand_size()
	return {
		math.random(math.floor(map_size / 10), math.floor(map_size / 3)),
		math.random(math.floor(map_size / 10), math.floor(map_size / 3))
	}
end

local function set_default_map(game_map) 
	for x = 1, map_size do
		game_map[x] = {}
		for y = 1, map_size do
			game_map[x][y] = {x, y, "."}
		end
	end
end


local function get_exposed_walls(game_map, room_contents)
	local exposed_walls = {}
	for room = 1, #room_contents do
		exposed_walls[room] = {}

		for vector = 1, #room_contents[room] do
			local x = room_contents[room][vector][1]
			local y = room_contents[room][vector][2]
			local v = room_contents[room][vector][3]

			local above = safe_index(game_map, x, y-1, 3)
			local below = safe_index(game_map, x, y+1, 3)
			local right = safe_index(game_map, x+1, y, 3)
			local left = safe_index(game_map, x-1, y, 3)



			local VectorIsAWall = game_map[x][y][3] == "#" 

			local WallIsExposed = above == '.' or below == '.' or right == '.' or left == '.'

			if VectorIsAWall and WallIsExposed then
				table.insert(exposed_walls[room], {x, y})
			end
		end
	end

	return exposed_walls
end

function pathfind(map, start, target)
	local startx = start[1]
	local starty = start[2]

	local targetx = target[1]
	local targety = target[2]
	-- print("Pathfinding from ("..startx..", "..starty..") to ("..targetx..", "..targety..")")
	
	return nil
end

function get_empty_quadrants(quadrant_data)
	local empty = 0
	for i = 1, 4 do
		if quadrant_data[i] == 0 then
			empty = empty + 1
		end
	end
	
	return empty
end

local function print_map(game_map)
	local quad_colors = {
		"\x1B[31m",
		"\x1B[32m",
		"\x1B[33m",
		"\x1B[34m"
	}

	for y = 1, #game_map do
		for x = 1, #game_map[y] do
			local q = get_quadrant(x, y)
			local color = quad_colors[q]

			if game_map[x][y][3] == "." then
				color = ""
			end

			local text = string.format("%s ", game_map[x][y][3])

			io.write(color .. text .. "\x1B[0m")
		end
		io.write("\n")
	end
end

local function visualize_map(map_vectors)
	local mapModel = Instance.new("Model")
	mapModel.Name = "Map"


	for row, row_data in ipairs(map_vectors) do
		for column, column_data in ipairs(row_data) do
			local status = map_vectors[row][column][3]
			if status == "." and render_empty_space == false then
				continue
			end
			local obj = Instance.new("Part", mapModel)
			obj.Size = Vector3.new(1, 1, 1)
			obj.Anchored = true -- 
			obj.Position = Vector3.new(map_vectors[row][column][1], 1, map_vectors[row][column][2])

			-- Customize the part based on status
			if status == "#" then
				obj.Color = Color3.new(1, 1, 1)
				obj.Size = Vector3.new(1, 25, 1)
			elseif status == "/" then
				obj.Color = Color3.new(1, 0, 0)
			end

			obj.Parent = mapModel


		end
	end


	-- Parent the entire model to the workspace
	mapModel.Parent = game.Workspace.World	
end

local function generate_map(ROOMS)
	local raw_map = {}                                             -- rooms will be drawn to this array
	local room_contents = {}                                       -- this will contain the vectors occupied by their respective room

	set_default_map(raw_map)                                       -- reset the map to be all empty

	for ROOM_ITERATION = 1, ROOMS do                               -- for each room
		
		local quadrant_data = enum_map_quadrants(raw_map)          -- returns array showing how many parts take up each quadrant of the map
		local priority = returnMin(quadrant_data)                  -- gets the least populated quadrant to prioritize it
		local empty_quadrants = get_empty_quadrants(quadrant_data) -- gets the number of quadrants that don't have anything in them
		
		local room_size = rand_size()                              -- random size vector for the room
 
 
		                                                           -- array of vectors that make up a new room for the map
		local vector_array = generate_room_vectors(raw_map, room_size, priority, empty_quadrants > 1, ROOM_ITERATION, room_contents)
		
		
		
		                                                           -- draw the room's vectors onto the raw map array
		draw_vectors(raw_map, vector_array)
	end


    -----------------------------------------------------------------------------------------------------------------------------------------

	local carved_map = carve_and_trim_map(raw_map)                 -- establishes room's walls & the edge of the map
	
	local quadrants = enum_map_quadrants(carved_map)               -- get the distribution of the map throughout 4 quadrants
	local exp_walls = get_exposed_walls(carved_map, room_contents) -- gets an array for each room, of wall vectors that are exposed on the outside


	for room = 1, #exp_walls do
		print("Room " .. room .. " exposed walls: " .. #exp_walls[room])
	end


	paths = {}                                                     -- will be used to store the possible paths halls can take between rooms

	for RoomIterA = 1, #exp_walls do
		for RoomIterB = 1, #exp_walls do

			if RoomIterB ~= RoomIterA then
				-- room A is the starting room
				-- room B is the target room

				local roomA = exp_walls[RoomIterA] 
				local roomB = exp_walls[RoomIterB]

				-- now try pathfinding from every wall 
				for WallA = 1, #roomA do
					for WallB = 1, #roomB do
						local start = roomA[WallA] -- This is {x, y, v} for room A

						local target = roomB[WallB] -- This is {x, y, v} for room B


						local startx = start[1]
						local starty = start[2]

						local targetx = target[1]
						local targety = target[2]

						local result = pathfind(carved_map, {startx, starty}, {targetx, targety})

						if result then
							table.insert(paths, result)
						end
					end
				end
			end


		end
	end
	
	print("Q1: " ..tostring(quadrants[1]) ..", Q2: " ..tostring(quadrants[2]) .. ", Q3: " .. tostring(quadrants[3]) .. ", Q4: " .. tostring(quadrants[4]))
	print("Paths found between rooms: " .. #paths)

	return carved_map
end



local map_vectors = generate_map(ROOMS) 
local end_time = os.clock() 

print(string.format("Generated map in %.2f ms:", (end_time - start_time) * 1000 )) 

if ROBLOX then
	visualize_map(map_vectors)
else
	print_map(map_vectors)
end


