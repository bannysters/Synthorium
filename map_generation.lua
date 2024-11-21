local map_size = 500 -- in studs
local ROOMS = 10
local ROBLOX = true -- enable if using in roblox studio

local branching_chance = 1/2
local BRANCHES_MIN = 1
local BRANCHES_MAX = 2

math.randomseed(os.time())

local function trim_map(game_map)
	for i = 1, map_size do
		game_map[i][1][3] = "#"
		game_map[1][i][3] = "#"
		game_map[i][map_size][3] = "#"
		game_map[map_size][i][3] = "#"
	end

	return game_map
end

local function carve_map(game_map)
	local carving = {}
	for x = 1, map_size do
		carving[x] = {}
		for y = 1, map_size do
			carving[x][y] = {game_map[x][y][1], game_map[x][y][2], game_map[x][y][3]}
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
				carving[x][y][3] = "/"
			end
		end
	end

	return carving
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
			math.random(math.max(1, room_origin_x - branch_size_x), math.min(map_size, room_origin_x + room_size_x))
		local branch_origin_y =
			math.random(math.max(1, room_origin_y - branch_size_y), math.min(map_size, room_origin_y + room_size_y))

		if branch_origin_x >= 1 and branch_origin_x <= map_size and branch_origin_y >= 1 and branch_origin_y <= map_size then
			local overlap = false
			for x = branch_origin_x, branch_origin_x + branch_size_x - 1 do
				for y = branch_origin_y, branch_origin_y + branch_size_y - 1 do
					if x >= 1 and x <= map_size and y >= 1 and y <= map_size then
						if game_map[y][x][3] == "#" or game_map[y][x][3] == "/" then
							overlap = true
							break
						end
					end
				end
				if overlap then
					break
				end
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

local function generate_room_vectors(game_map, room_size, priority, ignore_priority)
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
					if (game_map[y][x][3] == "#" or game_map[y][x][3] == "/") and not has_branches then
						continue
					end
					
					table.insert(vector_list, {x, y, "#"})
				end
			end
		end

		for i = 1, branches do
			vector_list = add_branch(game_map, vector_list, room_size_x, room_size_y, origin_x, origin_y, i)
		end

		local quadrants = enum_vector_quadrants(vector_list)

		if returnMax(quadrants) == priority then
			found = true
		end

		if ignore_priority then
			found = true
		end

		if found then
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

local function generate_map(ROOMS)
	local game_map = {}
	for x = 1, map_size do
		game_map[x] = {}
		for y = 1, map_size do
			game_map[x][y] = {x, y, "."}
		end
	end

	for _ = 1, ROOMS do
		local quadrant_data = enum_map_quadrants(game_map)
		local priority = returnMin(quadrant_data)

		local ignore_priority = false
		local empty = 0

		for i = 1, 4 do
			if quadrant_data[i] == 0 then
				empty = empty + 1
			end
		end

		local vector_array = generate_room_vectors(game_map, rand_size(), priority, empty > 1)
		draw_vectors(game_map, vector_array)
	end

	local carved = carve_map(game_map)
	local trimmed = trim_map(carved)

	local quadrants = enum_map_quadrants(trimmed)

	return trimmed, quadrants
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

local function unionParts(model)
	local parts = {}  -- Table to store BaseParts

	-- Collect all BaseParts in the model
	for _, child in pairs(model:GetChildren()) do
		if child:IsA("BasePart") then
			table.insert(parts, child)
		end
	end

	-- Ensure there are enough parts to union
	if #parts < 2 then
		warn("Not enough parts to union.")
		return
	end

	-- Try to create the union
	local success, union = pcall(function()
		return parts[1]:UnionAsync(parts)
	end)

	-- Check for success
	if success and union then
		union.Parent = model.Parent
		union.Anchored = true -- Set properties for the union
		union.Name = "Union"

		-- Clean up original parts
		for _, part in pairs(parts) do
			part:Destroy()
		end
	else
		warn("Failed to union parts:", union)
	end
end

local function init()
	

	local start_time = os.clock() 
	local map_vectors, quadrants = generate_map(ROOMS) 

	print(
		"Q1: " ..
			tostring(quadrants[1]) ..
			", Q2: " ..
			tostring(quadrants[2]) .. ", Q3: " .. tostring(quadrants[3]) .. ", Q4: " .. tostring(quadrants[4])
	)

	local end_time = os.clock() 

	print(string.format("Generated map in %.2f ms:", (end_time - start_time) * 1000 )) 

	if ROBLOX then
		local mapModel = Instance.new("Model")
		mapModel.Name = "Map"


		for row, row_data in ipairs(map_vectors) do
			for column, column_data in ipairs(row_data) do
				local status = map_vectors[row][column][3]

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


		local roof = Instance.new("Part")
		roof.Size = Vector3.new(map_size, 1, map_size)
		roof.Position = Vector3.new(map_vectors[1][1][1], 25, map_vectors[1][1][2])
		roof.Anchored = true -- Unanchor for welding
		roof.Transparency = 0.5
		roof.Name = "Roof"
		roof.Parent = mapModel


		-- Parent the entire model to the workspace
		mapModel.Parent = game.Workspace
		

	else
		print_map(map_vectors)
	end
end

init()
