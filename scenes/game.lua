local scene = require "scene"

local s = {}
s.__index = s
setmetatable(s, scene)

local Entity			= require "entity"
local EventsSystem		= require "systems.events"
local RenderSystem		= require "systems.renderer"
local TweenerSystem		= require "systems.tweener"
local EventComp			= require "components.event"
local ScriptComp		= require "components.script"
local PositionComp		= require "components.position"
local SpriteComp		= require "components.sprite"
local TableUtil			= require "util.table"

-- MARK: scene overrides

function s:init()
	self.entities		= {}
	self.systems		= {}
	self.systemsByType	= {}
	self.drawables		= {}
	self.updatables		= {}
	self.time			= 0
	
	self.removedEntities	= {}
	self.removedSystems		= {}
	
	-- add systems
	self:add(
		TweenerSystem:new(self),
		RenderSystem:new(self),
		EventsSystem:new(self)
	)
	
	-- add entities
	self:add(self:createCharacter())
	
	for _, sys in ipairs(self.systems) do
		sys:worldInitialized()
	end
end

function s:draw()
	for _, sys in ipairs(self.drawables) do
		sys:draw()
	end
end

function s:update(dt)
	self.time = self.time + dt
	for _, sys in ipairs(self.updatables) do
		sys:update(dt)
	end
	for _, sys in ipairs(self.removedSystems) do
		self.systemsByType[sys:type()] = nil
		TableUtil.remove(self.systems, sys)
	end
	for _, e in ipairs(self.removedEntities) do
		for _, sys in ipairs(self.systems) do
			sys:entityRemoved(e)
		end
	end
	self.removedSystems = {}
	self.removedEntities = {}
end

-- MARK: game scene methods

function s:add(...)
	for _, o in pairs({...}) do
		if o.isEntity then
			self:addEntity(o)
		elseif o.isSystem then
			self:addSystem(o)
		end
	end
	return ...
end

function s:remove(...)
	for _, o in pairs({...}) do
		if o.isEntity then
			self:removeEntity(o)
		elseif o.isSystem then
			self:removeSystem(o)
		end
	end
end

function s:addEntity(e)
	e.addedToWorld = true
	for _, sys in ipairs(self.systems) do
		sys:entityAdded(e)
	end
	return e
end

function s:removeEntity(e)
	table.insert(self.removedEntities, e)
end

function s:addSystem(sys)
	self.systemsByType[sys:type()] = sys
	table.insert(self.systems, sys)
	if sys.draw then
		table.insert(self.drawables, sys)
	end
	if sys.update then
		table.insert(self.updatables, sys)
	end
	return sys
end

function s:removeSystem(sys)
	table.insert(self.removedSystems, sys)
end

-- MARK: entity prefabs

function s:createCharacter()
	local char = Entity:new {
		PositionComp:new(100, 100),
		SpriteComp:new("character")
	}
	self:add(
		Entity:new {
			ScriptComp:new("animComplete" .. char.id, function(e)
				local sprite = e:get(SpriteComp:type())
				if sprite.anim == "appear" then
					sprite.anim = "idle"
				else
					sprite.anim = "walk"
				end
			end)
		}
	)
	return char
end

return s
