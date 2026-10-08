**Flags do compilador**

> padrão de C, warnings, sanitizers e otimizações pelo CMake

O CMake traduz algumas configurações para a flag certa de cada compilador (padrão de C, PIC, LTO), mas warnings, sanitizers e flags específicas ainda são passadas diretamente. Como cada compilador tem flags diferentes, essas opções costumam ser condicionadas ao compilador com generator expressions

```cmake
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

target_compile_options(app PRIVATE -Wall -Wextra -Wpedantic)
```

> As flags em si estão explicadas em `compilers/gcc/cheatsheet/flags.md` e `compilers/gcc/cheatsheet/warnings.md`

---

**Padrão de C**

```cmake
# para todos os targets (depois do project)
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# para um target
set_target_properties(app PROPERTIES C_STANDARD 23 C_STANDARD_REQUIRED ON C_EXTENSIONS OFF)

# como requisito mínimo, propagável para quem usa
target_compile_features(fila PUBLIC c_std_11)
```

| Configuração | Flag gerada (GCC/Clang) |
|---|---|
| `C_STANDARD 17` + `C_EXTENSIONS ON` (padrão) | `-std=gnu17` |
| `C_STANDARD 17` + `C_EXTENSIONS OFF` | `-std=c17` |
| `C_STANDARD 23` (3.21+) | `-std=c23` ou `-std=c2x`, conforme a versão |
| nenhuma | nenhuma, usa o padrão do compilador |

- Sem `C_STANDARD_REQUIRED ON`, se o compilador não suportar o padrão pedido, o CMake usa um anterior **sem avisar**
- `target_compile_features` declara o mínimo. Se uma dependência exige `c_std_11` e o target pede `17`, vale o maior

---

**Warnings**

```cmake
add_library(avisos INTERFACE)
target_compile_options(avisos INTERFACE
    "$<$<C_COMPILER_ID:GNU,Clang,AppleClang>:-Wall;-Wextra;-Wpedantic;-Wshadow>"
    "$<$<C_COMPILER_ID:MSVC>:/W4>"
)

target_link_libraries(app PRIVATE avisos)
target_link_libraries(fila PRIVATE avisos)
```

- O target `INTERFACE` agrupa as flags e é linkado como `PRIVATE`, então as flags não vazam para quem usa a biblioteca
- Dentro da generator expression, as flags são separadas por `;` e a expressão inteira fica entre aspas
- Alternativa simples para o projeto todo: `add_compile_options(-Wall -Wextra)` no `CMakeLists.txt` raiz, antes de criar os targets

```cmake
set_target_properties(app PROPERTIES COMPILE_WARNING_AS_ERROR ON)   # -Werror (3.24+)
```

```bash
cmake -S . -B build --compile-no-warning-as-error   # desliga o -Werror sem editar o projeto
```

---

**Sanitizers**

```cmake
option(USAR_SANITIZERS "Compila com AddressSanitizer e UBSan" OFF)

if(USAR_SANITIZERS)
    add_compile_options(-fsanitize=address,undefined -fno-omit-frame-pointer)
    add_link_options(-fsanitize=address,undefined)
endif()
```

```bash
cmake -S . -B build-asan -DCMAKE_BUILD_TYPE=Debug -DUSAR_SANITIZERS=ON
```

- A flag precisa estar na compilação **e** no link, por isso `add_compile_options` e `add_link_options`
- Use um diretório de build separado: misturar objetos com e sem sanitizer causa erros de link

> Os sanitizers estão explicados em `compilers/gcc/cheatsheet/sanitizers.md`

---

**LTO**

```cmake
include(CheckIPOSupported)
check_ipo_supported(RESULT tem_lto OUTPUT erro)

if(tem_lto)
    set_property(TARGET app PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)
else()
    message(WARNING "LTO não suportado: ${erro}")
endif()
```

- O CMake adiciona `-flto` e usa o `ar`/`ranlib` certos para bibliotecas estáticas com LTO
- `CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE ON` liga só no Release

---

**Flags avulsas**

```cmake
target_compile_options(app PRIVATE -march=native)          # compilação
target_link_options(app PRIVATE -Wl,--gc-sections)         # link (3.13+)
target_compile_definitions(app PRIVATE _GNU_SOURCE)        # -D_GNU_SOURCE
set_source_files_properties(lento.c PROPERTIES COMPILE_OPTIONS -O3)   # um arquivo só
```

- `target_compile_options` remove flags duplicadas. Para flags que precisam se repetir (como `-Xlinker a -Xlinker b`), use o prefixo `SHELL:` ex: `"SHELL:-Xlinker a"`
- `-Wl,` é específico de GCC/Clang. `LINKER:` é a forma portátil: `target_link_options(app PRIVATE "LINKER:--gc-sections")`

---

**Compilador**

```bash
CC=clang cmake -S . -B build-clang                       # pela variável de ambiente
cmake -S . -B build-gcc -DCMAKE_C_COMPILER=gcc-15        # pelo cache
```

- O compilador é escolhido na **primeira** configuração e fica gravado no cache. Para trocar, use outro diretório de build ou `--fresh`
- No macOS, `gcc` é o Apple Clang. Para o GCC de verdade, passe o nome com a versão (`gcc-15`)

> Flags de preferência pessoal (`-march=native`, sanitizers, `-Werror`) não devem ser obrigatórias no `CMakeLists.txt`: elas quebram o build em outras máquinas e compiladores. Coloque-as atrás de uma `option`, em um preset ou passe com `-DCMAKE_C_FLAGS` na linha de comando
