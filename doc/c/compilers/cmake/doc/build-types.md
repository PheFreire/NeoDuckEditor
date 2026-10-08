**Build types**

> Debug, Release, RelWithDebInfo e MinSizeRel

O build type escolhe um conjunto pronto de flags de otimização e debug. Em vez de passar `-g` ou `-O2` à mão, o projeto declara o build type e o CMake adiciona as flags certas para o compilador em uso (GCC, Clang ou MSVC)

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
cmake -S . -B build-release -DCMAKE_BUILD_TYPE=Release
```

| Build type | Flags (GCC/Clang) | Uso |
|---|---|---|
| `Debug` | `-g` | desenvolvimento e debugger |
| `Release` | `-O3 -DNDEBUG` | versão final, mais rápida |
| `RelWithDebInfo` | `-O2 -g -DNDEBUG` | profiling e crash em produção |
| `MinSizeRel` | `-Os -DNDEBUG` | binário menor |
| vazio | nenhuma | padrão quando nada é passado |

- `-DNDEBUG` desliga os `assert` em todos os build types menos o Debug
- O nome é case-insensitive para o CMake, mas o padrão é escrever com a primeira letra maiúscula

> As flags de otimização estão em `compilers/gcc/doc/optimization.md`

---

**Build type vazio**

Sem `-DCMAKE_BUILD_TYPE`, um generator single-config compila **sem** otimização e **sem** debug info (nem `-O` nem `-g`). É um build que não serve nem para depurar nem para distribuir

```cmake
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS Debug Release RelWithDebInfo MinSizeRel)
endif()
```

- Esse trecho, logo depois do `project()`, define um padrão quando o usuário não escolheu nenhum
- `CMAKE_CONFIGURATION_TYPES` só existe em generators multi-config, onde o build type não se aplica
- A variável de ambiente `CMAKE_BUILD_TYPE` (3.22+) também define o padrão: `export CMAKE_BUILD_TYPE=Debug`

---

**Single-config e multi-config**

```bash
# single-config (Makefiles, Ninja): um build type por diretório, escolhido no configure
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build

# multi-config (Ninja Multi-Config, Xcode, Visual Studio): escolhido no build
cmake -S . -B build -G "Ninja Multi-Config"
cmake --build build --config Debug
cmake --build build --config Release
```

- No multi-config, `CMAKE_BUILD_TYPE` é ignorado e os binários ficam em subdiretórios (`build/Debug/app`, `build/Release/app`)
- `CMAKE_DEFAULT_BUILD_TYPE` define a configuração usada quando `--config` não é passado (Ninja Multi-Config)
- Por isso, código que depende do build type deve usar generator expressions, que funcionam nos dois tipos (ver `generator-expressions.md`)

---

**Configuração por build type**

```cmake
target_compile_definitions(app PRIVATE
    $<$<CONFIG:Debug>:MODO_DEBUG>
)
target_compile_options(app PRIVATE
    $<$<CONFIG:Debug>:-fno-omit-frame-pointer>
    $<$<CONFIG:Release>:-march=native>
)
```

- `$<$<CONFIG:Debug>:X>` vira `X` no Debug e nada nos outros
- `$<CONFIG:Debug,RelWithDebInfo>` (3.19+) aceita várias configurações

---

**Mudando as flags padrão**

```cmake
set(CMAKE_C_FLAGS_DEBUG "-g3 -Og")                    # substitui o "-g" padrão
set(CMAKE_C_FLAGS_RELEASE "-O2 -DNDEBUG")             # O2 em vez de O3
```

```bash
cmake -S . -B build -DCMAKE_C_FLAGS="-Wall"           # flags para todos os build types
cmake -S . -B build -DCMAKE_C_FLAGS_DEBUG="-g3 -O0"   # só para o Debug
```

- A linha de compilação final é `CMAKE_C_FLAGS` + `CMAKE_C_FLAGS_<CONFIG>` + as opções dos targets
- Defina essas variáveis no `CMakeLists.txt` só para valores que o projeto realmente exige. Para preferências pessoais, use `-D` ou um preset (ver `presets.md`)
- A variável de ambiente `CFLAGS` preenche `CMAKE_C_FLAGS` na **primeira** configuração

---

**Build type personalizado**

```cmake
set(CMAKE_C_FLAGS_ASAN "-g -O1 -fsanitize=address -fno-omit-frame-pointer")
set(CMAKE_EXE_LINKER_FLAGS_ASAN "-fsanitize=address")
set(CMAKE_SHARED_LINKER_FLAGS_ASAN "-fsanitize=address")
```

```bash
cmake -S . -B build-asan -DCMAKE_BUILD_TYPE=Asan
```

- Qualquer nome funciona: o CMake procura as variáveis `CMAKE_C_FLAGS_<NOME>` e `CMAKE_<TIPO>_LINKER_FLAGS_<NOME>` em maiúsculo
- Uma alternativa mais simples é uma `option` que liga os sanitizers nos targets (ver `compiler-flags.md`)

> Use `RelWithDebInfo` para medir desempenho e investigar crashes da versão otimizada: o código é praticamente o mesmo do `Release`, mas o debugger e os profilers conseguem mostrar nomes de funções e linhas. A diferença do `-O2` para o `-O3` raramente é relevante, e o `-O3` pode deixar o binário bem maior
