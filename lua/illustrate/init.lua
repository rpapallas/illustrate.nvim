local M = {}
local utils = require('illustrate.utils')
local Config = require("illustrate.config")
vim.notify = require("notify")

function M.setup(options)
    Config.setup(options)
end

local function copy_template(template_path, destination_path)
    local ok, _, _ = os.execute("cp " .. template_path .. " " .. destination_path)
    if not ok then
        vim.notify("Failed to copy template.", "Error")
        return
    end
end

local function insert_include_code(filename)
    local filetype = vim.bo.filetype
    local extension = filename:match("^.+%.(%w+)$")

    local insert_code = ""
    if filetype == "tex" and extension == "svg" then
        insert_code = Config.options.text_templates.svg.tex:gsub("$FILE_PATH", filename)
    elseif filetype == "tex" and extension == "ai" then
        insert_code = Config.options.text_templates.ai.tex:gsub("$FILE_PATH", filename)
    elseif filetype == "markdown" and extension == "svg" then
        insert_code = Config.options.text_templates.svg.md:gsub("$FILE_PATH", filename)
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
        vim.notify("Failed to create the 'figures' directory.")
        return
    end
end

local function create_document(filename, template_path)
    local illustration_dir_path = Config.options.illustration_dir
    create_illustration_dir(illustration_dir_path)
    local destination_filename = illustration_dir_path .. "/" .. filename
    copy_template(template_path, destination_filename)
    return destination_filename
end

local function extract_path_from_tex_figure_environment()
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

function M.open_under_cursor()
    local filetype = vim.bo.filetype
    local file_path = nil

    if filetype == 'tex' then
        file_path = extract_path_from_tex_figure_environment()
    elseif filetype == 'markdown' then
        local line = vim.fn.getline('.')
        file_path = line:match('!%[[^%]]*%]%((.-)%s*%)')
    else
        vim.notify("Not a tex or markdown document.", "info")
    end

    if file_path then
        utils.open(file_path)
    else
        vim.notify("No figure environment found under cursor", "info")
    end
end

function M.create_and_open_svg()
    local filename = vim.fn.input("[SVG] Filename (w/o extension): ") .. ".svg"
    local template_files = Config.options.template_files
    local template_path = template_files.directory.svg .. template_files.default.svg
    local new_document_path = create_document(filename, template_path)
    insert_include_code(new_document_path)
    utils.open(new_document_path)
end

function M.create_and_open_ai()
    local filename = vim.fn.input("[AI] Filename (w/o extension): ") .. ".ai"
    local template_files = Config.options.template_files
    local template_path = template_files.directory.ai .. template_files.default.ai
    local new_document_path = create_document(filename, template_path)
    insert_include_code(new_document_path)
    utils.open(new_document_path)
end

return M

