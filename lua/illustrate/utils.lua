local M = {}
local Config = require("illustrate.config")
vim.notify = require("notify")

function M.get_os()
	local fh, _ = assert(io.popen("uname -o 2>/dev/null","r"))
    local osname
	if fh then
		osname = fh:read()
	end

	return osname or "Windows"
end

local function execute(command)
    local handle = io.popen(command .. " 2>&1")
    local result = handle:read("*a")
    handle:close()

    if result ~= "" then
        vim.notify("Error: " .. result, "error")
    end
end

function M.open(filename)
    local os_name = M.get_os()
    local default_app = Config.options.default_app.svg

    if default_app == 'inkscape' then
        execute("inkscape " .. filename)
    elseif default_app == 'illustrator' and os_name == 'Darwin' then
        execute("open -a 'Adobe Illustrator' " .. filename)
    end
end

return M
