local M = {}

M.namespace = vim.api.nvim_create_namespace("illustrate")

local defaults = {
    illustration_dir = "figures",
    template_files = {
        directory = {
            svg = "~/inbox/illustrate.nvim/templates/svg",
            ai = "~/inbox/illustrate.nvim/templates/ai",
        },
        default = {
        }
    },
    text_templates = {
        svg = {
            tex = "\\begin{figure}[htbp]\n\\centering\n\\includesvg[width=\\linewidth]{%s}\n\\caption{caption}\n\\label{fig:label}\n\\end{figure}",
            md = "![caption](%s)",
        },
        ai = {
            tex = "\\begin{figure}[htbp]\n\\centering\n\\includesvg[width=\\linewidth]{%s}\n\\caption{caption}\n\\label{fig:label}\n\\end{figure}",
            md = "![caption](%s)",
        }
    },
    default_app = {
        svg = "inkscape",
        ai = "inkscape",
    },
}

M.options = {}

function M.setup(options)
    M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

M.setup()

return M
