local setmetatable = setmetatable
local concat = table.concat
local insert = table.insert
local pairs = pairs

module "luaweb.request"

local req = {}
req.__index = req

function new(info)
	return setmetatable(info, req)
end

local statusMessages = {
	[200] = "OK";
	[500] = "Internal Server Error";
}

function req:reply(r)
	local status = r.status
	local lines = {("HTTP/1.1 %i %s"):format(status, r.message or statusMessages[status])}

	local headers = r.headers or {}
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
end
