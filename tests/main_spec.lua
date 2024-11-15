local function random_bytes(length)
    local bytes = {}
    for i = 1, length do
        table.insert(bytes, string.char(math.random(0, 255)))
    end
    return table.concat(bytes)
end

local uuid = require("uuid")
uuid.set_rng(random_bytes)

local lfs = require("lfs")
local illustrate = require('illustrate')
local illustrate_utils = require('illustrate.utils')

local function directory_exists(path)
    return lfs.attributes(path, "mode") == "directory"
end

local function file_exists(path)
    return lfs.attributes(path, "mode") == "file"
end

describe('test create_and_open_svg', function()
    local function generate_paths(svg_file_name, figures_path)
        local unique_number = uuid()
        local root_path = '/tmp/' .. unique_number
        lfs.mkdir(root_path)

        local figures_full_path = root_path .. '/' .. figures_path
        local svg_expected_path =  figures_full_path .. '/' .. svg_file_name .. '.svg'
        return root_path, figures_full_path, svg_expected_path
    end

    it('should create a new svg in newly created figures dir', function()
        local svg_file_name = 'test'
        local root_path, figures_full_path, svg_expected_path = generate_paths(svg_file_name, 'figures')

        assert.is_false(directory_exists(figures_full_path))
        assert.is_false(file_exists(svg_expected_path))

        vim.api.nvim_command("edit " .. root_path .. '/test.tex')
        local was_success = illustrate.create_and_open_svg(svg_file_name)

        assert.is_true(was_success)
        assert.is_true(directory_exists(figures_full_path))
        assert.is_true(file_exists(svg_expected_path))
    end)

    it('should create a new svg under existing figures', function()
        local svg_file_name = 'test'
        local root_path, figures_full_path, svg_expected_path = generate_paths(svg_file_name, 'figures')
        lfs.mkdir(figures_full_path)

        assert.is_true(directory_exists(figures_full_path))
        assert.is_false(file_exists(svg_expected_path))

        vim.api.nvim_command("edit " .. root_path .. '/test.tex')
        local was_success = illustrate.create_and_open_svg(svg_file_name)

        assert.is_true(was_success)
        assert.is_true(file_exists(svg_expected_path))
    end)

    it('should create a new figures/ under root and a new svg while editing relative to root', function()
        local svg_file_name = 'test'
        local root_path, figures_full_path, svg_expected_path = generate_paths(svg_file_name, 'figures')

        assert.is_false(directory_exists(figures_full_path))
        assert.is_false(file_exists(svg_expected_path))

        vim.api.nvim_command("edit " .. root_path .. '/sections/test.tex')
        local was_success = illustrate.create_and_open_svg(svg_file_name)

        assert.is_true(was_success)
        assert.is_true(directory_exists(figures_full_path))
        assert.is_true(file_exists(svg_expected_path))
    end)

    it('should save an svg under existing dir in sections', function()
        local svg_file_name = 'test'
        local root_path, figures_full_path, svg_expected_path = generate_paths(svg_file_name, 'sections/figures')

        assert.is_false(directory_exists(figures_full_path))
        assert.is_false(file_exists(svg_expected_path))

        os.execute('mkdir -p ' .. figures_full_path)
        vim.api.nvim_command("edit " .. root_path .. '/sections/test.tex')
        local was_success = illustrate.create_and_open_svg(svg_file_name)

        assert.is_true(was_success)
        assert.is_true(directory_exists(figures_full_path))
        assert.is_true(file_exists(svg_expected_path))
    end)

    it('should save an svg under existing dir in chapters', function()
        local svg_file_name = 'test'
        local root_path, figures_full_path, svg_expected_path = generate_paths(svg_file_name, 'chapters/figures')

        assert.is_false(directory_exists(figures_full_path))
        assert.is_false(file_exists(svg_expected_path))

        os.execute('mkdir -p ' .. figures_full_path)
        assert.is_true(directory_exists(figures_full_path))

        vim.api.nvim_command("edit " .. root_path .. '/chapters/test.tex')
        local was_success = illustrate.create_and_open_svg(svg_file_name)

        assert.is_true(was_success)
        assert.is_true(file_exists(svg_expected_path))
    end)

    it('should save an svg under existing dir in excluded custom dir name', function()
        local svg_file_name = 'test'
        local root_path, figures_full_path, svg_expected_path = generate_paths(svg_file_name, 'custom_name/figures')

        assert.is_false(directory_exists(figures_full_path))
        assert.is_false(file_exists(svg_expected_path))

        os.execute('mkdir -p ' .. figures_full_path)
        assert.is_true(directory_exists(figures_full_path))

        vim.api.nvim_command("edit " .. root_path .. '/custom_name/test.tex')
        local was_success = illustrate.create_and_open_svg(svg_file_name)

        assert.is_true(was_success)
        assert.is_true(file_exists(svg_expected_path))
    end)

    it('should not create a figures dir in chapters', function()
        local svg_file_name = 'test'
        local root_path, figures_full_path, svg_expected_path = generate_paths(svg_file_name, 'figures')

        assert.is_false(directory_exists(figures_full_path))
        assert.is_false(file_exists(svg_expected_path))

        vim.api.nvim_command("edit " .. root_path .. '/chapters/test.tex')
        local was_success = illustrate.create_and_open_svg(svg_file_name)

        assert.is_true(was_success)
        assert.is_true(directory_exists(figures_full_path))
        assert.is_false(directory_exists(root_path .. '/' .. 'chapters/figures'))
        assert.is_true(file_exists(svg_expected_path))
    end)

    it('should not create a figures dir in sections', function()
        local svg_file_name = 'test'
        local root_path, figures_full_path, svg_expected_path = generate_paths(svg_file_name, 'figures')

        assert.is_false(directory_exists(figures_full_path))
        assert.is_false(file_exists(svg_expected_path))

        vim.api.nvim_command("edit " .. root_path .. '/sections/test.tex')
        local was_success = illustrate.create_and_open_svg(svg_file_name)

        assert.is_true(was_success)
        assert.is_true(directory_exists(figures_full_path))
        assert.is_false(directory_exists(root_path .. '/' .. 'sections/figures'))
        assert.is_true(file_exists(svg_expected_path))
    end)

    it('should not create a figures dir in custom_name dir', function()
        local svg_file_name = 'test'
        local root_path, figures_full_path, svg_expected_path = generate_paths(svg_file_name, 'figures')

        assert.is_false(directory_exists(figures_full_path))
        assert.is_false(file_exists(svg_expected_path))

        vim.api.nvim_command("edit " .. root_path .. '/custom_name/test.tex')

        -- Make sure to add the 'custom_name' dir in the rules set.
        illustrate.setup({
            directories_to_avoid_creating_illustration_dir_in = {
                'custom_name'
            },
        })

        local was_success = illustrate.create_and_open_svg(svg_file_name)

        assert.is_true(was_success)
        assert.is_true(directory_exists(figures_full_path))
        assert.is_false(directory_exists(root_path .. '/custom_name/figures'))
        assert.is_true(file_exists(svg_expected_path))

        -- Revert custom config
        -- TODO: find a better way with setUp and tearDown to do this.
        illustrate.setup()
    end)

    it('should not create a figures dir with the indicated name', function()
        local svg_file_name = 'test'
        local root_path, figures_full_path, svg_expected_path = generate_paths(svg_file_name, 'illustrations')

        assert.is_false(directory_exists(figures_full_path))
        assert.is_false(file_exists(svg_expected_path))

        vim.api.nvim_command("edit " .. root_path .. '/test.tex')

        -- Make sure to add the 'custom_name' dir in the rules set.
        illustrate.setup({
            illustration_dir = "illustrations",
        })

        local was_success = illustrate.create_and_open_svg(svg_file_name)

        assert.is_true(was_success)
        assert.is_true(directory_exists(figures_full_path))
        assert.is_true(file_exists(svg_expected_path))

        -- Revert custom config
        -- TODO: find a better way with setUp and tearDown to do this.
        illustrate.setup()
    end)

    it('should not create figure with empty name', function()
        local svg_file_name = ''
        local root_path, figures_full_path, svg_expected_path = generate_paths(svg_file_name, 'figures')

        assert.is_false(directory_exists(figures_full_path))
        assert.is_false(file_exists(svg_expected_path))

        vim.api.nvim_command("edit " .. root_path .. '/test.tex')
        local was_success = illustrate.create_and_open_svg(svg_file_name)

        assert.is_false(was_success)
        assert.is_false(file_exists(svg_expected_path))
        assert.is_false(directory_exists(figures_full_path))
    end)

    it('should not create figure if file type is given in the file name', function()
        local svg_file_name = 'test.svg'
        local root_path, figures_full_path, svg_expected_path = generate_paths(svg_file_name, 'figures')

        assert.is_false(directory_exists(figures_full_path))
        assert.is_false(file_exists(svg_expected_path))

        vim.api.nvim_command("edit " .. root_path .. '/test.tex')
        local was_success = illustrate.create_and_open_svg(svg_file_name)

        assert.is_false(was_success)
        assert.is_false(file_exists(svg_expected_path))
        assert.is_false(directory_exists(figures_full_path))
    end)
end)

describe('test create_and_open_ai', function()
    local function generate_paths(ai_file_name, figures_path)
        local unique_number = uuid()
        local root_path = '/tmp/' .. unique_number
        lfs.mkdir(root_path)

        local figures_full_path = root_path .. '/' .. figures_path
        local svg_expected_path =  figures_full_path .. '/' .. ai_file_name .. '.ai'
        return root_path, figures_full_path, svg_expected_path
    end

    it('should create a new ai file in newly created figures dir', function()
        local ai_file_name = 'test'
        local root_path, figures_full_path, ai_expected_path = generate_paths(ai_file_name, 'figures')

        assert.is_false(directory_exists(figures_full_path))
        assert.is_false(file_exists(ai_expected_path))

        vim.api.nvim_command("edit " .. root_path .. '/test.tex')
        local was_success = illustrate.create_and_open_ai(ai_file_name)

        assert.is_true(was_success)
        assert.is_true(directory_exists(figures_full_path))
        assert.is_true(file_exists(ai_expected_path))
    end)
end)

describe('test get_all_illustration_files', function()
    local function generate_paths_svg(svg_file_name, figures_path)
        local unique_number = uuid()
        local root_path = '/tmp/' .. unique_number
        lfs.mkdir(root_path)

        local figures_full_path = root_path .. '/' .. figures_path
        local svg_expected_path =  figures_full_path .. '/' .. svg_file_name .. '.svg'
        return root_path, figures_full_path, svg_expected_path
    end

    local function generate_paths_ai(ai_file_name, figures_path)
        local unique_number = uuid()
        local root_path = '/tmp/' .. unique_number
        lfs.mkdir(root_path)

        local figures_full_path = root_path .. '/' .. figures_path
        local svg_expected_path =  figures_full_path .. '/' .. ai_file_name .. '.ai'
        return root_path, figures_full_path, svg_expected_path
    end

    it('should return empty table if no illustrations exists', function()
        local ai_file_name = 'test'
        local root_path, figures_full_path, ai_expected_path = generate_paths_ai(ai_file_name, 'figures')

        vim.api.nvim_command("edit " .. root_path .. '/test.tex')

        local all_illustrations = illustrate_utils.get_all_illustration_files()
        assert.is_same({}, all_illustrations)
    end)

    it('should return an svg file if one exists', function()
        local svg_file_name = 'test'
        local root_path, figures_full_path, svg_expected_path = generate_paths_svg(svg_file_name, 'figures')

        vim.api.nvim_command("edit " .. root_path .. '/test.tex')
        local was_success = illustrate.create_and_open_svg(svg_file_name)
        assert.is_true(was_success)

        local all_illustrations = illustrate_utils.get_all_illustration_files()
        assert.is_same({svg_expected_path}, all_illustrations)
    end)

    it('should return both svg and ai files if both exist', function()
        local file_name = 'test'
        local root_path, figures_full_path, svg_expected_path = generate_paths_svg(file_name, 'figures')
        local ai_expected_path = figures_full_path .. '/' .. file_name .. '.ai'


        vim.api.nvim_command("edit " .. root_path .. '/test.tex')
        local was_success = illustrate.create_and_open_svg(file_name)
        assert.is_true(was_success)
        was_success = illustrate.create_and_open_ai(file_name)
        assert.is_true(was_success)

        local all_illustrations = illustrate_utils.get_all_illustration_files()
        assert.is_same({svg_expected_path, ai_expected_path}, all_illustrations)
    end)

    it('should return multiple svg and ai files if all exist', function()
        local file_name_1 = 'test1'
        local root_path, figures_full_path, svg_expected_path_1 = generate_paths_svg(file_name_1, 'figures')
        local ai_expected_path_1 = figures_full_path .. '/' .. file_name_1 .. '.ai'

        local file_name_2 = 'test2'
        local svg_expected_path_2 = figures_full_path .. '/' .. file_name_2 .. '.svg'
        local ai_expected_path_2 = figures_full_path .. '/' .. file_name_2 .. '.ai'

        vim.api.nvim_command("edit " .. root_path .. '/test.tex')

        local was_success = illustrate.create_and_open_svg(file_name_1)
        assert.is_true(was_success)

        was_success = illustrate.create_and_open_svg(file_name_2)
        assert.is_true(was_success)

        was_success = illustrate.create_and_open_ai(file_name_1)
        assert.is_true(was_success)

        was_success = illustrate.create_and_open_ai(file_name_2)
        assert.is_true(was_success)

        local all_illustrations = illustrate_utils.get_all_illustration_files()
        assert.is_same({svg_expected_path_1, svg_expected_path_2,  ai_expected_path_1, ai_expected_path_2}, all_illustrations)
    end)
end)
