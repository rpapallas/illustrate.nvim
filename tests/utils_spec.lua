local uuid = require("uuid")
local utils = require('illustrate.utils')
local illustrate = require('illustrate')

describe('test get_path_to_illustration_dir', function()
    it('should return nil if no figures dir exists', function()
        local unique_number = uuid()
        local root_path = '/tmp/' .. unique_number

        vim.api.nvim_command('edit ' .. root_path .. '/test.tex')
        assert.are.same(utils.get_path_to_illustration_dir(), nil)
    end)

    it('should return /figures if figures in root exists while editing a file in root', function()
        local unique_number = uuid()
        local root_path = '/tmp/' .. unique_number

        os.execute('mkdir -p ' .. root_path .. '/figures')
        vim.api.nvim_command("edit " .. root_path .. '/test.tex')
        assert.are.same(utils.get_path_to_illustration_dir(), root_path .. '/figures')
    end)

    it('should return /sections/figures if figures in sections while editing a file in sections', function()
        local unique_number = uuid()
        local root_path = '/tmp/' .. unique_number

        os.execute('mkdir -p ' .. root_path .. '/sections/figures')
        vim.api.nvim_command("edit " .. root_path .. '/sections/test.tex')
        assert.are.same(utils.get_path_to_illustration_dir(), root_path .. '/sections/figures')
    end)

    it('`figures` in `sections`, editing a file in root, returns the nil', function()
        local unique_number = uuid()
        local root_path = '/tmp/' .. unique_number

        os.execute('mkdir -p ' .. root_path .. '/sections/figures')
        vim.api.nvim_command("edit " .. root_path .. '/test.tex')
        assert.are.same(utils.get_path_to_illustration_dir(), nil)
    end)

    it('two `figures` (`root` and `sections`), editing a file in root, returns the `/figures`', function()
        local unique_number = uuid()
        local root_path = '/tmp/' .. unique_number

        os.execute('mkdir -p ' .. root_path .. '/sections/figures')
        os.execute('mkdir -p ' .. root_path .. '/figures')
        vim.api.nvim_command("edit " .. root_path .. '/test.tex')
        assert.are.same(utils.get_path_to_illustration_dir(), root_path .. '/figures')
    end)

    it('two `figures` (`root` and `sections`), editing a file in `sections`, returns the `sections/figures`', function()
        local unique_number = uuid()
        local root_path = '/tmp/' .. unique_number

        os.execute('mkdir -p ' .. root_path .. '/sections/figures')
        os.execute('mkdir -p ' .. root_path .. '/figures')
        vim.api.nvim_command("edit " .. root_path .. '/sections/test.tex')
        assert.are.same(utils.get_path_to_illustration_dir(), root_path .. '/sections/figures')
    end)
end)

describe('test create_and_open_svg', function()
    it('create new svg without figures', function()
        local unique_number = uuid()
        local root_path = '/tmp/' .. unique_number
        local file_name = 'test'
        local file_path = root_path .. '/figures/' .. file_name .. '.svg'
        os.execute('mkdir -p ' .. root_path)

        vim.api.nvim_command("edit " .. root_path .. '/test.tex')
        illustrate.create_and_open_svg(file_name)
        local file = io.open(file_path, "r")
        assert.is.truthy(file)
        file:close()
    end)
end)
