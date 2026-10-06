**Mach-O**

> formato de executáveis e objetos no macOS (e iOS)

Mach-O (Mach Object) é o formato usado pela Apple para objetos (`.o`), executáveis, bibliotecas dinâmicas (`.dylib`), bundles e arquivos de debug (`.dSYM`). Cumpre o mesmo papel do ELF no Linux (ver `elf.md`), mas com outra organização: em vez de duas tabelas separadas (sections e segments), tudo é descrito por uma lista de `load commands`

```bash
file app             # Mach-O 64-bit executable arm64
otool -h app         # header
otool -l app         # todos os load commands (segments, sections, dylibs...)
otool -L app         # dylibs necessárias
size -m app          # tamanho de cada segment e section
dyld_info -fixups app  # fixups (relocations) que o dyld aplica (macOS 13+)
```

**Estrutura**

```text
┌──────────────────────────┐
│ Mach header              │  magic, CPU, tipo de arquivo, nº de load commands
├──────────────────────────┤
│ Load commands            │  LC_SEGMENT_64 __TEXT, LC_SEGMENT_64 __DATA,
│                          │  LC_MAIN, LC_LOAD_DYLINKER, LC_LOAD_DYLIB, ...
├──────────────────────────┤
│ __TEXT    (r-x)          │  __text, __stubs, __cstring, __const
│ __DATA_CONST (r-- após   │  __got, __const
│              o dyld)     │
│ __DATA    (rw-)          │  __data, __bss, __common
│ __LINKEDIT (r--)         │  símbolos, strings, fixups, assinatura de código
└──────────────────────────┘
```

**Header** — `otool -h`

- Magic `0xfeedfacf` para Mach-O 64 bits
- `cputype`: `ARM64` ou `X86_64`
- `filetype`: `MH_OBJECT` (`.o`), `MH_EXECUTE` (executável), `MH_DYLIB` (`.dylib`), `MH_BUNDLE` (plugin carregado com `dlopen`), `MH_DSYM` (debug info)

**Segments e sections**

- Seções são nomeadas como `segment,section`: `__TEXT,__text` é o código, `__TEXT,__cstring` as strings literais, `__DATA,__data` as variáveis inicializadas, `__DATA,__bss` as zeradas
- `__PAGEZERO`: em executáveis 64 bits, os primeiros 4 GB do espaço de endereçamento ficam sem permissão nenhuma. Qualquer acesso a um ponteiro nulo (ou a um ponteiro truncado para 32 bits) gera `EXC_BAD_ACCESS`
- `__LINKEDIT`: não contém código nem dados do programa, e sim as informações usadas pelo `dyld`: tabela de símbolos, fixups, exports e a assinatura de código

**Load commands importantes** — `otool -l`

| Comando | Função |
|---------|--------|
| `LC_SEGMENT_64` | um segment e suas sections, com endereço e permissões |
| `LC_MAIN` | offset do `main`. O `dyld` chama o `main` diretamente, sem `crt1.o` |
| `LC_LOAD_DYLINKER` | caminho do loader: `/usr/lib/dyld` |
| `LC_LOAD_DYLIB` | cada dylib necessária (equivale ao `DT_NEEDED` do ELF) |
| `LC_ID_DYLIB` | o `install name` de uma dylib (ver `../libraries.md`) |
| `LC_RPATH` | diretórios para resolver `@rpath` |
| `LC_SYMTAB` / `LC_DYSYMTAB` | tabela de símbolos e sua divisão em locais/exportados/indefinidos |
| `LC_DYLD_CHAINED_FIXUPS` | relocations em formato compacto (macOS 12+) |
| `LC_UUID` | identificador único, usado para casar o binário com o `.dSYM` |
| `LC_CODE_SIGNATURE` | assinatura de código |
| `LC_BUILD_VERSION` | plataforma e versão mínima do macOS |

**Diferenças práticas em relação ao ELF**

- Todo símbolo C ganha um `_` na frente: `main` vira `_main`, e é assim que aparece no `nm` e nos erros do linker
- **Two-level namespace**: cada símbolo importado é gravado junto com **a dylib** de onde ele vem (`_printf` de `libSystem.B.dylib`). No Linux, o loader procura o símbolo em todas as bibliotecas carregadas, em ordem
- Executáveis são sempre PIE e não podem ser totalmente estáticos (ver `static-linking.md`)
- Em ARM64, **todo** executável precisa estar assinado para rodar. O linker aplica automaticamente uma assinatura `ad-hoc`. Modificar os bytes do binário depois (por exemplo, com um editor hexadecimal) invalida a assinatura e o kernel mata o processo. Refaça com `codesign -s - -f app`
- O debug info não fica no executável: fica nos `.o` ou em um pacote `.dSYM` separado (ver `../debugging.md`)

**Universal binaries**

Um único arquivo pode conter versões para várias arquiteturas (`fat binary`), com um cabeçalho extra apontando para cada Mach-O interno:

```bash
clang -arch arm64 -arch x86_64 main.c -o app   # o GCC não gera universal binaries diretamente
lipo -info app                                  # Architectures in the fat file: x86_64 arm64
lipo app -thin arm64 -output app-arm64           # extrai só uma arquitetura
```

> Desde o macOS 11, as bibliotecas do sistema (como a `libSystem`) não existem mais como arquivos separados em `/usr/lib`: ficam todas dentro do `dyld shared cache`, um único arquivo pré-linkado. Na hora de compilar, o linker usa arquivos `.tbd` do SDK (texto descrevendo os símbolos exportados) no lugar delas
