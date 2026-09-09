--!strict
-- Adapted from Roblox/gear. See scripts/ROBLOX-GEAR-LICENSE.txt.

const json = require("@std/json")
const createLuauTaskAsync = require("./createLuauTaskAsync")
const getLuauTaskLogsAsync = require("./getLuauTaskLogsAsync")
const publishPlaceAsync = require("./publishPlaceAsync")
const waitForTaskCompletionAsync = require("./waitForTaskCompletionAsync")

const function executeLuauTaskAsync(
	placePath: string,
	scriptContent: string,
	universeId: string,
	placeId: string,
	apiKey: string
): { json.Value }
	const placeVersion = publishPlaceAsync(placePath, universeId, placeId, apiKey)
	print(`Starting Luau task against place version {placeVersion}`)
	const created = createLuauTaskAsync(scriptContent, universeId, placeId, apiKey, placeVersion)
	print(`Task created: {created.path}`)

	const completed = waitForTaskCompletionAsync(created.path, apiKey)
	print(`Task is now in {completed.state} state`)

	const ok, logs = pcall(getLuauTaskLogsAsync, created.path, apiKey)
	if ok then
		for _, message in logs do
			print(message)
		end
	else
		print(`Could not retrieve task logs: {tostring(logs)}`)
	end

	if completed.state == "COMPLETE" and completed.output ~= nil then
		return completed.output.results or {}
	end

	print(`Task failed: {json.serialize(completed.error)}`)
	return {}
end

return executeLuauTaskAsync
