-- Events System
-- consumes entities with event components immediately
-- consumes entities with script components with callOnce = true when it is fired

local sys = require "system"

local s = {}
s.__index = s
setmetatable(s, sys)

local ScriptComp	= require "components.script"
local EventComp		= require "components.event"

-- MARK: system overrides

function s:init()
	self.handlers		= {}
	self.queue			= {}
	self.scriptEntities	= {}
end

function s:type()
	return "events"
end

function s:accepts(e)
	return (e:has(ScriptComp:type()) or e:has(EventComp:type())) and not e:has(ScriptComp:type(), EventComp:type())
end

function s:acceptedEntityAdded(e)
	local script = e:get(ScriptComp:type())
	local event = e:get(EventComp:type())
	
	-- process the entity
	if script then
		self.handlers[script.event] = self.handlers[script.event] or {}
		self.handlers[script.event][e.id] = { call = script.handler, callOnce = script.callOnce, entity = e }
		table.insert(self.scriptEntities, e)
	end
	if event then
		table.insert(self.queue, event)
		self.world:remove(e)
	end
end

function s:acceptedEntityRemoved(e)
	local script = e:get(ScriptComp:type())
	if script then
		self.handlers[script.event][e.id] = nil
	end
end

function s:update(dt)
	for _, event in pairs(self.queue) do
		if self.handlers[event.name] then
			for _, h in pairs(self.handlers[event.name]) do
				h.call(unpack(event.args))
				if h.callOnce then
					self.world:remove(h.entity)
				end
			end
		end
	end
	self.queue = {}
end

return s
