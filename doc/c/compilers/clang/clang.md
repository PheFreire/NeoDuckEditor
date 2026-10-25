**clang**

> ferramenta de linha de comando (frontend C do projeto LLVM)

O Clang é o compilador de C, C++ e Objective-C do projeto LLVM. Assim como o `gcc`, o comando `clang` é um `driver`: recebe os arquivos e as flags e chama cada etapa do pipeline. A diferença é a arquitetura por dentro: o Clang só entende a linguagem e traduz o código para uma linguagem intermediária, o `LLVM IR`, e é o LLVM que otimiza esse IR e gera o código de máquina de cada arquitetura

```bash
clang [opções] arquivos... [-o saída]
```

```text
clang main.c -o main

main.c
  │  clang -cc1   frontend: preprocessor, parser, AST   (C → LLVM IR)
  ▼
LLVM IR
  │  LLVM         middle-end: otimizações sobre o IR   (IR → IR)
  ▼
  │  LLVM         backend: gera instruções da CPU       (IR → código de máquina)
  ▼
main.o
  │  ld           linka                                 (junta com a libc → executável)
  ▼
main
```

- **Frontend** (o Clang de verdade): lê o C, monta a AST, emite os warnings e gera o LLVM IR
- **Middle-end** (LLVM): aplica as otimizações do `-O` sobre o IR, sem saber de qual linguagem ele veio
- **Backend** (LLVM): traduz o IR para assembly ou direto para código de máquina de uma arquitetura (ARM64, x86-64...)
- Diferente do GCC, o assembler já fica dentro do próprio `clang` (`integrated assembler`), então o `.s` não passa por um programa `as` separado

> Veja o pipeline em detalhes em `compilation-pipeline.md`

---

**Clang e GCC**

O Clang foi feito para ser um substituto direto do GCC: aceita quase todas as flags, as extensões GNU da linguagem e o mesmo formato de linha de comando. Na prática, trocar `gcc` por `clang` em um `Makefile` costuma funcionar sem nenhuma outra mudança

- Compilação, linking, bibliotecas, ELF, Mach-O e o loader funcionam da mesma forma nos dois. Esses temas estão em `gcc/` e valem para o Clang (os caminhos `gcc/...` desta documentação são relativos a `compilers/`)
- Flags como `-c`, `-S`, `-E`, `-o`, `-I`, `-D`, `-L`, `-l`, `-g`, `-O2`, `-Wall`, `-Wextra` e `-fsanitize=` têm o mesmo significado (ver `gcc/cheatsheet/flags.md`)
- O Clang define `__GNUC__` (com o valor `4`) para que código feito para o GCC compile sem mudanças. Para saber se o compilador é mesmo o Clang, use `__clang__` (ver `extensions.md`)
- Os `.o` gerados pelos dois seguem a mesma ABI, então é possível linkar objetos do GCC com objetos do Clang no mesmo programa

O que é específico do Clang:
- O LLVM IR, que pode ser gerado, lido e otimizado separadamente (ver `llvm-ir.md`)
- A AST exposta para ferramentas como `clangd`, `clang-tidy` e `clang-format` (ver `ast.md` e `tooling.md`)
- Mensagens de erro com sugestões de correção (`fix-it`) e o `-Weverything` (ver `diagnostics.md`)
- Um único binário que compila para várias arquiteturas com `--target` (ver `cross-compilation.md`)
- Sanitizers e análise estática a mais (ver `sanitizers.md` e `static-analysis.md`)

---

**Compilando**

```bash
clang main.c -o main                  # um arquivo
clang main.c lista.c -o app           # vários arquivos
clang -c main.c                       # só gera main.o
clang -std=c17 -g -Wall -Wextra main.c -o main
```

- Sem `-std`, o Clang usa `gnu17` (C17 com extensões GNU) desde o Clang 11
- O C23 é `-std=c23` a partir do Clang 18. Nas versões anteriores, inclusive no Apple Clang 16, o nome é `-std=c2x`

---

**Ajuda e observações**

```bash
clang --version              # versão, target e diretório de instalação
clang --help                 # resumo das opções
clang -print-target-triple   # plataforma alvo, ex: arm64-apple-darwin24.0.0
clang -print-resource-dir    # headers internos e runtimes (sanitizers, builtins)
clang -dM -E - < /dev/null   # todas as macros predefinidas
```

```text
Apple clang version 16.0.0 (clang-1600.0.26.6)
Target: arm64-apple-darwin24.0.0
Thread model: posix
InstalledDir: /Library/Developer/CommandLineTools/usr/bin
```

- `Target` é o `target triple`: arquitetura, fabricante e sistema para os quais o código é gerado (ver `cross-compilation.md`)
- O `clang` não tem `--help=warnings` como o GCC. A lista de warnings fica na documentação online "Diagnostic flags in Clang", ou pode ser vista na prática com `-Weverything`

> No macOS, o `clang`, o `gcc` e o `cc` das Command Line Tools são todos o **Apple Clang**, uma versão do Clang mantida pela Apple, com numeração própria e algumas diferenças em relação ao Clang do LLVM. O Clang do LLVM pode ser instalado pelo Homebrew (`brew install llvm`). Ver `apple-clang.md`
