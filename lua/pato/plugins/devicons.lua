return {
  'nvim-tree/nvim-web-devicons',
  lazy = false,
  priority = 100000,
  config = function()
    require('nvim-web-devicons').setup {
      default = true,
      override = {
        -- Python (.py)
        py = {
          icon = "",           -- Ícone do Python
          color = "#61afef",     -- Cor azul do Python
          name = "Python"
        },
        -- JavaScript (.js)
        js = {
          icon = "",           -- Ícone do JavaScript
          color = "#F1E05A",     -- Cor amarela do JavaScript
          name = "JavaScript"
        },
        -- TypeScript (.ts)
        ts = {
          icon = "",           -- Ícone do TypeScript
          color = "#2b7489",     -- Cor azul do TypeScript
          name = "TypeScript"
        },
        -- HTML (.html)
        html = {
          icon = "",           -- Ícone do HTML5
          color = "#E34C26",     -- Cor laranja do HTML
          name = "HTML"
        },
        -- CSS (.css)
        css = {
          icon = "",           -- Ícone do CSS3
          color = "#563d7c",     -- Cor roxa do CSS
          name = "CSS"
        },
        -- Go (.go)
        go = {
          icon = "",           -- Ícone do Go
          color = "#00ADD8",     -- Cor azul do Go
          name = "Go"
        },
        -- Ruby (.rb)
        rb = {
          icon = "",           -- Ícone do Ruby
          color = "#701516",     -- Cor vermelha do Ruby
          name = "Ruby"
        },
        -- PHP (.php)
        php = {
          icon = "",           -- Ícone do PHP
          color = "#4F5D95",     -- Cor azul escuro do PHP
          name = "PHP"
        },
        -- C (.c)
        c = {
          icon = "",           -- Ícone do C
          color = "#555555",     -- Cor cinza do C
          name = "C"
        },
        -- C++ (.cpp)
        cpp = {
          icon = "",           -- Ícone do C++
          color = "#f34b7d",     -- Cor rosa do C++
          name = "Cpp"
        },
        -- Lua (.lua)
        lua = {
          icon = "",           -- Ícone do Lua
          color = "#000080",     -- Cor azul escuro do Lua
          name = "Lua"
        },
        -- Shell Script (.sh)
        sh = {
          icon = "",           -- Ícone do Shell Script
          color = "#808080",     -- Cor cinza do Shell
          name = "Shell"
        },
        -- Markdown (.md)
        md = {
          icon = "",           -- Ícone do Markdown
          color = "#519aba",     -- Cor azul do Markdown
          name = "Markdown"
        },
        -- JSON (.json)
        json = {
          icon = "",           -- Ícone do JSON
          color = "#cbcb41",     -- Cor amarela do JSON
          name = "JSON"
        },
        -- YAML (.yml ou .yaml)
        yaml = {
          icon = "",           -- Ícone do YAML
          color = "#6d8086",     -- Cor cinza do YAML
          name = "YAML"
        },
        -- Dockerfile
        Dockerfile = {
          icon = "󰡨",           -- Ícone do Docker
          color = "#2496ED",     -- Cor do Docker
          name = "Dockerfile"
        },
        -- Swift (.swift)
        swift = {
          icon = "",           -- Ícone para Swift
          color = "#F05138",     -- Cor laranja do Swift
          name = "Swift"
        },
        -- Rust (.rs)
        rs = {
          icon = "",           -- Ícone para Rust
          color = "#dea584",     -- Cor marrom do Rust
          name = "Rust"
        },
        -- Kotlin (.kt)
        kt = {
          icon = "",           -- Ícone para Kotlin
          color = "#F88A02",     -- Cor laranja do Kotlin
          name = "Kotlin"
        },
        -- Haskell (.hs)
        hs = {
          icon = "",           -- Ícone para Haskell
          color = "#5e5086",     -- Cor roxa do Haskell
          name = "Haskell"
        },
        -- Arquivo .envrc
        [".envrc"] = {
          icon = "",
          color = "#808080",
          name = "EnvRc"
        },
        -- Makefile
        Makefile = {
          icon = "",               -- Engrenagem
          color = "#E37933",         -- Laranja
          name = "Makefile"
        },
      }
    }
  end
}
