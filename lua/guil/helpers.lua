---@class Helpers
local Helpers = {}

-- Execute given cli command and return output
--
---@param input string
---@return string?
local function execute_command(input)
    local handle = io.popen(input)

    if handle then
        local result = handle:read("*a")
        handle:close()
        -- Trim any leading/trailing whitespace
        return result:match("^%s*(.-)%s*$")
    else
        vim.notify("Failed to execute command: " .. input)
        return nil
    end
end

Helpers.header_template = [[
//
//  %s
//  %s
//
//  Created by %s on %s.
//  Copyright © %s %s. All rights reserved.
//
]]

-- Extract module name from path
--
-- Checks first for Tuist "Project/Targets/[ModuleName]/Sources/Filename.swift" pattern
-- then for SPM "Project/Sources/[ModuleName]/Filename.swift" pattern
-- if no Tuist or SPM detected, fallback to dirname
--
---@param filepath string
---@return string
Helpers.module_name = function(filepath)
    local cwd = vim.fn.getcwd()
    local cwd_name = vim.fn.fnamemodify(cwd, ":t")
    local module_name = filepath:match("/Targets/([^/]+)/Sources/[^/]+$")

    if not module_name then
        module_name = filepath:match("/Sources/([^/]+)/[^/]+$")
    end

    return module_name or cwd_name
end

-- Try to get username from git config or from mac username
--
---@return string?
Helpers.username = function()
    local name = execute_command("git config user.name")

    if not name or name == "" then
        name = execute_command('osascript -e "long user name of (system info)"')
    end

    if not name or name == "" then
        vim.notify("Failed to get username from both Git and system")
        return nil
    end

    return name
end

return Helpers