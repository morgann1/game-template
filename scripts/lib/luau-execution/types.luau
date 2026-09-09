--!strict
-- Adapted from Roblox/gear. See scripts/ROBLOX-GEAR-LICENSE.txt.

const json = require("@std/json")

export type LuauTaskResponse = {
	read path: string,
	read state: "STATE_UNSPECIFIED" | "QUEUED" | "PROCESSING" | "CANCELLED" | "COMPLETE" | "FAILED",
	read output: {
		read results: { json.Value }?,
	}?,
	read error: json.Value,
}

const types = table.freeze({})

return types
