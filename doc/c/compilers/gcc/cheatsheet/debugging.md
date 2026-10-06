**Debugging**

> flags `-g`, `-Og`, `-O0` e `-fno-omit-frame-pointer`

O código de máquina não sabe nada sobre o seu código-fonte: não tem nomes de variáveis, tipos, nem números de linha. Para que um debugger (GDB, LLDB) consiga mostrar "você está na linha 12 de `main.c` e `total` vale 42", o compilador precisa gravar junto do binário um mapa entre as duas coisas. É isso que o `-g` faz

```bash
gcc -g3 -Og -Wall -Wextra main.c -o main
gdb ./main     # Linux
lldb ./main    # macOS
```

- `-g3`: grava informações de debug, incluindo as macros
- `-Og`: otimiza só o que não atrapalha o debug
- `-Wall -Wextra`: warnings úteis (ver `warnings.md`)

---

**O que o -g grava**

O formato usado no Linux e no macOS é o **DWARF**, com tabelas como:

```text
endereço 0x1149  →  main.c, linha 12, coluna 5         (.debug_line)
variável total   →  tipo int, em [rbp-4] / registrador (.debug_info)
struct Pessoa    →  campos nome (char *) e idade (int)  (.debug_info)
como desfazer a pilha a partir deste endereço           (.eh_frame / .debug_frame)
```

- O `-g` **não muda o código gerado**, só acrescenta metadados. O executável fica maior, mas não mais lento. Por isso dá para usar `-g` até em builds de release
- `-g` equivale a `-g2`. `-g3` acrescenta as definições de `#define`, permitindo `print MAX_SIZE` ou `macro expand MIN(a, b)` no GDB. `-g1` grava só o mínimo para stack traces
- `-ggdb` gera DWARF com extensões específicas do GDB. No Linux, na prática, é igual ao `-g`

> **Linux (ELF)**: o DWARF fica em sections `.debug_*` dentro do próprio executável. `strip main` remove essas sections. **macOS (Mach-O)**: o linker **não** copia o DWARF para o executável. Ele deixa apenas um "debug map" apontando para os `.o`. Se os `.o` forem apagados, o LLDB perde as informações, a não ser que você gere um pacote `.dSYM` com `dsymutil main`. Compilando e linkando em um único comando, o driver costuma rodar o `dsymutil` automaticamente

---

**-O0 vs -Og**

- `-O0`: nenhuma otimização. Toda variável existe na pilha durante toda a função e cada linha vira um bloco de instruções. É a correspondência mais fiel com o fonte, mas o programa fica bem mais lento
- `-Og`: aplica apenas otimizações que preservam a experiência de debug. Gera código mais rápido que `-O0` e ainda permite mais warnings que dependem de análise de fluxo
- Use `-Og` por padrão. Mude para `-O0` quando o debugger mostrar `<optimized out>` em uma variável que você precisa ver, ou quando o `step` estiver pulando linhas
- Com `-O2`, o debug ainda funciona, mas com as estranhezas descritas em `optimization.md`

---

**-fno-omit-frame-pointer**

```text
      pilha
┌──────────────────┐
│ frame de main    │ ◄─┐
├──────────────────┤   │ frame pointer salvo
│ frame de f       │ ──┘ (rbp no x86-64, x29 no ARM64)
├──────────────────┤
│ frame de g       │ ◄── rbp aponta para cá
└──────────────────┘
```

- A partir de `-O1`, no x86-64 o GCC usa o registrador `rbp` como registrador comum, em vez de mantê-lo como um ponteiro para o frame atual. Os frames deixam de formar uma lista encadeada
- Debuggers usam as tabelas de unwind (`.eh_frame`) e continuam montando o backtrace normalmente, mas profilers (`perf`), sanitizers e alguns crash reporters usam o caminho rápido do frame pointer e podem gerar stack traces cortados
- `-fno-omit-frame-pointer` mantém essa lista, custando um registrador. Recomendado junto com sanitizers e profilers
- No macOS ARM64 a ABI da Apple exige o frame pointer, então ele já é mantido

---

**Usando o debugger**

```bash
gdb ./main                 # ou: lldb ./main
(gdb) break main.c:12      # (lldb) b main.c:12
(gdb) run                  # (lldb) run
(gdb) next / step          # próxima linha / entra na função
(gdb) print total          # (lldb) p total
(gdb) bt                   # backtrace da pilha
```

- **DAP**: no Neovim, o `nvim-dap` conversa com o debugger pelo Debug Adapter Protocol. O GDB 14+ fala DAP nativamente (`gdb -i dap`). Para o LLDB usa-se o `lldb-dap` (ou o `codelldb`). Em ambos, as informações vêm do mesmo DWARF gerado pelo `-g`

> Sem `-g`, o debugger ainda roda o programa e mostra os nomes das funções que estão na tabela de símbolos (ver `symbols.md`), mas não mostra linhas, variáveis locais nem tipos, só assembly
