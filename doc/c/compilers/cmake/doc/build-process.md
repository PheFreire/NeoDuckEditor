**Processo de build**

> as fases configure, generate e build

Rodar o CMake não gera um executável. Ele passa por três fases, e só a última chama o compilador. Entender em qual fase cada coisa acontece explica a maioria dos comportamentos estranhos: por que uma variável não muda, por que o `if` não enxerga o build type ou por que um arquivo novo não foi compilado

```text
cmake -S . -B build
  │
  ├─ configure   executa o CMakeLists.txt de cima para baixo
  │              detecta compilador, procura pacotes, preenche o cache
  │              saída: build/CMakeCache.txt
  │
  ├─ generate    transforma os targets em arquivos do generator
  │              avalia as generator expressions $<...>
  │              saída: build/Makefile ou build/build.ninja
  │
cmake --build build
  │
  └─ build       o make/ninja compila e linka só o que mudou
                 saída: build/app, build/libfila.a, ...
```

- **configure**: o `CMakeLists.txt` é executado como um script. É nessa fase que rodam `message`, `if`, `set`, `find_package` e `option`
- **generate**: os `targets` já estão completos, e o CMake escreve as regras de compilação. Valores que dependem da configuração final (ex: `$<CONFIG>`) só existem a partir daqui (ver `generator-expressions.md`)
- **build**: o CMake já terminou. `cmake --build` apenas chama a ferramenta nativa com os argumentos certos

---

**Configure**

```bash
cmake -S . -B build
```

```text
-- The C compiler identification is GNU 14.2.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /usr/bin/cc - skipped
-- Configuring done (0.4s)
-- Generating done (0.0s)
-- Build files have been written to: /home/u/projeto/build
```

- Na **primeira** execução, o CMake escolhe o compilador (variável de ambiente `CC` ou o `cc` do `PATH`) e o testa compilando pequenos programas. O resultado fica gravado no cache e **não muda** nas execuções seguintes
- Tudo que deve sobreviver entre execuções (compilador, `CMAKE_BUILD_TYPE`, opções do usuário, caminhos encontrados) fica em `build/CMakeCache.txt` (ver `build-directory.md`)
- Rodar `cmake -S . -B build` de novo reaproveita o cache. Para descartar o cache, use `cmake --fresh -S . -B build` ou apague o diretório

---

**Generate**

O `generator` decide qual sistema de build é gerado. Ele é escolhido com `-G` na primeira configuração e não pode ser trocado depois sem limpar o diretório

```bash
cmake -S . -B build                        # padrão no Linux/macOS: Unix Makefiles
cmake -S . -B build -G Ninja               # build.ninja, mais rápido e paralelo por padrão
cmake -S . -B build -G "Ninja Multi-Config"
cmake -S . -B build -G Xcode               # projeto .xcodeproj (macOS)
cmake --help                               # a lista de generators fica no final
```

| Generator | Tipo | Ferramenta |
|---|---|---|
| `Unix Makefiles` | single-config | `make` |
| `Ninja` | single-config | `ninja` |
| `Ninja Multi-Config` | multi-config | `ninja` |
| `Xcode` | multi-config | `xcodebuild` |
| `Visual Studio 17 2022` | multi-config | `msbuild` |

- **single-config**: um diretório de build tem um único build type, escolhido no configure com `-DCMAKE_BUILD_TYPE`
- **multi-config**: o mesmo diretório gera Debug e Release, escolhidos no build com `--config` (ver `build-types.md`)
- A variável de ambiente `CMAKE_GENERATOR` define o generator padrão, ex: `export CMAKE_GENERATOR=Ninja`

---

**Build**

```bash
cmake --build build                  # compila o target padrão (all)
cmake --build build -j 8             # 8 jobs em paralelo
cmake --build build --target fila    # só um target e as suas dependências
cmake --build build --target clean   # apaga o que foi compilado (mantém o cache)
cmake --build build -v               # mostra os comandos gcc completos
cmake --build build --config Release # obrigatório em generators multi-config
```

- `cmake --build` funciona com qualquer generator, então scripts e CI não precisam saber se o projeto usa `make` ou `ninja`
- Chamar `make` ou `ninja` direto dentro de `build/` também funciona
- O build é incremental: só recompila os `.c` que mudaram ou cujos headers mudaram. As dependências de headers são detectadas automaticamente pelo compilador (`-MD`)

---

**Reconfiguração automática**

Depois do primeiro configure, não é preciso rodar `cmake -S . -B build` de novo a cada mudança. O sistema de build gerado sabe quais arquivos o CMake leu e reexecuta o configure sozinho quando algum deles muda

```text
edita CMakeLists.txt  →  cmake --build build  →  re-run cmake (automático)  →  compila
```

- Funciona para todo `CMakeLists.txt`, todo `.cmake` incluído e todo arquivo usado em `configure_file`
- **Não** funciona para arquivos novos encontrados com `file(GLOB)`: o CMake não sabe que um `.c` novo apareceu no diretório (ver `subdirectories.md`)
- Mudar uma opção exige rodar o configure explicitamente: `cmake -S . -B build -DUSAR_LOG=ON`

> Configure é a fase em que o seu código CMake roda. Build é a fase em que o código C compila. Uma variável definida com `set` não existe durante o build, e uma macro do C não existe durante o configure. A ponte entre os dois mundos são as definições passadas ao compilador (`target_compile_definitions`) e os arquivos gerados com `configure_file` (ver `custom-commands.md`)
