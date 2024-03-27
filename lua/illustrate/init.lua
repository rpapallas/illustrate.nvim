local M = {}
local utils = require('illustrate.utils')
local Config = require("illustrate.config")
vim.notify = require("notify")

function M.setup(options)
    Config.setup(options)
end

local function create_documenmt(file_path, type)
    local filename = vim.fn.input("File does not exist, create now?", file_path:match(".+/([^/]+)$"))

    if type == "svg" then
        local template_files = Config.options.template_files
        local template_path = template_files.directory.svg .. template_files.default.svg
        local new_document_path = utils.create_document(filename, template_path)
        utils.open(new_document_path)
    elseif type == "ai" then
        local template_files = Config.options.template_files
        local template_path = template_files.directory.ai .. template_files.default.ai
        local new_document_path = utils.create_document(filename, template_path)
        utils.open(new_document_path)
    else
        vim.notify("[illustrate.nvim] Unrecognised file type.", "error")
    end
end

function M.open_under_cursor()
    local filetype = vim.bo.filetype
    local file_path = nil

    if filetype == 'tex' then
        file_path = utils.extract_path_from_tex_figure_environment()
    elseif filetype == 'markdown' then
        local line = vim.fn.getline('.')
        file_path = line:match('!%[[^%]]*%]%((.-)%s*%)')
    else
        vim.notify("[illustrate.nvim] Not a tex or markdown document.", "info")
        return
    end

    if file_path then
        local open_was_successful = utils.open(file_path)

        if open_was_successful == false and file_path:match("%.ai$") then
            create_documenmt(file_path, "ai")
        elseif open_was_successful == false and file_path:match("%.svg$") then
            create_documenmt(file_path, "svg")
        end
    else
        vim.notify("[illustrate.nvim] No figure environment found under cursor", "info")
    end
end

function M.create_and_open_svg()
    local filename = vim.fn.input("[SVG] Filename (w/o extension): ") .. ".svg"
    local template_files = Config.options.template_files
    local template_path = template_files.directory.svg .. template_files.default.svg
    local new_document_path = utils.create_document(filename, template_path)
    local relatie_path = new_document_path:match(Config.options.illustration_dir .. "/[^/]+$")
    utils.insert_include_code(relatie_path)
    utils.open(new_document_path)
end

function M.create_and_open_ai()
    local filename = vim.fn.input("[AI] Filename (w/o extension): ") .. ".ai"
    local template_files = Config.options.template_files
    local template_path = template_files.directory.ai .. template_files.default.ai
    local new_document_path = utils.create_document(filename, template_path)
    local relatie_path = new_document_path:match(Config.options.illustration_dir .. "/[^/]+$")
    utils.insert_include_code(relatie_path)
    utils.open(new_document_path)
end

return M

