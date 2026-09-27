--!strict

const fs = require("@lute/fs")
const net = require("@lute/net")
const process = require("@lute/process")
const json = require("@std/json")

const PROJECT_PATH = "default.project.json"
const WALLY_PATH = "wally.toml"
const WALLY_LOCK_PATH = "wally.lock"

-- `wally login` stores a GitHub token under the API URL of the registry's index.
const WALLY_API = "https://api.wally.run/"

const USAGE = "Usage: lute scripts/rename.luau <name> [username]"

const function readFile(path: string): string
	const handle = fs.open(path)
	const contents = fs.read(handle)
	fs.close(handle)

	return contents
end

const function writeFile(path: string, contents: string)
	const handle = fs.open(path, "w")
	fs.write(handle, contents)
	fs.close(handle)
end

-- Wally scopes and names allow lowercase letters, digits and "-", up to 64 characters.
const function isWallyIdentifier(value: string): boolean
	return #value <= 64 and string.match(value, "^[a-z0-9-]+$") ~= nil
end

-- Returns the GitHub login of the account `wally login` authenticated, lowercased
-- to fit Wally's scope rules.
const function getWallyUsernameAsync(): string
	const authPath = `{process.homedir()}/.wally/auth.toml`
	const auth = if fs.exists(authPath) then readFile(authPath) else ""

	const _, keyEnd = string.find(auth, `"{WALLY_API}"`, 1, true)
	const token = if keyEnd ~= nil then string.match(auth, '^%s*=%s*"([^"]+)"', keyEnd + 1) else nil
	if token == nil then
		error("Wally is not logged in. Run `wally login` or pass a username.", 0)
	end

	const response = net.client.request("https://api.github.com/user", {
		headers = {
			["Accept"] = "application/vnd.github+json",
			["Authorization"] = `Bearer {token}`,
			["User-Agent"] = "game-template-rename",
		},
	})

	if not response.ok then
		error(`GitHub rejected the Wally token with HTTP {response.status}. Run \`wally login\` again.`, 0)
	end

	const user = json.deserialize(response.body) :: { login: string }
	return string.lower(user.login)
end

-- Returns `contents` with the one match of `pattern` replaced. The pattern captures
-- everything before the old value, and the old value must end at a double quote.
const function replaceQuotedValue(path: string, contents: string, pattern: string, value: string): string
	const updated, count = string.gsub(contents, pattern, `%1{value}"`)
	if count ~= 1 then
		error(`Expected one name in {path}, found {count}.`, 0)
	end

	return updated
end

const args: { string } = { ... }
-- Lute includes the script path as the first argument.
const name = args[2]
const argumentUsername = args[3]

if name == nil or name == "--help" or name == "-h" or #args > 3 then
	print(USAGE)
	print("Sets the Rojo project name to <name> and the Wally package to <username>/<name>.")
	print("Without a username, uses the GitHub account Wally is logged in as.")
	process.exit(if name == "--help" or name == "-h" then 0 else 1)
end

const ok, message = pcall(function()
	if not isWallyIdentifier(name) then
		error("The name can only contain lowercase letters, digits and '-', up to 64 characters.", 0)
	end

	const username = if argumentUsername ~= nil then argumentUsername else getWallyUsernameAsync()
	if not isWallyIdentifier(username) then
		error("The username can only contain lowercase letters, digits and '-', up to 64 characters.", 0)
	end

	const packageName = `{username}/{name}`

	-- Build every file before writing any, so a failure leaves the project untouched.
	const project = readFile(PROJECT_PATH)
	const wally = readFile(WALLY_PATH)
	const wallyLock = readFile(WALLY_LOCK_PATH)

	const oldPackageName = string.match(wally, '\nname%s*=%s*"([^"]*)"')
	if oldPackageName == nil then
		error(`Could not find the package name in {WALLY_PATH}.`, 0)
	end

	const updatedProject = replaceQuotedValue(PROJECT_PATH, project, '("name"%s*:%s*")[^"]*"', name)
	const updatedWally = replaceQuotedValue(WALLY_PATH, wally, '(\nname%s*=%s*")[^"]*"', packageName)

	-- Every package in the lockfile has a name line, so match the root package's exact old name.
	const lockStart, lockEnd = string.find(wallyLock, `name = "{oldPackageName}"`, 1, true)
	if lockStart == nil or lockEnd == nil then
		error(`Could not find {oldPackageName} in {WALLY_LOCK_PATH}.`, 0)
	end

	const updatedWallyLock = string.sub(wallyLock, 1, lockStart - 1)
		.. `name = "{packageName}"`
		.. string.sub(wallyLock, lockEnd + 1)

	writeFile(PROJECT_PATH, updatedProject)
	writeFile(WALLY_PATH, updatedWally)
	writeFile(WALLY_LOCK_PATH, updatedWallyLock)

	print(`Renamed the Rojo project to {name} and the Wally package to {packageName}.`)
end)

if not ok then
	print(message)
	process.exit(1)
end
