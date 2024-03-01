local M = {}
local Config = require("illustrate.config")

function M.get_os()
	local fh, _ = assert(io.popen("uname -o 2>/dev/null","r"))
    local osname
	if fh then
		osname = fh:read()
	end

	return osname or "Windows"
end


function M.open(filename)
    local os_name = M.get_os()
    local default_app = Config.options.default_app.svg
    if default_app == 'inkscape' then
        os.execute("inkscape " .. filename .. " >/dev/null 2>&1 &")
    elseif default_app == 'illustrator' and os_name == 'Darwin' then
        os.execute("open -a 'Adobe Illustrator' " .. filename)
    end
end

return M
