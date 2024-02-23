local M = {}
local Config = require("illustrate.config")

local function get_os()
	local fh, _ = assert(io.popen("uname -o 2>/dev/null","r"))
    local osname
	if fh then
		osname = fh:read()
	end

	return osname or "Windows"
end

function M.setup(options)
    require("illustrate.config").setup(options)
end

local function copy_template(template_path, destination_path)
    local ok, _, code = os.execute("cp " .. template_path .. " " .. destination_path)
end

local function insert_include_code(filename)
    local filetype = vim.bo.filetype
    local extension = filename:match("^.+%.(%w+)$")

    local insert_code = ""
    if filetype == "tex" and extension == "svg" then
        insert_code = Config.options.text_templates.svg.tex:gsub("$FILE_PATH", filename)
    elseif filetype == "tex" and extension == "ai" then
        insert_code = Config.options.text_templates.ai.tex:gsub("$FILE_PATH", filename)
    elseif filetype == "md" and extension == "svg" then
        insert_code = Config.options.text_templates.svg.md:gsub("$FILE_PATH", filename)
    elseif filetype == "md" and extension == "ai" then
        insert_code = Config.options.text_templates.ai.md:gsub("$FILE_PATH", filename)
    end

    if insert_code ~= "" then
        local lines = {}
        for line in insert_code:gmatch("([^\n]+)") do
            table.insert(lines, line)
        end

        local line_count = vim.api.nvim_buf_line_count(0)
        local current_line, _ = unpack(vim.api.nvim_win_get_cursor(0))
        if current_line > line_count then
            current_line = line_count
        end
        if current_line == 0 then
            current_line = 1
        end

        vim.api.nvim_buf_set_lines(0, current_line - 1, current_line - 1, false, lines)
    end
end

local function create_illustration_dir(illustration_dir_path)
    local command = "mkdir -p " .. illustration_dir_path
    local ok, _ = os.execute(command)
    if not ok then
        print("Failed to create the 'figures' directory.")
        return
    end
end

function M.create_and_open_svg()
    local illustration_dir_path = Config.options.illustration_dir
    create_illustration_dir(illustration_dir_path)

    local filename = vim.fn.input("[SVG] Filename (w/o extension): ") .. ".svg"
    local destination_filename = illustration_dir_path .. "/" .. filename

    local template_path = Config.options.template_files.directory.svg .. Config.options.template_files.default.svg
    copy_template(template_path, destination_filename)
    insert_include_code(destination_filename)

    local os_name = get_os()
    local default_app = Config.options.default_app.svg
    if default_app == 'inkscape' then
        os.execute("inkscape " .. destination_filename)
    elseif default_app == 'illustrator' and os_name == 'Darwin' then
        os.execute("open -a 'Adobe Illustrator' " .. destination_filename)
    end
end

function M.create_and_open_ai()
    vim.notify = require("notify")
    local illustration_dir_path = Config.options.illustration_dir
    create_illustration_dir(illustration_dir_path)

    local filename = vim.fn.input("[AI] Filename (w/o extension): ") .. ".ai"
    local destination_filename = illustration_dir_path .. "/" .. filename

    local template_path = Config.options.template_files.directory.ai .. Config.options.template_files.default.ai
    copy_template(template_path, destination_filename)
    insert_include_code(destination_filename)

    local os_name = get_os()
    local default_app = Config.options.default_app.svg
    if default_app == 'inkscape' then
        os.execute("inkscape " .. destination_filename)
    elseif default_app == 'illustrator' and os_name == 'Darwin' then
        os.execute("open -a 'Adobe Illustrator' " .. destination_filename)
    end
end

return M

