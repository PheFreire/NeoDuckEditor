**Flags do Clang**

> referência rápida das opções que só o Clang tem ou que mudam em relação ao GCC

As flags comuns (`-o`, `-c`, `-S`, `-E`, `-I`, `-D`, `-L`, `-l`, `-g`, `-O`, `-W`, `-std`, `-fsanitize=`, `-pthread`) funcionam igual no Clang e estão em `gcc/cheatsheet/flags.md`. Esta nota lista só o que é diferente

```bash
clang -std=c17 -g -Og -Wall -Wextra -fsanitize=address,undefined main.c -o main
clang -O2 -flto=thin -Rpass-missed=loop-vectorize -c main.c
```

---

**Pipeline e LLVM IR** (ver `compilation-pipeline.md` e `llvm-ir.md`)

- `-fsyntax-only`: para depois do frontend: mostra os erros e warnings sem gerar nenhum arquivo
- `-emit-llvm`: com `-S` gera LLVM IR em texto (`.ll`), com `-c` gera bitcode (`.bc`)
- `-ccc-print-phases`: mostra as fases que o driver vai executar para cada arquivo
- `-###`: mostra os comandos do `-cc1` e do linker sem executá-los
- `-save-temps`: guarda `.i`, `.bc`, `.s` e `.o`
- `-fno-discard-value-names`: mantém os nomes das variáveis do C no IR
- `-fno-integrated-as`: usa um assembler externo em vez do integrado

---

**Repassando opções**

- `-Xclang opção`: repassa para o `clang -cc1`, como `-Xclang -ast-dump` (ver `ast.md`)
- `-mllvm opção`: repassa para o LLVM (otimizador e backend), como `-mllvm -print-after-all` (ver `llvm-passes.md`)
- `-Wl,opção`: repassa para o linker, igual ao GCC
- Essas opções não são verificadas pelo driver e podem mudar entre versões. São para investigar, e não para deixar no build

---

**Target e plataforma** (ver `cross-compilation.md` e `apple-clang.md`)

- `--target=triple`: gera código para outra arquitetura ou sistema, como `--target=x86_64-linux-gnu`
- `-arch nome` (macOS): escolhe a arquitetura. Repetido (`-arch arm64 -arch x86_64`), gera um universal binary
- `-isysroot dir` / `--sysroot=dir`: o diretório raiz onde procurar os headers e as bibliotecas do sistema alvo
- `-mmacos-version-min=13.0`: a versão mínima do macOS em que o executável roda
- `-fuse-ld=lld`: escolhe o linker (ver `linkers.md`)
- `-print-target-triple`, `-print-resource-dir`, `--print-targets`: mostram o target atual, onde ficam os headers internos e runtimes, e quais backends este `clang` tem

---

**Diagnósticos** (ver `diagnostics.md`)

- `-Weverything`: liga todos os warnings que existem
- `-ferror-limit=N`: para depois de N erros (padrão `20`, `0` = sem limite). Equivale a um `-fmax-errors` do GCC
- `-fcolor-diagnostics` / `-fno-color-diagnostics`: força ou desliga as cores, útil quando a saída passa por um pipe ou por um build system
- `-fdiagnostics-parseable-fixits`: imprime as sugestões de correção em um formato que ferramentas conseguem aplicar
- `-fno-caret-diagnostics`: só a linha do erro, sem o trecho do código e o `^`
- `-fdiagnostics-format=msvc`: formato `arquivo(linha,coluna)`, para ferramentas do Windows

---

**Otimização** (ver `optimization.md`)

- `-Rpass=regex`, `-Rpass-missed=regex`, `-Rpass-analysis=regex`: mostram o que o otimizador fez, deixou de fazer e por quê
- `-fsave-optimization-record`: grava todas as remarks em um `.opt.yaml`
- `-flto=thin`: ThinLTO, a versão paralela do `-flto`
- `-fprofile-instr-generate` / `-fprofile-instr-use=arquivo`: PGO baseado em instrumentação
- `-fprofile-instr-generate -fcoverage-mapping`: cobertura de código, lida com `llvm-cov`
- `-ftime-trace`: grava um `.json` com o tempo de cada etapa da compilação
- `-fno-vectorize`, `-fno-slp-vectorize`, `-fno-unroll-loops`: desligam otimizações específicas

---

**Segurança e runtime** (ver `sanitizers.md`)

- `-fsanitize=integer`: overflow de `unsigned` e conversões que perdem valor, que não são UB e por isso ficam fora do `undefined`
- `-fsanitize=nullability`: verifica anotações `_Nonnull` em tempo de execução
- `-fsanitize-trap=undefined`: o UBSan para o programa com uma instrução de trap, sem precisar de runtime
- `-ftrivial-auto-var-init=zero` / `=pattern`: inicializa toda variável local não inicializada com zero ou com um padrão de bytes fácil de reconhecer (`0xAA`), apagando o "lixo" da pilha

---

**Análise e ferramentas** (ver `static-analysis.md` e `tooling.md`)

- `--analyze`: roda o analisador estático em vez de compilar
- `-MJ arquivo.json`: grava a entrada do `compile_commands.json` para este arquivo

> Flags do GCC que o Clang não conhece têm dois comportamentos: um `-f` desconhecido (como `-fipa-pta`) é `error: unknown argument` e para o build, e um `-W` desconhecido (como `-Wduplicated-cond`) é só `warning: unknown warning option`. Em builds que precisam funcionar nos dois compiladores, `-Wno-unknown-warning-option` silencia o segundo caso, e `-Qunused-arguments` silencia avisos de flags que não se aplicam àquela etapa, como `-lm` em um comando com `-c` (`'linker' input unused`)
