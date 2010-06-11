local httpserver = require "luaweb"

local server = httpserver.new{root = "www", port = 80}
server:run()
