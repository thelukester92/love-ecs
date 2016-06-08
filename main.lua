-- Copyright (C) 2016 Luke Godfrey
-- All Rights Reserved

local GameScene = require "scenes.game"

local g

function love.load()
	g = {
		frameRate	= 1.0 / 60.0,
		accumulator	= 0.0,
		scenes		= {
			game = GameScene:new()
		}
	}
	g.scene = g.scenes.game
end

function love.draw()
	g.scene:draw()
end

function love.update(dt)
	g.accumulator = g.accumulator + dt
	if g.accumulator > 10 * g.frameRate then
		g.accumulator = g.frameRate
	end
	while g.accumulator > g.frameRate do
		g.scene:update(g.frameRate)
		g.accumulator = g.accumulator - g.frameRate
	end
end
