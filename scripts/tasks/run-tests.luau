--!strict
-- Adapted from Roblox/gear. See scripts/ROBLOX-GEAR-LICENSE.txt.

const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Jest = require(ReplicatedStorage.Packages.Jest)
const root = ReplicatedStorage.Src

const status, result = Jest.runCLI(root, {
	verbose = false,
	ci = false,
}, { root }):awaitStatus()

if status ~= "Resolved" then
	print(result)
	return false
end

return result.results.numFailedTestSuites == 0 and result.results.numFailedTests == 0
