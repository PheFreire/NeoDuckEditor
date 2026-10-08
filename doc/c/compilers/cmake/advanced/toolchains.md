**Toolchains**

> trocar de compilador e fazer cross-compiling

Um arquivo de toolchain é um script `.cmake` carregado **antes** do `project()`, que diz ao CMake qual compilador usar e para qual sistema e arquitetura compilar. É o mecanismo para cross-compiling (compilar em uma máquina para rodar em outra), como gerar binários para ARM em um PC x86 ou para um microcontrolador

```bash
cmake -S . -B build-arm --toolchain cmake/aarch64-linux.cmake
cmake -S . -B build-arm -DCMAKE_TOOLCHAIN_FILE=cmake/aarch64-linux.cmake   # forma antiga
```

```text
host:    onde o CMake e o compilador rodam   (CMAKE_HOST_SYSTEM_NAME)
target:  onde o binário gerado vai rodar     (CMAKE_SYSTEM_NAME)
```

- O toolchain só é lido na **primeira** configuração. Para trocar, use outro diretório de build ou `--fresh`
- Mantenha o toolchain separado do `CMakeLists.txt`: o mesmo projeto deve compilar para qualquer alvo sem mudanças

---

**Toolchain para Linux ARM**

```cmake
# cmake/aarch64-linux.cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)

set(CMAKE_SYSROOT /usr/aarch64-linux-gnu)
set(CMAKE_FIND_ROOT_PATH /usr/aarch64-linux-gnu)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)    # programas: do host
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)     # bibliotecas: só do alvo
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)     # headers: só do alvo
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)     # pacotes: só do alvo
```

- `CMAKE_SYSTEM_NAME`: definir essa variável é o que liga o modo cross-compiling (`CMAKE_CROSSCOMPILING` vira verdadeiro)
- `CMAKE_SYSROOT`: diretório com os headers e bibliotecas do sistema alvo. Passado ao compilador como `--sysroot`
- `CMAKE_FIND_ROOT_PATH_MODE_*`: impede que `find_library` e `find_package` encontrem as bibliotecas x86 do host por engano

---

**Microcontrolador (bare metal)**

```cmake
# cmake/arm-none-eabi.cmake
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_C_FLAGS_INIT "-mcpu=cortex-m4 -mthumb")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-specs=nosys.specs")
```

- `Generic` significa "sem sistema operacional"
- `CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY`: o teste do compilador gera só uma biblioteca, porque sem linker script e startup um executável não linka
- As variáveis `_INIT` definem o valor inicial das flags, e o usuário ainda pode adicionar as suas com `-DCMAKE_C_FLAGS`
- Para gerar o `.bin`/`.hex` usado na gravação, adicione um `add_custom_command(TARGET ... POST_BUILD)` com `objcopy -O binary` (ver `custom-commands.md`)

---

**Só trocar o compilador**

```bash
CC=clang cmake -S . -B build-clang
CC=gcc-15 cmake -S . -B build-gcc15
cmake -S . -B build-gcc -DCMAKE_C_COMPILER=gcc-15
```

- Para usar outro compilador **na mesma plataforma**, não é preciso toolchain: basta `CC` ou `CMAKE_C_COMPILER` na primeira configuração
- Mudar `CMAKE_C_COMPILER` em um diretório já configurado faz o CMake apagar o cache e reconfigurar, avisando `You have changed variables that require your cache to be deleted`

---

**macOS: arquiteturas**

```bash
cmake -S . -B build -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"   # universal binary
cmake -S . -B build -DCMAKE_OSX_ARCHITECTURES=x86_64           # Intel em um Mac Apple Silicon
cmake -S . -B build -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0         # roda a partir do macOS 12
lipo -info build/app                                           # confere as arquiteturas
```

- No macOS, gerar para outra arquitetura não exige toolchain: o Apple Clang compila para as duas
- O universal binary contém o código das duas arquiteturas em um único arquivo (ver `compilers/gcc/advanced/mach-o.md`)
- Funciona com o Apple Clang. O GCC do Homebrew não gera universal binaries

---

**Rodar binários do alvo**

```cmake
set(CMAKE_CROSSCOMPILING_EMULATOR qemu-aarch64 -L /usr/aarch64-linux-gnu)
```

- Com essa variável, `add_test` e `add_custom_command` rodam os executáveis do alvo através do emulador, então o `ctest` funciona no cross-compiling
- Ferramentas que precisam rodar **durante** o build (geradores de código) devem ser compiladas para o host, em um build separado, e importadas no build do alvo

> O nome do compilador em `CMAKE_C_COMPILER` pode ser só o nome, se estiver no `PATH`, mas o caminho completo deixa o toolchain reproduzível em outras máquinas. Para saber o que o CMake decidiu, veja `build/CMakeFiles/<versão>/CMakeSystem.cmake` e `CMakeCCompiler.cmake` (ver `build-directory.md`)
