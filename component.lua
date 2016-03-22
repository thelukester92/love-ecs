--	Component Base Class
--		Every component should derive from this base class
--		and override the type() method.
--		Components should only contain data and no logic.
--		The init method should only save parameters and
--		initialize default values.
--		Any initialization more intensive than that should
--		save the parameters and process it in the appropriate
--		system's acceptedEntityAdded method.

local c = {}
c.__index = c

function c:new(...)
	local o = {}
	setmetatable(o, self)
	o:init(...)
	return o
end

function c:init()
end

function c:type()
	error("type must be overridden in the component!")
end

return c
