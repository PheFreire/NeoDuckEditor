**ELF**

> formato de executáveis e objetos no Linux (e na maioria dos Unix)

ELF (Executable and Linkable Format) é o formato de arquivo usado no Linux para objetos (`.o`), executáveis, bibliotecas compartilhadas (`.so`) e core dumps. O mesmo formato serve a dois públicos diferentes: o **linker**, que trabalha com `sections`, e o **loader/kernel**, que trabalha com `segments`. Não é universal: o macOS usa Mach-O (ver `mach-o.md`) e o Windows usa PE/COFF

```bash
file app                 # ELF 64-bit LSB pie executable, x86-64, dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2
readelf -h app           # ELF header
readelf -S app           # section headers (visão do linker)
readelf -l app           # program headers / segments (visão do loader)
readelf -d app           # seção dinâmica: bibliotecas necessárias, rpath...
```

**Estrutura**

```text
┌──────────────────────┐
│ ELF header           │  tipo, arquitetura, entry point, onde ficam as tabelas
├──────────────────────┤
│ Program header table │  lista de segments → usada pelo kernel/loader
├──────────────────────┤
│ .text                │ ┐
│ .rodata              │ ├ segment LOAD r-x / r--
│ .eh_frame            │ ┘
│ .data                │ ┐
│ .bss (sem bytes)     │ ├ segment LOAD rw-
│ .dynamic, .got       │ ┘
│ .symtab, .strtab     │   não carregados na memória
│ .debug_*             │   não carregados na memória
├──────────────────────┤
│ Section header table │  lista de sections → usada pelo linker e ferramentas
└──────────────────────┘
```

**ELF header** — `readelf -h`

- Começa com os bytes mágicos `7f 45 4c 46` (`\x7fELF`). É assim que o kernel e o `file` reconhecem o formato
- `Class`: 32 ou 64 bits. `Data`: little ou big endian. `Machine`: x86-64, AArch64, etc
- `Type`:
	- `REL`: arquivo objeto relocável (`.o`)
	- `EXEC`: executável com endereço fixo (sem PIE)
	- `DYN`: biblioteca compartilhada **ou** executável PIE. A maioria das distros compila executáveis como PIE por padrão, para permitir ASLR
	- `CORE`: core dump
- `Entry point address`: endereço da primeira instrução (`_start`). Zero em `.o`

**Sections** — visão do linker (`readelf -S`)

- Cada section é um bloco com nome, tipo, flags (`A` alocado na memória, `W` gravável, `X` executável) e conteúdo
- Os `.o` **só** precisam de sections. O linker junta as sections de mesmo nome dos vários `.o` (ver `../linking.md`)
- Principais: `.text`, `.rodata`, `.data`, `.bss` (ver `executable-sections.md`), `.symtab`/`.strtab` (ver `symbol-table.md`), `.rela.text` (ver `relocations.md`), `.dynsym`, `.dynamic`, `.plt`, `.got` (ver `dynamic-linking.md`)

**Segments** — visão do loader (`readelf -l`)

- Cada segment diz ao kernel: "mapeie estes bytes do arquivo neste endereço, com estas permissões". Um segment agrupa várias sections com as mesmas permissões
- Os `.o` não têm segments, pois não são carregados. Executáveis e `.so` têm
- Principais tipos:
	- `LOAD`: parte do arquivo a ser mapeada na memória
	- `INTERP`: caminho do dynamic loader (`/lib64/ld-linux-x86-64.so.2`)
	- `DYNAMIC`: aponta para a tabela `.dynamic` (bibliotecas necessárias, símbolos, relocations)
	- `GNU_STACK`: define se a pilha é executável (normalmente não: `RW`)
	- `GNU_RELRO`: área que o loader torna somente leitura depois das relocations
	- `TLS`: modelo das variáveis `_Thread_local`

```text
readelf -l app (resumido)
  Type     Offset   VirtAddr  FileSiz  MemSiz   Flg
  INTERP   0x000318 0x000318  0x00001c 0x00001c R      [/lib64/ld-linux-x86-64.so.2]
  LOAD     0x000000 0x000000  0x000628 0x000628 R
  LOAD     0x001000 0x001000  0x000175 0x000175 R E    ← .text
  LOAD     0x002000 0x002000  0x0000f4 0x0000f4 R      ← .rodata
  LOAD     0x002db8 0x003db8  0x000258 0x000260 RW     ← .data + .bss (MemSiz > FileSiz)
```

- `MemSiz > FileSiz` no segment de dados: a diferença é o `.bss`, que o kernel preenche com zeros sem ocupar espaço no arquivo

> As section headers são opcionais em executáveis: o kernel só lê o ELF header e os program headers. Por isso um binário com sections removidas ainda roda, mas ferramentas como `objdump` e debuggers perdem quase toda a informação. O `strip` remove `.symtab` e `.debug_*`, mas mantém o que é necessário para rodar (`.dynsym`, `.dynamic`)
