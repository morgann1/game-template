--!strict
-- Adapted from Roblox/gear. See scripts/ROBLOX-GEAR-LICENSE.txt.

const fs = require("@lute/fs")
const process = require("@lute/process")

const function dotenv(): ()
	if not fs.exists(".env") then
		return
	end

	const handle = fs.open(".env")
	const content = fs.read(handle)
	fs.close(handle)

	for line in string.gmatch(content, "[^\r\n]+") do
		const key, rawValue = string.match(line, "^%s*([%a_][%w_]*)%s*=%s*(.-)%s*$")
		if key == nil or rawValue == nil or process.env[key] ~= nil then
			continue
		end

		local value = rawValue
		const quote = string.sub(value, 1, 1)
		if quote == '"' or quote == "'" then
			if string.sub(value, -1) ~= quote then
				error(`Unclosed quote for {key} in .env`)
			end
			value = string.sub(value, 2, -2)
		else
			value = string.gsub(value, "%s+#.*$", "")
		end

		process.env[key] = value
	end
end

return dotenv
