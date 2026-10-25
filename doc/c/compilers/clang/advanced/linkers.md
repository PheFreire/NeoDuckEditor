**Linkers**

> `ld64`, GNU ld, `lld` e `-fuse-ld`

O Clang não tem um linker próprio embutido: o driver chama um linker externo no final, e qual deles depende da plataforma. O trabalho de qualquer linker é o mesmo (juntar os `.o`, resolver os símbolos, aplicar as relocations, ver `gcc/doc/linking.md`), mas eles diferem nos formatos que entendem, nas opções do `-Wl,` e na velocidade

```bash
clang -### main.o soma.o -o app   # mostra qual linker o driver chama e com quais argumentos
clang -Wl,-v main.o soma.o -o app # o linker mostra a versão e os diretórios de busca
```

| Linker | Plataforma | Formato | Observação |
|---|---|---|---|
| `ld` (ld-prime) | macOS | Mach-O | o padrão no macOS desde o Xcode 15 |
| `ld-classic` (ld64) | macOS | Mach-O | o linker antigo da Apple, obsoleto |
| GNU ld (`ld.bfd`) | Linux | ELF | o padrão na maioria das distribuições |
| `gold` | Linux | ELF | mais rápido que o GNU ld, hoje sem manutenção |
| `lld` | todas | ELF, Mach-O, COFF, WebAssembly | o linker do LLVM |
| `mold` | Linux, macOS | ELF, Mach-O | foco em velocidade, compatível com as opções do GNU ld |

---

**macOS: ld**

```bash
ld -v
```

```text
@(#)PROGRAM:ld PROJECT:ld-1115.7.3
configured to support archs: armv6 armv7 armv7s arm64 arm64e arm64_32 i386 x86_64 x86_64h ...
```

- O `ld` das Command Line Tools é o `ld-prime`, reescrito pela Apple no Xcode 15. O antigo ainda existe como `ld-classic`, mas `-Wl,-ld_classic` já avisa `-ld_classic is deprecated and will be removed in a future release`
- Só entende Mach-O. Por isso o macOS não consegue linkar um executável Linux com o linker padrão (ver `cross-compilation.md`)
- As opções são diferentes das do GNU ld: `-Wl,-dead_strip` em vez de `--gc-sections`, `-Wl,-map,arquivo` em vez de `-Map`, e sem `--verbose`, `--start-group` ou `-rpath-link`

```bash
clang -Wl,-map,app.map main.c soma.c -o app   # grava o mapa: onde cada símbolo ficou no executável
clang -O2 -Wl,-dead_strip main.c -o app       # remove funções e dados que ninguém usa
```

```text
# Symbols:
# Address     Size        File  Name
0x100003F24   0x0000004C  [  1] _main
0x100003F70   0x00000020  [  2] _soma
```

- `-dead_strip` remove do executável cada função que não é chamada a partir do `main`. No Linux, o efeito equivalente precisa de `-ffunction-sections -fdata-sections` na compilação e `-Wl,--gc-sections` no link

---

**Linux: GNU ld e a ordem das bibliotecas**

- No Linux, o Clang usa por padrão o mesmo `ld` do GCC (do GNU binutils), então as mensagens e as opções do `-Wl,` são as mesmas do GCC
- O GNU ld lê arquivos e bibliotecas da esquerda para a direita, e uma `.a` só fornece os símbolos que já estavam faltando quando ela foi lida. Por isso `-lm` precisa vir depois dos `.o` (ver `gcc/doc/libraries.md`)
- O `lld` e o `ld` do macOS não têm essa restrição: procuram nas bibliotecas os símbolos que faltam em qualquer posição. Um comando com `-l` no lugar errado pode funcionar no macOS e falhar no Linux

---

**lld**

O `lld` é o linker do projeto LLVM. Um único programa tem quatro "sabores", escolhidos pelo nome com que é chamado:

- `ld.lld`: ELF (Linux, BSD), compatível com as opções do GNU ld
- `ld64.lld`: Mach-O (macOS), compatível com as opções do `ld` da Apple
- `lld-link`: COFF (Windows), compatível com as opções do `link.exe` do Visual Studio
- `wasm-ld`: WebAssembly

```bash
clang -fuse-ld=lld main.c soma.c -o app           # usa o lld no lugar do linker padrão
clang --ld-path=/opt/homebrew/opt/lld/bin/ld64.lld main.c -o app   # caminho exato do linker
```

- `-fuse-ld=nome`: faz o driver procurar `ld.nome` (ou `ld64.nome` no macOS) no `PATH` e nos diretórios do Clang
- `--ld-path=caminho`: o caminho completo do linker, sem procura
- É várias vezes mais rápido que o GNU ld em projetos grandes, principalmente com LTO
- Não vem com o Apple Clang: `-fuse-ld=lld` falha com `invalid linker name in argument '-fuse-ld=lld'`. Vem com `brew install lld` ou com o LLVM do Homebrew

---

**LTO e o linker**

Com `-flto`, os `.o` contêm LLVM IR, e o linker precisa chamar o LLVM para terminar a compilação (ver `optimization.md`):

- O `ld` do macOS faz isso pela `libLTO.dylib` das Command Line Tools (o `-###` mostra `-lto_library .../libLTO.dylib`)
- O `lld` faz isso nativamente, por ser parte do LLVM
- O GNU ld e o `gold` precisam do plugin `LLVMgold.so`, instalado junto com o LLVM. Sem ele, o link com `-flto` falha com `file format not recognized`
- Por isso, no Linux, LTO com Clang costuma ser feito com `-flto -fuse-ld=lld`

> Trocar de linker raramente muda o executável final, mas pode mudar muito o tempo de build e as mensagens de erro. Quando um projeto grande demora mais para linkar do que para compilar, testar o `lld` (ou o `mold`) é a mudança mais barata. Quando um link funciona em uma máquina e falha em outra, compare qual linker cada uma usou com `clang -###`, pois a ordem das bibliotecas, o `-fcommon` e as opções do `-Wl,` mudam entre eles
