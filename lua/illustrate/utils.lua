local M = {}
local Config = require("illustrate.config")
vim.notify = require("notify")

local function get_os()
    local fh, _ = assert(io.popen("uname -o 2>/dev/null","r"))
    local osname
    if fh then
        osname = fh:read()
    end

    return osname or "Windows"
end

local function execute(command, background)
    local background_operator = ''
    if background then
        background_operator = ' &'
    end

    local handle = io.popen(command .. " 2>&1" .. background_operator)
    if handle then
        local result = handle:read("*a")
        handle:close()

        return result == ""
    end

    return true
end

local function copy_template(template_path, filename)
    local illustration_dir_path = Config.options.illustration_dir
    local destination_path = illustration_dir_path .. "/" .. filename
    execute("cp " .. template_path .. " " .. destination_path, false)
    return destination_path
end

local function create_illustration_dir()
    local illustration_dir_path = Config.options.illustration_dir
    execute("mkdir -p " .. illustration_dir_path, false)
end

function M.open(filename)
    local os_name = get_os()
    local default_app = Config.options.default_app.svg

    if default_app == 'inkscape' then
        return execute("inkscape " .. filename .. " >/dev/null ", true)
    elseif default_app == 'illustrator' and os_name == 'Darwin' then
        return execute("open -a 'Adobe Illustrator' " .. filename, false)
    end
end

function M.insert_include_code(filename)
    local filetype = vim.bo.filetype
    local extension = filename:match("^.+%.(%w+)$")

    local insert_code = ""
    if filetype == "tex" and extension == "svg" then
        insert_code = Config.options.text_templates.svg.tex:gsub("$FILE_PATH", filename)
    elseif filetype == "tex" and extension == "ai" then
        insert_code = Config.options.text_templates.ai.tex:gsub("$FILE_PATH", filename)
    elseif filetype == "markdown" and extension == "svg" then
        insert_code = Config.options.text_templates.svg.md:gsub("$FILE_PATH", filename)
    elseif filetype == "markdown" and extension == "ai" then
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

function M.create_document(filename, template_path)
    -- Create illustration dir if not exists.
    create_illustration_dir()
    local destination_filename = copy_template(template_path, filename)
    return destination_filename
end

function M.extract_path_from_tex_figure_environment()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local start_line = current_line
    local last_line_number = vim.api.nvim_buf_line_count(0)

    -- Search backward to find the start of the figure environment
    while start_line > 0 do
        local line = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line, false)[1]
        if line:find("\\begin{figure}") then
            break
        end
        start_line = start_line - 1
    end

    if start_line ~= current_line and start_line == 0 then
        return
    end

    local end_line = start_line

    -- Search forward to find the end of the figure environment
    while end_line <= last_line_number do
        local line = vim.api.nvim_buf_get_lines(0, end_line - 1, end_line, false)[1]
        if line:find("\\end{figure}") then
            break
        end
        end_line = end_line + 1
    end

    -- Check if the cursor position is within the figure environment
    if current_line >= start_line and current_line <= end_line then
        -- Search within the figure environment for the includesvg line
        for i = start_line, end_line do
            local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
            local path = line:match("\\include[s]?vg%[?[^%]]*%]?%{(.-)%}") or line:match("\\includegraphics%[?[^%]]*%]?%{(.-)%}")
            if path then
                return path
            end
        end
    end
end

function M.get_all_illustration_files()
    local figures_path = vim.fn.getcwd() .. "/" .. Config.options.illustration_dir
    local files = vim.fn.globpath(figures_path, "*.svg", false, true)
    local ai_files = vim.fn.globpath(figures_path, "*.ai", false, true)

    for _, file in ipairs(ai_files) do
        table.insert(files, file)
    end

    return files
end

function M.copy(source, destination)
    return execute("cp " .. source .. " " .. destination, false)
end


return M
