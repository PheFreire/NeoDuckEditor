return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "folke/todo-comments.nvim",
    'nvim-telescope/telescope-live-grep-args.nvim',
  },
  config = function()
    local telescope = require('telescope')
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    
    local open_after_tree = function(prompt_bufnr)
      local entry = action_state.get_selected_entry()
      actions.close(prompt_bufnr)
    
      vim.defer_fn(function()
        vim.cmd("edit " .. vim.fn.fnameescape(entry.path or entry.value))
      end, 20)
    end


    -- Configura o Telescope
    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-v>"] = function()
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-r>+", true, false, true), "n", true)
            end,
            ["<CR>"] = open_after_tree,
          },
          n = {
            ["k"] = actions.move_selection_next,
            ["j"] = actions.move_selection_previous,
            ["<A-j>"] = actions.move_to_top,
            ["<A-k>"] = actions.move_to_bottom,
            ["<CR>"] = open_after_tree

          },
        },
        preview = {
          mime_hook = function(filepath, bufnr, opts)
            local is_image = function(path)
              local supported_extensions = { "png", "jpg", "jpeg", "gif" }
              local ext = vim.fn.fnamemodify(path, ":e"):lower()
              return vim.tbl_contains(supported_extensions, ext)
            end

            if is_image(filepath) then
              local term = vim.api.nvim_open_term(bufnr, {})
              local function send_output(_, data, _)
                for _, line in ipairs(data) do
                  vim.api.nvim_chan_send(term, line .. "\r\n")
                end
              end

              vim.fn.jobstart({ "catimg", "-w", "80", filepath }, {
                on_stdout = send_output,
                stdout_buffered = true,
                pty = true,
              })
            end
          end
        },
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',  -- Adiciona a flag --hidden para incluir arquivos ocultos
          '--glob',
          '!.git/*', -- Exclui o diretório .git
          '--no-ignore', -- Não respeita o .gitignore
          '--fixed-strings',  -- Força a pesquisa literal (ignora expressões regulares)
        },
        file_ignore_patterns = {
          "%.exe",  -- Arquivos executáveis
          "%.bin",  -- Arquivos binários
          "%.dll",  -- Arquivos DLL no Windows
          "%.so",   -- Arquivos SO no Linux
          "%.o",    -- Arquivos objeto
          "%.a",     -- Ignora bibliotecas estáticas
          "%.class", -- Arquivos Java compilados
          "%.pyc",
          "%.pdf",   -- Ignora arquivos PDF
          "%.zip",   -- Ignora arquivos zipados
          "%.tar",   -- Ignora arquivos tar
          "%.gz",    -- Ignora arquivos gzip
          "%.d", -- ignora arquivos build do rust
          "%.rmeta",
          "%.rlib",
          "%.timestamp",
          "%.lock",
          "node_modules/", -- Ignora a pasta node_modules
          "__pycache__/",  -- Ignora cache do Python,
          ".mypy_cache/",
          "dist/",        -- ignora o diretório dist
          ".*/dist/.*",
          ".pytest_cache/"
        },
        -- Personalizações visuais e de comportamento
        prompt_prefix = "> ",
        selection_caret = "> ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "descending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            mirror = false,
          },
          vertical = {
            mirror = false,
          },
        },
        file_sorter = require('telescope.sorters').get_fuzzy_file,
        generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
        path_display = { "truncate" },
        winblend = 0,
        color_devicons = true,
        use_less = true,
        set_env = { ['COLORTERM'] = 'truecolor' },
        file_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
        grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
        qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
        buffer_previewer_maker = require('telescope.previewers').buffer_previewer_maker,
      },
      pickers = {
        live_grep = {
          grep_open_file = false,
        },
        find_files = {
          find_command = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',  -- Adiciona a flag --hidden para incluir arquivos ocultos
            '--glob',
            '!.git/*', -- Exclui o diretório .git
            '--no-ignore', -- Não respeita o .gitignore
            '--fixed-strings',  -- Força a pesquisa literal (ignora expressões regulares)
            "--files",
          },
        },
      },
    })
    -- telescope.load_extension('fzf')
    telescope.load_extension('live_grep_args')
  end,
}
