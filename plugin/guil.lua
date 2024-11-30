vim.api.nvim_create_augroup("NewFileGroup", { clear = true })
vim.api.nvim_create_augroup("HeaderCheckGroup", { clear = true })

vim.api.nvim_create_autocmd("BufNewFile", {
    group = "NewFileGroup",
    pattern = "*.swift",
    callback = function()
        local guil = require('guil')
        guil.insert_header()
    end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    group = "HeaderCheckGroup",
    pattern = "*.swift",
    callback = function()
        local guil = require('guil')
        if guil.has_header() then
            guil.check_header()
        end
    end,
})

vim.api.nvim_create_user_command("Guil", function(opts)
    local guil = require('guil')
    if opts.fargs[1] == "generate" then
        if guil.has_header() then
            guil.update_header()
        else
            guil.insert_header()
        end
    end
end, {
    range = false,
    nargs='?'
})

