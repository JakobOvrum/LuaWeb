local print = print

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
