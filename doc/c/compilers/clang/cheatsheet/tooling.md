**Ferramentas do ecossistema Clang**

> `clangd`, `compile_commands.json` e `clang-format`

Como o frontend do Clang é uma biblioteca, as ferramentas de editor para C são construídas em cima dele: o `clangd` dá autocomplete e erros em tempo real, e o `clang-format` formata o código. Para elas funcionarem igual ao compilador, precisam saber as flags que cada arquivo usa, e é isso que o `compile_commands.json` informa

---

**clangd**

O `clangd` é o servidor de linguagem (LSP) do C: o editor envia o arquivo aberto, e o `clangd` monta a AST (ver `ast.md`) e devolve os erros, os warnings, o autocomplete, a definição de cada nome e as correções sugeridas

- Os erros e warnings são os mesmos do `clang -fsyntax-only`, com as mesmas mensagens e fix-its (ver `diagnostics.md`). Os fix-its aparecem como `code actions`
- Com `--background-index`, indexa o projeto inteiro em segundo plano, para que "ir para a definição" e "achar referências" funcionem em arquivos que ainda não foram abertos. O índice fica em `.cache/clangd/` na raiz do projeto
- Com `--clang-tidy`, roda os checks do `.clang-tidy` junto com os warnings (ver `static-analysis.md`)
- Com `--enable-config`, lê também a configuração do usuário (`~/Library/Preferences/clangd/config.yaml` no macOS, `~/.config/clangd/config.yaml` no Linux), além do `.clangd` do projeto
- `clangd --check=main.c` simula o que o editor faria com o arquivo e mostra cada etapa no terminal. É o primeiro passo quando o editor mostra erros que o compilador não mostra

```yaml
# .clangd na raiz do projeto
CompileFlags:
  Add: [-std=c17, -Wall, -Wextra]
  Remove: [-fipa-pta]             # flag do GCC que o clangd não entende
Diagnostics:
  UnusedIncludes: Strict          # avisa #include que não é usado
```

- `CompileFlags.Add` e `Remove` mudam as flags que o `clangd` usa, sem mudar o build
- `Remove` é útil quando o projeto é compilado com GCC e usa flags que o Clang não aceita, que fariam o `clangd` mostrar `unknown argument` em todo arquivo

---

**compile_commands.json**

Um arquivo JSON com o comando exato usado para compilar cada `.c` do projeto. O `clangd`, o `clang-tidy` e o `scan-build` leem esse arquivo para usar os mesmos `-I`, `-D` e `-std` do build

```json
[
  {
    "directory": "/home/u/projeto",
    "file": "src/fila.c",
    "output": "build/fila.o",
    "arguments": ["clang", "-Iinclude", "-std=c17", "-c", "src/fila.c", "-o", "build/fila.o"]
  }
]
```

- O `clangd` procura o arquivo subindo a partir do `.c` aberto, e também nas pastas `build/` de cada nível
- Sem ele, um `#include "fila.h"` que está em `include/` aparece como `'fila.h' file not found` no editor, mesmo compilando no terminal

Formas de gerar:

```bash
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON   # CMake (ver cmake/cheatsheet/debugging.md)
bear -- make                                             # qualquer build system: intercepta as chamadas ao compilador

# só com o clang, sem nenhuma ferramenta a mais:
clang -MJ main.o.json -c main.c -o main.o
clang -MJ fila.o.json -c fila.c -o fila.o
sed -e '1s/^/[\n/' -e '$s/,$/\n]/' *.o.json > compile_commands.json
```

- `-MJ arquivo.json` faz o Clang gravar a entrada daquele arquivo enquanto compila. Cada uma termina em `,`, e o `sed` coloca os `[` `]` em volta e tira a última vírgula. Em um `Makefile`, basta adicionar `-MJ $@.json` à regra de compilação
- Para projetos pequenos, um `compile_flags.txt` na raiz, com uma flag por linha, é suficiente: o `clangd` aplica as mesmas flags a todos os arquivos (ver `tests/project_setup.md` em `doc/c`)

---

**clang-format**

O `clang-format` reescreve a formatação do código (indentação, espaços, quebras de linha, posição das chaves) seguindo um estilo, sem mudar o significado

```bash
clang-format main.c                       # imprime o arquivo formatado
clang-format -i src/*.c include/*.h       # formata os arquivos no lugar
clang-format --style=LLVM --dump-config > .clang-format   # gera um .clang-format completo para editar
git clang-format                          # formata só as linhas alteradas desde o último commit
```

```yaml
# .clang-format na raiz do projeto
BasedOnStyle: LLVM
IndentWidth: 2
ColumnLimit: 100
PointerAlignment: Right      # int *p, e não int* p
BreakBeforeBraces: Attach    # { na mesma linha
```

- `BasedOnStyle` parte de um estilo pronto (`LLVM`, `Google`, `Chromium`, `Mozilla`, `WebKit`, `GNU`) e as linhas seguintes mudam só o que for diferente
- O `.clang-format` vale para o diretório onde está e todos os de baixo, igual ao `.clang-tidy`
- O editor normalmente chama o `clang-format` ao salvar, e o `clangd` também consegue formatar usando o mesmo arquivo
- O `git clang-format` é o jeito de adotar o `clang-format` em um projeto antigo sem um commit gigante que muda todos os arquivos

Desligando a formatação em um trecho:

```c
// clang-format off
int identidade[] = {1, 0,
                    0, 1};
// clang-format on
```

- Útil para tabelas e matrizes alinhadas à mão, que o `clang-format` juntaria em uma linha só

> O `clang-format` trabalha só com os tokens, sem montar a AST completa, por isso ele não precisa do `compile_commands.json` e formata até código que não compila. O `clangd` e o `clang-tidy` precisam das flags certas, e quando um deles se comporta diferente do compilador, a causa quase sempre é um `compile_commands.json` ausente, desatualizado ou gerado para outro diretório
