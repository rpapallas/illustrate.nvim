local M = {}
local Config = require("illustrate.config")
vim.notify = require("notify")

local function get_os()
    local fh, _ = assert(io.popen("uname -o 2>/dev/null", "r"))
    local osname
    if fh then
        osname = fh:read()
    end

    return osname or "Windows"
end

local function execute(command, background)
    local background_operator = ""
    if background then
        background_operator = " &"
    end

    local handle = io.popen(command .. " 2>&1" .. background_operator)
    if handle then
        local result = handle:read("*a")
        handle:close()

        if result ~= "" then
            vim.notify("[illustrate.nvim] Error: " .. result, vim.log.levels.ERROR)
        end
    end
end

function M.open_file_in_vector_program(filename)
    local os_name = get_os()
    local default_app = Config.options.default_app.svg
    local current_os_user = vim.loop.os_getenv("USER")

    if default_app == "inkscape" and os_name == "Darwin" then
        execute("sudo -u " .. current_os_user .. " inkscape " .. filename .. " >/dev/null ", true)
    elseif default_app == "inkscape" then
        execute("inkscape " .. filename .. " >/dev/null ", true)
    elseif default_app == "illustrator" and os_name == "Darwin" then
        execute("open -a 'Adobe Illustrator' " .. filename, false)
    end
end

function M.insert_include_code(filename, caption)
    local insert_code = Config.options.text_templates.svg.md:gsub("$FILE_PATH", filename):gsub("$CAPTION", caption)

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

-- get output path for the file and create the directory if it doesn't exist
function M.get_output_path(file_name)
    local current_file_path = vim.fn.expand("%:p:h")
    local is_relative = false
    local output_file_absolute_path = Config.options.illustration_dir
    if Config.options.illustration_dir:sub(1, 1) == "~" then
        output_file_absolute_path = vim.fn.expand("~") .. Config.options.illustration_dir:sub(2)
    end
    if Config.options.illustration_dir:sub(1, 1) ~= "/" then
        output_file_absolute_path = current_file_path .. "/" .. Config.options.illustration_dir
        is_relative = true
    end

    if not vim.fn.isdirectory(output_file_absolute_path) then
        execute("mkdir -p " .. output_file_absolute_path, false)
    end

    return output_file_absolute_path .. "/" .. file_name, is_relative
end

-- get the template path for the file, returns nil if the file doesn't exist
function M.get_template_path()
    local template_files = Config.options.template_files
    local template_file_absolute_path = template_files.directory.svg .. template_files.default.svg
    if not vim.fn.filereadable(template_file_absolute_path) then
        template_file_absolute_path = nil
    end

    return template_file_absolute_path
end

-- create a name with input string, plus buffer name, plus date and time
function M.create_document_name(input_string)
    local buffer_file_name = vim.fn.expand("%:t:r")
    local date = os.date("%Y-%m-%d-%H-%M-%S")

    -- input string has any extension?
    if input_string:match("^.+%..+$") then
        vim.notify("[illustrate.nvim] Filename should not contain an extension", vim.log.levels.ERROR)
        return
    end

    -- input string is empty?
    if input_string == "" then
        return buffer_file_name .. "-" .. date .. ".svg", "undefined"
    else
        return buffer_file_name .. "-" .. date .. "-" .. input_string .. ".svg", input_string
    end
end

function M.create_new_file(template_path, destination_path)
    execute("cp " .. template_path .. " " .. destination_path, false)
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
            local path = line:match("\\include[s]?vg%[?[^%]]*%]?%{(.-)%}")
                or line:match("\\includegraphics%[?[^%]]*%]?%{(.-)%}")
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

return M
