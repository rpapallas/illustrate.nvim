local M = {}
local utils = require("illustrate.utils")
local Config = require("illustrate.config")
vim.notify = require("notify")

function M.setup(options)
    Config.setup(options)
end

function M.open_under_cursor()
    local filetype = vim.bo.filetype
    local file_path = nil

    if filetype == "tex" then
        file_path = utils.extract_path_from_tex_figure_environment()
    elseif filetype == "markdown" then
        local line = vim.fn.getline(".")
        file_path = line:match("!%[[^%]]*%]%((.-)%s*%)")
    else
        vim.notify("[illustrate.nvim] Not a tex or markdown document.", vim.log.levels.INFO)
        return
    end

    if file_path then
        utils.open(file_path)
    else
        vim.notify("[illustrate.nvim] No figure environment found under cursor", vim.log.levels.INFO)
    end
end

function M.create_and_open_svg()
    local filename = vim.fn.input("[SVG] Filename (w/o extension): ") .. ".svg"
    if filename == ".svg" then
        vim.notify("[illustrate.nvim] Invalid filename", vim.log.levels.ERROR)
        return
    end
    local output_file_absolute_path, output_is_relative = utils.get_output_path(filename)
    local template_file_absolute_path = utils.get_template_path()
    if not template_file_absolute_path then
        vim.notify("[illustrate.nvim] No default SVG template found", vim.log.levels.ERROR)
        return
    end

    utils.create_document(template_file_absolute_path, output_file_absolute_path)

    utils.open(output_file_absolute_path)

    if output_is_relative then
        utils.insert_include_code(Config.options.illustration_dir .. "/" .. filename)
    else
        utils.insert_include_code(output_file_absolute_path)
    end
end

function M.create_and_open_ai()
    local filename = vim.fn.input("[AI] Filename (w/o extension): ") .. ".ai"
    local template_files = Config.options.template_files
    local template_path = template_files.directory.ai .. template_files.default.ai
    local new_document_path = utils.create_document(filename, template_path)
    utils.insert_include_code(new_document_path)
    utils.open(new_document_path)
end

return M
