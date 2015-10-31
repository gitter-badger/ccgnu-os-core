--Settings File API used to parse and interpret and save settings files. 
--Entirely created by bwhodle
--Forum post: http://www.computercraft.info/forums2/index.php?/topic/14311-preferences-settings-configuration-store-them-all-settings-file-api/
local function trimComments(line)
    local commentstart = string.len(line)
	for i = 1, string.len(line) do
		if string.byte(line, i) == string.byte(";") then
			commentstart = i - 1
			break
		end
	end
	return string.sub(line, 0, commentstart)
end
local function split(line)
	local equalssign = nil
	for i = 1, string.len(line) do
		if string.byte(line, i) == string.byte("=") or string.byte(line, i) == string.byte(":") then
			equalssign = i - 1
		end
	end
	if equalssign == nil then
		return nil, nil
	end
	return string.sub(line, 1, equalssign - 1), string.sub(line, equalssign + 2)
end
function Trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end
local function RemoveQuotes(s)
	if string.byte(s, 1) == string.byte("\"") and string.byte(s, string.len(s)) == string.byte("\"") then
		return string.sub(s, 2, -2)
	end
	return s
end
function openSettingsFile(path)
	local settings = {}
	local currentsection = {}
	local currentsectionname = nil
	local file = fs.open(path, "r")
	local lines = true
	settings["content"] = {}
	while lines do
		local currentline = file.readLine()
		if currentline == nil then
			lines = false
			break
		end
		currentline = trimComments(currentline)
		if Trim(currentline) ~= "" then
			if string.byte(currentline, 1) == string.byte("[") then
				if currentsectionname ~= nil then
					settings["content"][currentsectionname] = currentsection
					currentsection = {}
				elseif currentsectionname == nil then
					settings["content"][1] = currentsection
					currentsection = {}
				end
				currentsectionname = string.sub(currentline, 2, -2)
			else
				local key, value = split(currentline)
				if Trim(key) ~= nil and Trim(value) ~= nil then
					local x = Trim(value)
					if tonumber(x) then
						x = tonumber(x)
					else
						x = RemoveQuotes(x)
					end
					if x ~= nil and tostring(Trim(key)) ~= nil then
						currentsection[Trim(key)] = x
					end
					
				end
			end
		end
	end
	if currentsectionname ~= nil then
		settings["content"][currentsectionname] = currentsection
		currentsection = {}
	elseif currentsectionname == nil then
		settings["content"][1] = currentsection
		currentsection = {}
	end
	
	function settings.addSection(name)
		settings["content"][name] = {}
	end
	
	function settings.getValue(key)
		local x = settings["content"][1]
		return x[key]
	end
	
	function settings.getSectionedValue(section, key)
		return settings["content"][section][key]
	end
	
	function settings.setValue(key, value)
		settings["content"][1][key] = value
	end
	
	function settings.setSectionedValue(section, key, value)
		settings["content"][section][key] = value
	end
	
	function settings.save(path)
		local file = fs.open(path, "w")
		local d = settings["content"][1]
		if d ~= nil then
			for k, v in pairs(d) do
				local x = v
				if string.byte(v, 1) == string.byte(" ") or string.byte(v, string.len(v)) == string.byte(" ") then
					x = "\""..v.."\""
				end
				file.writeLine(k.." = "..x)
			end
		end
		for k, v in pairs(settings["content"]) do
			if k ~= 1 then
				file.writeLine("")
				file.writeLine("["..k.."]")
				for j, l in pairs(v) do
					local x = l
					if string.byte(l, 1) == string.byte(" ") or string.byte(l, string.len(l)) == string.byte(" ") then
						x = "\""..l.."\""
					end
					file.writeLine(j.." = "..x)
				end
			end
		end
		file.close()
	end
	
	return settings
end