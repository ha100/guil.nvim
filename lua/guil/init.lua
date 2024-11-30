local helpers = require("guil.helpers")
local option_set = require("guil.optionSet")

---@class OptionSet
---@field contains table<number, boolean>
---@field new table

local OptionSet = option_set.OptionsSet
local options = option_set.Options

---@class Options
---@field company string: copyright owner

---@toc guil.contents

---@mod intro Introduction
---@brief [[
---
---a plugin to automatically generate Xcode style Swift file header
---
---Inserts the header when creating a new swift file. Detects module name for
---SPM and Tuist project structure. Username data is extracted from git and
---macOS username is used as a backup. If the header is present when opening
---an existing file, validation checks are performed and visual cues are given.
---
---@brief ]]

-- Default options for the Module
--
local Module = {
    company = "",
}

---@mod setup Setup
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

---@mod insert_header InsertHeader
---@brief [[
---
---Insert Xcode style Swift header at the top of the file
---
---@brief ]]
---@usage :Guil generate<cr>
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

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    vim.api.nvim_buf_set_lines(buf, 0, 0, false, vim.split(header, "\n"))
    vim.api.nvim_buf_set_lines(buf, #vim.split(header, "\n"), -1, false, lines)
end

---@mod has_header HasHeader
---@brief [[
---
---Check whether current buffer has header comment present
---
---@brief ]]
---@return boolean
Module.has_header = function()
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, 7, false)
    for _, line in ipairs(lines) do
        if not line:match("^//") then
            return false
        end
    end
    return true
end

---@mod check_header CheckHeader
---@brief [[
---
---Check which parts of the header comment are not compliant and return an OptionSet
---Mark the non-compliant parts with red color as a visual cue for user.
---
---@brief ]]
---@return OptionSet
Module.check_header = function()
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, 7, false)
    local changes = OptionSet.new()

    local filename = vim.api.nvim_buf_get_name(buf):match("([^/\\]+)$")
    local header_filename = lines[2]:match("//%s+([^%.]+%.%a+)")
    if filename ~= header_filename then
        changes:add(options.File)
        vim.api.nvim_buf_add_highlight(buf, -1, "ErrorMsg", 1, 0, -1)
    end

    local filepath = vim.api.nvim_buf_get_name(buf)
    local directory_name = helpers.module_name(filepath)
    local module_name = lines[3]:match("//%s+([^%s]+)")
    if directory_name ~= module_name then
        changes:add(options.Module)
        vim.api.nvim_buf_add_highlight(buf, -1, "ErrorMsg", 2, 0, -1)
    end

    local git_user = helpers.username()
    local header_author = lines[5]:match("Created by%s+([%w%s]+)%s+on")
    if git_user ~= header_author then
        changes:add(options.User)
        vim.api.nvim_buf_add_highlight(buf, -1, "ErrorMsg", 4, 0, -1)
    end

    local header_company = lines[6]:match("Copyright © %d+ (.+)%. All rights reserved%.")
    if Module.company ~= header_company then
        changes:add(options.Company)
        vim.api.nvim_buf_add_highlight(buf, -1, "ErrorMsg", 5, 0, -1)
    end

    return changes
end

---@mod update_header UpdateHeader
---@brief [[
---
---Update non-compliant parts of a header comment with valid info
---
---@brief ]]
Module.update_header = function()
    local optionset = Module.check_header()
    local buf = vim.api.nvim_get_current_buf()
    local filepath = vim.api.nvim_buf_get_name(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, 7, false)

    if optionset:contains(options.File) then
        local filename = vim.fn.fnamemodify(filepath, ":t")
        helpers.update(lines, 2, "//%s+([^%.]+%.%a+)", filename)
    end
    if optionset:contains(options.Module) then
        local updated_module_name = helpers.module_name(filepath)
        helpers.update(lines, 3, "//%s+([^%s]+)", updated_module_name)
    end
    if optionset:contains(options.User) then
        local git_user = helpers.username() or "N/A"
        helpers.update(lines, 5, "Created by%s+([%w%s]+)%s+on", git_user)
    end
    if optionset:contains(options.Company) then
        local company = Module.company
        helpers.update(lines, 6, "Copyright © %d+ (.+)%. All rights reserved%.", company)
    end
end

return Module
