Text [=[
--[[
module = {
	x=emitterPositionX, y=emitterPositionY,
	[1] = {
		system=particleSystem1,
		kickStartSteps=steps1, kickStartDt=dt1, emitAtStart=count1,
		blendMode=blendMode1, shader=shader1,
		texturePreset=preset1, texturePath=path1,
		shaderPath=path1, shaderFilename=filename1,
		x=emitterOffsetX, y=emitterOffsetY
	},
	[2] = {
		system=particleSystem2,
		...
	},
	...
}
]]
]=]

Text"local LG        = love.graphics\n"
Text"local particles = {x=" Lua(exported.emitterPosition.x) Text", y=" Lua(exported.emitterPosition.y) Text"}\n"
Text"\n"

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
			Text"local " Text(imageIdent) Text" = LG.newImage(" Lua(ps.texturePath) Text")\n"
		end

		if exported.pixelateTextures then
			Text(imageIdent) Text":setFilter(\"nearest\", \"nearest\")\n"
		else
			Text(imageIdent) Text":setFilter(\"linear\", \"linear\")\n"
		end
	end

	imageIdentBySystem[ps] = imageIdent
end

-- Define shaders. Some may be shared between multiple particle systems.
local shaderIdentBySystem   = {}
local shaderIdentByPath     = {}
local shaderIdentByFilename = {}
local shaderN               = 0

for _, ps in ipairs(exported.particleSystems) do
	if ps.shaderFilename ~= "" then
		local shaderIdentByKey = ps.shaderPath ~= "" and shaderIdentByPath or shaderIdentByFilename
		local key              = ps.shaderPath ~= "" and ps.shaderPath     or ps.shaderFilename
		local shaderIdent      = shaderIdentByKey[key]

		if not shaderIdent then
			shaderN               = shaderN + 1
			shaderIdent           = "shader" .. shaderN
			shaderIdentByKey[key] = shaderIdent

			if shaderN == 1 then  Text"\n"  end

			if ps.shaderPath == "" then
				Text"local " Text(shaderIdent) Text" = ? -- Filename: " Text(ps.shaderFilename) Text"\n"
			else
				Text"local " Text(shaderIdent) Text" = LG.newShader(" Lua(ps.shaderPath) Text")\n"
			end
		end

		shaderIdentBySystem[ps] = shaderIdent

	else
		shaderIdentBySystem[ps] = "nil"
	end
end

-- Define particle systems.
for _, ps in ipairs(exported.particleSystems) do
	Text"\n"
	Text"local ps = LG.newParticleSystem(" Text(imageIdentBySystem[ps]) Text", " Lua(ps.bufferSize) Text")\n"

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
			Text"LG.newQuad(" LuaCsv(quad) Text")"
		end
		Text")\n"
	end

	Text"table.insert(particles, {system=ps"
	Text", kickStartSteps=" Lua(ps.kickStartSteps)
	Text", kickStartDt="    Lua(ps.kickStartDt)
	Text", emitAtStart="    Lua(ps.emitAtStart)
	Text", blendMode="      Lua(ps.blendMode)
	Text", shader="         Text(shaderIdentBySystem[ps])
	Text", texturePath="    Lua(ps.texturePath)
	Text", texturePreset="  Lua(ps.texturePreset)
	Text", shaderPath="     Lua(ps.shaderPath)
	Text", shaderFilename=" Lua(ps.shaderFilename)
	Text", x="              Lua(ps.emitterOffset.x)
	Text", y="              Lua(ps.emitterOffset.y)
	Text"})\n"
end

Text"\n"
Text"return particles\n"
