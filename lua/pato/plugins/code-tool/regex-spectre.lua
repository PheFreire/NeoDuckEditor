return {
  "nvim-pack/nvim-spectre",
  config = function()
    _G.globalSpectreReplacer = function()
      local entries = require('spectre.actions').get_all_entries() or {}
      local state = require('spectre.actions').get_state()
      local replace = state.query.replace_query or ""
      local search = state.query.search_query or ""
      local function table_length(tbl)
        local count = 0
        for _ in pairs(tbl) do
          count = count + 1
        end
        return count
      end

      if table_length(entries) == 0 or search == "" or replace == "" then
        vim.notify("❌ Spectre: empty search, replace or no matches found.", vim.log.levels.WARN)
        return
      end

      local function escape(str)
        return str
          :gsub("%%", "%%%%")  -- escapa '%' para não quebrar string.format
          :gsub("/", "\\/")    -- escapa '/' para não quebrar :s///
      end

      if replace:find("\\r") then
        local escaped_search = escape(search)
        local escaped_replace = escape(replace)
        require("spectre.actions").send_to_qf()

        vim.defer_fn(function()
          local cmd = string.format("cdo %%s/\\v%s/%s/g | update", escaped_search, escaped_replace)
          vim.cmd(cmd)
        end, 100)

        vim.cmd("silent cclose")
        vim.notify("🔁 Replacement executed using :cdo on Spectre results (multiline).", vim.log.levels.INFO)
        return
      end
        require("spectre.actions").run_replace()
        vim.notify("✅ Replacement executed using Spectre (normal).", vim.log.levels.INFO)
    end

    require('spectre').setup({
      color_devicons = true,
      open_cmd = "noswapfile vnew",
      live_update = false,
      lnum_for_results = true,
      line_sep_start = "╭─────────────────────────────────────",
      result_padding = "│ ",
      line_sep =       "╰─────────────────────────────────────",
      highlight = {
          ui = "Comment",
          search = "Search",
          replace = "IncSearch"
      },
      mapping={
        ['toggle_line'] = {
            map = "dd",
            cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
            desc = "toggle item"
        },
        ['enter_file'] = {
            map = "<cr>",
            cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
            desc = "open file"
        },
        ['run_current_replace'] = {
          map = "<leader>r",
          cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
          desc = "replace current line"
        },
        ['run_replace'] = {
            map = "<leader>R",
            cmd =  "<cmd>lua globalSpectreReplacer()<CR>",
            desc = "replace all"
        },
        ['toggle_ignore_case'] = {
          map = "<leader>c",
          cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
          desc = "toggle ignore case"
        },
        ['delete_line'] = {
            map = '<leader>d',
            cmd = "<cmd>lua require('spectre.actions').run_delete_line()<CR>",
            desc = 'delete line',
        }
      },
      find_engine = {
        ['rg'] = {
          cmd = "rg",
          args = {
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--multiline',
            '--pcre2'
          },
          options = {
            ['ignore-case'] = {
              value= "--ignore-case",
              icon="[I]",
              desc="ignore case"
            },
            ['hidden'] = {
              value="--hidden",
              desc="hidden file",
              icon="[H]"
            },
          }
        },
      },
      replace_engine={
          ['sed']={
              cmd = 'gsed',
              args = { "-E", "-i" },
              options = {
                ['ignore-case'] = {
                  value= "--ignore-case",
                  icon="[I]",
                  desc="ignore case"
                },
              }
          },
          ['perl'] = {
            cmd = "perl",
            args = { "-0777", "-pi", "-e" },
            options = {
              ['ignore-case'] = {
                value = "",
                icon = "[I]",
                desc = "ignore case (adicione (?i) na regex manualmente)"
              }
            }
          }
      },
      default = {
          find = {
              cmd = "rg",
              options = {"ignore-case"}
          },
          replace={
              cmd = "sed"
          }
      },
      replace_vim_cmd = "cdo",
      use_trouble_qf = false,
      is_open_target_win = true,
      is_insert_mode = false,
      is_multiline = true,
      is_block_ui_break = false
    })

  end,
}

