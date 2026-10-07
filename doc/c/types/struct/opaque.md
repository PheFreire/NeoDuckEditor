**struct opaca**

> padrão de organização de código, usa declaração antecipada de struct

Uma struct opaca é declarada no `.h` sem os campos e definida por completo só no `.c`. Quem usa o tipo enxerga apenas um ponteiro e só consegue mexer nele pelas funções do módulo, o equivalente em C a uma classe com todos os campos privados

> Uma struct declarada só com o nome, sem as chaves e os campos, é um tipo incompleto. O compilador sabe que o tipo existe, mas não sabe o tamanho nem os campos, então permite ponteiros para ele e nada mais

```c
// modulo.h
typedef struct nome Nome;

Nome *nome_criar(void);
void nome_destruir(Nome *n);
```

- O `.h` mostra só o nome do tipo e as funções
- O `.c` define a struct e implementa as funções, sendo o único arquivo que acessa os campos

---

**Exemplo completo**

```c
// pilha.h
#ifndef PILHA_H
#define PILHA_H

#include <stdbool.h>

typedef struct pilha Pilha;

Pilha *pilha_criar(void);
bool pilha_empilhar(Pilha *p, int valor);
bool pilha_desempilhar(Pilha *p, int *saida);
void pilha_destruir(Pilha *p);

#endif
```

```c
// pilha.c
#include <stdlib.h>
#include "pilha.h"

struct pilha {
  int *itens;
  size_t total;
  size_t capacidade;
};

Pilha *pilha_criar(void) {
  Pilha *p = calloc(1, sizeof *p);
  return p;
}

bool pilha_empilhar(Pilha *p, int valor) {
  if (p->total == p->capacidade) {
    size_t nova = p->capacidade ? p->capacidade * 2 : 8;
    int *itens = realloc(p->itens, nova * sizeof *itens);
    if (itens == NULL) {
      return false;
    }
    p->itens = itens;
    p->capacidade = nova;
  }
  p->itens[p->total++] = valor;
  return true;
}

bool pilha_desempilhar(Pilha *p, int *saida) {
  if (p->total == 0) {
    return false;
  }
  *saida = p->itens[--p->total];
  return true;
}

void pilha_destruir(Pilha *p) {
  if (p != NULL) {
    free(p->itens);
    free(p);
  }
}
```

```c
// main.c
#include "pilha.h"

Pilha *p = pilha_criar();
pilha_empilhar(p, 10);

int valor;
pilha_desempilhar(p, &valor);  // valor == 10

p->total = 0;   // ERRO de compilação: os campos são desconhecidos aqui
Pilha outra;    // ERRO de compilação: o tamanho é desconhecido aqui

pilha_destruir(p);
```

---

**Vantagens e custos**

- Mudar os campos da struct não exige recompilar quem usa, só o `.c`, pois o código de fora nunca dependeu do tamanho dela
- Ninguém consegue deixar a struct em um estado inválido mexendo nos campos diretamente
- Prefixar as funções com o nome do tipo (`pilha_`) e passar a struct como primeiro argumento imita métodos de uma classe
- O custo é que toda instância precisa ser alocada pelo módulo, normalmente com `malloc`, pois quem usa não sabe o tamanho para criar uma na pilha de execução

> O `FILE` do `stdio.h` é usado dessa forma: ninguém acessa seus campos, só `fopen`, `fread`, `fclose` e afins. É o padrão mais comum para bibliotecas em C, pois deixa a parte pública pequena e estável enquanto a implementação muda livremente
