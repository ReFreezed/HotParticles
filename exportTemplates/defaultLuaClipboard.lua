-- Define images. Some may be shared between multiple particle systems.
local imageIdentBySystem        = {}
local imageIdentByTexturePath   = {}
local imageIdentByTexturePreset = {}
local imageN                    = 0

for _, ps in ipairs(exported.particleSystems) do
	local imageIdentByKey = ps.texturePath ~= "" and imageIdentByTexturePath or imageIdentByTexturePreset
	local key             = ps.texturePath ~= "" and ps.texturePath          or ps.texturePreset
	local imageIdent      = imageIdentByKey[key]

	if not imageIdent then
		imageN               = imageN + 1
		imageIdent           = "image" .. imageN
		imageIdentByKey[key] = imageIdent

		if ps.texturePath == "" then
			Text"local " Text(imageIdent) Text" = ? -- Preset: " Text(ps.texturePreset) Text"\n"
		else
			Text"local " Text(imageIdent) Text" = love.graphics.newImage(" Lua(ps.texturePath) Text")\n"
		end

		if exported.pixelateTextures then
			Text(imageIdent) Text":setFilter(\"nearest\", \"nearest\")\n"
		else
			Text(imageIdent) Text":setFilter(\"linear\", \"linear\")\n"
		end
	end

	imageIdentBySystem[ps] = imageIdent
end

-- Define particle systems.
for _, ps in ipairs(exported.particleSystems) do
	Text"\n"
	Text"local ps = love.graphics.newParticleSystem(" Text(imageIdentBySystem[ps]) Text", " Lua(ps.bufferSize) Text")\n"

	Text"ps:setColors("                 LuaCsv(ps.colors)                 Text")\n"
	Text"ps:setDirection("              LuaCsv(ps.direction)              Text")\n"
	Text"ps:setEmissionArea("           LuaCsv(ps.emissionArea)           Text")\n"
	Text"ps:setEmissionRate("           LuaCsv(ps.emissionRate)           Text")\n"
	Text"ps:setEmitterLifetime("        LuaCsv(ps.emitterLifetime)        Text")\n"
	Text"ps:setInsertMode("             LuaCsv(ps.insertMode)             Text")\n"
	Text"ps:setLinearAcceleration("     LuaCsv(ps.linearAcceleration)     Text")\n"
	Text"ps:setLinearDamping("          LuaCsv(ps.linearDamping)          Text")\n"
	Text"ps:setOffset("                 LuaCsv(ps.textureOffset)          Text")\n"
	Text"ps:setParticleLifetime("       LuaCsv(ps.particleLifetime)       Text")\n"
	Text"ps:setRadialAcceleration("     LuaCsv(ps.radialAcceleration)     Text")\n"
	Text"ps:setRelativeRotation("       LuaCsv(ps.relativeRotation)       Text")\n"
	Text"ps:setRotation("               LuaCsv(ps.rotation)               Text")\n"
	Text"ps:setSizes("                  LuaCsv(ps.sizes)                  Text")\n"
	Text"ps:setSizeVariation("          LuaCsv(ps.sizeVariation)          Text")\n"
	Text"ps:setSpeed("                  LuaCsv(ps.speed)                  Text")\n"
	Text"ps:setSpin("                   LuaCsv(ps.spin)                   Text")\n"
	Text"ps:setSpinVariation("          LuaCsv(ps.spinVariation)          Text")\n"
	Text"ps:setSpread("                 LuaCsv(ps.spread)                 Text")\n"
	Text"ps:setTangentialAcceleration(" LuaCsv(ps.tangentialAcceleration) Text")\n"

	if ps.quads[1] then
		Text"ps:setQuads("
		for i, quad in ipairs(ps.quads) do
			if i > 1 then Text", " end
			Text"love.graphics.newQuad(" LuaCsv(quad) Text")"
		end
		Text")\n"
	end

	if ps.kickStartSteps > 0 or ps.emitAtStart > 0 then
		Text"-- At start time:\n"
		Text"-- ps:start()\n"
		if ps.kickStartSteps > 0 then
			Text"-- for step = 1, " Lua(ps.kickStartSteps) Text"  ps:update(" Lua(ps.kickStartDt) Text")  end\n"
		end
		if ps.emitAtStart > 0 then
			Text"-- ps:emit(" Lua(ps.emitAtStart) Text")\n"
		end
	end

	Text"-- At draw time:\n"
	if ps.shaderFilename ~= "" then
		Text"-- love.graphics.setShader(?) -- " Text(ps.shaderPath ~= "" and ps.shaderPath or ps.shaderFilename) Text"\n"
	end
	Text"-- love.graphics.setBlendMode(" Lua(ps.blendMode) Text")\n"
	Text"-- love.graphics.draw(ps, "
	Lua(exported.emitterPosition.x) Text(ps.emitterOffset.x >= 0 and "+" or "") Lua(ps.emitterOffset.x) Text", "
	Lua(exported.emitterPosition.y) Text(ps.emitterOffset.y >= 0 and "+" or "") Lua(ps.emitterOffset.y)
	Text")\n"
end
