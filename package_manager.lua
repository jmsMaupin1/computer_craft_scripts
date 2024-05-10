-- Not an actual package manager in the traditional sense, will basically just work to get the files from this repository
local function printUsage()
	print("Usage:")
	print("<package_manager scripts name> i <script_name>")
	print("<package_manager scripts name> l")
	print("<package_manager scripts name> b")
	print("<package_manager scripts name> --config.user <user_name>")
	print("<package_manager scripts name> --config.repo <repo_name>")
	print("<package_manager scripts name> --config.branch <branch_name>")
	print("<package_manager scripts name> --config")
end

local CONFIG_NAME = "jpm.json"
local GITHUB_API_BASE = "https://api.github.com"

local jpm_config = {
	user="jmsMaupin1",
	repo="computer_craft_scripts",
	branch="main"
}

local tArgs = { ... }
if #tArgs < 1 then
	printUsage()
	return
end

if not http then
	print("jpm requires the http API")
	print("set http_enable to true in ComputerCraft.cfg")
end

local function read_file(file_name)
	local sPath = shell.resolve(file_name)
	local file = fs.open(sPath, "r")

	if not file then
		return nil, "file not found"
	end

	return file.readAll(), nil
end

local function write_file(file_name, contents)
	local sPath = shell.resolve(file_name)
	local file = fs.open(sPath, "wb")
	file.write(contents)
	file.close()
end

local function load_config()
	local config, err = read_file(CONFIG_NAME)

	if err then
		return jpm_config
	end

	return textutils.unserializeJSON(config)
end

local function save_config()
	write_file(CONFIG_NAME, textutils.serializeJSON(jpm_config))
end

local function strip_file_ext(file_name)
	return file_name:match("(.+)%..+$") or file_name
end

local function get_all_branches()
	local url = GITHUB_API_BASE .. "/repos" .. "/" .. jpm_config.user .. "/" .. jpm_config.repo .. "/branches"

	local res = http.get(url, nil, true)
	if not res then
		print("failed to get branches")
	end

	local sRes = res.readAll()
	local branch_table = textutils.unserializeJSON(sRes)
	for i = 1,#branch_table do
		print(branch_table[i].name)
	end
end

local function get_available_scripts()
	local url = GITHUB_API_BASE .. "/" .. jpm_config.user .. "/" .. jpm_config.repo .. "/git/trees/" .. jpm_config.branch .. "?recursive=1"

	local res = http.get(url, nil, true)
	if not res then
		printError("Failed getting scripts")
	end

	local sRes = res.readAll()
	local files_table = textutils.unserializeJSON(sRes)
	for i = 1,#files_table["tree"] do
		local file_name = files_table["tree"][i]["path"]
		if not string.find(file_name, "README") then
			print(strip_file_ext(file_name))
		end
	end
end

local function get_script(file_name)
	print("connecting to github to grab " .. file_name .. "... ")
	local url = "https://raw.githubusercontent.com/" .. jpm_config.user .. "/" .. jpm_config.repo .. "/" .. jpm_config.branch .. "/"  .. file_name .. ".lua"

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
	local res = get_script(script_name)
	write_file(file_name, res)

	print("Downloaded script as " .. file_name)
end

jpm_config = load_config()

-- Theres definitely a better way to deal with arguments
-- this is very quick and dirty for now
if tArgs[1] == "i" then
	local file_name = tArgs[2] .. ".lua"
	if tArgs[3] then
		file_name = tArgs[3]
	end

	install(tArgs[2], file_name)
	return nil
end

if tArgs[1] == "l" then
	get_available_scripts()
	return nil
end

if tArgs[1] == "b" then
	get_all_branches()
end

if tArgs[1] == "config.user" then
	jpm_config.user = tArgs[2]
	save_config()
	return nil
end

if tArgs[1] == "config.repo" then
	jpm_config.repo = tArgs[2]
	save_config()
	return nil
end

if tArgs[1] == "config.branch" then
	jpm_config.branch = tArgs[2]
	save_config()
	return nil
end

if tArgs[1] == "config" then
	print(textutils.serialize(jpm_config))
end

