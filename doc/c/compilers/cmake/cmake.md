**cmake**

> ferramenta de linha de comando (gerador de sistemas de build)

O CMake não compila nada sozinho. Ele lê a descrição do projeto em um arquivo `CMakeLists.txt` e gera os arquivos de um sistema de build nativo (`Makefile`, `build.ninja`, projeto do Xcode ou do Visual Studio). Quem chama o compilador (`gcc`, `clang`) é esse sistema de build. Por isso o CMake é chamado de `meta build system`: ele descreve **o que** construir e deixa o **como** para a ferramenta da plataforma

```bash
cmake [opções] -S <diretório do código> -B <diretório de build>
cmake --build <diretório de build>
```

```text
cmake -S . -B build && cmake --build build

CMakeLists.txt
  │  cmake -S . -B build     configura e gera   (CMakeLists.txt → Makefile / build.ninja)
  ▼
build/Makefile
  │  cmake --build build     chama o make/ninja
  ▼
gcc -c main.c ...  e  gcc main.o ... -o app
  │
  ▼
build/app
```

- O trabalho acontece em duas fases separadas:
    - **configure + generate**: executa o `CMakeLists.txt`, detecta o compilador, procura dependências e escreve os arquivos de build
    - **build**: o `make`/`ninja` compila só o que mudou desde o último build
- O mesmo `CMakeLists.txt` gera o build para Linux, macOS e Windows, com GCC, Clang ou MSVC

> Veja as fases em detalhes em `build-process.md`

---

**Primeiro projeto**

```text
projeto/
├── CMakeLists.txt
└── main.c
```

```cmake
cmake_minimum_required(VERSION 3.20)
project(app LANGUAGES C)

add_executable(app main.c)
```

```bash
cmake -S . -B build
cmake --build build
./build/app
```

- `cmake_minimum_required`: a versão mínima do CMake que o projeto exige. Deve ser a primeira linha (ver `policies.md`)
- `project`: nome do projeto e linguagens usadas. Sem `LANGUAGES C`, o CMake habilita C e C++ e exige um compilador C++ instalado
- `add_executable`: cria um `target` chamado `app` a partir de `main.c` (ver `targets.md`)
- `-S .`: diretório onde está o `CMakeLists.txt` raiz
- `-B build`: diretório onde tudo é gerado (é criado se não existir)

---

**Out-of-source build**

Todos os arquivos gerados (Makefiles, `.o`, executáveis e o cache) ficam dentro do diretório de build, e o diretório do código continua limpo. Para começar do zero, basta apagar o diretório de build

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
cmake -S . -B build-release -DCMAKE_BUILD_TYPE=Release   # vários builds do mesmo código lado a lado
rm -rf build                                              # descarta tudo que foi gerado
```

- Coloque `build/` no `.gitignore`
- Evite rodar `cmake .` dentro da pasta do código: esse `in-source build` espalha `CMakeCache.txt`, `CMakeFiles/` e `Makefile` no meio dos fontes

---

**Equivalência com o gcc**

| gcc | CMake |
|---|---|
| `gcc main.c lista.c -o app` | `add_executable(app main.c lista.c)` |
| `-Iinclude` | `target_include_directories(app PRIVATE include)` |
| `-DDEBUG` | `target_compile_definitions(app PRIVATE DEBUG)` |
| `-Wall -Wextra` | `target_compile_options(app PRIVATE -Wall -Wextra)` |
| `-std=c17` | `set_target_properties(app PROPERTIES C_STANDARD 17)` |
| `-lm` | `target_link_libraries(app PRIVATE m)` |
| `-g` / `-O3 -DNDEBUG` | `-DCMAKE_BUILD_TYPE=Debug` / `Release` |
| `ar rcs libfila.a fila.o` | `add_library(fila STATIC fila.c)` |
| `gcc -shared -fPIC` | `add_library(fila SHARED fila.c)` |

- A diferença principal: no gcc as flags valem para um comando. No CMake elas pertencem a um `target` e podem ser propagadas automaticamente para quem o usa (ver `targets.md`)

---

**Ajuda e observações**

```bash
cmake --version                          # versão instalada
cmake --help                             # opções e lista de generators disponíveis
cmake --help-command add_executable      # manual de um comando
cmake --help-variable CMAKE_BUILD_TYPE   # manual de uma variável
cmake --help-property C_STANDARD         # manual de uma propriedade
cmake --help-module FetchContent         # manual de um módulo
cmake --help-command-list                # todos os comandos
cmake --system-information | less        # tudo que o CMake detecta da plataforma
```

> No macOS, o CMake não vem com as Command Line Tools e pode ser instalado pelo Homebrew (`brew install cmake`). No Linux, o pacote da distro costuma ser antigo, então confira o `cmake --version` antes de usar recursos novos. A partir do CMake 4.0, projetos com `cmake_minimum_required` abaixo de 3.5 não configuram mais (ver `common-errors.md`). Para builds mais rápidos, instale o `ninja` e use `cmake -G Ninja`
