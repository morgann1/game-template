--!strict
-- Adapted from Roblox/gear. See scripts/ROBLOX-GEAR-LICENSE.txt.

const fs = require("@lute/fs")
const fetchAsync = require("@scripts/lib/fetchAsync")
const json = require("@std/json")

const function publishPlaceAsync(placePath: string, universeId: string, placeId: string, apiKey: string): number
	print(`Uploading a saved version to test place {placeId} in universe {universeId}`)

	const handle = fs.open(placePath)
	const content = fs.read(handle)
	fs.close(handle)

	const response =
		fetchAsync(`https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType=Saved`, {
			method = "POST",
			body = content,
			headers = {
				["x-api-key"] = apiKey,
				["Content-Type"] = "application/octet-stream",
				["Accept"] = "application/json",
			},
		})

	const body = json.deserialize(response.body) :: { versionNumber: number }
	if body.versionNumber == nil or body.versionNumber <= 0 then
		error("The place upload did not return a valid version number.")
	end
	return body.versionNumber
end

return publishPlaceAsync
