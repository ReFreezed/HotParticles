for _, ps in ipairs(particleSystems) do
	Text "local ps = love.graphics.newParticleSystem("
	if ps.texturePath == "" then
		Text "?--[[Preset:"
		Text(ps.texturePreset)
		Text "]]"
	else
		Text "love.graphics.newImage("
		LuaCsv(ps.texturePath)
		Text ")"
	end
	Text ", " LuaCsv(ps.bufferSize) Text ")\n"

	Text "ps:setColors("                 LuaCsv(ps.colors)                 Text ")\n"
	Text "ps:setDirection("              LuaCsv(ps.direction)              Text ")\n"
	Text "ps:setEmissionArea("           LuaCsv(ps.emissionArea)           Text ")\n"
	Text "ps:setEmissionRate("           LuaCsv(ps.emissionRate)           Text ")\n"
	Text "ps:setEmitterLifetime("        LuaCsv(ps.emitterLifetime)        Text ")\n"
	Text "ps:setInsertMode("             LuaCsv(ps.insertMode)             Text ")\n"
	Text "ps:setLinearAcceleration("     LuaCsv(ps.linearAcceleration)     Text ")\n"
	Text "ps:setLinearDamping("          LuaCsv(ps.linearDamping)          Text ")\n"
	Text "ps:setOffset("                 LuaCsv(ps.offset)                 Text ")\n"
	Text "ps:setParticleLifetime("       LuaCsv(ps.particleLifetime)       Text ")\n"
	Text "ps:setRadialAcceleration("     LuaCsv(ps.radialAcceleration)     Text ")\n"
	Text "ps:setRelativeRotation("       LuaCsv(ps.relativeRotation)       Text ")\n"
	Text "ps:setRotation("               LuaCsv(ps.rotation)               Text ")\n"
	Text "ps:setSizes("                  LuaCsv(ps.sizes)                  Text ")\n"
	Text "ps:setSizeVariation("          LuaCsv(ps.sizeVariation)          Text ")\n"
	Text "ps:setSpeed("                  LuaCsv(ps.speed)                  Text ")\n"
	Text "ps:setSpin("                   LuaCsv(ps.spin)                   Text ")\n"
	Text "ps:setSpinVariation("          LuaCsv(ps.spinVariation)          Text ")\n"
	Text "ps:setSpread("                 LuaCsv(ps.spread)                 Text ")\n"
	Text "ps:setTangentialAcceleration(" LuaCsv(ps.tangentialAcceleration) Text ")\n"

	if ps.quads[1] then
		Text "ps:setQuads("
		for i, quad in ipairs(ps.quads) do
			if i > 1 then Text ", " end
			Text "love.graphics.newQuad(" LuaCsv(quad) Text ")"
		end
		Text ")\n"
	end

	Text "-- love.graphics.setBlendMode(" LuaCsv(ps.blendMode) Text ")\n"
end
