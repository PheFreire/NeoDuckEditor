**Expansão dinâmica do Python**

> fórmula de crescimento de arrays dinâmicos, não precisa de header

É a conta que decide quanto espaço reservar quando um array dinâmico enche. Em vez de pedir memória para exatamente um elemento a mais, ela reserva alguns espaços sobrando, para que as próximas inserções não precisem pedir memória de novo

> Um array dinâmico é um array que cresce conforme novos elementos são adicionados. Ele guarda dois números: o `tamanho` (quantos elementos estão em uso) e a `capacidade` (quantos cabem no espaço já reservado). Enquanto sobra capacidade, adicionar é só escrever na próxima posição. Quando enche, é preciso um `realloc` para um bloco maior, o que pode copiar todos os elementos para outro lugar da memória

```c
size_t new_total_size = (
    total_size +
    (total_size >> 3) +
    (total_size < 9 ? 3 : 6)
);
```

- `total_size`: a quantidade de elementos que precisa caber, ou seja, o tamanho atual mais o elemento que está sendo adicionado
- Devolve a nova capacidade, sempre um pouco maior que `total_size`

---

**Onde é usado**

- É a fórmula que a `list` do Python usa para crescer a cada `append` que não cabe mais no espaço reservado
- Serve para qualquer array dinâmico em C: listas, pilhas, buffers de texto que crescem, vetores de structs

---

**O que significa cada operação**

- `total_size`: o espaço que realmente precisa caber
- `total_size >> 3`: deslocar 3 bits para a direita é dividir por 8 (`2³`). Adiciona uns 12,5% de folga, proporcional ao tamanho. É usado o shift em vez do `/ 8` por ser uma operação mais barata, mas o resultado é o mesmo para números sem sinal
- `total_size < 9 ? 3 : 6`: uma folga fixa. Com poucos elementos, os 12,5% dão quase nada (`5 >> 3` é `0`), então soma `3` para listas pequenas e `6` para as maiores

Capacidades geradas ao adicionar um elemento por vez, começando de uma lista vazia:

```text
precisa caber   1 → capacidade  4
precisa caber   5 → capacidade  8
precisa caber   9 → capacidade 16
precisa caber  17 → capacidade 25
precisa caber  26 → capacidade 35
precisa caber  36 → capacidade 46
precisa caber  47 → capacidade 58
```

---

**Por que ele é bom**

- **Poucas realocações**: cada `realloc` abre espaço para várias inserções seguintes, então adicionar um elemento custa, em média, tempo constante (O(1) amortizado)
- **Pouco desperdício**: a folga é de só 12,5%. A estratégia comum de dobrar a capacidade pode deixar até metade da memória reservada sem uso
- **Bom com listas pequenas**: a folga fixa de `3` ou `6` evita um `realloc` a cada um dos primeiros elementos, que é quando a parte proporcional ainda é zero
- **Barato de calcular**: só soma, shift e uma comparação

> A troca é que, com listas muito grandes, crescer 12,5% faz mais `realloc` do que dobrar. Para chegar a 1 milhão de elementos, são 85 realocações contra 21 dobrando. O Python aceita esse custo para economizar memória, já que listas grandes são onde o desperdício mais pesa

---

**Exemplo de uso**

```c
#include <stdio.h>
#include <stdlib.h>

typedef struct {
  int *itens;
  size_t tamanho;
  size_t capacidade;
} Lista;

static size_t nova_capacidade(size_t total_size) {
  return total_size + (total_size >> 3) + (total_size < 9 ? 3 : 6);
}

static int lista_push(Lista *l, int valor) {
  if (l->tamanho == l->capacidade) {             // cheia: precisa crescer
    size_t cap = nova_capacidade(l->tamanho + 1);
    int *novo = realloc(l->itens, cap * sizeof(int));
    if (novo == NULL) {
      return -1;                                 // sem memória, a lista antiga continua válida
    }
    l->itens = novo;
    l->capacidade = cap;
  }
  l->itens[l->tamanho++] = valor;                // com espaço sobrando: só escreve
  return 0;
}

int main(void) {
  Lista l = {0};                                 // vazia: itens NULL, tamanho e capacidade 0
  for (int i = 0; i < 50; i++) {
    lista_push(&l, i);                           // 50 inserções, só 7 realloc
  }
  printf("%zu de %zu\n", l.tamanho, l.capacidade); // 50 de 58
  free(l.itens);
  return 0;
}
```

- O `realloc(NULL, n)` funciona como um `malloc`, por isso a lista pode começar com `itens` igual a `NULL`
- O resultado do `realloc` vai para uma variável separada (`novo`): se ele falhar e devolver `NULL`, o ponteiro antigo não é perdido

> Nas versões mais novas do Python a fórmula mudou um pouco: soma sempre `6` e arredonda o resultado para um múltiplo de 4. A ideia continua a mesma: o tamanho necessário, mais 1/8 dele, mais uma folga pequena
