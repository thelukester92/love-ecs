-- Tweener System
-- Consumes entities with tween components on tween complete

local sys = require "system"

local s = {}
s.__index = s
setmetatable(s, sys)

local Entity	= require "entity"
local Tween		= require "dependencies.tween"
local EventComp	= require "components.event"
local TweenComp	= require "components.tween"

-- MARK: system overrides

function s:accepts(e)
	return e:has(TweenComp:type())
end

function s:type()
	return "tweener"
end

function s:acceptedEntityAdded(e)
	local tween = e:get(TweenComp:type())
	tween.tween = Tween.new(tween.time, tween.object, tween.targetProps, tween.easing)
end

function s:update(dt)
	for i, e in ipairs(self.entities) do
		local tween = e:get(TweenComp:type())
		if tween.delay > 0 then
			tween.delay = tween.delay - dt
		end
		if tween.delay <= 0 and tween.tween:update(dt) then
			self.world:add(Entity:new {
				EventComp:new("tweenComplete" .. e.id, e)
			})
			self.world:remove(e)
		end
	end
end

return s
