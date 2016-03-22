local comp = require "component"

local c = {}
c.__index = c
setmetatable(c, comp)

function c:init(name, ...)
	self.name = name
	self.args = {...}
end

function c:type()
	return "event"
end

return c
