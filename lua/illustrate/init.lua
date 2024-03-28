local M = {}
local utils = require('illustrate.utils')
local Config = require("illustrate.config")
vim.notify = require("notify")

function M.setup(options)
    Config.setup(options)
end

local function create_documenmt(filename, type)
    local template_files = Config.options.template_files
    local template_path = nil

    if type == "svg" then
        template_path = template_files.directory.svg .. template_files.default.svg
    elseif type == "ai" then
        template_path = template_files.directory.ai .. template_files.default.ai
    else
        vim.notify("[illustrate.nvim] Unrecognised file type.", "error")
        return
    end

    return utils.create_document(filename, template_path)
end


local function create_and_open(new_file_name, type)
    if new_file_name == '' then
        vim.notify("[illustrate.nvim] Figure name can't be empty.", "error")
        return false
    end

    new_file_name = new_file_name .. '.' .. type
    local new_document_path = create_documenmt(new_file_name, type)
    local relative_path = utils.get_relative_path(new_document_path)
    utils.insert_include_code(relative_path)
    utils.open(new_document_path)
    return true
end

local function extract_path_from_figure()
    local file_path = nil
    local filetype = vim.bo.filetype

    if filetype == 'tex' then
        file_path = utils.extract_path_from_tex_figure_environment()
    elseif filetype == 'markdown' then
        local line = vim.fn.getline('.')
        file_path = line:match('!%[[^%]]*%]%((.-)%s*%)')
    else
        vim.notify("[illustrate.nvim] Not a tex or markdown document.", "info")
        return
    end

    return file_path
end

function M.open_under_cursor()
    local file_path = extract_path_from_figure()
    local filename = string.match(file_path, "([^/]+)$")
    local illustration_dir = utils.get_path_to_illustration_dir()
    file_path = illustration_dir .. '/' .. filename

    if file_path then
        local open_was_successful = utils.open(file_path)

        if not open_was_successful then
            local filename = vim.fn.input("File does not exist. Create now?", file_path:match(".+/([^/]+)$"))

            local illustration_filetype = nil
            if file_path:match("%.ai$") then
                illustration_filetype = 'ai'
            elseif file_path:match("%.svg$") then
                illustration_filetype = 'svg'
            else
                vim.notify("[illustrate.nvim] file type unknown.", "error")
                return
            end

            local new_document_path = create_documenmt(filename, illustration_filetype)
            utils.open(new_document_path)
        end
    else
        vim.notify("[illustrate.nvim] No figure environment found under cursor", "info")
    end
end

function M.create_and_open_svg(new_file_name)
    if new_file_name == nil then
        new_file_name = vim.fn.input("[SVG] Filename (w/o extension): ")
    end

    return create_and_open(new_file_name, 'svg')
end

function M.create_and_open_ai(new_file_name)
    if new_file_name == nil then
        new_file_name = vim.fn.input("[AI] Filename (w/o extension): ")
    end

    create_and_open(new_file_name, 'ai')
end

return M

