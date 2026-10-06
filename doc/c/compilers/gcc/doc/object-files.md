**Arquivos objeto (.o)**

> saída de `gcc -c`, entrada do linker

Um arquivo `.o` (object file) é o resultado de compilar e montar um único `.c`: ele já contém o código de máquina das funções daquele arquivo, mas ainda não é um programa. Faltam os endereços finais, o código das funções que estão em outros arquivos e o código de inicialização que chama o `main`. É o formato de troca entre o compilador e o linker

```bash
gcc -c main.c        # gera main.o
file main.o
# Linux: main.o: ELF 64-bit LSB relocatable, x86-64 ...
# macOS: main.o: Mach-O 64-bit object arm64
```

> O formato depende do sistema: **ELF** no Linux (e na maioria dos Unix), **Mach-O** no macOS, **COFF/PE** no Windows. Os conceitos abaixo valem para todos, mudam os nomes e os detalhes

---

**O que tem dentro**

```text
main.o
├── header          formato, arquitetura, onde está cada parte
├── sections
│   ├── .text       código de máquina das funções
│   ├── .data       variáveis globais/static inicializadas  (int x = 5;)
│   ├── .bss        variáveis globais/static zeradas         (int y;) — só o tamanho
│   ├── .rodata     constantes e strings literais            ("ola mundo")
│   └── .debug_*    informações do -g (DWARF)
├── tabela de símbolos     nomes definidos aqui e nomes usados mas não definidos
└── relocations            pontos do código que precisam de um endereço ainda desconhecido
```

- No Mach-O, as sections ficam dentro de segments e têm nomes como `__TEXT,__text`, `__DATA,__data`, `__DATA,__bss` e `__TEXT,__cstring`
- O `.bss` não ocupa espaço no arquivo, só registra quantos bytes zerados serão necessários quando o programa for carregado

**Símbolos definidos e não resolvidos**

```c
// main.c
#include <stdio.h>
int contador = 0;                        // definido aqui
int soma(int a, int b);                  // apenas declarado: está em outro .c
int main(void) {
  printf("%d\n", soma(contador, 2));     // usa dois símbolos de fora
  return 0;
}
```

```bash
nm main.o
# 0000000000000000 B contador     B = definido, no .bss
# 0000000000000000 T main         T = definido, no .text
#                  U printf       U = undefined, ainda não resolvido
#                  U soma
```

- Os símbolos `U` são promessas: o `.o` diz "eu uso `soma`, alguém tem que fornecer". Ver `symbols.md`
- No macOS os nomes aparecem com `_` na frente (`_main`, `_printf`), convenção do Mach-O

**Relocations**

Ao gerar o `.o`, o assembler não sabe em que endereço `soma` ou `printf` vão estar, nem onde o próprio `main` vai ficar no executável. Então ele escreve zeros no lugar e anota uma relocation:

```bash
objdump -d -r main.o   # Linux (no macOS: objdump --macho -d -r, ou otool -tv)
#   1e:  e8 00 00 00 00     call  23 <main+0x23>
#             1f: R_X86_64_PLT32  soma-0x4
```

- `e8 00 00 00 00`: instrução `call` com o endereço zerado
- `R_X86_64_PLT32 soma`: "no byte `0x1f`, escreva o deslocamento até `soma`". Quem faz isso é o linker, depois de decidir onde cada coisa fica (ver `linking.md`)

**Por que um .o não é um executável**

- Tem símbolos indefinidos (`U`) que ninguém resolveu
- Os endereços são relativos ao início de cada section (por isso `relocatable`), e não endereços finais
- Não tem ponto de entrada: o `_start`, que prepara o processo e chama o `main`, está nos arquivos `crt*.o`, adicionados pelo driver só no link
- Não tem informações de carregamento (quais partes mapear em memória, com quais permissões, qual dynamic loader usar)

**Ferramentas**

| Ferramenta | Linux | macOS |
|------------|-------|-------|
| símbolos | `nm main.o` | `nm main.o` |
| sections e headers | `readelf -S main.o`, `objdump -h` | `otool -l main.o`, `size -m` |
| desmontar | `objdump -d main.o` | `objdump -d main.o`, `otool -tv` |
| relocations | `readelf -r main.o` | `otool -r main.o` |

> Um `.o` compilado com `-c` em uma máquina só pode ser linkado com outros `.o` do mesmo formato e arquitetura. Não dá para juntar um `.o` x86-64 com um ARM64. Uma biblioteca estática (`.a`) é simplesmente um pacote de vários `.o` (ver `libraries.md`)
