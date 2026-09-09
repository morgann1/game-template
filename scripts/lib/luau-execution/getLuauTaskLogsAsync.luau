--!strict
-- Adapted from Roblox/gear. See scripts/ROBLOX-GEAR-LICENSE.txt.

const fetchAsync = require("@scripts/lib/fetchAsync")
const json = require("@std/json")

type TaskLogsResponse = {
	read luauExecutionSessionTaskLogs: { { read messages: { string }? } }?,
	read nextPageToken: string?,
}

const function getLuauTaskLogsAsync(taskPath: string, apiKey: string): { string }
	const messages: { string } = {}
	local pageToken: string? = nil

	repeat
		local url = `https://apis.roblox.com/cloud/v2/{taskPath}/logs`
		if pageToken ~= nil then
			const encoded = string.gsub(pageToken, "[^%w%-_%.~]", function(character)
				return string.format("%%%02X", string.byte(character))
			end)
			url ..= `?pageToken={encoded}`
		end

		const response = fetchAsync(url, {
			headers = { ["x-api-key"] = apiKey },
		})
		const logs = json.deserialize(response.body) :: TaskLogsResponse
		for _, chunk in logs.luauExecutionSessionTaskLogs or {} do
			for _, message in chunk.messages or {} do
				table.insert(messages, message)
			end
		end
		pageToken = logs.nextPageToken
	until pageToken == nil or pageToken == ""

	return messages
end

return getLuauTaskLogsAsync
