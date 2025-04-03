<p align="center">
  <img src="assets/logo.png" alt="Figmify Logo" width="150" />
</p>


# NeoDuckEditor Configuration

Este é o meu setup personalizado para o Neovim, focado em uma configuração eficiente e com uma série de plugins para aprimorar a experiência de desenvolvimento.

## Estrutura do Projeto

A estrutura do projeto é organizada da seguinte forma:

```
nvim/
├── lua/
│   └── pato/
│       ├── core/
│       ├── plugins/
│       └── lazy.lua
├── lazy-lock.json
├── setup.sh
├── init.lua
├── Makefile
└── .git/
```

## Plugins Utilizados

O Neovim é configurado para usar vários plugins através do gerenciador de plugins **lazy.nvim**. Abaixo estão os plugins principais e suas configurações.

### Lista de Plugins

1. **[vim-visual-multi](https://github.com/mg979/vim-visual-multi)**
   - Permite seleção múltipla de texto no Neovim.
   - Configuração:
     ```lua
     vim.g.VM_theme = 'purplegray'
     vim.g.VM_persistent_registers = true
     ```

2. **[which-key](https://github.com/folke/which-key.nvim)**
   - Mostra dicas de teclas para facilitar a memorização de atalhos.

3. **[treesitter](https://github.com/nvim-treesitter/nvim-treesitter)**
   - Habilita suporte a sintaxe avançada e destaque para várias linguagens.

4. **[git-blame](https://github.com/f-person/git-blame.nvim)**
   - Exibe informações sobre o autor da linha de código ao passar o cursor sobre ela.

5. **[maximizer](https://github.com/BeGoodJr/maximizer.nvim)**
   - Maximiza as janelas para facilitar o trabalho com múltiplos buffers.

6. **[quickfixdd](https://github.com/dhruvasagar/quickfixdd)**
   - Interface de correção rápida para resolver problemas no código.

7. **[indent-blankline](https://github.com/lukas-reineke/indent-blankline.nvim)**
   - Exibe linhas de indentação para uma navegação melhor no código.

8. **[vim-commentary](https://github.com/tpope/vim-commentary)**
   - Facilita a adição e remoção de comentários no código.

9. **[leap](https://github.com/ggandor/leap.nvim)**
   - Plugin para navegar rapidamente entre palavras no código.

10. **[git-tools](https://github.com/tpope/vim-fugitive)**
    - Ferramentas auxiliares para trabalhar com Git no Neovim.

11. **[markdown](https://github.com/plasticboy/vim-markdown)**
    - Suporte e realce de sintaxe para arquivos Markdown.

12. **[lualine](https://github.com/nvim-lualine/lualine.nvim)**
    - Linha de status configurável e leve para Neovim.

13. **[telescope](https://github.com/nvim-telescope/telescope.nvim)**
    - Ferramenta de busca altamente configurável.

14. **[mason](https://github.com/williamboman/mason.nvim)**
    - Gerenciador de ferramentas para o Neovim, integrando com LSPs e linters.

15. **[obsidian](https://github.com/epwalsh/obsidian.nvim)**
    - Suporte para o Obsidian, uma ferramenta de anotações baseada em Markdown.

16. **terminal-path-link**
    - Converte caminhos em links clicáveis no terminal do Neovim.

17. **[nvim-tree](https://github.com/kyazdani42/nvim-tree.lua)**
    - Explorador de arquivos para Neovim, facilitando a navegação no projeto.

18. **[trouble](https://github.com/folke/trouble.nvim)**
    - Exibe listas de problemas e mensagens de erro.

## Mapeamento de Teclas Personalizado

A seguir, estão os grupos de mapeamento de teclas definidos no Neovim, com explicações sobre cada comando e atalho associado:

### 1. **Mapeamentos Gerais**
   - **`i`**: Inicia no modo de inserção.
     - `i`: Inicia inserção com o cursor na posição direita (`<Right>`).
   - **Navegação de linha**:
     - `k`: Move o cursor para baixo (`<Down>`).
     - `j`: Move o cursor para cima (`<Up>`).
     - `<C-l>`: Move o cursor para a última posição na linha (`e`).
     - `<A-l>`: Move o cursor para o final da linha (`$`).
     - `<C-h>`: Move o cursor para a palavra anterior (`b`).
     - `<A-h>`: Move o cursor para o início da linha (`0`).
   - **Comandos de saída**:
     - `<C-q>`: Sai sem salvar (`:q!`).
     - `<C-s>`: Salva o arquivo atual (`:w`).
   - **Outros**:
     - `<leader>gb`: Abre o último buffer editado.

### 2. **Mapeamentos no Modo Visual**
   - **Navegação**:
     - `k`, `j`: Move o cursor para cima e para baixo no modo visual, respectivamente.
     - `<C-l>`, `<A-l>`: Move o cursor para o final da linha.
     - `<C-h>`, `<A-h>`: Move o cursor para o início da palavra.
   - **Comandos personalizados**:
     - `x`: Deleta a seleção sem afetar o registro (`"_d`).
     - `l`, `h`: Move o cursor dentro da seleção com comportamento personalizado, dependendo da posição do cursor na linha.

### 3. **Mapeamentos para Manipulação de Janela**
   - **Divisão de janelas**:
     - `<leader>s`: Divide a janela verticalmente (`<C-w>v`).
     - `<leader>ss`: Divide a janela horizontalmente (`<C-w>s`).
     - `<leader>sx`: Fecha a janela atual (`:close`).
   - **Ajuste de tamanho de janelas**:
     - `<leader>sj`: Torna a janela mais curta (`<C-w>-`).
     - `<leader>sk`: Torna a janela mais alta (`<C-w>+`).
     - `<leader>sl`: Aumenta a largura da janela (`<C-w>>5`).
     - `<leader>sh`: Diminui a largura da janela (`<C-w><5`).

### 4. **Mapeamentos de Abas**
   - **Gerenciamento de abas**:
     - `<leader>to`: Abre uma nova aba (`:tabnew`).
     - `<leader>tx`: Fecha a aba atual (`:tabclose`).
     - `<leader>l`: Vai para a próxima aba (`:tabn`).
     - `<leader>h`: Vai para a aba anterior (`:tabp`).

### 5. **Mapeamentos para o Nvim-tree (Explorador de Arquivos)**
   - **Explorador de arquivos**:
     - `<leader>ee`: Alterna o explorador de arquivos (`:NvimTreeToggle`).
     - `<leader>f`: Encontra o arquivo atual no explorador (`:NvimTreeFindFile`).
     - `<leader>ec`: Colapsa o explorador (`<cmd>NvimTreeCollapse`).
     - `<leader>er`: Atualiza o explorador e reinicia o LSP (`<cmd>:LspRestart<CR><cmd>NvimTreeRefresh`).

## Como Instalar

1. Clone este repositório no seu diretório de Neovim:
   ```bash
   git clone https://github.com/PheFreire/NeoDuckEditor ~/.config/nvim
   ```

2. Execute o script de instalação `setup.sh` para instalar as dependências:
   ```bash
   bash setup.sh
   ```

3. Após a instalação, inicie o Neovim para carregar a configuração.

## Personalizações

Este setup inclui diversas personalizações para aumentar a produtividade, como:

- **Atalhos de teclado** para operações rápidas.
- **Plugins de navegação e busca**, como `telescope` e `nvim-tree`.
- **Integração com Git**, incluindo `git-blame` e `git-tools`.

Sinta-se à vontade para modificar e personalizar de acordo com suas necessidades.

## Licença

Este projeto está licenciado sob a [Licença MIT](LICENSE).
