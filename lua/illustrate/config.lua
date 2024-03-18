local M = {}

M.namespace = vim.api.nvim_create_namespace("illustrate")
local templates_dir = vim.fn.stdpath("data") .. "/lazy/illustrate.nvim/templates"

local defaults = {
    illustration_dir = "figures",
    template_files = {
        directory = {
            svg = templates_dir .. "/svg/",
        },
        default = {
            svg = "default.svg",
        },
    },
    text_templates = {
        svg = {
            md = "![$CAPTION]($FILE_PATH)",
        },
    },
    default_app = {
        svg = "inkscape",
    },
}

M.options = {}

function M.setup(options)
    M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

M.setup()

return M
