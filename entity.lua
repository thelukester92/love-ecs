local e = {}
e.__index = e
e.nextId = 1

function e:new(comps)
	local o = {}
	setmetatable(o, e)
	o:init(e.nextId, comps)
	e.nextId = e.nextId + 1
	return o
end

function e:init(id, comps)
	self.isEntity		= true
	self.addedToWorld	= false
	self.id				= id
	self.components		= {}
	self:add(unpack(comps))
end

function e:add(...)
	assert(not self.addedToWorld, "cannot add components after entity has been added to world!")
	for _, c in pairs({...}) do
		assert(not self:has(c:type()), "cannot add multiple components with the same type! attempting to add a second " .. c:type() .. " component!")
		self.components[c:type()] = c
	end
end

-- returns whether this entity has ALL of the component types listed
function e:has(...)
	for _, type in pairs({...}) do
		if self.components[type] == nil then
			return false
		end
	end
	return true
end

function e:get(type)
	return self.components[type]
end

return e
