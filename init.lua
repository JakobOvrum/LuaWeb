local socket = require "socket"

local sleep = socket.sleep
local remove = table.remove
local setmetatable = setmetatable
local assert = assert

local client = require "luaweb.client"

module "luaweb"

_M = {}
local server = _M
server.__index = server

function new(config)
	local self = {
		port = config.port or 80;
		socket = socket.tcp();
		backlog = config.backlog or 16;
		callback = assert(config.callback, "callback required");
		clients = {};
	}

	assert(self.socket:bind("*", self.port))
	assert(self.socket:listen(self.backlog))

	self.socket:settimeout(0)

	return setmetatable(self, server)
end

function server:think()
	local clients = self.clients
	do
		local s, err = self.socket:accept()
		if s then
			clients[#clients + 1] = client.new(s, self.callback)
		end
	end

	for k = 1, #clients do
		local c = clients[k]
		if not c:think() then
			remove(clients, k)
		end
	end
end

function server:run()
	while true do
		self:think()
	end
end
