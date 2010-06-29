local print = print
local tonumber = tonumber
local char = string.char

module "luaweb.parse"

function requestLine(line)
	return line:match("^(%S+) (%S+) HTTP/(%S+)$")
end

function header(line)
	return line:match("^([^:]+): (.+)$")
end

function url(uri)
	return uri:gsub("%%(..)", function(hex)
		hex = tonumber(hex, 16)
		if hex then
			return char(hex)
		end
	end)
end
function params(str)
    local p = {}
    for pair in str:gmatch("([^&]+)&?") do
        local key, value = pair:match("^([^=]+)=(.+)$")
        if key then
            p[url(key)] = url(value)
        else
            p[url(pair)] = true
        end
    end
    return p
end
