**Sections do executável e layout de memória**

> onde cada parte do seu programa vai parar

Cada coisa que você escreve em C acaba em um lugar específico: o código em uma section, as strings literais em outra, as variáveis globais em outra. Quando o programa roda, o loader mapeia essas sections na memória com permissões diferentes, e é isso que define, por exemplo, por que alterar uma string literal derruba o programa

```bash
size app                # tamanho de text, data e bss
readelf -S app          # Linux: todas as sections
size -m app             # macOS: segments e sections
cat /proc/<pid>/maps    # Linux: mapa de memória de um processo rodando
vmmap <pid>             # macOS: equivalente
```

---

**Onde cada coisa vai**

```c
#include <stdlib.h>

int global_init = 5;            // .data       (__DATA,__data)
int global_zero;                // .bss        (__DATA,__bss / __common)
static int estatica = 0;        // .bss        (zerado vai para o .bss)
const int constante = 10;       // .rodata     (__TEXT,__const)

int main(void) {                // .text       (__TEXT,__text)
  static int contador = 1;      // .data       (static local também é global por dentro)
  int local = 3;                // pilha       (não é section)
  const char *msg = "ola";      // "ola" no .rodata (__TEXT,__cstring); msg na pilha
  char buf[] = "ola";           // pilha: cópia gravável da string
  int *p = malloc(16);          // p na pilha; os 16 bytes no heap
  free(p);
  return 0;
}
```

| Section (ELF) | Mach-O | Conteúdo | Permissão |
|---------------|--------|----------|-----------|
| `.text` | `__TEXT,__text` | código das funções | `r-x` |
| `.rodata` | `__TEXT,__const`, `__TEXT,__cstring` | `const` globais, strings literais, tabelas de `switch` | `r--` |
| `.data` | `__DATA,__data` | globais e `static` inicializadas com valor diferente de zero | `rw-` |
| `.bss` | `__DATA,__bss` | globais e `static` zeradas ou sem inicializador. Não ocupa espaço no arquivo | `rw-` |
| `.init_array` / `.fini_array` | `__DATA_CONST,__mod_init_func` | ponteiros para `__attribute__((constructor/destructor))` | `rw-` → `r--` |
| `.eh_frame` | `__TEXT,__eh_frame`, `__unwind_info` | tabelas de unwind da pilha | `r--` |

---

**Layout do processo na memória**

```text
endereço alto
┌───────────────────────┐
│ stack       rw-       │ ↓ cresce para baixo; variáveis locais, endereços de retorno
├───────────────────────┤
│        ...            │
│ bibliotecas (.so)     │   libc, ld-linux / dyld shared cache, mmap()
│        ...            │
├───────────────────────┤
│ heap        rw-       │ ↑ cresce para cima; malloc
├───────────────────────┤
│ .bss        rw-       │ ┐
│ .data       rw-       │ │ vindos do executável
│ .rodata     r--       │ │
│ .text       r-x       │ ┘
├───────────────────────┤
│ não mapeado           │   ponteiros nulos caem aqui (__PAGEZERO no macOS)
└───────────────────────┘
endereço baixo
```

- Com ASLR, o endereço base do executável (se for PIE), das bibliotecas, do heap e da pilha muda a cada execução. O desenho mostra só a ordem relativa típica

---

**Comportamentos que vêm daqui**

- `char *s = "ola"; s[0] = 'O';` causa segmentation fault: a string está no `.rodata`, que é somente leitura. `char s[] = "ola";` cria uma cópia na pilha, que pode ser alterada
- Variáveis globais e `static` sem inicializador valem zero porque o `.bss` é preenchido com zeros pelo kernel. Variáveis locais **não** têm essa garantia, pois a pilha contém o lixo deixado por chamadas anteriores
- `int grande[1000000] = {0};` global não aumenta o executável (vai para o `.bss`), mas `= {1}` aumenta em 4 MB (vai para o `.data`, com todos os bytes gravados no arquivo)
- Um `const` local normalmente fica na pilha ou em registrador, e não no `.rodata`. O `const` só garante que o compilador não deixa você alterar

---

**Proteções**

- **W^X**: nenhuma página é gravável e executável ao mesmo tempo. O código não pode ser alterado, e dados injetados não podem ser executados
- **Pilha não executável** (`GNU_STACK` sem `E`): impede executar código colocado na pilha por um buffer overflow
- **RELRO** (Linux): depois que o loader aplica as relocations, partes como `.got` e `.init_array` viram somente leitura (ver `dynamic-linking.md`). No macOS, o segment `__DATA_CONST` cumpre papel parecido

> Sections são a divisão do arquivo usada pelo linker. Segments são a divisão usada para carregar na memória (ver `elf.md` e `mach-o.md`). O que aparece no `/proc/<pid>/maps` ou no `vmmap` são os segments mapeados, com as permissões acima, mais heap, pilha e bibliotecas
