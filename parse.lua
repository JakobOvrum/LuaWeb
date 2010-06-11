module "luaweb.parse"

function request(line)
	return line:match("^(%S+) (%S+) HTTP/(%S+)$")
end

function header(line)
	return line:match("^([^:]+): (.+)$")
end
