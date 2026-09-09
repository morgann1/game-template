--!strict
-- Adapted from Roblox/gear. See scripts/ROBLOX-GEAR-LICENSE.txt.

const process = require("@lute/process")

const function requireId(name: string): string
	const value = process.env[name]
	if value == nil or string.match(value, "^%d+$") == nil or string.match(value, "[1-9]") == nil then
		error(`{name} must be a positive numeric ID in the environment or .env`)
	end
	return value
end

const function universeId(): string
	return requireId("ROBLOX_UNIT_TESTING_UNIVERSE_ID")
end

const function placeId(): string
	return requireId("ROBLOX_UNIT_TESTING_PLACE_ID")
end

const testingPlace = table.freeze({
	universeId = universeId,
	placeId = placeId,
})

return testingPlace
