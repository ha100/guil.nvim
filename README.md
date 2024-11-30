<div align="center">

  <h1>guil.nvim</h1>
  <h5>Xcode style file header creator for nvim</h5>

</div>

## Table of Contents

- [Features](#features)
- [Installation](#installation)
  - [Requirements](#requirements)
  - [Setup Using Lazy](#lazy)
- [Lint](#lint)

## ✨ Features<a name="features"></a>

- [x] auto-insert Xcode style file header when creating a new file
- [x] use hotkey to manually insert header to a current buffer
- [x] display visual cues to user about invalid header info
- [x] update outdated header info in current file (author, company, module, file)
- [ ] specify own template

## 📦 Installation<a name="installation"></a>

### Requirements<a name="requirements"></a>

    git - to obtain username - will fallback to macOS username

### Setup Using Lazy<a name="lazy"></a>

```lua
return {
    dir = "https://github.com/ha100/guil.nvim",
    ft = "swift",
    lazy = false,
    config = function()
        require("guil").setup({
            company = "ha100"
        })
    end,
    keys = {
        vim.keymap.set("n", "<leader><F4>", ":Guil generate<cr>", { desc = "generate Xcode style header" })
    }
}
```

## 🛠️ Lint<a name="lint"></a>

PRs are checked with the following software:
- [luacheck](https://github.com/luarocks/luacheck#installation)
- [stylua](https://github.com/JohnnyMorganz/StyLua)
- [selene](https://github.com/Kampfkarren/selene)

To run the linter locally:

```shell
$ make lint
```

To install tools run:
```shell
$ make install-dev
```

