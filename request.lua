local setmetatable = setmetatable
local concat = table.concat
local insert = table.insert
local pairs = pairs
local error = error

local parse = require "luaweb.parse"

module "luaweb.request"

local req = {}
req.__index = req

function new(info)
    local path = info.path

    if info.method == "GET" then
        local uri, params = path:match("^([^%?]+)%?(.+)$")
        info.path = parse.url(uri or path)
        if params then
            info.params = parse.params(params)
        end
	else
        info.path = parse.url(path)
        if info.method == "POST" then
            info.params = parse.params(info.body)
        end
	end
	
	return setmetatable(info, req)
end

local statusMessages = {
	[200] = "OK";

    [400] = "Bad Request";
	[403] = "Forbidden";
	[404] = "Not Found";

	[500] = "Internal Server Error";
	[501] = "Not Implemented";
}

function statusName(code)
    return statusMessages[code]
end

function req:isActive()
    return not self.served
end

function req:reply(r)
    if self.served then
        error("request already served", 2)
    end
    
	local status = r.status
	local lines = {("HTTP/1.1 %i %s"):format(status, r.message or statusName(status))}

	local headers = r.headers or {
        Server = "LuaWeb";
	}
	
	local body = r.body
	if body then
		headers["Content-Length"] = body:len()
	end
	
	for name, value in pairs(headers) do
		insert(lines, ("%s: %s"):format(name, value))
	end

	if body then
		insert(lines, "")
		insert(lines, body)
	end

	self.sink(concat(lines, "\r\n"))

	self.served = true
end
