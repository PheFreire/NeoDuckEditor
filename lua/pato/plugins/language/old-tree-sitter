return {
  "nvim-treesitter/nvim-treesitter",
  build = function()
    require("nvim-treesitter.install").update({ with_sync = true })()
  end,
  branch = 'master',
  lazy = false,
  config = function()
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      ensure_installed = {
        "bash", "c", "diff", "html", "javascript", "jsdoc", "json", "jsonc",
        "lua", "luadoc", "luap", "printf",
        "python", "query", "regex", "toml", "tsx", "typescript", "vim",
        "vimdoc", "xml", "yaml", "css", "scss", "rust", "go", "php", "sql",
        "dockerfile", "terraform", "gitignore", "prisma",
      },

      sync_install = false,
      indent = { enable = true, },
      autotag = { enable = true, },
      highlight = {
        enable = true,
        disable = function(_, bufnr)
          local ok, bt = pcall(function() return vim.bo[bufnr].buftype end)
          if not ok then return true end
          return bt == "nofile" or bt == "prompt" or bt == "nowrite"
        end,
      },
      additional_vim_regex_highlighting = false,
    })
  end
}

