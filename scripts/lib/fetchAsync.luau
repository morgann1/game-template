--!strict
-- Adapted from Roblox/gear. See scripts/ROBLOX-GEAR-LICENSE.txt.

const net = require("@lute/net")

type Options = {
	read method: string?,
	read headers: { [string]: string }?,
	read body: string?,
}

type Response = {
	body: string,
	headers: { [string]: string },
	status: number,
	ok: boolean,
}

const function fetchAsync(url: string, options: Options): Response
	const method = options.method or "GET"
	const response = net.client.request(url, {
		method = method,
		headers = options.headers,
		body = options.body,
	})

	if not response.ok then
		error(`{method} {url} failed with HTTP {response.status}: {response.body}`, 2)
	end

	return response
end

return fetchAsync
