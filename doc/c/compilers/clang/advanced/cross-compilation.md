**Cross-compilation**

> `--target`, `--sysroot` e `-arch`

Cross-compilar é gerar, em uma máquina, um executável para outra arquitetura ou outro sistema, como compilar no macOS ARM64 um programa para Linux x86-64. No GCC, cada combinação precisa de um compilador próprio (`aarch64-linux-gnu-gcc`, `x86_64-w64-mingw32-gcc`). No Clang, um único binário tem vários backends do LLVM, e o alvo é escolhido na linha de comando com `--target`

```bash
clang --target=x86_64-linux-gnu -c soma.c -o soma_linux.o
clang --target=x86_64-pc-windows-msvc -c soma.c -o soma_win.o
file soma_linux.o soma_win.o
```

```text
soma_linux.o: ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), not stripped
soma_win.o:   Intel amd64 COFF object file, not stripped
```

- Um Clang no macOS gerou um `.o` ELF para Linux e um COFF para Windows, sem nada instalado a mais
- Isso só funciona para o `.o` de um arquivo que não inclui nenhum header do sistema. Para incluir `stdio.h` e para linkar, é preciso ter os arquivos do sistema alvo (abaixo)

---

**Target triple**

O alvo é descrito por um `triple`: `arquitetura-fabricante-sistema-ambiente`. Partes podem ser omitidas, e o Clang completa com valores padrão

```text
arm64-apple-darwin24.0.0      Mac Apple Silicon (o padrão desta máquina)
x86_64-apple-macosx13.0       Mac Intel, macOS 13 ou mais novo
x86_64-linux-gnu              Linux x86-64 com glibc
aarch64-linux-gnu             Linux ARM64 com glibc (Raspberry Pi 64 bits, servidores ARM)
x86_64-linux-musl             Linux x86-64 com musl (executáveis estáticos)
x86_64-pc-windows-msvc        Windows com a ABI do Visual Studio
x86_64-w64-windows-gnu        Windows com a ABI do MinGW
wasm32-unknown-unknown        WebAssembly, sem sistema operacional
```

- **arquitetura**: o conjunto de instruções (`x86_64`, `aarch64`/`arm64`, `riscv64`, `wasm32`)
- **fabricante**: normalmente `apple`, `pc` ou `unknown`, e pouco importa fora da Apple
- **sistema**: `linux`, `darwin`/`macosx`, `windows` ou `none` (bare metal, sem sistema)
- **ambiente**: a ABI e a libc, como `gnu` (glibc), `musl`, `msvc`, `android`
- `clang -print-target-triple` mostra o triple atual, e `clang --target=... -print-target-triple` mostra como o Clang completou um triple parcial

---

**Quais targets este clang tem**

```bash
clang --print-targets
```

```text
  Registered Targets:
    aarch64    - AArch64 (little endian)
    arm        - ARM
    arm64      - ARM64 (little endian)
    x86        - 32-bit X86: Pentium-Pro and above
    x86-64     - 64-bit X86: EM64T and AMD64
    ...
```

- O Apple Clang só tem os backends de ARM, AArch64 e x86. `--target=wasm32` ou `--target=riscv64-linux-gnu` falham com `No available targets are compatible with triple`
- O Clang do LLVM do Homebrew e o dos pacotes do Linux vêm com todos os backends, incluindo RISC-V, WebAssembly, MIPS, PowerPC e AVR

---

**Sysroot: os arquivos do sistema alvo**

O compilador gera o código, mas os headers da libc, a própria libc, o código de inicialização (`crt1.o`) e o linker certo são do sistema alvo, e não vêm com o Clang:

```text
main.c:1:10: fatal error: 'stdio.h' file not found     ← clang --target=x86_64-linux-gnu main.c
```

```bash
# sysroot: uma cópia de /usr/include e /usr/lib do sistema alvo
clang --target=aarch64-linux-gnu --sysroot=$HOME/sysroots/aarch64 \
      -fuse-ld=lld main.c -o main_arm64
```

- `--sysroot=dir`: o Clang passa a procurar headers em `dir/usr/include` e bibliotecas em `dir/usr/lib`, como se `dir` fosse a raiz do sistema alvo
- `-fuse-ld=lld`: o `lld` sabe linkar ELF, Mach-O, COFF e WebAssembly no mesmo binário. O `ld` do macOS só linka Mach-O (ver `linkers.md`)
- Formas comuns de conseguir um sysroot de Linux: copiar `/usr/include`, `/usr/lib` e `/lib` de uma máquina ou container do sistema alvo, ou instalar os pacotes de cross-compilation da distribuição (no Debian e no Ubuntu, `libc6-dev-arm64-cross`)
- Para Windows com a ABI `msvc`, os headers e as bibliotecas vêm do Windows SDK. Com a ABI `gnu`, vêm do MinGW-w64

---

**No macOS: -arch e versões do sistema**

Entre as plataformas da Apple o SDK já está instalado, então não é preciso sysroot:

```bash
clang -arch x86_64 main.c -o main_intel                    # Mac Intel, a partir de um Mac ARM
clang -arch arm64 -arch x86_64 main.c -o main_universal    # as duas arquiteturas em um arquivo
lipo -info main_universal                                  # Architectures in the fat file: x86_64 arm64
clang -mmacos-version-min=12.0 main.c -o main              # roda a partir do macOS 12
```

- `-arch` é a forma da Apple de escolher a arquitetura. `-arch x86_64` equivale a `--target=x86_64-apple-macosx`
- Com mais de um `-arch`, o driver compila uma vez para cada arquitetura e junta os resultados com o `lipo` em um universal binary (ver `gcc/advanced/mach-o.md`)
- O executável `x86_64` roda no Mac ARM pelo Rosetta 2, o que permite testar o resultado na mesma máquina

---

**WebAssembly**

```bash
clang --target=wasm32 -nostdlib -Wl,--no-entry -Wl,--export-all -O2 soma.c -o soma.wasm
```

- `-nostdlib`: sem libc, pois o WebAssembly puro não tem sistema operacional, e o código só pode usar o que ele mesmo define
- `--no-entry`: não há `main`, o módulo só exporta funções (`--export-all`) para serem chamadas de fora
- Precisa do Clang do LLVM com o backend `wasm32` e do `wasm-ld` (parte do `lld`). Para usar a libc, existe o `wasi-libc`, com o target `wasm32-wasi`

> O Clang resolve a parte difícil da cross-compilation, que é gerar o código de máquina, mas não a parte trabalhosa, que é conseguir a libc e as bibliotecas do sistema alvo. Quando o objetivo é só gerar um executável Linux a partir do macOS, compilar dentro de um container Linux costuma ser mais simples que montar um sysroot. A cross-compilation com `--target` compensa quando o mesmo build precisa gerar para vários alvos, e o CMake tem suporte direto a ela por meio de `toolchain files` (ver `cmake/advanced/toolchains.md`)
