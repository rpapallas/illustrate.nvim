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
    local ok, _, _ = os.execute("cp " .. template_path .. " " .. destination_path)
    if not ok then
        print("Failed to copy template.")
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
        print("Failed to create the 'figures' directory.")
        return
    end
end

local function open(filename)
    local os_name = get_os()
    local default_app = Config.options.default_app.svg
    if default_app == 'inkscape' then
        os.execute("inkscape " .. filename .. " >/dev/null 2>&1 &")
    elseif default_app == 'illustrator' and os_name == 'Darwin' then
        os.execute("open -a 'Adobe Illustrator' " .. filename)
    end
end

local function create_document(filename, template_path)
    local illustration_dir_path = Config.options.illustration_dir
    create_illustration_dir(illustration_dir_path)

    local destination_filename = illustration_dir_path .. "/" .. filename

    copy_template(template_path, destination_filename)
    insert_include_code(destination_filename)
    open(destination_filename)
end

function M.create_and_open_svg()
    local filename = vim.fn.input("[SVG] Filename (w/o extension): ") .. ".svg"
    local template_files = Config.options.template_files
    local template_path = template_files.directory.svg .. template_files.default.svg
    create_document(filename, template_path)
end

function M.create_and_open_ai()
    local filename = vim.fn.input("[AI] Filename (w/o extension): ") .. ".ai"
    local template_files = Config.options.template_files
    local template_path = template_files.directory.ai .. template_files.default.ai
    create_document(filename, template_path)
end

local function extract_svg_path()
    vim.notify = require("notify")
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local start_line = current_line
    vim.notify("" .. current_line, 'info')

    -- Search backward to find the start of the figure environment
    while start_line > 0 do
        local line = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line, false)[1]
        if line:find("\\begin{figure}") then
            break
        end
        start_line = start_line - 1
    end

    local end_line = start_line

    -- Search forward to find the end of the figure environment
    while end_line <= current_line do
        local line = vim.api.nvim_buf_get_lines(0, end_line - 1, end_line, false)[1]
        if line:find("\\end{figure}") then
            break
        end
        end_line = end_line + 1
    end

    vim.notify(" " .. start_line .. ", " .. current_line .. ", " .. end_line, 'info')

    -- Check if the cursor position is within the figure environment
    if current_line >= start_line and current_line <= end_line then
        -- Search within the figure environment for the includesvg line
        for i = start_line, end_line do
            local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
            local path = line:match("\\includesvg%[?[^%]]*%]?%{(.-)%}")
            if path then
                return path
            end
        end
    end
end

function M.open_under_cursor()
    local filetype = vim.bo.filetype
    local line = vim.fn.getline('.')

    if filetype == 'tex' then
        local svg_path = extract_svg_path()
        if svg_path then
            open(svg_path)
        else
            print('SVG file not found')
        end
    elseif filetype == 'markdown' and line:find('!%[[^%]]*%]%((.-)%s*%)') then
        local img_file = line:match('!%[[^%]]*%]%((.-)%s*%)')
        if img_file then
            open(img_file)
        else
            print('Image file not found')
        end
    else
        print('Not in LaTeX figure environment or Markdown image tag')
    end
end

return M

