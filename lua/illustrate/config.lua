local M = {}

M.namespace = vim.api.nvim_create_namespace("illustrate")
local templates_dir = vim.fn.stdpath("data") .. "/lazy/illustrate.nvim/templates"

local defaults = {
    illustration_dir = "figures",
    template_files = {
        directory = {
            svg = templates_dir .. "/svg/",
            ai = templates_dir .. "/ai/",
        },
        default = {
            svg = "default.svg",
            ai = "default.ai",
        }
    },
    text_templates = {
        svg = {
            tex = [[
\begin{figure}[h]
  \centering
  \includesvg[width=0.8\textwidth]{$FILE_PATH}
  \caption{Caption}
  \label{fig:}
\end{figure}
            ]],
            md = "![caption]($FILE_PATH)",
        },
        ai = {
            tex = [[
\begin{figure}[h]
  \centering
  \includegraphics[width=0.8\linewidth]{$FILE_PATH}
  \caption{Caption}
  \label{fig:}
\end{figure}
            ]],
            md = "![caption]($FILE_PATH)",
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
