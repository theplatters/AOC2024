local open = io.open

local function read_file(path)
	local file = open(path, "rb") -- r read mode and b binary mode
	if not file then
		return nil
	end
	local content = file:read("*a") -- *a or *all reads the whole file
	file:close()
	return content
end

local function to_key(x, y)
	return x .. "," .. y
end

local function from_key(key)
	local x, y = key:match("^(%-?%d+),(%-?%d+)$")
	return { tonumber(x), tonumber(y) }
end

local function add(t1, t2)
	return { t1[1] + t2[1], t1[2] + t2[2] }
end
local function subtract(t1, t2)
	return { t1[1] - t2[1], t1[2] - t2[2] }
end

local function eq(t1, t2)
	return t1[1] == t2[1] and t1[2] == t2[2]
end

List = {}
function List.new()
	return { first = 0, last = -1 }
end

function List.pushleft(list, value)
	local first = list.first - 1
	list.first = first
	list[first] = value
end

function List.pushright(list, value)
	local last = list.last + 1
	list.last = last
	list[last] = value
end

function List.isempty(list)
	local first = list.first
	return first > list.last
end
function List.popleft(list)
	local first = list.first
	if first > list.last then
		error("list is empty")
	end
	local value = list[first]
	list[first] = nil -- to allow garbage collection
	list.first = first + 1
	return value
end

function List.popright(list)
	local last = list.last
	if list.first > last then
		error("list is empty")
	end
	local value = list[last]
	list[last] = nil -- to allow garbage collection
	list.last = last - 1
	return value
end

local function dijkstra(graph, source)
	local dist = {} -- Table to store the shortest distances from the source
	local visited = {} -- Table to mark visited nodes
	local previous = {} -- Table to store the path

	-- Initialize distances and visited status
	for node, _ in pairs(graph) do
		dist[node] = math.huge -- Set initial distance to infinity
		visited[node] = false -- Mark all nodes as unvisited
	end
	dist[source] = 0 -- Distance to the source is 0

	local l = List.new()
	List.pushleft(l, source)
	while not List.isempty(l) do
		local currentNode = List.popright(l)

		visited[currentNode] = true
		for _, neighbor in pairs(graph[currentNode]) do
			local weight = 1
			if
				previous[currentNode]
				and not eq(
					from_key(neighbor),
					add(from_key(currentNode), subtract(from_key(currentNode), from_key(previous[currentNode])))
				)
			then
				weight = 1000
			end
			local altDist = dist[currentNode] + weight
			if not visited[neighbor] or altDist < dist[neighbor] then
				dist[neighbor] = altDist
				previous[neighbor] = currentNode
				List.pushleft(l, neighbor)
			end
		end
	end
	return dist, previous
end

local function maze_to_graph(maze)
	local graph = {}
	local start, endNode

	-- Define directions (up, down, left, right)
	local directions = {
		{ -1, 0 }, -- Up
		{ 1, 0 }, -- Down
		{ 0, -1 }, -- Left
		{ 0, 1 }, -- Right
	}

	for row = 1, #maze do
		for col = 1, #maze[row] do
			local cell = maze[row]:sub(col, col)
			if cell == "." or cell == "S" or cell == "E" then
				local node = to_key(row, col)
				graph[node] = {}
				if cell == "S" then
					start = node
				end
				if cell == "E" then
					endNode = node
				end

				-- Check neighbors
				for _, dir in ipairs(directions) do
					local newRow, newCol = row + dir[1], col + dir[2]
					if maze[newRow] and maze[newRow]:sub(newCol, newCol):match("[.SE]") then
						table.insert(graph[node], to_key(newRow, newCol))
					end
				end
			end
		end
	end

	return graph, start, endNode
end
local content = read_file("input16.txt")
local maze = {}

for line in string.gmatch(content, "([^\n]*)\n?") do
	table.insert(maze, line)
end
local graph, start, endNode = maze_to_graph(maze)

local distances, paths = dijkstra(graph, start)

print(distances[endNode])
