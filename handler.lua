local print = print

module "luaweb.handler"

function handle(sink, command, path, headers, body)
	print(command, path, headers, body)
	sink("HTTP/1.1 500 Hello, world!\r\n")
end
