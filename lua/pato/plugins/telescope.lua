return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "folke/todo-comments.nvim",
    'nvim-telescope/telescope-live-grep-args.nvim',
  },
  config = function()
    local telescope = require("telescope")
    local actions = require('telescope.actions')
    local transform_mod = require("telescope.actions.mt").transform_mod
    local trouble = require("trouble")
    
    -- Cria ações personalizadas
    local custom_actions = transform_mod({
      open_trouble_qflist = function(prompt_bufnr)
        trouble.toggle("quickfix")
      end,
    })
 
    -- Configura o Telescope
    telescope.setup({
      defaults = {
        mappings = {
          n = {
            ["k"] = actions.move_selection_next,
            ["j"] = actions.move_selection_previous,
            ["h"] = actions.close,
            ["l"] = actions.select_default,
            ["<A-j>"] = actions.move_to_top,
            ["<A-k>"] = actions.move_to_bottom,
          },
        },
        preview = {
          mime_hook = function(filepath, bufnr, opts)
            local is_image = function(filepath)
              local image_extensions = {'png','jpg'}   -- Formatos de imagem suportados
              local split_path = vim.split(filepath:lower(), '.', {plain=true})
              local extension = split_path[#split_path]
              return vim.tbl_contains(image_extensions, extension)
            end
            if is_image(filepath) then
              local term = vim.api.nvim_open_term(bufnr, {})
              local function send_output(_, data, _ )
                for _, d in ipairs(data) do
                  vim.api.nvim_chan_send(term, d..'\r\n')
                end
            end
              vim.fn.jobstart(
                { 'catimg', filepath },
                { on_stdout=send_output, stdout_buffered=true, pty=true }
              )
            else
              require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
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
          "node_modules/", -- Ignora a pasta node_modules
          "__pycache__/",  -- Ignora cache do Python,
          ".mypy_cache/"
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
        file_previewer = require('telescope.previewers').vim_buffer_cat.new,
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
            "rg",
            "--files",
            "--hidden",
            "--glob",
            -- "!**/.git/*",
            '!.git/*',
            '--no-ignore', -- Não respeita o .gitignore
            '--smart-case',
          },
        },
      },
    })
    require('telescope').load_extension('fzf')
    require('telescope').load_extension('live_grep_args')
  end,
}
