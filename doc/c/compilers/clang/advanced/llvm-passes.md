**Passes do LLVM**

> o que o `-O2` faz por dentro, passe por passe

O otimizador do LLVM não é um bloco único: ele é uma sequência de `passes`, pequenos programas que recebem o LLVM IR, fazem uma transformação específica e devolvem o IR modificado para o próximo. O `-O2` é só uma lista escolhida de passes, rodados em uma ordem definida (o `pipeline`). Dá para ver o IR depois de cada um deles e acompanhar como o código muda (ver `llvm-ir.md`)

```bash
clang -O2 -fno-discard-value-names -mllvm -print-changed -c abs.c -o /dev/null
```

- `-mllvm`: repassa a opção para o LLVM, e não para o Clang (ver `flags.md`)
- `-print-changed`: imprime o IR só depois dos passes que mudaram alguma coisa. Os que não mudaram aparecem como `omitted because no change`
- A saída vai para o `stderr` e pode ter milhares de linhas. Redirecione para um arquivo (`2> passes.txt`)

---

**Exemplo: maior(a, b)**

```c
int maior(int a, int b) {
  int r;
  if (a > b) {
    r = a;
  } else {
    r = b;
  }
  return r;
}
```

```text
*** IR Dump At Start ***
*** IR Dump After InferFunctionAttrsPass on [module] ***
*** IR Dump After SROAPass on maior ***
*** IR Dump After GlobalOptPass on [module] ***
*** IR Dump After SimplifyCFGPass on maior ***
*** IR Dump After InstCombinePass on maior ***
*** IR Dump After TailCallElimPass on maior ***
*** IR Dump After PostOrderFunctionAttrsPass on (maior) ***
*** IR Dump After AArch64 Instruction Selection (aarch64-isel) on maior ***
...
```

- Dos mais de 200 passes do `-O2`, só esses mudaram a função. Os últimos (`AArch64 ...`) já são do backend, que trabalha com instruções da CPU e não mais com IR

O início é o IR do `-O0` (com `alloca`, `load` e `store`, ver `llvm-ir.md`). Cada passe faz uma parte:

```text
; 1. SROA: as variáveis da pilha viram valores SSA, e o r vira um phi
entry:
  %cmp = icmp sgt i32 %a, %b
  br i1 %cmp, label %if.then, label %if.else
if.then:
  br label %if.end
if.else:
  br label %if.end
if.end:
  %r.0 = phi i32 [ %a, %if.then ], [ %b, %if.else ]
  ret i32 %r.0

; 2. SimplifyCFG: os blocos vazios somem e o desvio vira um select
entry:
  %cmp = icmp sgt i32 %a, %b
  %a.b = select i1 %cmp, i32 %a, i32 %b
  ret i32 %a.b

; 3. InstCombine: "compara e escolhe o maior" vira o intrinsic de máximo
entry:
  %a.b = call i32 @llvm.smax.i32(i32 %a, i32 %b)
  ret i32 %a.b
```

- **SROA** (Scalar Replacement of Aggregates): tira as variáveis da memória e as coloca em registradores virtuais. É o passe que mais muda o código de `-O0` para `-O1`, e é ele que faz as variáveis aparecerem como `<optimized out>` no debugger
- **SimplifyCFG**: simplifica o grafo de blocos (o `CFG`, Control Flow Graph): junta blocos, remove os vazios e troca desvios curtos por `select`
- **InstCombine**: troca sequências de instruções por outras equivalentes e mais simples, como `x * 2` por `x << 1`, ou o `select` acima por `smax`

---

**Os passes mais importantes**

- `SROA`, `mem2reg`: variáveis da pilha para registradores
- `InstCombine`, `InstSimplify`: simplificações algébricas e de instruções
- `SimplifyCFG`: simplificação dos blocos e desvios
- `EarlyCSE`, `GVN`: eliminação de subexpressões repetidas (calcular `a * b` uma vez só quando aparece duas vezes)
- `Inliner`: copia o corpo de funções pequenas para dentro de quem as chama
- `LICM` (Loop Invariant Code Motion): tira de dentro do laço o que não muda entre as voltas
- `IndVarSimplify`: simplifica as variáveis de controle de laço, e é o que troca um laço de soma por uma fórmula fechada
- `LoopVectorize`, `SLPVectorizer`: vetorização de laços e de blocos (ver `optimization.md`)
- `LoopUnroll`: desenrola laços
- `DCE`, `ADCE`: remove código cujo resultado nunca é usado
- `TailCallElim`: troca uma recursão de cauda por um laço

---

**Mais opções de inspeção**

```bash
clang -O2 -mllvm -print-after-all -c main.c -o /dev/null 2> todos.txt     # o IR depois de cada passe
clang -O2 -mllvm -print-after=sroa -c main.c -o /dev/null                 # só depois de um passe
clang -O2 -mllvm -print-before=instcombine -c main.c -o /dev/null         # antes de um passe
clang -O2 -mllvm -print-after-all -mllvm -filter-print-funcs=maior ...    # só uma função
clang -O2 -ftime-report -c main.c -o /dev/null                           # quanto tempo cada passe levou
```

- Os nomes curtos usados em `-print-after=` (`sroa`, `instcombine`, `gvn`, `licm`) são os mesmos que o `opt` aceita em `-passes=`
- `-filter-print-funcs` é quase obrigatório em arquivos reais: sem ele, o `-print-after-all` imprime cada função do arquivo depois de cada passe

Com o `opt` (do LLVM do Homebrew, ver `apple-clang.md`), dá para rodar passes isolados sobre um `.ll`:

```bash
clang -S -emit-llvm -O0 -Xclang -disable-O0-optnone abs.c -o abs.ll
opt -passes=sroa -S abs.ll -o -                       # só o SROA
opt -passes='sroa,simplifycfg,instcombine' -S abs.ll  # os três do exemplo, em ordem
opt -passes='default<O2>' -print-pipeline-passes abs.ll -disable-output   # lista o pipeline do -O2
```

> Ver o IR passe por passe é a forma mais direta de entender uma otimização surpreendente: um laço que sumiu, uma verificação de `NULL` removida ou um overflow que "deixou de acontecer". Nesses dois últimos casos, quase sempre há um comportamento indefinido no código, e o passe que fez a mudança mostra qual regra do C o otimizador usou, como o `nsw` de uma soma com sinal (ver `llvm-ir.md`)
