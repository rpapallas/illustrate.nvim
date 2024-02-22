local M = {}
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require "telescope.config".values
local action_state = require "telescope.actions.state"
local actions = require "telescope.actions"
local Config = require("illustrate.config")

local function get_os()
	local fh,err = assert(io.popen("uname -o 2>/dev/null","r"))
	if fh then
		osname = fh:read()
	end

	return osname or "Windows"
end

function M.search_and_open()
    vim.notify = require("notify")
    local figures_path = vim.fn.getcwd() .. "/" .. Config.options.illustration_dir

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

                local os_name = get_os()
                if os_name == 'Darwin' then
                    local default_app = Config.options.default_app.svg
                    if default_app == 'inkscape' then
                        os.execute("open -a 'inkscape' " .. selection.value)
                    elseif default_app == 'illustrator' then
                        os.execute("open -a 'Adobe Illustrator' " .. selection.value)
                    end
                end
            end)
            return true
        end,
    }):find()
end

return M

