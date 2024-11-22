local helpers = require("guil.helpers")

---@class Options
---@field company string: copyright owner

---@toc guil.contents

---@mod mod.intro Introduction
---@brief [[
---
---a plugin to automatically generate Xcode style Swift hedaer
---
---there are currently multiple other plugins better suited for generating headers.
---this one was created just to serve the need to get into nvim lua plugin development.
---It will try to extract the user name from git and use macOS username as a backup.
---
---@brief ]]

-- Default options for the Module
--
local Module = {
    company = "",
}

---@mod mod.setup Setup
---@brief [[
---
---Setup the Module with user specified overrides for settings
---
---@brief ]]
---@param opts Options
---@usage lua [[
---return {
---    "https://github.com/ha100/guil.nvim",
---    ft = "swift",
---    lazy = false,
---    config = function()
---        require("guil").setup({
---            company = "ha100"
---        })
---    end,
---    keys = {
---        vim.keymap.set("n", "<leader><F4>", ":Guil generate<cr>", { desc = "generate Xcode style header" })
---    }
---}
---@usage ]]
Module.setup = function(opts)
    for key, value in pairs(opts) do
        Module[key] = value
    end
end

---@mod mod.insert_header InsertHeader
---@brief [[
---
---Insert Xcode style Swift header at the top of the file
---
---@brief ]]
---@usage lua `require('guil'):insert_header()`
Module.insert_header = function()
    local buf = vim.api.nvim_get_current_buf()
    local filepath = vim.api.nvim_buf_get_name(buf)
    local filename = vim.fn.fnamemodify(filepath, ":t")
    local author = helpers.username()
    local module_name = helpers.module_name(filepath)
    local current_date = os.date("%d/%m/%Y")
    local current_year = os.date("%Y")
    local header = string.format(
        helpers.header_template,
        filename,
        module_name,
        author,
        current_date,
        current_year,
        Module.company
    )

    -- Get the current content of the buffer
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    -- Insert the header at the top of the buffer
    vim.api.nvim_buf_set_lines(buf, 0, 0, false, vim.split(header, "\n"))

    -- Append the original content after the header
    vim.api.nvim_buf_set_lines(buf, #vim.split(header, "\n"), -1, false, lines)
end

return Module
