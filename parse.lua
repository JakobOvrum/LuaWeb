local print = print
local char = string.char

module "luaweb.parse"

function requestLine(line)
	return line:match("^(%S+) (%S+) HTTP/(%S+)$")
end

function header(line)
	return line:match("^([^:]+): (.+)$")
end

function request(data)
	for line in data:gmatch("(.+)\r\n") do
		print(line)
	end
end

function url(uri)
	return uri:gsub("%%..", function(hex)
		hex = tonumber(hex, 16)
		if hex then
			return char(hex)
		end
	end
end
