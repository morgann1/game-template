--!strict
-- Adapted from Roblox/gear. See scripts/ROBLOX-GEAR-LICENSE.txt.

const fs = require("@lute/fs")
const process = require("@lute/process")
const project = require("@root/project")
const dotenv = require("@scripts/lib/dotenv")
const executeLuauTaskAsync = require("@scripts/lib/luau-execution/executeLuauTaskAsync")
const testingPlace = require("@scripts/lib/testingPlace")

const placePath = "tests.rbxl"
const args: { string } = { ... }
local ownsPlace = false

const function testAsync(): boolean
	local argumentKey: string? = nil
	-- Lute includes the script path as the first argument.
	local index = 2

	while index <= #args do
		const argument = args[index]
		if argument == "--help" or argument == "-h" then
			print("Usage: lute scripts/test.luau [--apiKey KEY | -k KEY]")
			print(
				"Set ROBLOX_API_KEY, ROBLOX_UNIT_TESTING_UNIVERSE_ID, and ROBLOX_UNIT_TESTING_PLACE_ID in the environment or .env."
			)
			print("Uploads a saved version to the configured test place and runs Jest through Open Cloud.")
			return true
		elseif argument == "--apiKey" or argument == "-k" then
			index += 1
			argumentKey = args[index]
			if argumentKey == nil or argumentKey == "" or string.sub(argumentKey, 1, 1) == "-" then
				error("--apiKey requires a value")
			end
		elseif string.sub(argument, 1, 9) == "--apiKey=" then
			argumentKey = string.sub(argument, 10)
		else
			error("Unknown argument. Run with --help for usage.")
		end
		index += 1
	end

	dotenv()

	const environmentKey = process.env.ROBLOX_API_KEY
	const apiKey = if environmentKey ~= nil and environmentKey ~= "" then environmentKey else argumentKey
	if apiKey == nil or apiKey == "" then
		error("Supply an Open Cloud API key with --apiKey or ROBLOX_API_KEY.")
	end

	const universeId = testingPlace.universeId()
	const placeId = testingPlace.placeId()

	if fs.exists(placePath) then
		error("tests.rbxl already exists. Move or remove it before running tests.")
	end

	ownsPlace = true
	print(`Building {project.TESTS_PROJECT_PATH}`)
	const build = process.run({ "rojo", "build", project.TESTS_PROJECT_PATH, "--output", placePath }, {
		stdio = "inherit",
	})
	if not build.ok then
		error("Failed to build the test place.")
	end

	const handle = fs.open("scripts/tasks/run-tests.luau")
	const scriptContent = fs.read(handle)
	fs.close(handle)

	const results = executeLuauTaskAsync(placePath, scriptContent, universeId, placeId, apiKey)
	return results[1] == true
end

const ok, result = pcall(testAsync)

if ownsPlace and fs.exists(placePath) then
	fs.remove(placePath)
end

if not ok then
	print(result)
end

process.exit(if ok and result == true then 0 else 1)
