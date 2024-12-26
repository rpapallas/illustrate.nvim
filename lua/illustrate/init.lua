local M = {}
local config = require("illustrate.config")
local utils = require("illustrate.utils")
utils.setup_notify()

function M.setup(options)
    config.setup(options)
end

local function create_documenmt(filename, type)
    local template_files = config.options.template_files
    local template_path = nil

    if type == "svg" then
        template_path = template_files.directory.svg .. template_files.default.svg
    elseif type == "ai" then
        template_path = template_files.directory.ai .. template_files.default.ai
    else
        vim.notify("[illustrate.nvim] Unrecognised file type.", vim.log.levels.ERROR)
        return
    end

    return utils.create_document(filename, template_path)
end

local function create_and_open(new_file_name, caption, label, type)
    new_file_name = new_file_name .. '.' .. type
    local new_document_path = create_documenmt(new_file_name, type)
    local relative_path = utils.get_relative_path(new_document_path)
    utils.insert_include_code(relative_path, caption, label)
    utils.open_file_in_vector_program(new_document_path)
    return true
end

local function extract_path_from_figure()
    local file_path = nil
    local filetype = vim.bo.filetype

    if filetype == "tex" then
        file_path = utils.extract_path_from_tex_figure_environment()
    elseif filetype == "markdown" then
        local line = vim.fn.getline(".")
        file_path = line:match("!%[[^%]]*%]%((.-)%s*%)")
    else
        vim.notify("[illustrate.nvim] Not a tex or markdown document.", vim.log.levels.INFO)
        return
    end

    return file_path
end

local function read_optionally_caption_and_label(caption, label)
    if caption == nil and config.options.prompt_caption then
        caption = vim.fn.input("Provide caption for the figure: ")
    end

    local is_latex_document = vim.bo.filetype == 'tex'
    if label == nil and config.options.prompt_label and is_latex_document then
        label = vim.fn.input("Provide label for the figure: ")
    end

    return caption, label
end

function M.open_under_cursor()
    local file_path = extract_path_from_figure()

    if file_path then
        local filename = string.match(file_path, "([^/]+)$")
        local illustration_dir = utils.get_path_to_illustration_dir()

        if illustration_dir == nil then
            vim.notify("[illustrate.nvim] You attempt to open a figure but the illustration directory cannot be found.", vim.log.levels.ERROR)
            return
        end

        file_path = illustration_dir .. '/' .. filename
        local open_was_successful = utils.open_file_in_vector_program(file_path)

        if not open_was_successful then
            local filename = vim.fn.input("File does not exist. Create now? ", file_path:match(".+/([^/]+)$"))

            local illustration_filetype = nil
            if file_path:match("%.ai$") then
                illustration_filetype = 'ai'
            elseif file_path:match("%.svg$") then
                illustration_filetype = 'svg'
            else
                vim.notify("[illustrate.nvim] file type unknown.", vim.log.levels.ERROR)
                return
            end

            local new_document_path = create_documenmt(filename, illustration_filetype)
            utils.open_file_in_vector_program(new_document_path)
        end
    else
        vim.notify("[illustrate.nvim] No figure environment found under cursor", vim.log.levels.INFO)
    end
end

function M.create_and_open_svg(new_file_name, caption, label)
    if new_file_name == nil then
        new_file_name = vim.fn.input("[SVG] Filename (w/o extension): ")
    end

    if new_file_name == '' then
        vim.notify("[illustrate.nvim] Figure name can't be empty.", vim.log.levels.ERROR)
        return false
    end

    if new_file_name:match("%.ai$") or new_file_name:match("%.svg$") then
        vim.notify("[illustrate.nvim] The file name should not contain the file type (.ai/.svg).", vim.log.levels.ERROR)
        return false
    end

    caption, label = read_optionally_caption_and_label(caption, label)
    return create_and_open(new_file_name, caption, label, 'svg')
end

function M.create_and_open_ai(new_file_name, caption, label)
    if new_file_name == nil then
        new_file_name = vim.fn.input("[AI] Filename (w/o extension): ")
    end

    if new_file_name == '' then
        vim.notify("[illustrate.nvim] Figure name can't be empty.", vim.log.levels.ERROR)
        return false
    end

    if new_file_name:match("%.ai$") or new_file_name:match("%.svg$") then
        vim.notify("[illustrate.nvim] The file name should not contain the file type (.ai/.svg).", vim.log.levels.ERROR)
        return false
    end

    caption, label = read_optionally_caption_and_label(caption, label)
    return create_and_open(new_file_name, caption, label, 'ai')
end

return M
