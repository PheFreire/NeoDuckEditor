**Ferramentas úteis**

> inspecionar, desmontar e depurar arquivos compilados

Cada etapa do pipeline produz um arquivo que pode ser inspecionado. Saber qual ferramenta abre qual etapa transforma erros misteriosos ("por que essa função não está aqui?", "de onde vem essa biblioteca?") em perguntas com respostas diretas. No Linux, a maioria vem do **GNU binutils**. No macOS, das **Xcode Command Line Tools** (que incluem versões LLVM de `nm`, `objdump`, `size`, etc)

---

**Equivalências Linux / macOS**

| Para | Linux | macOS |
|------|-------|-------|
| tipo do arquivo | `file app` | `file app` |
| símbolos | `nm`, `readelf -s` | `nm`, `nm -m` |
| headers e sections | `readelf -h -S -l`, `objdump -h` | `otool -h -l`, `size -m` |
| desmontar | `objdump -d -M intel` | `objdump -d`, `otool -tv` |
| relocations | `readelf -r`, `objdump -r` | `otool -r`, `dyld_info -fixups` |
| dependências dinâmicas | `readelf -d`, `ldd` | `otool -L` |
| strings no binário | `strings app` | `strings app` |
| remover símbolos | `strip` | `strip` |
| criar `.a` | `ar rcs` | `ar rcs` / `libtool -static` |
| endereço → linha do fonte | `addr2line -e app 0x1149` | `atos -o app 0x100003f50` |
| syscalls | `strace` | `dtruss` (restrito pelo SIP) |
| chamadas a bibliotecas | `ltrace` | — |
| debugger | `gdb` | `lldb` |
| erros de memória | `valgrind`, sanitizers | sanitizers, `leaks` |
| profiling | `perf` | Instruments, `sample` |
| arquiteturas de um binário | — | `lipo -info` |
| assinatura de código | — | `codesign -dv` |

---

**Do próprio GCC**

```bash
gcc -v main.c                  # cada programa chamado e os caminhos de busca
gcc -save-temps main.c         # guarda .i, .s e .o
gcc -E -dM - < /dev/null       # macros predefinidas
gcc -print-search-dirs         # onde procura programas e bibliotecas
gcc -print-file-name=libc.a    # caminho de uma biblioteca específica
gcc -Q --help=optimizers -O2   # otimizações ativas em um nível
```

---

**Fluxos comuns**

```bash
# onde está definida a função que gera "undefined reference"?
nm -A *.o *.a 2>/dev/null | grep ' T soma'

# a biblioteca exporta mesmo esse símbolo?
nm -D libfila.so | grep fila_criar       # Linux
nm -gU libfila.dylib | grep fila_criar   # macOS (-U: só os definidos)

# por que o executável está grande?
size app
nm --size-sort -S app | tail             # os maiores símbolos (Linux)

# um crash deu só o endereço: em qual linha foi?
addr2line -f -e app 0x401136             # executável sem PIE; com PIE, use o offset dentro do binário

# quais bibliotecas o programa abre e onde as encontra?
LD_DEBUG=libs ./app                      # Linux
DYLD_PRINT_LIBRARIES=1 ./app             # macOS

# ver os bytes crus
xxd app | head                           # ou: hexdump -C app | head
```

---

**Utilitários auxiliares**

- `c++filt`: desfaz o name mangling de C++ (`_Z4somaii` → `soma(int, int)`). `nm -C` faz o mesmo direto
- `objcopy`: copia e transforma objetos. Extrair o debug info (`--only-keep-debug`), remover sections, converter para binário cru (`-O binary`, usado em firmware)
- `pkg-config --cflags --libs nome`: mostra as flags `-I`, `-L` e `-l` corretas para uma biblioteca instalada
- `ldconfig -p` (Linux): lista as bibliotecas no cache do loader
- `perf` / `valgrind --tool=callgrind`: onde o programa gasta tempo
- **Compiler Explorer** (godbolt.org): assembly de qualquer trecho, com qualquer compilador e flags, lado a lado com o C

> No macOS, `objdump` e `nm` são as versões LLVM e aceitam a maioria das opções do binutils, mas não todas (`readelf` não existe, e opções específicas de ELF não fazem sentido para Mach-O). Pelo Homebrew dá para instalar o `binutils` GNU, mas eles não entendem Mach-O completamente. Para Mach-O, prefira `otool`, `nm -m`, `dyld_info` e `size -m`
