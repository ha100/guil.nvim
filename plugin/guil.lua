
vim.api.nvim_create_augroup("NewFileGroup", { clear = true })

vim.api.nvim_create_autocmd("BufNewFile", {
    group = "NewFileGroup",
    pattern = "*.swift",
    callback = function()
        local guil = require('guil')
        guil.insert_header()
    end,
})

vim.api.nvim_create_user_command("Guil", function(opts)
    local guil = require('guil')
    if opts.fargs[1] == "generate" then
        guil.insert_header()
    end
end, {
    range = false,
    nargs='?'
})

