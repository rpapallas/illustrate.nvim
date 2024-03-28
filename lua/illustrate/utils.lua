local M = {}
local Config = require("illustrate.config")
vim.notify = require("notify")

function M.get_path_to_illustration_dir()
    local directory_name = Config.options.illustration_dir

    local function directory_exists(path)
        return vim.fn.isdirectory(path .. "/" .. directory_name) == 1
    end

    local function search_in_parent_directories(path)
        local parent_directory = vim.fn.fnamemodify(path, ":h")
        if path == parent_directory then
            return nil  -- Reached root directory, return nil
        elseif directory_exists(path) then
            return path .. "/" .. directory_name
        else
            return search_in_parent_directories(parent_directory)
        end
    end

    local current_file_path = vim.fn.expand("%:p:h")

    -- Search for the directory in the current working directory
    if directory_exists(vim.fn.getcwd()) then
        return vim.fn.getcwd() .. "/" .. directory_name
    end

    -- Search for the directory in the directory of the file being edited and its parent directories
    return search_in_parent_directories(current_file_path)
end


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
    execute("cp " .. template_path .. " " .. filename, false)
end

local function create_illustration_dir()
    local cwd = vim.fn.getcwd()
    local illustration_dir = Config.options.illustration_dir

    -- Function to check if the directory path contains "sections" or "chapters"
    local function has_excluded_directories(path)
        local normalized_path = path:gsub("\\", "/")

        for _, name in ipairs(Config.options.directories_to_avoid_creating_illustration_dir_in) do
            if string.find(normalized_path, "/" .. name .. "/") or
               string.match(normalized_path, "^" .. name .. "/") or
               string.match(normalized_path, "/" .. name .. "$") or
               normalized_path == name then
                return true
            end
        end

        return false
    end

    local function get_parent_without_excluded_directories(path)
        local parent_dir = vim.fn.fnamemodify(path, ":h")
        if not has_excluded_directories(parent_dir) then
            return parent_dir
        else
            return get_parent_without_excluded_directories(parent_dir)
        end
    end

    local parent_without_excluded_directories = cwd
    if has_excluded_directories(cwd) then
        parent_without_excluded_directories = get_parent_without_excluded_directories(cwd)
    end

    local figures_dir = parent_without_excluded_directories .. '/' .. illustration_dir
    vim.fn.mkdir(figures_dir, "p")
    vim.notify("Directory created under: " .. figures_dir)
    return figures_dir
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
    local directory_path = M.get_path_to_illustration_dir()
    if not directory_path then
        directory_path = create_illustration_dir()
    end

    local file_path = directory_path .. '/' .. filename
    copy_template(template_path, file_path)
    return file_path
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
