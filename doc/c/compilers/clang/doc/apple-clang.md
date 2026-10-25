**Apple Clang**

> o `clang`, `gcc` e `cc` do macOS (Xcode e Command Line Tools)

O Apple Clang é a versão do Clang que a Apple distribui com o Xcode e com as Command Line Tools. Ele parte do código do LLVM, mas é mantido em um ramo separado, com numeração própria, recursos removidos e alguns ajustes para as plataformas da Apple. No macOS, ele é o único compilador instalado por padrão, e responde tanto por `clang` quanto por `gcc` e `cc`

```bash
xcode-select --install    # instala as Command Line Tools (compilador, linker, SDK, lldb)
clang --version
gcc --version             # também mostra Apple clang
```

```text
Apple clang version 16.0.0 (clang-1600.0.26.6)
Target: arm64-apple-darwin24.0.0
Thread model: posix
InstalledDir: /Library/Developer/CommandLineTools/usr/bin
```

- `Apple clang version 16.0.0`: o número segue a versão do Xcode, e **não** a do LLVM. O Apple Clang 16 (Xcode 16) é baseado no LLVM 17, então recursos que a documentação do LLVM indica como "Clang 17" ou "Clang 18" podem ou não existir nele
- `InstalledDir`: `/Library/Developer/CommandLineTools` quando só as Command Line Tools estão instaladas, ou dentro de `/Applications/Xcode.app` quando o Xcode é o ativo (`xcode-select -p` mostra qual é)
- No código, o Apple Clang define `__apple_build_version__` além do `__clang__`. Os números de `__clang_major__` são os da Apple (`16`), e não os do LLVM

---

**SDK e xcrun**

No macOS, os headers da libc (`stdio.h`, `stdlib.h`) e as bibliotecas do sistema não ficam em `/usr/include` e `/usr/lib`, e sim dentro de um **SDK**, um diretório com os headers e os stubs (`.tbd`) das bibliotecas de uma versão do sistema

```bash
xcrun --show-sdk-path       # /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk
xcrun --show-sdk-version    # 15.2
xcrun --find clang          # caminho real do clang ativo
xcrun llvm-profdata ...     # roda uma ferramenta que não está no PATH
```

- O driver passa o SDK sozinho para o `-cc1` com `-isysroot` (visível com `clang -###`). Por isso `#include <stdio.h>` funciona sem nenhum `-I`
- `xcrun` encontra ferramentas que existem nas Command Line Tools mas não estão no `PATH`, como o `llvm-profdata` e o `llvm-cov`
- Vários SDKs podem estar instalados (`MacOSX14.sdk`, `MacOSX15.sdk`). O `MacOSX.sdk` é um link para o mais novo
- `-mmacos-version-min=13.0` define a versão mínima do macOS em que o executável roda. Sem ela, o padrão é a versão atual do sistema, e o binário pode não abrir em versões mais antigas

---

**O que o Apple Clang não tem**

Comparado ao Clang do LLVM da mesma época:

- **Ferramentas**: `clang-tidy`, `scan-build`, `opt`, `llc`, `llvm-dis` e `lld` não vêm nas Command Line Tools. O `clangd`, o `lldb`, o `llvm-profdata`, o `llvm-cov`, o `llvm-objdump` e o `dsymutil` vêm, e o `clang-format` também, mas fora do `PATH` (só pelo `xcrun clang-format`)
- **Sanitizers**: sem LeakSanitizer, MemorySanitizer, SafeStack, CFI e sem o runtime do libFuzzer. AddressSanitizer, UBSan e ThreadSanitizer funcionam (ver `sanitizers.md`)
- **OpenMP**: `-fopenmp` dá `unsupported option`
- **Targets**: só os backends de ARM, AArch64 e x86. `--target=wasm32` ou `--target=riscv64-linux-gnu` falham com `No available targets are compatible with triple` (ver `cross-compilation.md`)
- **Padrão C**: o C23 só existe como `-std=c2x` no Apple Clang 16, e não como `-std=c23`

A Apple também deixa alguns avisos mais rígidos por padrão. O driver passa `-Werror=implicit-function-declaration` para o `-cc1` (visível com `clang -###`), então a chamada de uma função sem declaração é erro mesmo com `-std=c89`, onde ela é permitida pelo padrão:

```text
impl.c:1:24: error: implicit declaration of function 'soma' [-Werror,-Wimplicit-function-declaration]
```

---

**O que só o Apple Clang tem**

- `-arch arm64 -arch x86_64`: gera um universal binary, com o código das duas arquiteturas em um só arquivo (ver `gcc/advanced/mach-o.md`)
- `arm64e`: a variante do ARM64 com `pointer authentication`, usada pelo próprio sistema
- Integração com o linker da Apple (`ld64` e o novo `ld-prime`, ver `linkers.md`), com os frameworks (`-framework Cocoa`) e com o `dsymutil`
- Os ajustes de ABI do macOS ARM64, como os argumentos variádicos sempre na pilha (ver `gcc/advanced/assembly.md`)

---

**Usando o Clang do LLVM no macOS**

```bash
brew install llvm
/opt/homebrew/opt/llvm/bin/clang --version      # Homebrew clang version ...
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"  # para ele virar o clang padrão no terminal
```

- O Homebrew não coloca esse `clang` no `PATH` sozinho (o pacote é `keg-only`), justamente para não esconder o Apple Clang, que o Xcode e outros programas esperam encontrar
- Ele traz as ferramentas que faltam: `clang-tidy`, `scan-build`, `opt`, `llc`, `lld`, `llvm-dis`, e os runtimes do LeakSanitizer e do libFuzzer
- Ele continua usando o SDK da Apple para os headers do sistema. Se um `stdio.h` não for encontrado, passe o SDK explicitamente com `-isysroot "$(xcrun --show-sdk-path)"`
- Para o CMake usar esse compilador, configure com `-DCMAKE_C_COMPILER=/opt/homebrew/opt/llvm/bin/clang`

> Para o dia a dia no macOS, o Apple Clang é suficiente: compila, debuga, roda ASan e UBSan. O Clang do Homebrew vale a pena quando você precisa de uma ferramenta que falta (`clang-tidy`, `opt`, `lld`), de um recurso mais novo da linguagem (`-std=c23`, `#embed`) ou do LeakSanitizer. Os dois podem ficar instalados juntos sem conflito, desde que você saiba qual deles o `clang` do terminal está chamando (`which clang` e `clang --version`)
