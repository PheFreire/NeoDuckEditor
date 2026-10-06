**Relocations**

> instruções para preencher endereços que ainda não são conhecidos

Quando o assembler gera um `.o`, ele não sabe em que endereço vai ficar cada função, nem onde estão as funções de outros arquivos. Então ele escreve um valor provisório (normalmente zero) e anota uma `relocation`: "neste byte, coloque o endereço de tal símbolo, calculado de tal forma". O linker (e, para bibliotecas dinâmicas, o loader) percorre essas anotações e preenche os valores reais

```bash
readelf -r main.o          # Linux: tabelas .rela.*
objdump -d -r main.o       # desmontagem com as relocations intercaladas
otool -r main.o            # macOS: relocations de um .o
dyld_info -fixups app      # macOS: fixups aplicados pelo dyld no executável
```

**Anatomia**

```c
int soma(int, int);
int contador;
int main(void) { return soma(contador, 2); }
```

```text
objdump -d -r main.o (x86-64, resumido)
   0:  8b 05 00 00 00 00        mov    eax, DWORD PTR [rip+0x0]
            2: R_X86_64_PC32     contador-0x4
   6:  be 02 00 00 00           mov    esi, 0x2
   b:  89 c7                    mov    edi, eax
   d:  e8 00 00 00 00           call   12 <main+0x12>
            e: R_X86_64_PLT32    soma-0x4
```

Cada relocation tem:
- **Offset**: onde escrever (`0x2`, `0xe`): o byte logo depois do opcode, onde estão os zeros
- **Tipo**: como calcular o valor e quantos bytes escrever
- **Símbolo**: de qual endereço se trata (`contador`, `soma`)
- **Addend**: uma constante somada ao cálculo (`-0x4`)

**Como o valor é calculado**

Os tipos mais comuns no x86-64 usam endereçamento relativo ao `rip` (a posição da próxima instrução):

```text
R_X86_64_PC32 / PLT32:   valor = S + A - P

S = endereço final do símbolo (contador)
A = addend (-4)
P = endereço final do byte sendo corrigido

O -4 existe porque o rip aponta para o FIM da instrução, 4 bytes depois de P
```

| Tipo (x86-64) | Uso |
|---------------|-----|
| `R_X86_64_PC32` | acesso a dado relativo ao `rip` |
| `R_X86_64_PLT32` | `call` para uma função (pode passar pela PLT, se ela for dinâmica) |
| `R_X86_64_64` | endereço absoluto de 64 bits (ex: `int *p = &contador;` global) |
| `R_X86_64_GOTPCRELX` | acesso via GOT, usado com `-fPIC` para símbolos que podem vir de outra biblioteca |

- No ARM64, como uma instrução tem só 32 bits, um endereço é montado em duas etapas: `adrp` (página de 4 KB) + `add`/`ldr` (offset dentro da página), com relocations `R_AARCH64_ADR_PREL_PG_HI21` e `R_AARCH64_ADD_ABS_LO12_NC` (no Mach-O: `ARM64_RELOC_PAGE21` e `ARM64_RELOC_PAGEOFF12`). Chamadas usam `bl` com `R_AARCH64_CALL26` / `ARM64_RELOC_BRANCH26`

**Estáticas vs dinâmicas**

```text
main.o ──(relocations estáticas: .rela.text)──► ld ──► app
                                                        │
                       (relocations dinâmicas: .rela.dyn, .rela.plt)
                                                        ▼
                                                  ld-linux.so / dyld ao executar
```

- **Estáticas**: ficam nos `.o` e são resolvidas pelo linker. Quando ele termina, não sobra nenhuma no executável para símbolos internos
- **Dinâmicas**: ficam no executável ou na `.so` e são resolvidas pelo loader, porque dependem de onde as bibliotecas e o próprio programa (PIE + ASLR) foram carregados:
	- `R_X86_64_RELATIVE`: soma o endereço base de carregamento a um valor. Usada em PIE para ponteiros internos
	- `R_X86_64_GLOB_DAT`: preenche uma entrada da GOT com o endereço de um símbolo de outra biblioteca
	- `R_X86_64_JUMP_SLOT`: preenche a entrada da GOT usada pela PLT de uma função (ver `dynamic-linking.md`)
- No macOS, executáveis linkados não guardam relocations no formato do `.o`: guardam `rebase` (ajustar pelo endereço base) e `bind` (preencher com um símbolo de dylib), em formato compacto chamado `chained fixups` a partir do macOS 12

**Por que -fPIC existe**

- Sem PIC, código de uma biblioteca teria relocations dentro do próprio `.text`, que o loader precisaria alterar, impedindo que a mesma página de código fosse compartilhada entre processos (e exigindo `.text` gravável)
- Com `-fPIC`, todo acesso a símbolos que podem estar em outro lugar passa pela **GOT** (Global Offset Table), uma tabela de ponteiros no segmento de dados. O loader corrige só a GOT, e o `.text` continua intocado e compartilhável

> Erros de relocation aparecem no link e quase sempre indicam código compilado com opções incompatíveis, por exemplo: `relocation R_X86_64_32 against '.rodata' can not be used when making a PIE object; recompile with -fPIE` ou `... when making a shared object; recompile with -fPIC`. A solução é recompilar os `.o` (ou a `.a` usada) com `-fPIC`/`-fPIE`
