local sys = require "system"

local s = {}
s.__index = s
setmetatable(s, sys)

local Entity			= require "entity"
local PositionComp		= require "components.position"
local SpriteComp		= require "components.sprite"
local EventComp			= require "components.event"
local TableUtil			= require "util.table"

-- MARK: system overrides

function s:init()
	self.textureCache	= {}
	self.animatables	= {}	-- list of drawables with multiple frames
	self.drawables		= {}	-- list of drawables, sorted by zIndex
end

function s:type()
	return "renderer"
end

function s:accepts(e)
	return e:has(PositionComp:type(), SpriteComp:type())
end

function s:acceptedEntityAdded(e)
	local sprite	= e:get(SpriteComp:type())
	local arg		= sprite.arg
	sprite.arg		= nil
	sprite.name		= type(arg) == "string" and arg or nil
	sprite.texture	= type(arg) ~= "string" and (arg.image ~= nil and arg or { image = arg }) or nil
	
	-- get sprite texture
	if not sprite.texture then
		sprite.texture = self:loadTexture(sprite.name)
	end
	
	-- get sprite anims
	if sprite.texture.anims then
		sprite.delayDef	= sprite.texture.delay or sprite.delayDef
		sprite.anim		= sprite.texture.anim
		sprite.prevAnim	= nil
		sprite.frame	= sprite.texture.frames[sprite.texture.anims[sprite.anim][sprite.frameIdx]]
		table.insert(self.animatables, e)
	end
	
	-- get sprite size
	if sprite.frame then
		_, _, sprite.width, sprite.height = sprite.frame:getViewport()
	else
		sprite.width, sprite.height = sprite.texture.image:getDimensions()
	end
	sprite.halfWidth, sprite.halfHeight = math.floor(sprite.width / 2), math.floor(sprite.height / 2)
	
	-- add sprite to drawables
	TableUtil.insertSorted(self.drawables, e, function(a, b) return a:get(SpriteComp:type()).zIndex > b:get(SpriteComp:type()).zIndex end)
end

function s:acceptedEntityRemoved(e)
	TableUtil.remove(self.animatables, e)
	TableUtil.remove(self.drawables, e)
end

function s:draw()
	for _, e in ipairs(self.drawables) do
		local position	= e:get(PositionComp:type())
		local sprite	= e:get(SpriteComp:type())
		local args		= { sprite.texture.image, 0, 0 }
		
		if sprite.frame then
			table.insert(args, 2, sprite.frame)
		end
		
		local x, y = position.x, position.y
		if sprite.scaleX == -1 then
			x = x + sprite.width
		end
		x, y = math.floor(x), math.floor(y)
		
		love.graphics.push()
		love.graphics.setColor(255, 255, 255, sprite.opacity)
		
		love.graphics.translate(x, y)
		love.graphics.scale(sprite.scaleX, sprite.scaleY)
		
		love.graphics.draw(unpack(args))
		love.graphics.pop()
	end
end

function s:update(dt)
	for _, e in ipairs(self.animatables) do
		self:updateFrame(e)
	end
end

-- MARK: renderer methods

function s:loadTexture(name)
	if self.textureCache[name] == nil then
		local texture = { image = love.graphics.newImage("resources/" .. name .. ".png") }
		texture.image:setFilter("nearest")
		
		-- if the following pcall fails, no metadata exists for this texture
		-- and the entire image is used rather than treating it as a spritesheet
		
		pcall(function()
			local meta = love.filesystem.load("resources/" .. name .. ".lua")()
			local w, h = texture.image:getDimensions()
			
			texture.delay = meta.delay
			texture.frames = {}
			
			if meta.frames then
				for _, rect in pairs(meta.frames) do
					table.insert(texture.frames, love.graphics.newQuad(rect.x, rect.y, rect.w, rect.h, w, h))
				end
			elseif meta.tileWidth and meta.tileHeight then
				local padding = meta.padding or 0
				local tHeight = meta.tileHeight + padding
				local tWidth = meta.tileWidth + padding
				
				local rows = h / tHeight
				local cols = w / tWidth
				for i = 1, rows do
					for j = 1, cols do
						local r, c = i - 1, j - 1
						table.insert(texture.frames, love.graphics.newQuad(c * tWidth, r * tHeight, meta.tileWidth, meta.tileHeight, w, h))
					end
				end
			end
			
			texture.anims = meta.anims
			texture.anim = meta.anim
			
			-- find the first anim
			if not texture.anim and texture.anims then
				for k, v in pairs(texture.anims) do
					texture.anim = k
					break
				end
			end
		end)
		
		self.textureCache[name] = texture
	end
	return self.textureCache[name]
end

function s:updateFrame(e)
	local sprite = e:get(SpriteComp:type())
	
	if sprite.anim ~= sprite.prevAnim then
		sprite.delay	= sprite.delayDef
		sprite.frameIdx	= 1
		sprite.scaleX	= sprite.texture.anims[sprite.anim].scaleX or 1
	end
	
	sprite.delay = sprite.delay - 1
	if sprite.delay <= 0 then
		sprite.delay = sprite.delayDef
		sprite.frameIdx = sprite.frameIdx + 1
		if sprite.frameIdx > #sprite.texture.anims[sprite.anim] then
			if sprite.texture.anims[sprite.anim].loops then
				sprite.frameIdx = 1
			else
				sprite.frameIdx = sprite.frameIdx - 1
			end
			self.world:add(Entity:new { EventComp:new("animComplete" .. e.id, e) })
		end
	end
	sprite.prevAnim = sprite.anim
	sprite.frame = sprite.texture.frames[sprite.texture.anims[sprite.anim][sprite.frameIdx]]
end

return s
