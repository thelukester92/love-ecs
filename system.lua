--	System Base Class
--		Every system should derive from this base class
--		and override the type() method.
--		Systems contain all logic for the game.
--		The accepts method should return true for entities
--		that contain components relevant to the system.
--		The acceptedEntityAdded method can be used to
--		process entities as they are accepted.
--		The acceptedEntityAdded method must not be used if
--		the system requires components that must be
--		initialized by other systems first (i.e. sprites)

local sys = {}
sys.__index = sys

function sys:new(w)
	local o = { world = w }
	setmetatable(o, self)
	o:superinit()
	o:init()
	return o
end

-- MARK: methods meant to be overridden
-- note: draw() and update(dt) are intentionally left undefined

function sys:init()
end

function sys:type()
	error("type must be overridden in the system!")
end

function sys:accepts(e)
	return false
end

function sys:worldInitialized()
end

function sys:acceptedEntityAdded(e)
end

function sys:acceptedEntityRemoved(e)
end

-- MARK: methods not meant to be overridden

function sys:superinit()
	self.isSystem	= true
	self.entities	= {}
end

function sys:entityAdded(e)
	if self:accepts(e) then
		table.insert(self.entities, e)
		self:acceptedEntityAdded(e)
	end
end

function sys:entityRemoved(e)
	if self:accepts(e) then
		for i, o in ipairs(self.entities) do
			if e == o then
				table.remove(self.entities, i)
				break
			end
		end
		self:acceptedEntityRemoved(e)
	end
end

return sys
