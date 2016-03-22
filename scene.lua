local scene = {}
scene.__index = scene

function scene:new()
	local o = {}
	setmetatable(o, self)
	o:init()
	return o
end

function scene:init()
end

function scene:draw()
end

function scene:update(dt)
end

return scene
