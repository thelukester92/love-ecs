local comp = require "component"

local c = {}
c.__index = c
setmetatable(c, comp)

--	arg: string|object		if string, the name of the texture used to load a .png and .lua file representing the texture
--							if love.Image, uses { image = object } as the non-animated texture
--							if table, uses it directly as a texture (animated or non-animated)
--	args: table|nil			if table, uses the following table values to initialize properties
--		zIndex: number			defaults to 0
--		opacity: number			defaults to 255
--		anchorX: number			defaults to 0
--		anchorY: number			defaults to 0
--		scaleX: number			defaults to 1
--		scaleY: number			defaults to scaleX
--		delay: number			defaults to 5

function c:init(arg, args)
	args				= args or {}
	self.arg			= arg
	self.zIndex			= args.zIndex or 0
	self.opacity		= args.opacity or 255
	self.anchorX		= args.anchorX or 0
	self.anchorY		= args.anchorY or 0
	self.scaleX			= args.scaleX or 1
	self.scaleY			= args.scaleY or self.scaleX
	
	-- for animatable sprites only
	self.frameIdx		= 1
	self.delayDef		= args.delay or 5
	self.delay			= self.delayDef
	
	-- for transformable sprites only
	self.meshVertices	= nil
	self.texVertices	= nil
	self.mesh			= nil
	
	-- to be initialized by the renderer
	self.texture		= nil
	self.anim			= nil
	self.prevAnim		= nil
	self.width			= 0
	self.height			= 0
	self.halfWidth		= 0
	self.halfHeight		= 0
end

function c:type()
	return "sprite"
end

return c
