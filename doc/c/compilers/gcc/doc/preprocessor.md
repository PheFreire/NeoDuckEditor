**Preprocessor**

> primeira etapa do pipeline, parte do `cc1`

O preprocessor é a primeira etapa da compilação e trabalha só com texto: ele não entende tipos, funções ou variáveis. Ele:
- Executa as linhas que começam com `#`
- Colando arquivos incluidos
- Substituindo macros
- Removendo trechos condicionais
- Entrega para o compilador um único arquivo de C puro `translation unit`

```bash
gcc -E main.c              # mostra o resultado no terminal
gcc -E -P main.c -o main.i # sem os marcadores de linha "# 1 main.c"
```

> Um `hello world` com `#include <stdio.h>` vira centenas de linhas depois do `-E`: é o conteúdo do `stdio.h` (e de tudo que ele inclui) colado no lugar do `#include`

---

**#include**

```c
#include <stdio.h>   // procura só nos diretórios de sistema e nos do -I
#include "lista.h"   // procura primeiro no diretório do arquivo atual, depois como <>
```

- O `#include` copia literalmente o conteúdo do arquivo naquele ponto ou seja, não existe "importar módulo" em C
- `-I dir`: adiciona `dir` à busca, antes dos diretórios do sistema
- `gcc -xc -E -v - < /dev/null` mostra a lista completa de diretórios onde o GCC procura headers
- `gcc -H main.c` mostra a árvore de headers incluídos

---

**Headers: declarações, não definições**

Um header (`.h`) é um arquivo de texto que declara para o compilador o que existe fora do `.c` atual, seja em outro `.c` do projeto ou em uma biblioteca, sem conter a implementação. 

Para cada função, ele informa a `assinatura`:
- O nome da função
- Os tipos dos parâmetros de entrada
- O tipo do valor de retorno

```c
// soma.h — declaração: só a assinatura, sem o corpo
int soma(int a, int b);
```

```c
// soma.c — definição: o código da função
#include "soma.h"

int soma(int a, int b) {
  return a + b;
}
```

```c
// main.c — usa a função conhecendo apenas o soma.h
#include "soma.h"

int main(void) {
  return soma(2, 3);
}
```

```bash
gcc -c main.c               # main.o: chama soma, mas não tem o código dela
gcc -c soma.c               # soma.o: tem o código de soma
gcc main.o soma.o -o app    # o linker liga a chamada em main.o ao código em soma.o
```

- Ao compilar `main.c`, o código de `soma` não existe para o compilador.
    - O compilador vê apenas a declaração vinda do `soma.h`, que basta para checar se a chamada passa os argumentos certos e para saber o tipo do retorno

- O `main.o` fica com uma referência não resolvida para `soma` (ver `symbols.md`). 
    - O código da função só passa a fazer parte do programa quando o linker une o `main.o` ao `soma.o` (ver `linking.md`)

- O linker não lê headers, ele trabalha só com os símbolos dos `.o` e das bibliotecas.
    - O header serve ao compilador, e é por isso que um header incluído sem a biblioteca correspondente compila, mas falha no link com `undefined reference`

- O mesmo vale para bibliotecas externas: 
    - Incluir o header delas só torna as funções conhecidas para o compilador, e o `-l` no link é o que traz o código (ver `libraries.md`)

> Colocar uma definição (corpo de função, variável com valor, struct, enum...) em um header faz ela aparecer em cada `.c` que o inclui, gerando `multiple definition` no link (ver `symbols.md` e `common-errors.md`). A exceção são funções `static inline`

---

**#define**

```c
#define TAMANHO 128
#define QUADRADO(x) ((x) * (x))
```

- Substituição puramente textual, feita antes do compilador, o compilador nunca vê o nome `TAMANHO`
- Em macros com parâmetros, coloque parênteses em cada parâmetro e na expressão inteira: sem eles, `QUADRADO(1 + 2)` viraria `1 + 2 * 1 + 2 = 5`
- Os argumentos são avaliados quantas vezes aparecem: `QUADRADO(i++)` incrementa `i` duas vezes, o que é comportamento indefinido

---

**Compilação condicional**

```c
#ifdef DEBUG
  fprintf(stderr, "x = %d\n", x);
#endif

#if defined(__linux__)
  // código só para Linux
#elif defined(__APPLE__)
  // código só para macOS
#endif
```

- O trecho fora da condição é removido antes de compilar, então nem precisa ser válido para a outra plataforma

- O comando `gcc -dM -E - < /dev/null` lista todas as macros predefinidas pelo compilador:
    - `__linux__`
    - `__APPLE__`
    - `__x86_64__`
    - `__GNUC__`
    - `__STDC_VERSION__`

---

**Flags de macros -D e -U**

As flags `-D` e `-U` criam e removem macros pela linha de comando, sem alterar o código. É a forma de mudar o comportamento de um programa entre builds diferentes (debug, release, plataformas) usando a mesma fonte

```bash
gcc -DNOME main.c -o main         # como #define NOME 1
gcc -DNOME=valor main.c -o main   # como #define NOME valor
gcc -UNOME main.c -o main         # como #undef NOME
```

- `-DNOME`: define a macro com o valor `1`
- `-DNOME=valor`: define a macro com o valor informado (`-DNOME=` sem nada depois do `=` define a macro vazia)
- `-UNOME`: remove a macro, inclusive as predefinidas pelo compilador ou definidas por um `-D` anterior
- O espaço é opcional: `-D DEBUG` e `-DDEBUG` são iguais
- As macros valem para todos os `.c` daquele comando, como se o `#define` estivesse na primeira linha de cada um
- `-D` e `-U` são aplicados na ordem em que aparecem: em `gcc -DDEBUG -UDEBUG`, a macro termina indefinida

```c
#include <stdio.h>

#ifndef VERSAO
#define VERSAO 1   // valor padrão, usado quando não há -DVERSAO
#endif

int main(void) {
#ifdef DEBUG
  printf("[debug] iniciando\n");
#endif
  printf("versão %d\n", VERSAO);
  return 0;
}
```

```bash
gcc main.c -o main                     # versão 1
gcc -DDEBUG main.c -o main             # [debug] iniciando / versão 1
gcc -DDEBUG -DVERSAO=3 main.c -o main  # [debug] iniciando / versão 3
```

- `-DNDEBUG` é um caso especial já usado pela biblioteca padrão: com ele, todos os `assert()` de `assert.h` viram código vazio. É comum em builds de release
- Para passar uma string, as aspas precisam chegar ao preprocessor, então é preciso protegê-las do shell: `-DNOME='"app"'` equivale a `#define NOME "app"`

> Se o código também tiver um `#define` com o mesmo nome e um valor diferente, o compilador avisa sobre redefinição e o valor do código prevalece a partir daquela linha. Use `#ifndef` em volta do valor padrão, como no exemplo, para deixar o `-D` sobrescrevê-lo. Para conferir quais macros ficaram definidas, use `gcc -DDEBUG -dM -E main.c | grep DEBUG`

---

**Include guards**

Se um header for incluído duas vezes na mesma `translation unit` (diretamente ou por meio de outro header), suas definições de `struct` e `typedef` se repetem e o compilador acusa redefinição. O guard faz o preprocessor pular o conteúdo a partir da segunda vez:

```c
#ifndef LISTA_H
#define LISTA_H

struct lista { int *itens; int total; };
int lista_tamanho(const struct lista *l);

#endif
```

```text
main.c ─┬─ #include "lista.h"   → LISTA_H não definido: copia e define LISTA_H
        └─ #include "fila.h"
             └─ #include "lista.h" → LISTA_H já definido: pula tudo
```

- `#pragma once` faz o mesmo em uma linha e é suportado por GCC, Clang e MSVC, mas não faz parte do padrão C
- O guard protege só dentro de uma mesma translation unit
- O guard não impede `multiple definition` entre `.c` diferentes, pois cada `.c` é preprocessado do zero

> Erros de preprocessor são fáceis de reconhecer: `fatal error: lista.h: No such file or directory` (header não encontrado, falta um `-I`)
> Erros estranhos em linhas que parecem corretas, normalmente são causados por uma macro expandida de um jeito inesperado. Nesse caso, `gcc -E` mostra exatamente o código que o compilador recebeu
