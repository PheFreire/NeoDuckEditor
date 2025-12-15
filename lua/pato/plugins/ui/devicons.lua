return {
  'nvim-tree/nvim-web-devicons',
  priority = 100000,
  config = function()
    require('nvim-web-devicons').setup {
      default = true,
      override = {
        py = { icon = "", color = "#61afef", cterm_color = "68", name = "Python" },
        js = { icon = "", color = "#F1E05A", cterm_color = "221", name = "JavaScript" },
        ts = { icon = "󰛦", color = "#2b7489", cterm_color = "31", name = "TypeScript" },
        html = { icon = "", color = "#E34C26", cterm_color = "196", name = "HTML" },
        css = { icon = "", color = "#563d7c", cterm_color = "98", name = "CSS" },
        go = { icon = "", color = "#00ADD8", cterm_color = "38", name = "Go" },
        rb = { icon = "", color = "#701516", cterm_color = "52", name = "Ruby" },
        php = { icon = "", color = "#4F5D95", cterm_color = "61", name = "PHP" },
        c = { icon = "", color = "#555555", cterm_color = "241", name = "C" },
        cpp = { icon = "", color = "#f34b7d", cterm_color = "204", name = "Cpp" },
        lua = { icon = "", color = "#51a0cf", cterm_color = "75", name = "Lua" },
        sh = { icon = "", color = "#808080", cterm_color = "245", name = "Shell" },
        md = { icon = "󰉉", color = "#519aba", cterm_color = "67", name = "Markdown" },
        json = { icon = "", color = "#cbcb41", cterm_color = "185", name = "JSON" },
        yaml = { icon = "", color = "#6d8086", cterm_color = "66", name = "YAML" },
        Dockerfile = { icon = "󰡨", color = "#2496ED", cterm_color = "32", name = "Dockerfile" },
        swift = { icon = "", color = "#F05138", cterm_color = "202", name = "Swift" },
        rs = { icon = "", color = "#dea584", cterm_color = "180", name = "Rust" },
        kt = { icon = "󱈙", color = "#F88A02", cterm_color = "208", name = "Kotlin" },
        hs = { icon = "", color = "#5e5086", cterm_color = "60", name = "Haskell" },
        [".envrc"] = { icon = "", color = "#808080", cterm_color = "245", name = "EnvRc" },
        Makefile = { icon = "", color = "#6d8086", cterm_color = "66", name = "Makefile" },
      }
    }
  end
}

