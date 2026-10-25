**Funções variádicas**

> `stdarg.h`

Uma função variádica é uma função que aceita uma quantidade variável de argumentos, como o `printf`. Ela é declarada com `...` no fim dos parâmetros, e dentro dela os argumentos que caíram no `...` são lidos **um de cada vez, na ordem**, usando quatro peças da `stdarg.h`: `va_list`, `va_start`, `va_arg` e `va_end`

```c
void imprimir_verde(int count, ...);

imprimir_verde(3, "A", "B", "C");
//             │  └──────┬──────┘
//             │         └── vão para o ... (os argumentos extras)
//             └── vai para o parâmetro count (o argumento fixo)
```

- Os argumentos **fixos** (antes do `...`) têm nome e são usados normalmente, como `count`
- Os argumentos **extras** (que caem no `...`) não têm nome. A função não sabe quantos são nem de que tipo, e só consegue pegá-los com as peças da `stdarg.h`

---

**A ideia: uma fila e um marcador**

Pense nos argumentos extras como uma fila de valores, um atrás do outro, e nas quatro peças como as ações de ler essa fila com um marcador (como o dedo seguindo as linhas de um texto):


| Peça | O que é | Na analogia |
|---|---|---|
| `va_list args` | uma variável que guarda a posição na fila | o marcador |
| `va_start(args, count)` | coloca o marcador no primeiro extra, logo depois de `count` | pôr o dedo no começo da fila |
| `va_arg(args, char *)` | lê o valor onde o marcador está e anda uma posição | ler e passar o dedo para o próximo |
| `va_end(args)` | termina o uso do marcador | tirar o dedo |


- O `va_list` sozinho não faz nada: é só a variável. Quem o coloca no lugar é o `va_start`, e quem o faz andar é o `va_arg`

- O `va_arg` é o único que devolve um valor. Cada chamada devolve **um** argumento e já deixa o marcador no próximo

- O marcador só anda para frente. Não dá para voltar nem pular direto para o terceiro argumento

---

**Passo a passo**

A chamada `imprimir_verde(3, "A", "B", "C")`, acompanhando onde o marcador está a cada linha:

```c
void imprimir_verde(int count, ...) {
  va_list args;                       // 1
  va_start(args, count);              // 2
  char *t1 = va_arg(args, char *);    // 3
  char *t2 = va_arg(args, char *);    // 4
  char *t3 = va_arg(args, char *);    // 5
  va_end(args);                       // 6
}
```

- Por que o `va_start` recebe o `count`: os extras começam logo depois do último argumento fixo, e é por ele que o `va_start` sabe onde a fila começa

- Por que o `va_arg` recebe o tipo (`char *`): os extras não têm tipo declarado, então é você quem diz como interpretar o valor lido

- O que acontece com um quarto `va_arg`: o marcador está depois do fim da fila (`???`), e o `va_arg` lê lixo da memória sem dar erro. **A fila não tem um fim visível**, então a função precisa saber por conta própria quando parar

- Por isso existe o `count`: ele diz quantas vezes o `va_arg` pode ser chamado

---

**O exemplo completo**

Com um laço, o mesmo passo a passo funciona para qualquer quantidade de textos:

```c
#include <stdio.h>
#include <stdarg.h>

// O primeiro parâmetro 'count' diz quantos argumentos foram passados
void imprimir_verde(int count, ...) {
    va_list args;
    va_start(args, count); // Inicializa a lista de argumentos

    printf("\033[32m"); // Ativa a cor verde

    for (int i = 0; i < count; i++) {
        // va_arg extrai o próximo argumento (especificando o tipo, ex: char*)
        char *texto = va_arg(args, char*);
        printf("%s ", texto);
    }

    printf("\033[0m\n"); // Reseta a cor

    va_end(args); // Limpa a memória da lista
}

int main() {
    // Chamada informando que são 3 strings
    imprimir_verde(3, "Texto 1", "Texto 2", "Texto infinitos...");
    return 0;
}
```

```text
Texto 1 Texto 2 Texto infinitos...      (em verde no terminal)
```

- O `for` chama o `va_arg` exatamente `count` vezes, uma por texto
- O `va_end` não libera memória (nenhum `malloc` foi feito), ele só encerra o marcador. Mesmo assim o padrão exige que todo `va_start` tenha um `va_end` na mesma função
- `"\033[32m"` e `"\033[0m"` são códigos que o terminal entende como "texto verde" e "volta para a cor padrão". Não têm relação com a `stdarg.h`

---

**Sem count: parar em um NULL**

Em vez de dizer quantos textos vieram, a chamada coloca um `NULL` no fim da fila, e a função lê até encontrá-lo:

```c
void imprimir_verde(const char *texto, ...) {
  va_list args;
  va_start(args, texto);

  printf("\033[32m");
  while (texto != NULL) {
    printf("%s ", texto);
    texto = va_arg(args, const char *);  // o próximo texto, ou o NULL do fim
  }
  printf("\033[0m\n");

  va_end(args);
}

imprimir_verde("Texto 1", "Texto 2", "Texto infinitos...", NULL);
```

```text
texto     extras
┌─────┐   ┌─────┬──────────────────────┬──────┐
│ "T1"│   │ "T2"│ "Texto infinitos..." │ NULL │  ← a função para aqui
└─────┘   └─────┴──────────────────────┴──────┘
```

- O primeiro texto é o argumento fixo, e os outros vêm pela fila
- O `NULL` é o "fim da fila" que a fila não tem sozinha. Esquecê-lo faz a função ler lixo, como o quarto `va_arg` do passo a passo

---

**Sem count: uma string de formato**

É o jeito do `printf`: o argumento fixo é uma string, e cada `%` dentro dela diz que há mais um valor na fila e de que tipo ele é:

```c
#include <stdio.h>
#include <stdarg.h>

void imprimir_verde(const char *formato, ...) {
  va_list args;
  va_start(args, formato);
  printf("\033[32m");
  vprintf(formato, args);   // entrega o marcador para o vprintf ler a fila
  printf("\033[0m\n");
  va_end(args);
}

imprimir_verde("%s %s %s", "Texto 1", "Texto 2", "Texto infinitos...");
imprimir_verde("%d itens, total %.2f", 3, 9.5);   // 3 itens, total 9.50
```

- Aqui a função não chama o `va_arg`: ela entrega o marcador para o `vprintf`, que chama o `va_arg` por dentro, uma vez para cada `%`
- É a única das três formas que aceita valores de tipos diferentes na mesma fila
- Um exemplo prático, uma função de log que monta a mensagem com `vsnprintf`, está em `va-list-forwarding.md`

Docs deste diretório:

- `stdarg.md`: as quatro peças em detalhe, e o `va_copy` para ler a fila duas vezes
- `type-promotion.md`: por que `va_arg(args, float)` e `va_arg(args, char)` estão errados
- `count-macros.md`: macros que colocam o `NULL` ou calculam o `count` sozinhas
- `va-list-forwarding.md`: entregando o marcador para `vprintf`, `vsnprintf` e outras funções
- `c23-variadic.md`: funções só com `...`, sem argumento fixo

> O ponto mais importante é que a fila não sabe o próprio tamanho nem o tipo dos valores: o `va_arg` lê o que você mandar, quantas vezes você mandar. Por isso toda função variádica precisa de uma regra para saber quando parar (um `count`, um `NULL` ou uma string de formato), e chamar a função com argumentos que não batem com essa regra compila sem erro e lê lixo. Quando todos os valores são do mesmo tipo, um array com um tamanho (`void f(const char **textos, size_t n)`) é mais simples e mais seguro
