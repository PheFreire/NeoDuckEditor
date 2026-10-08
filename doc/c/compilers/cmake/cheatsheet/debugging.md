**Debugging**

> investigar o configure, ver os comandos do build e depurar o programa

Quando um projeto CMake não faz o esperado, a pergunta é sempre em qual fase o problema está: no **configure** (uma variável com valor errado, um pacote não encontrado), no **build** (uma flag que não chegou ao compilador) ou no **programa** (que precisa de um build Debug para o debugger). Cada fase tem as suas ferramentas

---

**message**

```cmake
message(STATUS "FONTES = ${FONTES}")
```

| Modo | Efeito |
|---|---|
| `FATAL_ERROR` | erro, para o configure na hora |
| `SEND_ERROR` | erro, continua o configure mas não gera o build |
| `WARNING` | aviso com arquivo e linha |
| `AUTHOR_WARNING` | aviso para quem mantém o projeto (some com `-Wno-dev`) |
| `DEPRECATION` | aviso de recurso obsoleto |
| (nenhum) / `NOTICE` | texto simples no `stderr` |
| `STATUS` | linha com `-- ` no `stdout` |
| `VERBOSE` | só aparece com `--log-level=VERBOSE` |
| `DEBUG` | só aparece com `--log-level=DEBUG` |
| `TRACE` | só aparece com `--log-level=TRACE` |

```bash
cmake -S . -B build --log-level=DEBUG
```

---

**Imprimir variáveis e propriedades**

```cmake
include(CMakePrintHelpers)
cmake_print_variables(CMAKE_BUILD_TYPE CMAKE_C_COMPILER PROJECT_SOURCE_DIR)
cmake_print_properties(TARGETS app PROPERTIES INCLUDE_DIRECTORIES LINK_LIBRARIES)
```

```text
-- CMAKE_BUILD_TYPE="Debug" ; CMAKE_C_COMPILER="/usr/bin/cc" ; PROJECT_SOURCE_DIR="/home/u/projeto"
```

- Mostra o nome junto com o valor, sem precisar escrever a mensagem
- Generator expressions aparecem sem avaliar (`$<...>`), porque só são resolvidas no generate. Para ver o valor final, use `file(GENERATE)` (ver `generator-expressions.md`)

---

**Rastrear o configure**

```bash
cmake -S . -B build --trace                       # cada comando executado, com arquivo e linha
cmake -S . -B build --trace-expand                # o mesmo, com as variáveis já expandidas
cmake -S . -B build --trace-source=CMakeLists.txt # só os comandos de um arquivo
cmake -S . -B build --trace-expand --trace-redirect=trace.txt   # grava em arquivo
cmake -S . -B build --debug-find                  # onde cada find_package/find_library procurou
cmake -S . -B build --debug-find-pkg=Fila         # só para um pacote (3.23+)
cmake -S . -B build --warn-uninitialized          # avisa quando uma variável inexistente é usada
```

- `--debug-find` é a forma mais rápida de entender por que um pacote não foi encontrado: lista cada diretório tentado
- O resultado das checagens do configure (compilador, `check_*`, `try_compile`) fica em `build/CMakeFiles/CMakeConfigureLog.yaml` (3.26+). Em versões antigas, `CMakeOutput.log` e `CMakeError.log`

---

**Ver os comandos do build**

```bash
cmake --build build -v                     # linha de compilação completa de cada arquivo
cmake --build build -- VERBOSE=1           # o mesmo, com Makefiles
cmake -S . -B build -DCMAKE_VERBOSE_MAKEFILE=ON   # sempre verboso
```

- Mostra exatamente quais `-I`, `-D` e flags chegaram ao `gcc`. É o jeito de confirmar se um `target_*` funcionou
- Para ver o que o próprio `gcc` faz por baixo, adicione `-v` às opções do target (ver `compilers/gcc/doc/compilation-pipeline.md`)

---

**`compile_commands.json`**

```bash
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ln -s build/compile_commands.json .
```

```json
[
  {
    "directory": "/home/u/projeto/build",
    "command": "/usr/bin/cc -I/home/u/projeto/include -g -o src/CMakeFiles/fila.dir/fila.c.o -c /home/u/projeto/src/fila.c",
    "file": "/home/u/projeto/src/fila.c"
  }
]
```

- Um JSON com o comando exato de cada arquivo. O `clangd` (LSP de C no Neovim) usa esse arquivo para saber os includes e defines e parar de marcar headers como não encontrados
- O `clangd` procura o arquivo na raiz do projeto e também em `build/`. Para outro diretório, use o link simbólico
- Funciona com os generators Makefiles e Ninja
- A variável de ambiente `CMAKE_EXPORT_COMPILE_COMMANDS=ON` (3.17+) liga em todos os projetos

---

**Depurar o programa**

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build
gdb ./build/app        # Linux
lldb ./build/app       # macOS
```

- O build type `Debug` adiciona `-g`. Sem build type, não há debug info e o debugger não mostra linhas nem variáveis
- Para mais informação de macros no debugger: `-DCMAKE_C_FLAGS_DEBUG="-g3 -O0"`

> Comandos do debugger em `compilers/gcc/cheatsheet/debugging.md`

---

**Depurar o próprio CMake**

```bash
cmake -S . -B build --debugger --debugger-pipe /tmp/cmake-dap   # 3.27+
```

- O CMake implementa o Debug Adapter Protocol: dá para colocar breakpoints em um `CMakeLists.txt` e inspecionar variáveis passo a passo, usando um cliente DAP (como o `nvim-dap`)
- Na prática, `message` e `--trace-expand` resolvem quase todos os casos

> Quando uma mudança no `CMakeLists.txt` parece não ter efeito, a causa costuma ser o cache: um `set(... CACHE ...)` não sobrescreve o valor que já existe, e um `find_*` que já achou algo não procura de novo. Confira o valor com `cmake -LH build` e, se for o caso, reconfigure com `--fresh`
