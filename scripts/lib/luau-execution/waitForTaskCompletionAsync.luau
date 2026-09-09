--!strict
-- Adapted from Roblox/gear. See scripts/ROBLOX-GEAR-LICENSE.txt.

const task = require("@lute/task")
const time = require("@lute/time")
const fetchAsync = require("@scripts/lib/fetchAsync")
const json = require("@std/json")
const types = require("./types")

const POLL_INTERVAL_SECONDS = 2
const RETRY_DELAY_SECONDS = 5
const MAX_CONSECUTIVE_FAILURES = 5
const TIMEOUT_SECONDS = 600

const function waitForTaskCompletionAsync(taskPath: string, apiKey: string): types.LuauTaskResponse
	const url = `https://apis.roblox.com/cloud/v2/{taskPath}`
	const started = time.now()
	local consecutiveFailures = 0

	while time.since(started) < TIMEOUT_SECONDS do
		const ok, response = pcall(function()
			return fetchAsync(url, {
				headers = { ["x-api-key"] = apiKey },
			})
		end)

		if not ok then
			consecutiveFailures += 1
			if consecutiveFailures >= MAX_CONSECUTIVE_FAILURES then
				error(`Polling failed {consecutiveFailures} times: {tostring(response)}`)
			end

			print(`Polling failed, retrying in {RETRY_DELAY_SECONDS}s: {tostring(response)}`)
			task.wait(RETRY_DELAY_SECONDS)
			continue
		end

		consecutiveFailures = 0
		const luauTask = json.deserialize(response.body) :: types.LuauTaskResponse
		if luauTask.state ~= "QUEUED" and luauTask.state ~= "PROCESSING" then
			return luauTask
		end

		task.wait(POLL_INTERVAL_SECONDS)
	end

	error(`Timed out waiting for {taskPath} after {TIMEOUT_SECONDS}s`)
end

return waitForTaskCompletionAsync
