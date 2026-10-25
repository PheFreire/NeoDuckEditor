**Análise estática**

> `clang --analyze`, `scan-build` e `clang-tidy`

Análise estática é procurar bugs **sem executar** o programa, só lendo o código. Os warnings do compilador já são uma forma simples disso, mas olham cada linha quase isolada. As ferramentas do Clang vão além: o analisador estático simula os caminhos possíveis de cada função (cada `if` tomado ou não), e o `clang-tidy` procura padrões conhecidos de código problemático. Os dois usam a mesma AST do compilador (ver `ast.md`)

> A diferença para os sanitizers é o momento: um sanitizer só encontra o erro se aquele caminho for executado durante o teste, enquanto a análise estática olha para todos os caminhos, inclusive os que nenhum teste percorre. Em troca, ela gera falsos positivos e não enxerga valores que só existem em tempo de execução

---

**clang --analyze**

```c
#include <stdlib.h>
int f(int n) {
  int *p = malloc(sizeof(int));
  if (n > 0) {
    return n;
  }
  *p = n;
  free(p);
  return 0;
}
```

```bash
clang --analyze leak.c                                    # só o warning
clang --analyze -Xanalyzer -analyzer-output=text leak.c   # com o caminho até o erro
```

```text
leak.c:5:12: warning: Potential leak of memory pointed to by 'p' [unix.Malloc]
    5 |     return n;
      |            ^
leak.c:3:12: note: Memory is allocated
    3 |   int *p = malloc(sizeof(int));
      |            ^~~~~~~~~~~~~~~~~~~
leak.c:4:7: note: Assuming 'n' is > 0
    4 |   if (n > 0) {
      |       ^~~~~
leak.c:4:3: note: Taking true branch
    4 |   if (n > 0) {
      |   ^
leak.c:5:12: note: Potential leak of memory pointed to by 'p'
```

- O `-Wall -Wextra` não avisa nada nesse código. O analisador segue o caminho em que `n > 0` e percebe que `p` sai da função sem `free`
- As `note` contam o caminho passo a passo: onde a memória foi alocada, qual condição foi assumida e qual desvio foi tomado
- Não gera executável. Por padrão grava um `.plist` com o mesmo relatório, que pode ser apagado
- Precisa das mesmas flags do build (`-I`, `-D`, `-std`) para entender o código, e analisa um arquivo por vez

---

**Checkers**

Cada tipo de bug é procurado por um `checker`, e o nome dele aparece entre colchetes no warning:

- `core.NullDereference`, `core.DivideZero`, `core.uninitialized.*`: ponteiro nulo acessado, divisão por zero, valor não inicializado usado
- `core.StackAddressEscape`: devolver o endereço de uma variável local
- `unix.Malloc`: leak, double free, use-after-free
- `unix.cstring.NullArg`: `NULL` passado para `strcpy`, `strlen` e parecidas
- `deadcode.DeadStores`: valor guardado em uma variável que nunca é lido depois
- `security.insecureAPI.*`: uso de `gets`, `strcpy`, `rand`, `mktemp` (alguns ficam desligados por padrão)

```bash
clang -cc1 -analyzer-checker-help                                   # lista todos os checkers
clang --analyze -Xanalyzer -analyzer-checker=security.insecureAPI.strcpy main.c   # liga um checker
```

```c
char *p = NULL;
if (n > 10) {
  p = malloc(16);
}
strcpy(p, "ola");   // warning: Null pointer passed as 1st argument to string copy function [unix.cstring.NullArg]
free(p);
free(p);            // warning: Attempt to free released memory [unix.Malloc]
```

---

**scan-build**

```bash
scan-build make                # roda o build interceptando o compilador
scan-build -o relatorio make   # grava os relatórios em ./relatorio
scan-view relatorio/<data>     # abre o relatório HTML no navegador
```

- Roda o analisador em todos os arquivos que o build compila, sem precisar mudar o `Makefile`, trocando o `CC` por um wrapper
- O relatório HTML mostra cada bug com o caminho marcado em cima do código
- Não vem nas Command Line Tools do macOS. Vem com o LLVM do Homebrew ou com o pacote `clang-tools` no Linux

---

**clang-tidy**

O `clang-tidy` é um linter: cada `check` procura um padrão de código que costuma ser bug, que é inseguro ou que pode ser escrito de forma mais clara. Muitos checks também sabem corrigir o código sozinhos

```bash
clang-tidy main.c -- -std=c17 -Iinclude                     # flags do build depois do --
clang-tidy -p build main.c                                  # pega as flags do build/compile_commands.json
clang-tidy -checks='-*,bugprone-*,cert-*' main.c --         # escolhe os checks
clang-tidy --fix -checks='-*,readability-braces-around-statements' main.c --
clang-tidy -list-checks -checks='*'                         # lista todos os checks
```

- Tudo depois do `--` são flags de compilação. Sem o `--`, ele procura um `compile_commands.json` (ver `tooling.md`)
- `-checks` usa uma lista com `*` e `-` na frente para tirar: `-*` desliga tudo e depois só o que for listado é ligado

Famílias de checks úteis em C:
- `bugprone-*`: padrões que quase sempre são bug, como `bugprone-sizeof-expression` (`sizeof(ptr)` onde se queria o tamanho do array) e `bugprone-suspicious-string-compare` (`if (strcmp(a, b))` sem comparar com `0`)
- `cert-*`: regras do CERT C, como `cert-err34-c`, que aponta `atoi` e sugere `strtol`, já que o `atoi` não informa erro de conversão
- `clang-analyzer-*`: os mesmos checkers do `clang --analyze`, rodando dentro do `clang-tidy`
- `misc-*`, `performance-*`, `readability-*`: estilo e clareza. Os de `readability` são os que mais geram ruído

```yaml
# .clang-tidy na raiz do projeto
Checks: >
  -*,
  bugprone-*,
  cert-*,
  clang-analyzer-*,
  -bugprone-easily-swappable-parameters
WarningsAsErrors: ''
```

- O `.clang-tidy` vale para o diretório onde está e todos os de baixo, e é lido tanto pelo `clang-tidy` quanto pelo `clangd`
- Não vem nas Command Line Tools do macOS (ver `apple-clang.md`). O `clangd` iniciado com `--clang-tidy` roda os checks do `.clang-tidy` direto no editor, sem precisar do executável `clang-tidy` instalado

> Os falsos positivos são o preço da análise estática. Para um aviso que foi verificado e não é bug, `// NOLINT(nome-do-check)` no fim da linha silencia o `clang-tidy` só ali, e `#ifndef __clang_analyzer__` esconde um trecho do `clang --analyze`. Prefira essas marcações pontuais a desligar o check inteiro, pois o mesmo check pode encontrar um bug real em outro arquivo
