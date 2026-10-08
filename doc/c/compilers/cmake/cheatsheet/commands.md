**Comandos do CMake**

> referência rápida da linha de comando

O executável `cmake` tem vários modos: configurar um projeto, chamar o build, instalar, executar scripts e servir de ferramenta portátil (`cmake -E`). Junto com ele vêm o `ctest` (testes), o `cpack` (pacotes) e o `ccmake` (editor do cache no terminal)

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build -j 8
ctest --test-dir build --output-on-failure
cmake --install build --prefix ~/.local
```

---

**Configure** (ver `build-process.md`)

- `-S dir`: diretório do código (onde está o `CMakeLists.txt` raiz)
- `-B dir`: diretório de build. Criado se não existir
- `-G "nome"`: generator (`Ninja`, `Unix Makefiles`, `Xcode`). Só vale na primeira configuração
- `-D VAR=valor` / `-D VAR:TIPO=valor`: define uma variável de cache. Ex: `-DCMAKE_BUILD_TYPE=Release`
- `-U VAR`: remove uma variável do cache (aceita `*` como coringa: `-U "FILA_*"`)
- `-C arquivo.cmake`: pré-carrega o cache a partir de um script com vários `set(... CACHE ...)`
- `--fresh` (3.24+): descarta o cache e configura do zero, sem apagar os arquivos compilados
- `--preset nome`: usa um preset do `CMakePresets.json` (ver `presets.md`)
- `--toolchain arquivo` (3.21+): o mesmo que `-DCMAKE_TOOLCHAIN_FILE=arquivo` (ver `toolchains.md`)
- `-Wdev` / `-Wno-dev`: liga/desliga os avisos para desenvolvedores do projeto (como policies não definidas)
- `--install-prefix dir` (3.21+): o mesmo que `-DCMAKE_INSTALL_PREFIX=dir`

---

**Build**

- `cmake --build dir`: compila o target padrão (`all`)
- `--target nome` / `-t nome`: compila só um target (pode repetir: `-t app -t fila`)
- `--target clean`: apaga os arquivos compilados
- `--clean-first`: limpa e compila de novo
- `-j N` / `--parallel N`: número de jobs. Sem `N`, usa o padrão da ferramenta
- `--config Nome`: configuração em generators multi-config (`Debug`, `Release`)
- `-v` / `--verbose`: mostra a linha de comando completa de cada compilação
- `-- args`: o que vier depois de `--` vai direto para o `make`/`ninja`. Ex: `cmake --build build -- -k 0`

---

**Install** (ver `install.md`)

- `cmake --install dir`: instala no `CMAKE_INSTALL_PREFIX`
- `--prefix dir`: muda o prefixo na hora
- `--config Nome`: configuração a instalar (multi-config)
- `--component nome`: instala só um componente
- `--strip`: remove os símbolos de debug dos binários instalados

---

**Inspecionar o cache**

```bash
cmake -L build          # variáveis de cache não avançadas
cmake -LA build         # todas, inclusive as avançadas
cmake -LH build         # com a descrição de cada uma
cmake -N -LH build      # só lê o cache, sem reconfigurar
ccmake build            # editor interativo no terminal (c configura, g gera, q sai)
cmake-gui               # interface gráfica (se instalada)
cmake --list-presets    # presets disponíveis
```

---

**Script mode**

```bash
cmake -P script.cmake                 # executa um arquivo CMake como script, sem projeto
cmake -DNOME=valor -P script.cmake    # -D deve vir antes do -P
```

- Útil para tarefas portáteis de build (gerar arquivos, baixar coisas) sem depender de bash ou PowerShell
- Comandos de projeto (`add_executable`, `project`) não existem no script mode

---

**cmake -E** (ferramentas portáteis)

```bash
cmake -E make_directory build/saida        # mkdir -p
cmake -E rm -rf build/tmp                  # rm -rf (3.17+)
cmake -E copy a.txt b.txt                  # cp
cmake -E copy_directory dados build/dados  # cp -r
cmake -E create_symlink alvo link          # ln -s
cmake -E rename antigo novo                # mv
cmake -E touch arquivo                     # touch
cmake -E env VAR=1 ./app                   # roda com variável de ambiente
cmake -E chdir build ./app                 # roda em outro diretório
cmake -E compare_files a.txt b.txt         # código 0 se iguais
cmake -E cat arquivo                       # cat (3.18+)
cmake -E sha256sum arquivo                 # hash
cmake -E tar czf saida.tar.gz dir          # tar
cmake -E time ./app                        # mede o tempo de execução
cmake -E capabilities                      # recursos do CMake em JSON
```

- Usado dentro de `add_custom_command` para que os comandos funcionem em qualquer sistema (ver `custom-commands.md`)

---

**ctest e cpack**

- `ctest --test-dir build`: roda os testes. Opções em `testing.md`
- `cpack --config build/CPackConfig.cmake`: gera os pacotes. Opções em `cpack.md`

---

**Ajuda**

- `--help-command nome`, `--help-variable nome`, `--help-property nome`, `--help-module nome`, `--help-policy CMP0xxx`
- `--help-command-list`, `--help-variable-list`, `--help-module-list`, `--help-policy-list`
- `--system-information`: dump de tudo que foi detectado na plataforma

> `cmake -S . -B build` pode ser repetido quantas vezes for preciso: ele reaproveita o cache e só refaz o que mudou. Quando algo parecer preso a um valor antigo (outro compilador, um pacote que não é mais encontrado), use `--fresh` antes de apagar o diretório inteiro
