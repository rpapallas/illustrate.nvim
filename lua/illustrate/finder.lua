local M = {}
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local utils = require("illustrate.utils")
utils.setup_notify()

function M.search_and_open()
    local files = utils.get_all_illustration_files()

    pickers
        .new({}, {
            prompt_title = "Illustration Files",
            finder = finders.new_table({
                results = files,
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = vim.fn.fnamemodify(entry, ":t"),
                        ordinal = entry,
                    }
                end,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    utils.open_file_in_vector_program(selection.value)
                end)
                return true
            end,
        })
        :find()
end

function M.search_create_copy_and_open()
    local files = utils.get_all_illustration_files()

    pickers
        .new({}, {
            prompt_title = "Clone Illustration File",
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
                    local file_extension = selection.value:match("^.+(%..+)$")

                    local new_name = vim.fn.input("New filename (w/o extension): ") .. file_extension
                    local illustration_dir_path = utils.get_path_to_illustration_dir()
                    local destination_path = illustration_dir_path .. "/" .. new_name
                    local source_path = selection.value

                    utils.copy(source_path, destination_path)

                    local relative_path = utils.get_relative_path(destination_path)
                    utils.insert_include_code(relative_path)
                    utils.open_file_in_vector_program(destination_path)
                end)
                return true
            end,
    }):find()
end

return M
