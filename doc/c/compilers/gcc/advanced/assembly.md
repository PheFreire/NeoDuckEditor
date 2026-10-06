**Assembly**

> saída de `gcc -S`, entrada do assembler (`as`)

Assembly é a representação em texto das instruções de máquina de uma arquitetura: cada linha corresponde (quase sempre) a uma instrução que a CPU executa. É o que o compilador gera a partir do C e o que o assembler transforma em bytes no `.o`. Ler assembly é a forma mais direta de saber o que o compilador **realmente** fez com o seu código, especialmente com otimização (ver `../optimization.md`)

```bash
gcc -S -O2 main.c                                  # gera main.s
gcc -S -O2 -masm=intel main.c                      # sintaxe Intel (só x86)
gcc -S -O2 -fno-asynchronous-unwind-tables main.c  # sem as diretivas .cfi_*
objdump -d -M intel main.o                         # desmonta um .o já compilado
```

- O assembly depende da **arquitetura**: x86-64 (Intel/AMD) e ARM64 (Apple Silicon, servidores ARM) têm instruções, registradores e convenções completamente diferentes
- O `.s` gerado pelo GCC está na sintaxe **AT&T** em x86. `-masm=intel` troca para a Intel, usada pela maioria dos manuais e tutoriais
- O site Compiler Explorer (godbolt.org) mostra o assembly de vários compiladores lado a lado, com cada linha de C colorida junto das instruções correspondentes

---

**Exemplo**

```c
int soma(int a, int b) {
  return a + b;
}
```

```text
x86-64, AT&T (gcc -O2)        x86-64, Intel                 ARM64 (gcc -O2)
soma:                         soma:                         soma:
    leal (%rdi,%rsi), %eax        lea eax, [rdi+rsi]            add w0, w0, w1
    ret                           ret                           ret
```

- Os argumentos chegam em registradores (`edi`/`esi` no x86-64, `w0`/`w1` no ARM64) e o retorno sai em `eax` / `w0`. Quem define isso é a **ABI** (abaixo), e não o C
- Em `-O0`, a mesma função tem um prólogo/epílogo e passa os valores pela pilha:

```text
soma:
    push  rbp                 ; salva o frame pointer de quem chamou
    mov   rbp, rsp            ; novo frame começa aqui
    mov   DWORD PTR [rbp-4], edi   ; a vai para a pilha
    mov   DWORD PTR [rbp-8], esi   ; b vai para a pilha
    mov   edx, DWORD PTR [rbp-4]
    mov   eax, DWORD PTR [rbp-8]
    add   eax, edx
    pop   rbp
    ret
```

---

**AT&T vs Intel**

| | AT&T | Intel |
|---|---|---|
| Ordem | `origem, destino` | `destino, origem` |
| Registrador | `%rax` | `rax` |
| Constante | `$5` | `5` |
| Tamanho | sufixo: `movl`, `movq` | pelo operando: `DWORD PTR` |
| Memória | `-8(%rbp)` | `[rbp-8]` |

---

**ABI: a convenção de chamada**

A ABI (Application Binary Interface) define como funções compiladas separadamente conversam: onde vão os argumentos, onde fica o retorno e quais registradores cada lado deve preservar. É por ela que um `.o` do GCC pode chamar uma função de uma biblioteca compilada pelo Clang

| | x86-64 System V (Linux, macOS Intel) | ARM64 (AAPCS64) |
|---|---|---|
| Argumentos inteiros/ponteiros | `rdi, rsi, rdx, rcx, r8, r9` | `x0`–`x7` |
| Argumentos `float`/`double` | `xmm0`–`xmm7` | `v0`–`v7` |
| Retorno | `rax` (`xmm0` para float) | `x0` (`v0` para float) |
| Preservados pela função chamada | `rbx, rbp, r12`–`r15` | `x19`–`x28`, `x29` (FP) |
| Endereço de retorno | empilhado pelo `call` | registrador `x30` (LR), pelo `bl` |
| Pilha | alinhada em 16 bytes antes do `call` | sempre alinhada em 16 bytes |

- Argumentos que não cabem nos registradores vão para a pilha
- x86-64 System V tem a `red zone`: 128 bytes abaixo do `rsp` que funções folha podem usar sem ajustar a pilha
- **macOS ARM64** difere do AAPCS64 padrão em detalhes: argumentos variádicos (os `...` do `printf`) vão **sempre** pela pilha, e o registrador `x18` é reservado pelo sistema. Isso importa ao escrever assembly à mão ou ao declarar mal uma função variádica

---

**Diretivas**

Linhas que começam com `.` não são instruções, e sim comandos para o assembler:

- `.text`, `.data`, `.section .rodata`: em qual section colocar o que vem a seguir (ver `executable-sections.md`)
- `.globl soma`: torna `soma` um símbolo global (ver `symbol-table.md`)
- `.string "ola"` / `.asciz`, `.long 5`, `.quad`: dados literais
- `.cfi_*`: informações de unwind para debuggers e exceções. Ocupam boa parte do `.s` e podem ser escondidas com `-fno-asynchronous-unwind-tables` só para leitura
- `.p2align 4`: alinha o próximo item

> `.s` (minúsculo) é assembly puro. `.S` (maiúsculo) passa pelo preprocessor antes, permitindo `#include` e `#define` em arquivos de assembly escritos à mão. Para pequenos trechos dentro do C, o GCC tem `__asm__` (inline assembly), mas é fácil errar a lista de registradores alterados. Prefira as funções `intrinsics` (como as de `<immintrin.h>`) quando existirem
