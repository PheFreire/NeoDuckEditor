<p align="center">
  <img src="assets/logo.png" alt="NeoDuckEditor Logo" width="150" />
</p>

<h1 align="center">NeoDuckEditor</h1>

<p align="center">
  Uma configuração de Neovim altamente personalizada, rápida e opinativa — construída para desenvolvimento de software moderno com uma ergonomia de teclado própria.
</p>

---

## Bem-vindo

Este repositório é o setup pessoal de Neovim. Não é um framework nem uma distribuição — é uma configuração construída do zero com decisões deliberadas sobre cada detalhe: navegação, aparência, ferramentas de código e fluxo de trabalho.

O projeto segue uma filosofia simples: **menos cliques, mais foco**. Cada plugin foi escolhido por um motivo claro, cada atalho foi pensado para eliminar fricção. O resultado é um editor que se comporta como uma extensão natural do pensamento, não como um obstáculo entre você e o código.

Destaques do setup:
- Navegação remapeada completamente (sem depender do layout padrão HJKL do Vim)
- LSP completo com 11 servidores de linguagem configurados e auto-instalados
- Debugging integrado para C via nvim-dap + CodeLLDB (UI automática, virtual text inline)
- Tema próprio `dark-duck`, construído sobre tonalidades quentes de preto e amarelo
- File explorer moderno via Oil.nvim (edita arquivos como buffers)
- Busca poderosa com Telescope + ripgrep
- Multi-cursor, find & replace global, folding via Treesitter

---

## Estrutura de Diretórios

```
nvim/
├── init.lua                        # Ponto de entrada: carrega core, lazy e tema
├── colors/
│   └── dark-duck.lua               # Tema customizado baseado em xeno.nvim
├── assets/
│   └── logo.png                    # Logo do projeto
├── setup.sh                        # Script de instalação de dependências externas
├── Makefile                        # Utilitários de build
├── lazy-lock.json                  # Lockfile do lazy.nvim (versões fixas dos plugins)
└── lua/
    └── pato/
        ├── lazy.lua                # Bootstrap e configuração do lazy.nvim
        ├── theme-selection.lua     # Carregamento do tema ativo
        └── core/
        │   ├── init.lua            # Orquestrador do core
        │   ├── options.lua         # Opções globais do Vim/Neovim
        │   ├── highlights.lua      # Customizações de highlight e diagnósticos
        │   ├── lsp-buffer.lua      # Comportamento de diagnóstico e hover do LSP
        │   ├── kitty_spacing.lua   # Integração de espaçamento com Kitty terminal
        │   ├── aesthetics/
        │   │   ├── excluded-themes.lua   # Temas excluídos do seletor
        │   │   ├── function-fold.lua     # Configuração de folding via Treesitter
        │   │   └── duck-mono.lua         # Variante monocromática do tema
        │   └── keymaps/
        │       ├── init.lua        # Importa todos os módulos de keymaps
        │       ├── core.lua        # Navegação, clipboard, buffer, undo (~60 keybinds)
        │       ├── comment.lua     # Toggle de comentários
        │       ├── fold.lua        # Toggle de folding
        │       ├── dap.lua         # Debug: breakpoints, step, UI toggle
        │       ├── leap.lua        # Salto entre janelas
        │       ├── markdown.lua    # Preview de Markdown
        │       ├── nvim-lsp.lua    # Hover, go-to-def, referências, format
        │       ├── obsidian.lua    # Abertura do vault Obsidian
        │       ├── oil.lua         # File explorer (float e aba)
        │       ├── spectre.lua     # Find & replace global
        │       ├── split-window.lua  # Divisão e redimensionamento de janelas
        │       ├── tab.lua         # Gerenciamento de abas
        │       ├── telescope.lua   # Busca de arquivos, grep, buffers, temas
        │       ├── terminal.lua    # Sessões de terminal nomeadas
        │       ├── trouble.lua     # Diagnósticos do workspace
        │       └── visual-multi.lua  # Configuração de multi-cursor
        └── plugins/
            ├── nvim-cmp.lua        # Engine de autocompletion
            ├── ui/                 # Aparência: temas, lualine, oil, trouble, devicons
            ├── code-tool/          # Ferramentas de código: telescope, spectre, leap, flash
            ├── language/           # LSP + DAP: mason, mason-lspconfig, treesitter, nvim-dap
            ├── file-support/       # Suporte a arquivos: obsidian, dotenv
            ├── home-page/          # Dashboard de boas-vindas (alpha-nvim)
            ├── utils/              # Markdown preview
            └── optimization-tool/  # Bigfile (desabilita features em arquivos grandes)
```

---

## Instalação

**Pré-requisitos:** Neovim `>= 0.9`, `git`, `ripgrep`, `node`, `npm`, `cargo`

```bash
# Clone o repositório
git clone https://github.com/PheFreire/NeoDuckEditor ~/.config/nvim

# Instale as dependências externas (catimg, FiraCode Nerd Font)
bash ~/.config/nvim/setup.sh

# Abra o Neovim — o lazy.nvim vai instalar todos os plugins automaticamente
nvim
```

> **Fonte recomendada:** FiraCode Nerd Font (instalada pelo `setup.sh`). Sem ela, os ícones não renderizam corretamente.

---

## Opções Globais

Configuradas em `lua/pato/core/options.lua`.

### Editor

| Opção | Valor | Efeito |
|---|---|---|
| `fileencoding` | `utf-8` | Codificação padrão |
| `clipboard` | `unnamedplus` | Integração com clipboard do sistema |
| `wrap` | `false` | Sem quebra de linha suave |
| `linebreak` | `true` | Quebra em fronteiras de palavra |
| `cursorline` | `true` | Destaca a linha atual |
| `number` | `true` | Números de linha |
| `signcolumn` | `no` | Sem coluna de sinais (mais espaço) |
| `updatetime` | `300ms` | Intervalo para swap e CursorHold |
| `timeoutlen` | `500ms` | Timeout para sequências de teclas |
| `swapfile` | `false` | Sem swap file |

### Indentação

| Opção | Valor |
|---|---|
| `tabstop` | 2 espaços |
| `shiftwidth` | 2 espaços |
| `expandtab` | `true` (espaços, não tabs) |
| `autoindent` | `true` |

### Busca

| Opção | Valor |
|---|---|
| `hlsearch` | `true` (destaca resultados) |
| `ignorecase` | `true` (case-insensitive por padrão) |
| `smartcase` | `true` (case-sensitive se usar maiúsculas) |
| `inccommand` | `split` (preview de substituições em split) |

### Janelas

| Opção | Valor |
|---|---|
| `splitbelow` | `true` (splits abaixo) |
| `splitright` | `true` (splits à direita) |
| `winborder` | `rounded` |
| `pumheight` | `10` (altura do menu de completion) |

---

## Tema

O tema padrão é o **dark-duck**, uma criação própria construída sobre o `xeno.nvim`. Ele foi desenhado para sessões longas de código, com contraste cuidadoso e tonalidades quentes.

| Elemento | Cor | Descrição |
|---|---|---|
| Background | `#11100f` | Preto quente (quase preto) |
| Foreground | `#e6e0c2` | Creme suave |
| Accent / Keywords | `#FFCC33` | Amarelo dourado |
| Strings | `#ccb973` | Tan quente |
| Built-ins | `#e78a4e` | Laranja |
| Fields | `#d8c080` | Tan claro |
| Comments | Cinza, itálico | |
| Cursor line | `#2a2927` | Fundo levemente mais claro |

O seletor de temas (`tt` no modo normal) exibe apenas temas instalados, excluindo os defaults do Vim e variantes do GitHub que não se encaixam no setup.

---

## Gerenciador de Plugins

Usa o **lazy.nvim** com bootstrap automático. Na primeira execução, o lazy é clonado do GitHub e todos os plugins são instalados automaticamente. O lockfile `lazy-lock.json` garante versões reproduzíveis.

Os plugins são divididos em 8 categorias carregadas como módulos separados:

| Módulo | Conteúdo |
|---|---|
| `pato.plugins` | nvim-cmp (autocompletion) |
| `pato.plugins.ui` | Temas, lualine, oil, trouble, devicons, indent |
| `pato.plugins.code-tool` | Telescope, Spectre, Leap, Flash, Visual Multi |
| `pato.plugins.language` | Mason, mason-lspconfig, Treesitter, nvim-dap (C debug) |
| `pato.plugins.file-support` | Obsidian, dotenv |
| `pato.plugins.home-page` | Alpha dashboard |
| `pato.plugins.utils` | Markdown preview |
| `pato.plugins.optimization-tool` | Bigfile (desabilita features em arquivos > 2MB) |

> Na inicialização, o lazy também executa `kitty @ set-spacing margin=0` para remover margens do Kitty terminal, integrando o editor à janela.

---

## Keybinds

> **Leader key:** `Space`

O setup usa um **layout de navegação remapeado**. As teclas padrão do Vim foram reorganizadas para uma ergonomia diferente:

| Tecla original | Função no Vim | Mapeamento aqui |
|---|---|---|
| `h/l` | esquerda/direita | movimento horizontal com wrap de linha |
| `j/k` | cima/baixo | invertidos: `j` = cima, `k` = baixo |
| `i` | insert mode | `startinsert<Right>` (posição natural) |

---

### Navegação — Modo Normal

| Tecla | Ação |
|---|---|
| `j` | Cima |
| `k` | Baixo |
| `h` | Esquerda (wrap para linha anterior se no início) |
| `l` | Direita (wrap para linha seguinte se no final) |
| `<C-h>` | Palavra anterior (`b`) |
| `<C-l>` | Final da próxima palavra (`e`) |
| `<A-h>` | Início da linha (`0`) |
| `<A-l>` | Final da linha (`$`) |
| `<A-j>` | Início do arquivo (`gg`) |
| `<A-k>` | Final do arquivo (`G`) |
| `<C-Left>` | Palavra anterior |
| `<C-Right>` | Próxima palavra |
| `J` | Scroll da tela para cima (2 linhas, cursor fixo) |
| `K` | Scroll da tela para baixo (2 linhas, cursor fixo) |

---

### Navegação — Modo Insert

| Tecla | Ação |
|---|---|
| `<A-h/j/k/l>` | Movimento direcional |
| `<A-H>` | Palavra anterior |
| `<A-L>` | Próxima palavra |
| `<A-J>` | Início do arquivo |
| `<A-K>` | Final do arquivo |
| `<A-Left>` | Início da linha |
| `<A-Right>` | Final da linha |
| `<C-Left>` | Palavra anterior (com lógica de linha) |
| `<C-Right>` | Próxima palavra (com lógica de linha) |
| `jk` | Sair do insert mode |
| `<C-H>` | Deletar palavra anterior |

---

### Buffer e Arquivo

| Tecla | Modo | Ação |
|---|---|---|
| `<C-s>` | n / i | Salvar |
| `<C-q>` | n | Fechar sem salvar |
| `<leader>gb` | n | Abrir último buffer |
| `<leader>n` | n | Novo buffer sem nome |
| `cc` | n | Copiar path do buffer atual para o clipboard |

---

### Clipboard

| Tecla | Modo | Ação |
|---|---|---|
| `<C-c>` | v | Copiar seleção para clipboard do sistema |
| `<C-x>` | v | Recortar seleção |
| `<C-v>` | i | Colar do clipboard do sistema |
| `x` | v | Deletar sem afetar o clipboard (`"_d`) |

---

### Undo / Redo

| Tecla | Modo | Ação |
|---|---|---|
| `<C-z>` | n / i | Desfazer |
| `<A-z>` | n / i | Refazer |

---

### Janelas (splits)

Configurado em `keymaps/split-window.lua`.

| Tecla | Ação |
|---|---|
| `<leader>s` | Dividir verticalmente |
| `<leader>ss` | Dividir horizontalmente |
| `<leader>sx` | Fechar split atual |
| `<leader>sj` | Diminuir altura |
| `<leader>sk` | Aumentar altura |
| `<leader>sh` | Diminuir largura (-5) |
| `<leader>sl` | Aumentar largura (+5) |

---

### Abas

Configurado em `keymaps/tab.lua`.

| Tecla | Ação |
|---|---|
| `<leader>to` | Abrir nova aba |
| `<leader>tx` | Fechar aba atual |
| `<leader>l` | Próxima aba |
| `<leader>h` | Aba anterior |

---

### Telescope — Busca

Configurado em `keymaps/telescope.lua` e `plugins/code-tool/telescope.lua`.

| Tecla | Ação |
|---|---|
| `<leader>ff` | Buscar arquivos |
| `<leader>fg` | Live grep (busca em conteúdo) |
| `<leader>fs` | Grep na palavra sob o cursor |
| `<leader>t` | Listar buffers abertos |
| `tt` | Seletor de temas (filtrado) |

**Dentro do Telescope (navegação adaptada ao layout):**

| Tecla | Ação |
|---|---|
| `k` | Próximo item |
| `j` | Item anterior |
| `<A-j>` | Ir ao topo da lista |
| `<A-k>` | Ir ao final da lista |
| `<CR>` | Selecionar |
| `<C-v>` | Colar no campo de busca |

---

### Oil — File Explorer

Configurado em `keymaps/oil.lua` e `plugins/ui/oil.lua`.

O Oil permite editar o sistema de arquivos como se fosse um buffer de texto: renomear, mover, deletar e criar arquivos com os mesmos comandos de edição do Neovim.

| Tecla | Ação |
|---|---|
| `<leader>f` | Abrir Oil em float |
| `<leader>ee` | Abrir Oil em nova aba (CWD) |
| `p` | Toggle painel de preview |

**Dentro do buffer do Oil:**

| Tecla | Ação |
|---|---|
| `<C-s>` | Salvar alterações |
| `<Esc>` / `q` | Fechar |
| `o` | Abrir arquivo com app padrão do sistema |
| `v` / `<A-v>` | Entrar em modo visual |

---

### LSP

Configurado em `keymaps/nvim-lsp.lua`, `plugins/language/mason-lsp.lua` e `core/lsp-buffer.lua`.

| Tecla | Ação |
|---|---|
| `<leader>gg` | Hover (documentação inline) |
| `<leader>gd` | Ir à definição |
| `<leader>gr` | Ver referências |
| `<leader>gs` | Símbolos do documento |
| `<leader>gf` | Formatar seleção (visual) |
| `<leader>er` | Reiniciar LSP |
| `e` | Abrir float de diagnóstico no cursor |
| `ee` | Ver erros do workspace (via Telescope) |

---

### Spectre — Find & Replace Global

Configurado em `keymaps/spectre.lua` e `plugins/code-tool/regex-spectre.lua`.

Usa `ripgrep` como engine de busca e `sed` como engine de substituição, com suporte a PCRE2 para regex avançado.

| Tecla | Ação |
|---|---|
| `<C-f>` | Abrir/fechar painel do Spectre |

**Dentro do Spectre:**

| Tecla | Ação |
|---|---|
| `dd` | Toggle linha (incluir/excluir da substituição) |
| `<CR>` | Abrir arquivo da linha |
| `<leader>r` | Substituir linha atual |
| `<leader>R` | Substituir tudo |
| `<leader>c` | Toggle case-insensitive |
| `<leader>d` | Deletar linha |

---

### Terminal

Configurado em `keymaps/terminal.lua`.

| Tecla | Modo | Ação |
|---|---|---|
| `<C-t>` | n | Criar sessão de terminal (pede um nome) |
| `jk` | t | Sair do modo terminal (`<C-\><C-n>`) |

---

### Debug — DAP

Configurado em `keymaps/dap.lua` e `plugins/language/nvim-dap.lua`.

O adaptador **CodeLLDB** é instalado automaticamente pelo Mason. Ao iniciar o debug (`<F5>`), o dapui abre automaticamente com painel lateral (variáveis, breakpoints, call stack, watches) e console inferior. Os valores das variáveis aparecem inline no código via virtual text.

**Fluxo de uso:** compile com `gcc -g main.c -o main`, pressione `<F5>` e selecione o binário no input.

| Tecla | Ação |
|---|---|
| `<F5>` | Iniciar / Continuar sessão |
| `<F10>` | Step Over (próxima linha) |
| `<F11>` | Step Into (entrar na função) |
| `<F12>` | Step Out (sair da função) |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Breakpoint condicional (pede expressão) |
| `<leader>du` | Toggle UI manualmente |
| `<leader>dr` | Abrir REPL |
| `<leader>dl` | Repetir última sessão |

**Layout do dapui:**

| Posição | Painéis |
|---|---|
| Lateral esquerda | Scopes (35%), Breakpoints (15%), Call Stack (30%), Watches (20%) |
| Inferior | REPL (50%), Console (50%) |

---

### Outras Ferramentas

| Tecla | Modo | Ação |
|---|---|---|
| `<leader><leader>` | n | Toggle fold |
| `<leader>sw` | n | Leap — saltar para outra janela |
| `<C-_>` | n / v / i | Toggle comentário (linha ou seleção) |
| `<C-f>` | n | Abrir Spectre (find & replace) |
| `<leader>p` | n | Preview de Markdown no browser |
| `<leader>o` | n | Abrir Obsidian |
| `//` | n | Limpar highlight de busca |
| `m` | n | Toggle word wrap |

---

### Multi-cursor (Visual Multi)

Configurado em `keymaps/visual-multi.lua` e `plugins/code-tool/vs-code-tools.lua`.

| Tecla | Modo | Ação |
|---|---|---|
| `<A-s>` | i | Selecionar ocorrência sob o cursor (com conversão de case) |
| `<A-d>` | i | Selecionar ocorrência sob o cursor (sem conversão de case) |

Dentro do modo multi-cursor, as teclas de navegação são remapeadas automaticamente para o layout personalizado (`j/k/h/l`, `J/K` para scroll, etc.).

---

## LSP — Language Server Protocol

O LSP é gerenciado pelo **Mason** com instalação automática. Na primeira abertura do Neovim, os servidores são baixados e configurados sem nenhuma intervenção manual.

### Servidores Configurados

| Servidor | Linguagem | Configurações especiais |
|---|---|---|
| `pyright` | Python | Type checking básico, extra paths `src`, ignora `build/dist/__pycache__` |
| `rust_analyzer` | Rust | Todos os features Cargo habilitados, Clippy no save, lens habilitado |
| `lua_ls` | Lua | Globals: `vim`, `Snacks`, `require` |
| `ts_ls` | TypeScript / JavaScript | JS, JSX, TS, TSX. Sugestões desabilitadas |
| `eslint` | JS / TS | Linting para JS, JSX, TS, TSX |
| `biome` | JS / TS | Formatter + linter alternativo |
| `emmet_ls` | HTML / JSX / TSX | Snippets de expansão HTML |
| `cssls` | CSS / SCSS / Less | Validação CSS, lint flexível |
| `clangd` | C / C++ | |
| `html` | HTML | |
| `tailwindcss` | Tailwind | |

### Ferramentas Auto-instaladas via Mason

Além dos language servers, o Mason instala automaticamente:

**Formatters:** `stylua`, `prettier`, `black`, `autopep8`, `biome`, `clang-format`

**Linters:** `eslint-lsp`, `quick_lint_js`, `editorconfig-checker`

**Debug:** `codelldb` (adaptador DAP para C/C++/Rust via CodeLLDB)

**Outros:** `emmet-ls`, `jsonls`, `lemminx`, `marksman`, `js-debug-adapter`

### Comportamento de Diagnósticos

| Configuração | Valor |
|---|---|
| Virtual lines | Habilitado (mostra erros abaixo da linha) |
| Virtual text | Desabilitado |
| Underline | Habilitado |
| Severity sort | Habilitado |
| Float border | Bold |

**Ícones de diagnóstico:**

| Severidade | Ícone |
|---|---|
| Error | `󰅚` |
| Warning | `󰀪` |
| Info | `󰋽` |
| Hint | `󰌶` |

---

## Treesitter — Syntax Highlighting

Configurado em `plugins/language/treesitter.lua`. Instala parsers automaticamente para 45 linguagens.

**Web:** `javascript`, `typescript`, `tsx`, `html`, `css`, `scss`, `json`, `jsonc`, `yaml`, `graphql`, `prisma`, `svelte`, `markdown`

**Sistemas:** `c`, `cpp`, `rust`, `python`, `go`, `bash`, `lua`, `vim`, `dockerfile`, `toml`, `xml`, `sql`, `terraform`

**Outros:** `diff`, `query`, `vimdoc`, `jsdoc`, `luadoc`, `gitignore`, `regex`, `printf`

**Features habilitadas:** highlighting, folding por expressão, indentação, incremental selection, auto-tag em JSX/TSX.

---

## Autocompletion

Configurado em `plugins/nvim-cmp.lua` com **LuaSnip** como engine de snippets (carrega snippets VSCode).

**Fontes de completion (por prioridade):**

| Fonte | Descrição |
|---|---|
| `nvim_lsp` | Sugestões do servidor LSP ativo |
| `luasnip` | Snippets |
| `buffer` | Palavras do buffer atual |
| `path` | Caminhos de arquivo |

| Tecla | Ação |
|---|---|
| `<CR>` | Confirmar completion |
| `<S-Tab>` | Item anterior / navegar em snippet |

---

## Dashboard

Ao abrir o Neovim sem argumentos, o **alpha-nvim** exibe uma tela de boas-vindas com acesso rápido a:

| Tecla | Ação |
|---|---|
| `p` | Projetos recentes (via project.nvim) |
| `f` | Buscar arquivo |
| `r` | Arquivos recentes |
| `q` | Sair |

Projetos são detectados automaticamente pela presença de `.git`, `Makefile` ou `package.json`.

---

## Plugins Completos

| Plugin | Categoria | Função |
|---|---|---|
| `lazy.nvim` | Core | Gerenciador de plugins |
| `nvim-cmp` | Completion | Engine de autocompletion |
| `LuaSnip` | Completion | Snippets |
| `mason.nvim` | LSP | Gerenciador de ferramentas LSP |
| `mason-lspconfig` | LSP | Integração Mason + nvim-lspconfig |
| `nvim-treesitter` | Syntax | Highlighting e folding |
| `telescope.nvim` | Busca | Fuzzy finder |
| `telescope-fzf-native` | Busca | FZF nativo para Telescope |
| `nvim-spectre` | Busca | Find & replace global com regex |
| `oil.nvim` | Files | File explorer editável como buffer |
| `oil-lsp-diagnostics` | Files | Diagnósticos LSP no Oil |
| `leap.nvim` | Navegação | Saltos rápidos no buffer/janelas |
| `flash.nvim` | Navegação | Navegação por salto de caractere |
| `vim-visual-multi` | Edição | Multi-cursor |
| `vim-commentary` | Edição | Toggle de comentários |
| `nvim-surround` | Edição | Operações em delimitadores |
| `lualine.nvim` | UI | Status line |
| `nvim-web-devicons` | UI | Ícones de arquivo |
| `indent-blankline` | UI | Guias de indentação |
| `trouble.nvim` | UI | Painel de diagnósticos |
| `fidget.nvim` | UI | Notificações de progresso LSP |
| `vim-maximizer` | UI | Maximizar/restaurar janela |
| `alpha-nvim` | UI | Dashboard de boas-vindas |
| `gruvbox-material` | Tema | Tema gruvbox |
| `github-nvim-theme` | Tema | Temas GitHub |
| `gruber-darker` | Tema | Tema escuro minimalista |
| `xeno.nvim` | Tema | Base do tema dark-duck |
| `nvim-dap` | Debug | Core do protocolo DAP |
| `nvim-dap-ui` | Debug | Interface gráfica (variáveis, call stack, REPL) |
| `nvim-dap-virtual-text` | Debug | Valores de variáveis inline no código |
| `mason-nvim-dap.nvim` | Debug | Integração Mason → DAP (instala CodeLLDB) |
| `nvim-nio` | Debug | Dependência assíncrona do nvim-dap-ui |
| `obsidian.nvim` | Notes | Integração com Obsidian |
| `dotenv.nvim` | Files | Carregamento de `.env` |
| `ts-error-translator` | DX | Tradução de erros TypeScript |
| `markdown-preview` | Utils | Preview de Markdown no browser |
| `bigfile.nvim` | Performance | Desabilita features em arquivos grandes |

---

## Dependências Externas

Instaladas via `setup.sh`:

| Ferramenta | Como instalar | Para que serve |
|---|---|---|
| `ripgrep` | `brew install ripgrep` | Backend de busca do Telescope e Spectre |
| `catimg` | Instalado pelo `setup.sh` | Preview de imagens no Telescope |
| FiraCode Nerd Font | Instalado pelo `setup.sh` | Ícones e ligatures |
| `node` / `npm` | Instalação manual | Servidores LSP de JS/TS |
| `cargo` (Rust) | Instalação manual | rust_analyzer |

---

## Licença

MIT
