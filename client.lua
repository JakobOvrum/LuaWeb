local tonumber = tonumber
local concat = table.concat
local setmetatable = setmetatable
local error = error
local pcall = pcall
local type = type

local parse = require "luaweb.parse"
local request = require "luaweb.request"

module "luaweb.client"

local function httpAssert(a, message, code)
	if not a then
		error({message = message, code = code}, 2)
	end
	return a
end

_M = {}
local client = _M
client.__index = client

local handlers

function new(socket, callback)
	return setmetatable({
		socket = socket;
		handler = handlers.requestLine;
		parser = parse.requestLine;
		headers = {};
		receiver = function(s) return s:receive("*l") end;
		callback = callback;
	}, client)
end

function client:think()
	local data, err = self.receiver(self.socket)

	if data then
		local succ, err = pcall(self.handle, self, data)
		if not succ then
			self:handleError(err)
			return false
		end
		
	elseif err ~= "timeout" then
		return false
	end

	return true
end

handlers = {
	requestLine = function(self, command, path, version)
		httpAssert(command and path and version, "invalid request-line", 400)
		
		version = httpAssert(tonumber(version), "invalid HTTP version", 400)
		httpAssert(version >= 1.1, "client must be HTTP/1.1 compatible", 505)
		self.command = command
		self.path = path
		self.version = version

		return handlers.header, parse.header
	end;

	header = function(self, name, value)
		if not name then
			local contentLength = self.headers["Content-Length"]
			if contentLength then
				self.receiver = function(s) return s:receive(httpAssert(tonumber(contentLength), "invalid Content-Length", 400)) end
				return handlers.body, function(data) return data end
			else
				self:finalize()
				return nil, function() error{message = "body not expected", code = 400} end
			end
		end

		self.headers[name] = value
		return handlers.header, parse.header
	end;

	body = function(self, data)
		self.body = data
		self:finalize()
	end;
}

function client:handle(data)
	self.handler, self.parser = self:handler(self.parser(data))
end

function client:handleError(err)
	if type(err) == "string" then
		error(err, 3)
	else
		self:sendError(err.code, err.message)
	end
end

local errorTemplate = "HTTP/1.1 %i %s\r\n"

function client:sendError(code, message)
	self.socket:write(errorTemplate:format(code, message))
end

function client:finalize()
	local req = request.new{
		body = self.body, command = self.command, path = self.path, headers = self.headers;
		sink = function(data) self.socket:send(data) end;
	}
	self.callback(req)
	self.socket:close()
end
