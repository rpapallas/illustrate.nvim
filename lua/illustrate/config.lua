vim.notify = require("notify")
local M = {}

M.namespace = vim.api.nvim_create_namespace("illustrate")

local function get_plugin_path()
    local stack_info = debug.getinfo(2, "S")
    local file_path = stack_info.source

    if file_path:sub(1, 1) == "@" then
        file_path = file_path:sub(2)
    end

    local lua_index = file_path:find('/lua/')
    
    if lua_index then
        return file_path:sub(1, lua_index - 1)
    else
        return nil
    end
end

local templates_dir = get_plugin_path() .. "/templates"

local defaults = {
    illustration_dir = "figures",
    directories_to_avoid_creating_illustration_dir_in = {
        'sections',
        'chapters',
    },
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
