dofile("plugin/guil.lua")
local helper = require("tests.helper")
local eq = assert.are.equal
local current_dir = vim.fn.expand("%:p:h")
local file_path = current_dir .. "/tests/mocks/Test.swift"

describe("guil", function()
    before_each(function()
        require("guil").setup({ company = "ha100" })
    end)

    after_each(function()
        os.remove(file_path)
    end)

    it("injects header into newly created Swift file automatically", function()
        vim.cmd("edit " .. file_path)
        local bufnameOrigo = vim.fn.bufname("%")
        local bufOrigo = vim.fn.bufnr(bufnameOrigo)
        vim.api.nvim_buf_call(bufOrigo, function()
            vim.cmd("write!")
            vim.cmd("bdelete")
        end)

        local content = helper.read_file(file_path)
        local template = helper.update_dates(helper.templateNew)
        eq(template, content)
    end)

    it("injects header via command", function()
        local from_path = current_dir .. "/tests/mocks/mockExisting.swift"
        os.execute(('cp "%s" "%s"'):format(from_path, file_path))

        vim.cmd("edit " .. file_path)
        local bufnameOrigo = vim.fn.bufname("%")
        local bufOrigo = vim.fn.bufnr(bufnameOrigo)
        vim.cmd("Guil generate")
        vim.api.nvim_buf_call(bufOrigo, function()
            vim.cmd("write!")
            vim.cmd("bdelete")
        end)

        local content = helper.read_file(file_path)
        local template = helper.update_dates(helper.template)
        eq(template, content)
    end)
end)

describe("setup", function()
    it("will handle default options", function()
        local module = require("guil")
        module.setup({ company = "" })
        eq("", module.company)
    end)

    it("will pass through user options", function()
        local opts = {
            company = "ou",
        }

        local module = require("guil")
        module.setup(opts)
        eq("ou", module.company)
    end)
end)
