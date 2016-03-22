local comp = require "component"

local c = {}
c.__index = c
setmetatable(c, comp)

function c:init(object, targetProps, time, easing, delay)
	self.object			= object
	self.targetProps	= targetProps
	self.time			= time or 1
	self.easing			= easing or "linear"
	self.delay			= delay or 0
	self.interpolation	= 0
	self.tween			= nil -- to be initialized by the tweener
end

function c:type()
	return "tween"
end

return c
