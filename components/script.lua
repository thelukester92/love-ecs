local comp = require "component"

local c = {}
c.__index = c
setmetatable(c, comp)

function c:init(event, handler, callOnce)
	self.event		= event
	self.handler	= handler
	self.callOnce	= callOnce or false
end

function c:type()
	return "script"
end

return c
