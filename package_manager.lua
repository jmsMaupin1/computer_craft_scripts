-- Not an actual package manager in the traditional sense, will basically just work to get the files from this repository
local function printUsage()
	print("Usage:")
	print("jpm install <script_name>")
end

local tArgs = { ... }
if #tArgs < 1 then
	printUsage()
	return
end

if not http then
	print("jpm requires the http API")
	print("set http_enable to true in ComputerCraft.cfg")
end

local function get(file_name)
	print("connecting to github to grab " .. file_name .. "... ")
	url = "https://raw.githubusercontent.com/jmsMaupin1/computer_craft_scripts/main/"  .. file_name .. ".lua"

	local ok, err = http.checkURL(url)
	if not ok then
		print("Failed to fetch the script")
		if err then
			printError(err)
		end
		return nil
	end

	local response = http.get(url, nil, true)
	if not response then
		print("Failed")
		return nil
	end

	print ("Success!")
	local sResponse = response.readAll()
	response.close()
	return sResponse
end

local function install(script_name, file_name)
	local sPath = shell.resolve(file_name)
	local res = get(script_name)

	local file = fs.open(sPath, "wb")
	file.write(res)
	file.close()

	print("Downloaded script as " .. file_name)
end

if tArgs[1] == "install" then
	local file_name = tArgs[2] .. ".lua"
	if tArgs[3] then
		file_name = tArgs[3]
	end

	install(tArgs[2], file_name)
end
