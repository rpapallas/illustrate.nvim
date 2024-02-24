local M = {}
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require "telescope.config".values
local action_state = require "telescope.actions.state"
local actions = require "telescope.actions"
local Config = require("illustrate.config")

local function get_os()
	local fh, _ = assert(io.popen("uname -o 2>/dev/null","r"))
    local os_name
	if fh then
		os_name = fh:read()
	end

	return os_name or "Windows"
end

local function get_all_illustration_files()
    local figures_path = vim.fn.getcwd() .. "/" .. Config.options.illustration_dir
    local files = vim.fn.globpath(figures_path, "*.svg", false, true)
    local ai_files = vim.fn.globpath(figures_path, "*.ai", false, true)

    for _, file in ipairs(ai_files) do
        table.insert(files, file)
    end

    return files
end

function M.search_and_open()
    local files = get_all_illustration_files()

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

                local os_name = get_os()
                local default_app = Config.options.default_app.svg
                if default_app == 'inkscape' then
                    os.execute("inkscape " .. selection.value .. " >/dev/null 2>&1 &")
                elseif default_app == 'illustrator' and os_name == 'Darwin' then
                    os.execute("open -a 'Adobe Illustrator' " .. selection.value)
                end
            end)
            return true
        end,
    }):find()
end

return M

