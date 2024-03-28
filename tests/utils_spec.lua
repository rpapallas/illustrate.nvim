local uuid = require("uuid")
local lfs = require("lfs")
local illustrate = require('illustrate')

describe('test create_and_open_svg', function()
    local function generate_paths(svg_file_name, figures_path)
        local unique_number = uuid()
        local root_path = '/tmp/' .. unique_number
        lfs.mkdir(root_path)

        local figures_full_path = root_path .. '/' .. figures_path
        local svg_expected_path =  figures_full_path .. '/' .. svg_file_name .. '.svg'
        return root_path, figures_full_path, svg_expected_path
    end

    local function directory_exists(path)
        return lfs.attributes(path, "mode") == "directory"
    end

    local function file_exists(path)
        return lfs.attributes(path, "mode") == "file"
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

    it('should not create figure with empty name', function()
        local svg_file_name = ''
        local root_path, figures_full_path, svg_expected_path = generate_paths(svg_file_name, 'figures')

        assert.is_false(file_exists(svg_expected_path))

        vim.api.nvim_command("edit " .. root_path .. '/test.tex')
        local was_success = illustrate.create_and_open_svg(svg_file_name)

        assert.is_false(was_success)
        assert.is_false(file_exists(svg_expected_path))
    end)
end)
