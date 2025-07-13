local map_size = 500
local ROOMS = 10
local ROBLOX = true
local HALLWAY_WIDTH = math.random(6, 15)
local WALL_HEIGHT = 10

math.randomseed(tick())

local ROOM_TYPES = {"Bedroom", "LivingRoom", "Office", "Lab", "Locker", "Bathroom"}
local FURNITURE = {
	Bedroom = {"Bed", "Nightstand", "Lamp"},
	LivingRoom = {"Sofa", "CoffeeTable", "TV"},
	Office = {"Desk", "Chair", "Computer"},
	Lab = {"LabTable", "Microscope", "Shelf"},
	Locker = {"Locker", "Bench"},
	Bathroom = {"Toilet", "Sink", "Shower"}
}

local function set_default_map()
	local map = {}
	for x = 1, map_size do
		map[x] = {}
		for y = 1, map_size do
			map[x][y] = false
		end
	end
	return map
end

local function rand_size()
	local min_size = 50
	local max_size = 100
	return math.random(min_size, max_size), math.random(min_size, max_size)
end

local function draw_room(map, x0, y0, w, h)
	for x = x0, x0 + w - 1 do
		for y = y0, y0 + h - 1 do
			if x > 0 and x <= map_size and y > 0 and y <= map_size then
				map[x][y] = true
			end
		end
	end
end

local function place_room(map, room_centers, room_types)
	local w, h = rand_size()
	for _ = 1, 50 do
		local x = math.random(10, map_size - w - 10)
		local y = math.random(10, map_size - h - 10)
		local overlap = false
		for i = x - 5, x + w + 5 do
			for j = y - 5, y + h + 5 do
				if i > 0 and i <= map_size and j > 0 and j <= map_size and map[i][j] then
					overlap = true
					break
				end
			end
			if overlap then break end
		end
		if not overlap then
			draw_room(map, x, y, w, h)
			table.insert(room_centers, {x + w // 2, y + h // 2, w, h})
			table.insert(room_types, ROOM_TYPES[math.random(1, #ROOM_TYPES)])
			return true
		end
	end
	return false
end

local function draw_hallway(map, start_pos, end_pos)
	local x, y = start_pos[1], start_pos[2]
	while x ~= end_pos[1] do
		for i = -HALLWAY_WIDTH // 2, HALLWAY_WIDTH // 2 do
			for j = -HALLWAY_WIDTH // 2, HALLWAY_WIDTH // 2 do
				local xi, yi = x + i, y + j
				if xi > 0 and xi <= map_size and yi > 0 and yi <= map_size then
					map[xi][yi] = true
				end
			end
		end
		if x < end_pos[1] then x = x + 1 else x = x - 1 end
	end
	while y ~= end_pos[2] do
		for i = -HALLWAY_WIDTH // 2, HALLWAY_WIDTH // 2 do
			for j = -HALLWAY_WIDTH // 2, HALLWAY_WIDTH // 2 do
				local xi, yi = x + i, y + j
				if xi > 0 and xi <= map_size and yi > 0 and yi <= map_size then
					map[xi][yi] = true
				end
			end
		end
		if y < end_pos[2] then y = y + 1 else y = y - 1 end
	end
end

local function connect_rooms(map, room_centers)
	for i = 1, #room_centers - 1 do
		draw_hallway(map, room_centers[i], room_centers[i + 1])
	end
end

local function place_furniture(room_type, room_center, w, h, model)
	local furniture_items = FURNITURE[room_type]
	if not furniture_items then return end

	local num_items = math.random(2, #furniture_items)
	for i = 1, num_items do
		local item_name = furniture_items[math.random(1, #furniture_items)]
		local part = Instance.new("Part")
		part.Name = item_name
		part.Size = Vector3.new(3, 3, 3)
		part.Position = Vector3.new(
			room_center[1] - map_size / 2 + math.random(-w // 2 + 5, w // 2 - 5),
			1.5,
			room_center[2] - map_size / 2 + math.random(-h // 2 + 5, h // 2 - 5)
		)
		part.Anchored = true
		part.Color = Color3.new(math.random(), math.random(), math.random())
		part.Parent = model
	end
end

local function place_spawnpoint(room_center, model)
	local spawn = Instance.new("SpawnLocation")
	spawn.Size = Vector3.new(5, 1, 5)
	spawn.Position = Vector3.new(room_center[1] - map_size / 2, 1, room_center[2] - map_size / 2)
	spawn.Anchored = true
	spawn.BrickColor = BrickColor.new("Bright green")
	spawn.Name = "SpawnPoint"
	spawn.Parent = model
end

local function visualize_map(map, room_centers, room_types)
	if not ROBLOX then return end
	local model = Instance.new("Model")
	model.Name = "GeneratedMap"

	for x = 1, map_size do
		for y = 1, map_size do
			if map[x][y] then
				local floor = Instance.new("Part")
				floor.Name = "Floor"
				floor.Size = Vector3.new(1, 1, 1)
				floor.Position = Vector3.new(x - map_size / 2, 0.5, y - map_size / 2)
				floor.Anchored = true
				floor.Color = Color3.new(0.8, 0.8, 0.8)
				floor.Parent = model

				local directions = {{1,0}, {-1,0}, {0,1}, {0,-1}}
				for _, dir in ipairs(directions) do
					local nx, ny = x + dir[1], y + dir[2]
					if nx < 1 or nx > map_size or ny < 1 or ny > map_size or not map[nx][ny] then
						local wall = Instance.new("Part")
						wall.Name = "Wall"
						wall.Size = Vector3.new(1, WALL_HEIGHT, 1)
						wall.Position = Vector3.new(x - map_size / 2, WALL_HEIGHT / 2, y - map_size / 2)
						wall.Anchored = true
						wall.Color = Color3.new(0.3, 0.3, 0.3)
						wall.Parent = model
					end
				end

				local ceiling = Instance.new("Part")
				ceiling.Name = "Ceiling"
				ceiling.Size = Vector3.new(1, 1, 1)
				ceiling.Position = Vector3.new(x - map_size / 2, WALL_HEIGHT + 0.5, y - map_size / 2)
				ceiling.Anchored = true
				ceiling.Color = Color3.new(0.7, 0.7, 0.7)
				ceiling.Parent = model
			end
		end
	end

	for i = 1, #room_centers do
		place_furniture(room_types[i], room_centers[i], room_centers[i][3], room_centers[i][4], model)
	end

	for i = 1, math.min(3, #room_centers) do
		place_spawnpoint(room_centers[i], model)
	end

	model.Parent = workspace
end

local function generate_map()
	local map = set_default_map()
	local room_centers = {}
	local room_types = {}
	local placed = 0
	local attempts = 0
	while placed < ROOMS and attempts < ROOMS * 20 do
		if place_room(map, room_centers, room_types) then
			placed = placed + 1
		end
		attempts = attempts + 1
	end
	connect_rooms(map, room_centers)
	return map, room_centers, room_types
end

local function render()
	local start = os.clock()
	local map, room_centers, room_types = generate_map()
	visualize_map(map, room_centers, room_types)
	local elapsed = os.clock() - start
	print(string.format("Map generation took %.2f seconds", elapsed))
end

return {
	render = render
}
