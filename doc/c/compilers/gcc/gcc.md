**gcc**

> ferramenta de linha de comando (GNU Compiler Collection)

O GCC (GNU Compiler Collection) é um conjunto de compiladores do projeto GNU para várias linguagens (C, C++, Fortran, Ada, Go, D, etc). O comando `gcc` que você digita no terminal não é o compilador em si, e sim um `driver`: um programa que recebe os seus arquivos e flags e chama, na ordem certa, cada ferramenta do pipeline (preprocessor, compilador, assembler e linker)

```bash
gcc [opções] arquivos... [-o saída]
```

```text
gcc main.c -o main

main.c
  │  cc1   pre-processa e compila   (C → assembly)
  ▼
main.s
  │  as    monta                   (assembly → código de máquina)
  ▼
main.o
  │  ld    linka                   (junta com a libc → executável)
  ▼
main
```

- O driver decide o que fazer com cada arquivo pela extensão:
    - `.c` passa por todas as etapas
    - `.i` pula o preprocessor
    - `.s` vai direto ao assembler
    - `.S` (maiúsculo) é assembly que ainda passa pelo preprocessor
    - `.o`/`.a`/`.so` vão direto ao linker

- `gcc -v` mostra cada programa chamado pelo driver
- `gcc -###` mostra os comandos sem executá-los. 

> Veja o pipeline em detalhes em `compilation-pipeline.md`

---

**Compilando um arquivo**

```bash
gcc main.c -o main
./main
```

- `main.c`: o arquivo fonte passa pelas 4 etapas e vira um executável
- `-o main`: o nome do arquivo de saída (sem ele, o executável se chama `a.out`)

---

**Compilando vários arquivos**

```bash
# tudo de uma vez: cada .c é compilado separadamente e depois tudo é linkado junto
gcc main.c lista.c utils.c -o app

# em etapas: compila cada .c em um .o, e só depois linka
gcc -c main.c          # gera main.o
gcc -c lista.c         # gera lista.o
gcc main.o lista.o -o app
```

- Cada `.c` é uma `translation unit` independente: o compilador não enxerga o conteúdo dos outros `.c`, só as declarações que chegam pelos headers. Quem junta tudo é o linker (ver `linking.md`)

---

**Padrão da linguagem**

```bash
gcc -std=c17 main.c -o main    # ISO C17 puro
gcc -std=gnu17 main.c -o main  # C17 + extensões GNU
gcc -std=c23 main.c -o main    # C23 (GCC 14+, era -std=c2x antes)
```

- `-std=cXX` segue o padrão ISO e desliga extensões que conflitam com ele
- `-std=gnuXX` habilita as extensões GNU
- Sem `-std`, o GCC usa um padrão `gnu` que depende da versão:
    - `gnu17` do GCC 11 ao 14
    - `gnu23` a partir do GCC 15

> A flag `-std` não ativa sozinha os avisos de código fora do padrão. Para isso use `-Wpedantic` (ver `warnings.md`)

---

**Ajuda e observações**

```bash
gcc --version              # versão do compilador (e se é Clang disfarçado)
gcc --help                 # resumo das opções
gcc --help=warnings        # lista todos os warnings disponíveis
gcc --help=optimizers      # lista todas as otimizações
man gcc                    # manual completo
info gcc                   # manual GNU em formato info (mais detalhado)
gcc -dumpmachine           # plataforma alvo, ex: x86_64-linux-gnu
```

> No macOS, o comando `gcc` que vem com as Command Line Tools é, na verdade, um apelido para o Apple Clang. O `gcc --version` mostra `Apple clang version ...`. O GCC de verdade pode ser instalado pelo Homebrew (`brew install gcc`) e é chamado pelo nome com a versão, como `gcc-14` ou `gcc-15`. Quase todas as flags desta documentação funcionam nos dois, mas há diferenças pontuais que são indicadas quando relevantes
