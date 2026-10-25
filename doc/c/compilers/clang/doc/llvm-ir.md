**LLVM IR**

> saída de `clang -S -emit-llvm`, entrada do otimizador e do backend do LLVM

O LLVM IR (Intermediate Representation) é a linguagem que fica entre o C e o assembly. O frontend do Clang traduz o C para IR, todas as otimizações do `-O` são feitas em cima desse IR, e só no final o backend o transforma em instruções de uma CPU específica. Como o IR não pertence a nenhuma linguagem nem a nenhuma arquitetura, o mesmo otimizador e os mesmos backends servem para C, C++, Rust, Swift e qualquer outra linguagem que gere IR

> Uma representação intermediária é um "assembly genérico": tem instruções simples como `add`, `load` e `br` (desvio), mas com tipos, com um número infinito de registradores e sem se prender aos registradores e instruções de uma CPU real. É isso que permite otimizar uma vez só e gerar código para qualquer arquitetura depois

```bash
clang -S -emit-llvm soma.c                          # gera soma.ll (texto)
clang -c -emit-llvm soma.c                          # gera soma.bc (bitcode, binário)
clang -S -emit-llvm -O2 soma.c -o -                 # IR otimizado no stdout
clang -S -emit-llvm -fno-discard-value-names abs.c  # mantém os nomes das variáveis do C
```

- `.ll` é o IR em texto, legível. `.bc` (bitcode) é o mesmo conteúdo em formato binário, menor e mais rápido de ler
- Os dois podem voltar para o `clang` como se fossem um `.c`: `clang main.c soma.ll -o app` compila e linka normalmente
- Por padrão o IR usa números (`%0`, `%1`) no lugar dos nomes. `-fno-discard-value-names` mantém os nomes do C (`%a`, `%cmp`), o que deixa o IR bem mais fácil de ler

---

**Exemplo**

```c
int soma(int a, int b) {
  return a + b;
}
```

```text
; clang -S -emit-llvm -O2 soma.c
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-macosx15.0.0"

define i32 @soma(i32 noundef %0, i32 noundef %1) local_unnamed_addr #0 {
  %3 = add nsw i32 %1, %0
  ret i32 %3
}
```

- `target triple` e `target datalayout`: para qual plataforma o IR foi gerado e o tamanho e alinhamento de cada tipo nela. O IR gerado a partir de C já depende do target, pois o `sizeof(long)` e a ABI mudam entre plataformas
- `define i32 @soma(...)`: uma função que devolve `i32`. Nomes globais começam com `@` e valores locais com `%`
- `i32`: inteiro de 32 bits. O IR não diferencia `signed` de `unsigned` no tipo, quem diferencia é a instrução (`sdiv` e `udiv`, `icmp sgt` e `icmp ugt`)
- `nsw` (no signed wrap): o resultado não pode estourar como inteiro com sinal. Vem do C, onde overflow de `signed` é comportamento indefinido, e libera o otimizador para assumir que nunca acontece
- `noundef`: o argumento nunca é um valor indefinido (lixo)
- `#0`: um grupo de atributos definido no fim do arquivo, como a CPU alvo (`"target-cpu"="apple-m1"`) e se a função mantém o frame pointer

---

**SSA e a mesma função em -O0**

O IR é **SSA** (Static Single Assignment): cada valor `%x` recebe um valor uma única vez e nunca é alterado. Variáveis do C que mudam de valor viram, em `-O0`, espaços na pilha (`alloca`) lidos e escritos com `load` e `store`:

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
; clang -S -emit-llvm -O0 -fno-discard-value-names
define i32 @maior(i32 noundef %a, i32 noundef %b) #0 {
entry:
  %a.addr = alloca i32, align 4          ; espaço na pilha para a, b e r
  %b.addr = alloca i32, align 4
  %r = alloca i32, align 4
  store i32 %a, ptr %a.addr, align 4
  store i32 %b, ptr %b.addr, align 4
  %0 = load i32, ptr %a.addr, align 4
  %1 = load i32, ptr %b.addr, align 4
  %cmp = icmp sgt i32 %0, %1             ; a > b, com sinal
  br i1 %cmp, label %if.then, label %if.else

if.then:                                 ; preds = %entry
  %2 = load i32, ptr %a.addr, align 4
  store i32 %2, ptr %r, align 4
  br label %if.end

if.else:                                 ; preds = %entry
  %3 = load i32, ptr %b.addr, align 4
  store i32 %3, ptr %r, align 4
  br label %if.end

if.end:                                  ; preds = %if.else, %if.then
  %4 = load i32, ptr %r, align 4
  ret i32 %4
}
```

- O código é dividido em `basic blocks` (`entry`, `if.then`, `if.else`, `if.end`): sequências de instruções sem desvios no meio, sempre terminadas por um `br` (desvio) ou `ret`
- `br i1 %cmp, label %if.then, label %if.else` é o `if`: vai para um bloco ou para o outro conforme o `i1` (um bit, o resultado da comparação)
- `ptr` é um ponteiro sem tipo. O tipo do valor lido ou escrito fica na instrução (`load i32, ptr %r`)
- O comentário `preds` lista de quais blocos se pode chegar ali

Com `-O1`, o otimizador transforma os `alloca` em valores SSA e percebe que a função inteira é um "máximo com sinal":

```text
define i32 @maior(i32 noundef %a, i32 noundef %b) local_unnamed_addr #0 {
entry:
  %a.b = tail call i32 @llvm.smax.i32(i32 %a, i32 %b)
  ret i32 %a.b
}
```

- `@llvm.smax.i32` é um `intrinsic`: uma função que o LLVM conhece e que o backend troca por instruções da CPU (no ARM64, um `cmp` e um `csel`)

---

**phi e select**

Quando um valor depende de qual caminho foi seguido, o SSA usa o `phi`: "se cheguei do bloco X, o valor é este, se cheguei do Y, é aquele". Em um laço, o otimizador pode até trocar o laço inteiro por uma fórmula:

```c
int soma_ate(int n) {
  int total = 0;
  for (int i = 0; i < n; i++) {
    total += i;
  }
  return total;
}
```

```text
; clang -S -emit-llvm -O1 -fno-discard-value-names (trecho)
entry:
  %cmp4 = icmp sgt i32 %n, 0
  br i1 %cmp4, label %for.cond.cleanup.loopexit, label %for.cond.cleanup

for.cond.cleanup.loopexit:
  ...                                    ; calcula (n - 1) * n / 2 sem nenhum laço
  %8 = add i32 %7, -1
  br label %for.cond.cleanup

for.cond.cleanup:
  %total.0.lcssa = phi i32 [ 0, %entry ], [ %8, %for.cond.cleanup.loopexit ]
  ret i32 %total.0.lcssa
}
```

- O `phi` diz: vindo de `entry` (quando `n <= 0`), o total é `0`. Vindo do outro bloco, é o resultado da fórmula
- Quando os dois lados são simples, o otimizador troca o desvio por um `select`, que escolhe entre dois valores sem desviar: `%r = select i1 %cond, i32 %x, i32 %y`

---

**Globais e chamadas**

```c
#include <stdio.h>
int main(void) { printf("ola\n"); return 0; }
```

```text
; clang -S -emit-llvm -O2 (trecho)
@str = private unnamed_addr constant [4 x i8] c"ola\00", align 1

  %1 = tail call i32 @puts(ptr nonnull dereferenceable(1) @str)

declare noundef i32 @puts(ptr nocapture noundef readonly) local_unnamed_addr #1
```

- `@str`: a string literal virou uma constante global. `[4 x i8]` é um array de 4 bytes, e o `\00` é o `\0`
- `declare`: uma função usada mas definida em outro lugar (a libc). No `.o`, ela vira um símbolo indefinido resolvido pelo linker (ver `gcc/doc/symbols.md`)
- O `printf("ola\n")` virou `puts("ola")`: o LLVM conhece a semântica das funções da libc e troca chamadas por versões mais baratas quando o resultado é o mesmo

---

**Ferramentas do LLVM**

```bash
opt -O2 -S soma.ll -o soma.opt.ll   # roda só o otimizador em um .ll
llc soma.ll -o soma.s               # roda só o backend: IR → assembly
llvm-dis soma.bc -o soma.ll         # bitcode → texto
llvm-as soma.ll -o soma.bc          # texto → bitcode
lli soma.ll                         # executa o IR direto, sem gerar executável
```

- Essas ferramentas **não** vêm nas Command Line Tools do macOS, só com o LLVM do Homebrew (`brew install llvm`, ver `apple-clang.md`)
- Com o Apple Clang dá para fazer quase tudo pelo próprio `clang`: `clang -S soma.ll` faz o papel do `llc` e `clang -S -emit-llvm -O2 soma.ll` faz o papel do `opt`
- O IR gerado com `-O0` marca cada função com o atributo `optnone`, e nenhum otimizador mexe nela depois. Para gerar um IR sem otimização que ainda possa ser otimizado com `opt`, use `clang -S -emit-llvm -O0 -Xclang -disable-O0-optnone`
- Ver os passes do otimizador e o IR depois de cada um deles: `llvm-passes.md`

> O LLVM IR não é estável entre versões: um `.bc` gerado por um LLVM mais novo pode não ser lido por um mais antigo, e o Apple Clang tem o próprio formato de versão. Use o IR para entender o que o compilador fez, e não como formato para distribuir código. O IR também é a base do LTO: com `-flto`, o `.o` guarda bitcode em vez de código de máquina, e a otimização final acontece no link (ver `optimization.md`)
