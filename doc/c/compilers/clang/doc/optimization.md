**Otimização**

> flags `-O`, `-R` e `-flto` do Clang

Os níveis de otimização do Clang têm os mesmos nomes e a mesma ideia dos do GCC (ver `gcc/doc/optimization.md`): `-O0` não otimiza, `-O2` é o padrão para release, `-O3` é mais agressivo e `-Os`/`-Oz` priorizam o tamanho. A diferença é onde isso acontece: no Clang, toda otimização é feita pelo LLVM sobre o LLVM IR (ver `llvm-ir.md`), e o Clang deixa ver exatamente o que cada otimização fez ou deixou de fazer

```bash
clang -O2 main.c -o main
clang -O2 -S -emit-llvm main.c -o -    # o IR depois das otimizações
```

---

**Níveis no Clang**

| Flag | No Clang |
|------|----------|
| `-O0` | nenhuma otimização (padrão). Gera IR com `optnone` |
| `-Og` | hoje é igual ao `-O1`, diferente do GCC, onde tem passes próprios para debug |
| `-O1` | otimizações básicas |
| `-O2` | release: inlining, vetorização de laços e de blocos (SLP), etc |
| `-O3` | `-O2` + inlining e transformações de laço mais agressivos |
| `-Os` | `-O2` sem o que aumenta o tamanho |
| `-Oz` | ainda menor que `-Os`, desliga até a vetorização de laços |
| `-Ofast` | `-O3` + `-ffast-math`. Obsoleto a partir do Clang 19, que pede `-O3 -ffast-math` explicitamente |
| `-O4` | aceito só por compatibilidade, vira `-O3` com o aviso `-O4 is equivalent to -O3` |

- A vetorização (usar instruções que processam vários valores de uma vez, como as NEON no ARM64 e as AVX no x86-64) é ligada em `-O2`. `-fno-vectorize` desliga a de laços e `-fno-slp-vectorize` a de blocos
- `#pragma clang loop vectorize(disable)` e `#pragma clang loop unroll(disable)` antes de um `for` controlam só aquele laço

---

**Optimization remarks: o que foi otimizado**

As `remarks` são mensagens do otimizador, no mesmo formato dos warnings, dizendo o que ele fez em cada linha do código:

```c
int quadrado(int x) { return x * x; }
int total(int *v, int n) {
  int s = 0;
  for (int i = 0; i < n; i++) s += quadrado(v[i]);
  return s;
}
```

```bash
clang -O2 -Rpass='inline|loop-vectorize' -c laco.c
```

```text
laco.c:4:36: remark: 'quadrado' inlined into 'total' with (cost=-30, threshold=337) at callsite total:2:36; [-Rpass=inline]
laco.c:4:3: remark: vectorized loop (vectorization width: 4, interleaved count: 4) [-Rpass=loop-vectorize]
```

- `-Rpass=regex`: o que foi feito, filtrado pelo nome do passe. `-Rpass='.*'` mostra tudo
- `-Rpass-missed=regex`: o que o passe tentou e **não** conseguiu fazer. É a mais útil para descobrir por que um laço não foi vetorizado
- `-Rpass-analysis=regex`: o motivo de uma decisão, normalmente junto com o `-Rpass-missed`
- `vectorization width: 4`: o laço processa 4 `int` por instrução. `interleaved count: 4`: 4 dessas instruções ficam intercaladas em cada volta
- Só o último `-Rpass=` passado vale. Para ver dois passes, junte os nomes na mesma regex com `|`, como acima

```bash
clang -O2 -fsave-optimization-record -c laco.c   # grava todas as remarks em laco.opt.yaml
```

- O `.opt.yaml` tem as mesmas informações das remarks, em um formato que scripts conseguem ler, incluindo as que não foram pedidas com `-R`

---

**LTO: otimização no link**

Cada `.c` é otimizado sozinho, então o compilador não consegue fazer inlining de uma função que está em outro arquivo. Com LTO (Link Time Optimization), o `.o` guarda LLVM IR em vez de código de máquina, e o linker chama o LLVM para otimizar o programa inteiro de uma vez

```bash
clang -O2 -flto -c soma.c       # soma.o contém bitcode: "LLVM bitcode, wrapper"
clang -O2 -flto -c main.c
clang -O2 -flto main.o soma.o -o app
```

- `-flto` (full LTO): junta todo o IR em um módulo só e otimiza tudo junto. Melhor resultado, mas lento e usa muita memória em projetos grandes
- `-flto=thin` (ThinLTO): cada arquivo continua sendo otimizado separadamente e em paralelo, mas com um resumo dos outros, o que permite o inlining entre arquivos. Quase o mesmo ganho do full, com um tempo de link bem menor. É o mais usado em projetos grandes
- A flag precisa estar na compilação **e** no link
- `.o` com bitcode do Clang não podem ser linkados com LTO do GCC, e o contrário também vale. Sem `-flto`, objetos dos dois compiladores se misturam normalmente

---

**PGO: otimização guiada por perfil**

Com PGO (Profile Guided Optimization), o programa é compilado uma vez com contadores, executado com uma entrada típica, e compilado de novo usando a contagem de quantas vezes cada `if` e cada laço rodou. O otimizador passa a saber quais caminhos são quentes

```bash
clang -O2 -fprofile-instr-generate pgo.c -o pgo           # 1. compila com contadores
LLVM_PROFILE_FILE=pgo.profraw ./pgo                       # 2. roda e grava o perfil
xcrun llvm-profdata merge -output=pgo.profdata pgo.profraw # 3. converte o perfil
clang -O2 -fprofile-instr-use=pgo.profdata pgo.c -o pgo   # 4. compila usando o perfil
```

- O ganho vem de decisões que dependem da frequência: quais funções vale a pena fazer inlining, a ordem dos blocos para o caminho comum ficar sem desvios, quais laços desenrolar
- O `llvm-profdata` vem nas Command Line Tools do macOS (por isso o `xcrun`). No Linux, vem com o pacote do LLVM
- O mesmo `-fprofile-instr-generate` com `-fcoverage-mapping` é a base da cobertura de testes (`llvm-cov`)

---

**Tempo de compilação**

```bash
clang -ftime-trace -c laco.c   # gera laco.json
```

- O `.json` mostra quanto tempo cada etapa levou (`Frontend`, `Backend`, cada header incluído, cada função otimizada). Abre em visualizadores de trace como o `chrome://tracing` ou o Perfetto
- O caso mais comum de compilação lenta em C são headers grandes incluídos em todo arquivo, e o `-ftime-trace` mostra quais são

> As remarks respondem a pergunta que o assembly sozinho não responde: **por que** o compilador fez aquilo. Ao otimizar um laço, o fluxo comum é ver o assembly (`clang -O2 -S`), rodar `-Rpass-missed=loop-vectorize` para descobrir o que bloqueou a vetorização (aliasing entre ponteiros, chamada de função, dependência entre voltas do laço) e só então mudar o código, como adicionar `restrict` aos ponteiros
