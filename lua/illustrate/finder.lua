local M = {}
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require "telescope.config".values
local action_state = require "telescope.actions.state"
local actions = require "telescope.actions"

function M.search_and_open()
    -- TODO: make sure the path to figures is defined in the config.
    local figures_path = vim.fn.getcwd() .. "/figures"

    -- Just get SVG and AI (Adobe Illustrator) files.
    local svg_files = vim.fn.globpath(figures_path, "*.svg", false, true)
    local ai_files = vim.fn.globpath(figures_path, "*.ai", false, true)

    -- TODO: the following which seems neater doesn't include all files from
    -- both tables vim.tbl_extend('force', svg_files, ai_files) so had to concat
    -- manually.
    local files = {}
    for _, file in ipairs(svg_files) do
        table.insert(files, file)
    end
    for _, file in ipairs(ai_files) do
        table.insert(files, file)
    end

    pickers.new({}, {
        prompt_title = "Illustration Files",
        finder = finders.new_table {
            results = files,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = vim.fn.fnamemodify(entry, ":t"),
                    ordinal = entry,
                }
            end,
        },
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()

                -- TODO: make sure the program to use is defined in the config.
                -- also make sure this works for Windows and Linux on top of 
                -- macOS.
                os.execute("open -a 'Adobe Illustrator' " .. selection.value)
            end)
            return true
        end,
    }):find()
end

return M

