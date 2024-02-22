local M = {}
local Config = require("illustrate.config")

function M.setup(options)
    require("illustrate.config").setup(options)
end

local function copy_template(template_path, destination_path)
    local ok, _, code = os.execute("cp " .. template_path .. " " .. destination_path)
end

local function insert_include_code(filename)
    local filetype = vim.bo.filetype
    local latex_svg_code = string.format("\\begin{figure}[htbp]\n\\centering\n\\includegraphics[width=\\linewidth]{%s}\n\\caption{caption}\n\\label{fig:label}\n\\end{figure}", filename)
    local markdown_svg_code = string.format("![caption](%s)", filename)

    local insert_code = ""
    if filetype == "tex" then
        insert_code = latex_svg_code
    elseif filetype == "markdown" then
        insert_code = markdown_svg_code
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

local function create_figures_dir(figures_path)
    -- TODO: make sure this command works on Windows too.
    local ok, _ = os.execute("mkdir -p " .. figures_path)
    if not ok then
        print("Failed to create the 'figures' directory.")
        return
    end
end

function M.create_and_open_svg()
    vim.notify = require("notify")
    local figures_path = Config.options.illustration_dir
    create_figures_dir(figures_path)

    local filename = vim.fn.input("[SVG] Filename (w/o extension): ") .. ".svg"
    local destination_filename = figures_path .. "/" .. filename

    -- TODO: get path from the config
    -- TODO: allow user to pick templates from a template list?
    local template_path = os.getenv("HOME") .. "/inbox/illustrate.nvim/templates/svg/template.svg"
    copy_template(template_path, destination_filename)
    insert_include_code(destination_filename)

    -- TODO: define app to open in the config; make this work for Windows and Linux.
    os.execute("open -a 'Adobe Illustrator' " .. destination_filename)
end

function M.create_and_open_ai()
    vim.notify = require("notify")
    local figures_path = Config.options.illustration_dir
    create_figures_dir(figures_path)

    local filename = vim.fn.input("[AI] Filename (w/o extension): ") .. ".ai"
    local destination_filename = figures_path .. "/" .. filename

    -- TODO: get path from the config
    -- TODO: allow user to pick templates from a template list?
    local template_path = os.getenv("HOME") .. "/inbox/illustrate.nvim/templates/ai/template.ai"
    copy_template(template_path, destination_filename)
    insert_include_code(destination_filename)

    -- TODO: define app to open in the config; make this work for Windows and Linux.
    os.execute("open -a 'Adobe Illustrator' " .. destination_filename)
end

return M

