local M = {}
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require "telescope.config".values
local action_state = require "telescope.actions.state"
local actions = require "telescope.actions"
local utils = require("illustrate.utils")

function M.search_and_open()
    local files = utils.get_all_illustration_files()

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
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                utils.open(selection.value)
            end)
            return true
        end,
    }):find()
end

return M

