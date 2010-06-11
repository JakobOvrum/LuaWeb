local socket = require "socket"
local sleep = socket.sleep
local remove = table.remove
local setmetatable = setmetatable

local client = require "luaweb.client"
local requestHandler = require "luaweb.handler".handle

module "luaweb"

_M = {}
local server = _M
server.__index = server

function new(config)
	local self = {
		port = config.port or 80;
		root = config.root or "www";
		socket = socket.tcp();
		backlog = config.backlog or 16;
		clients = {};
	}

	self.socket:bind("*", self.port)
	self.socket:settimeout(0)
	self.socket:listen(self.backlog)

	return setmetatable(self, server)
end

function server:think()
	local clients = self.clients
	do
		local s, err = self.socket:accept()
		if s then
			clients[#clients + 1] = client.new(s, requestHandler)
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
