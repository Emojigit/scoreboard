scoreboard = {}
scoreboard.list = {}
local lpp = 14
local function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
				if type(k) ~= 'number' then k = '"'..k..'"' end
				s = s .. '['..k..'] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end
local default_here = minetest.get_modpath("default")
local keep_key = {}
table.insert(keep_key,"\\description\\")

local function report_book(name, table_name, key, value)
	if not(default_here) then
		return false, "No mods can make books"
	end
	local item = ItemStack("default:book_written")
	local meta = item:get_meta()
	local data = {}
	data.owner = "Universe itself" -- Minecraft 20w14infinite
	local title = "Scoreboard Report: "..tostring(key).."@"..tostring(table_name)
	data.title = title
	data.description = "\""..title.."\" by "..data.owner
	data.text = dump(value)
	data.text = data.text:gsub("\r\n", "\n"):gsub("\r", "\n")
	data.page = 1
	data.page_max = math.ceil((#data.text:gsub("[^\n]", "") + 1) / lpp)
	item:get_meta():from_table({ fields = data })
	local receiverref = minetest.get_player_by_name(name)
	if receiverref == nil then
		return false, receiver .. " is not a known player"
	end
	local leftover = receiverref:get_inventory():add_item("main", item)
	local partiality = ""
	if leftover:is_empty() then
		partiality = ""
	elseif leftover:get_count() == itemstack:get_count() then
		partiality = "could not be "
	else
		partiality = "partially "
	end
	return true, "The book "..partiality.."added to inventory."
end

minetest.register_chatcommand("sget",{
	params = "<list> <key>",  -- Short parameter description
	description = "Get scoreboard data",  -- Full description
	privs = {interact=true},  -- Require the "privs" privilege to run
	func = function(name, param)
		local listn, key = param:match('^(%S+)%s(.+)$')
		if not(scoreboard.list[listn]) then
			return false, "Scoreboard not exist"
		end
		local sb = scoreboard.list[listn]
		if not(sb[key]) then
			return false, "Invaid key or value not exist"
		end
		local ty = type(sb[key])
		if ty == "string" then
			return true, key.."@"..listn..": "..sb[key]
		else
			return report_book(name, listn, key, sb[key])
		end
		
			
	end,
	-- Called when command is run. Returns boolean success and text output.
})

minetest.register_chatcommand("sset",{
	params = "<list> <key> <value>",  -- Short parameter description
	description = "Set scoreboard data",  -- Full description
	privs = {server=true},  -- Require the "privs" privilege to run
	func = function(name, param)
		local listn, key, value = param:match('^(.+) ([^ ]+) (.+)$')
		if not(scoreboard.list[listn]) then
			return false, "Scoreboard not exist"
		end
		scoreboard.list[listn][key] = value
	end,
	-- Called when command is run. Returns boolean success and text output.
})

minetest.register_chatcommand("sadd",{
	params = "<list>",  -- Short parameter description
	description = "Add scoreboard",  -- Full description
	privs = {server=true},  -- Require the "privs" privilege to run
	func = function(name, param)
		scoreboard.list[param] = scoreboard.list[param] or {["\\description\\"] = "placeholder",}
		return true, "Setted!"
	end,
	-- Called when command is run. Returns boolean success and text output.
})

minetest.register_chatcommand("sdel",{
	params = "<list>",  -- Short parameter description
	description = "Delete scoreboard",  -- Full description
	privs = {server=true},  -- Require the "privs" privilege to run
	func = function(name, param)
		scoreboard.list[param] = nil
		return true, "deleted!"
	end,
	-- Called when command is run. Returns boolean success and text output.
})

scoreboard.list["test"] = {}
scoreboard.list["test"]["\\description\\"] = ""
scoreboard.list["test"]["dist"] = {foo="bar",hello="World"}



