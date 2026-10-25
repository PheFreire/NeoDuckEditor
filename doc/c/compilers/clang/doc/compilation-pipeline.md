**Pipeline de compilação**

> etapas coordenadas pelo driver `clang`

O caminho de um `.c` até o executável é o mesmo do GCC (preprocessor, compilação, assembly, linking e loader), mas a etapa de compilação do Clang é dividida em duas partes: o frontend transforma o C em LLVM IR, e o backend do LLVM transforma o IR em código de máquina. O assembler também fica dentro do próprio `clang`, então quase tudo acontece em um único processo, o `clang -cc1`

```text
main.c          código C escrito por você
   │
   │ 1. Preprocessor     (clang -cc1)        clang -E
   ▼
main.i          C puro: headers colados, macros expandidas
   │
   │ 2. Frontend         (clang -cc1)        clang -fsyntax-only
   ▼
AST             a árvore do programa, com tipos já checados
   │
   │ 3. Codegen          (clang -cc1)        clang -S -emit-llvm
   ▼
main.ll         LLVM IR: independente da linguagem
   │
   │ 4. Otimização       (LLVM, no -cc1)     clang -O2 -S -emit-llvm
   ▼
main.ll         LLVM IR otimizado
   │
   │ 5. Backend          (LLVM, no -cc1)     clang -S
   ▼
main.s          assembly da arquitetura alvo
   │
   │ 6. Assembler        (integrado)         clang -c
   ▼
main.o          código de máquina relocável + tabela de símbolos
   │
   │ 7. Linker           (ld / ld64 / lld)   clang
   ▼
main            executável (ELF no Linux, Mach-O no macOS)
```

- As etapas de 1 a 6 rodam dentro do mesmo `clang -cc1`. Os arquivos intermediários só existem em disco se forem pedidos com `-E`, `-S`, `-emit-llvm` ou `-save-temps`
- O linker é o único programa externo chamado pelo driver
- O loader (`./main`) não depende do compilador e funciona igual ao do GCC (ver `gcc/doc/compilation-pipeline.md`)

---

**Driver e -cc1**

O `clang` que você digita é só o driver: ele descobre o target, os caminhos do SDK e das bibliotecas, e chama a si mesmo com `-cc1`, que é o compilador de verdade, com uma linha de comando bem mais longa

```bash
clang -### main.c -o main          # mostra os comandos sem executá-los
clang -v main.c -o main            # executa e mostra os comandos e os caminhos de busca
clang -ccc-print-phases main.c soma.c
```

```text
               +- 0: input, "main.c", c
            +- 1: preprocessor, {0}, cpp-output
         +- 2: compiler, {1}, ir
      +- 3: backend, {2}, assembler
   +- 4: assembler, {3}, object
   |           +- 5: input, "soma.c", c
   |        +- 6: preprocessor, {5}, cpp-output
   |     +- 7: compiler, {6}, ir
   |  +- 8: backend, {7}, assembler
   |- 9: assembler, {8}, object
+- 10: linker, {4, 9}, image
11: bind-arch, "arm64", {10}, image
```

- `-ccc-print-phases` mostra o plano do driver: cada arquivo passa pelas fases até virar um `object`, e o `linker` junta todos em uma `image` (o executável)
- `compiler` produz `ir` e `backend` produz `assembler`: é a divisão entre o Clang e o LLVM
- O `-###` mostra o `"clang" "-cc1" ...` e o `"ld" ...` com todos os argumentos que o driver adicionou sozinho, como o `-triple`, o `-isysroot` do SDK e as bibliotecas de inicialização
- Flags passadas com `-Xclang` vão direto para o `-cc1` e não são entendidas pelo driver, como `-Xclang -ast-dump` (ver `ast.md`)

---

**Diferenças em relação ao GCC**

| | GCC | Clang |
|---|---|---|
| compilador interno | `cc1` | `clang -cc1` |
| representação intermediária | GIMPLE e RTL, internos | LLVM IR, pode ser salvo e lido |
| assembler | `as` separado (GNU binutils) | integrado ao `clang` |
| linker | `collect2` chamando `ld` | `ld` direto (`ld64` no macOS) |
| alvos | um GCC por arquitetura | um Clang para várias (`--target`) |

- O `-save-temps` também existe no Clang e grava `main.i`, `main.bc` (o IR em formato binário), `main.s` e `main.o`
- `-fno-integrated-as` faz o Clang chamar um assembler externo, útil só quando um `.s` escrito à mão usa diretivas que o assembler integrado não aceita

---

**Parando em cada etapa**

| Flag | Para depois de | Saída padrão |
|------|----------------|--------------|
| `-E` | preprocessing | `stdout` |
| `-fsyntax-only` | análise e warnings, sem gerar nada | (nenhuma) |
| `-S -emit-llvm` | geração do LLVM IR em texto | `main.ll` |
| `-c -emit-llvm` | geração do LLVM IR em binário | `main.bc` |
| `-S` | backend | `main.s` |
| `-c` | assembly | `main.o` |
| (nenhuma) | linking | `a.out` |

- `-fsyntax-only` é o jeito mais rápido de ver os erros e warnings de um arquivo, pois para logo depois do frontend. É o que editores e o `clangd` fazem a cada alteração
- O driver também aceita entrar no meio do pipeline: `clang main.ll -o main` e `clang main.bc -o main` começam pelo otimizador, `clang main.s -o main` começa pelo assembler

> Os erros continuam dizendo de qual etapa vieram: `fatal error: 'x.h' file not found` vem do preprocessor, `error: expected ';'` vem do frontend, e `Undefined symbols` / `linker command failed` vem do linker. A mensagem final `clang: error: linker command failed with exit code 1` é do driver, só avisando que o linker falhou. O erro de verdade está nas linhas acima dela (ver `common-errors.md`)
