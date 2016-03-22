-- the position of the entity in world space

local comp = require "component"

local c = {}
c.__index = c
setmetatable(c, comp)

function c:init(x, y)
	self.x = x or 0
	self.y = y or 0
end

function c:type()
	return "position"
end

return c
