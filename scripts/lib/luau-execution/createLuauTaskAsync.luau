--!strict
-- Adapted from Roblox/gear. See scripts/ROBLOX-GEAR-LICENSE.txt.

const fetchAsync = require("@scripts/lib/fetchAsync")
const json = require("@std/json")
const types = require("./types")

const function createLuauTaskAsync(
	scriptContent: string,
	universeId: string,
	placeId: string,
	apiKey: string,
	placeVersion: number
): types.LuauTaskResponse
	-- Pin the uploaded version so concurrent runs cannot test each other's place.
	const response = fetchAsync(
		`https://apis.roblox.com/cloud/v2/universes/{universeId}/places/{placeId}/versions/{placeVersion}/luau-execution-session-tasks`,
		{
			method = "POST",
			headers = {
				["Content-Type"] = "application/json",
				["x-api-key"] = apiKey,
			},
			body = json.serialize({ script = scriptContent }),
		}
	)

	return json.deserialize(response.body) :: types.LuauTaskResponse
end

return createLuauTaskAsync
