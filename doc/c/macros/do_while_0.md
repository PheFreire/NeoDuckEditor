**do { } while (0)**

> diretiva do pré-processador, não precisa de nenhum header

O `do { ... } while (0)` é um truque usado para escrever macros com várias instruções que se comportam como uma única instrução, podendo ser usadas com `;` no final e dentro de um `if` sem chaves sem quebrar o código

> Um `do { } while (0)` executa o seu corpo exatamente uma vez, já que a condição `0` é sempre falsa. Ele não serve como laço aqui, apenas agrupa as instruções em um bloco que exige um `;` depois, igual a uma chamada de função

```c
#define NOME(params) \
  do {               \
    instrução1;      \
    instrução2;      \
  } while (0)
```

- O `while (0)` não leva `;` dentro da macro: o `;` é colocado por quem usa, como em qualquer chamada de função
- As variáveis declaradas dentro do bloco ficam visíveis só ali dentro, sem conflitar com variáveis de mesmo nome de fora
- O compilador remove o "laço" completamente, então não há nenhum custo de performance

---

**O problema sem o do while**

Uma macro com duas instruções soltas funciona sozinha, mas quebra dentro de um `if` sem chaves:

```c
#define LOG_ERRO(msg) fprintf(stderr, "erro: "); fprintf(stderr, "%s\n", msg)

if (falhou)
  LOG_ERRO("arquivo não encontrado");

// vira:
if (falhou)
  fprintf(stderr, "erro: ");
fprintf(stderr, "%s\n", "arquivo não encontrado"); // fora do if, roda sempre
```

---

**Por que só chaves não resolvem**

Envolvendo em `{ }`, as duas instruções ficam no `if`, mas o `;` que quem usa coloca depois vira uma instrução vazia que fecha o `if`, e um `else` em seguida deixa de compilar:

```c
#define LOG_ERRO(msg) { fprintf(stderr, "erro: "); fprintf(stderr, "%s\n", msg); }

if (falhou)
  LOG_ERRO("arquivo não encontrado");
else
  printf("ok\n");

// vira:
if (falhou)
  { fprintf(stderr, "erro: "); fprintf(stderr, "%s\n", "arquivo não encontrado"); };
else // erro de compilação: o ';' depois da '}' terminou o if, este else está sozinho
  printf("ok\n");
```

---

**A solução**

Com o `do { } while (0)`, o `;` de quem usa completa o `while (0)`, e o conjunto todo vira uma única instrução:

```c
#define LOG_ERRO(msg)                  \
  do {                                 \
    fprintf(stderr, "erro: ");         \
    fprintf(stderr, "%s\n", msg);      \
  } while (0)

if (falhou)
  LOG_ERRO("arquivo não encontrado");
else
  printf("ok\n");

// vira:
if (falhou)
  do { fprintf(stderr, "erro: "); fprintf(stderr, "%s\n", "arquivo não encontrado"); } while (0);
else
  printf("ok\n");
```

Um exemplo prático, liberando um ponteiro e já o deixando `NULL` para evitar um ponteiro dangling:

```c
#define FREE_NULL(ptr) \
  do {                 \
    free(ptr);         \
    (ptr) = NULL;      \
  } while (0)

char *nome = malloc(10);
FREE_NULL(nome); // nome == NULL
```

> Diferente de uma macro de expressão como `MAX(a, b)`, que devolve um valor e é escrita entre parênteses, uma macro de instruções não devolve nada e deve sempre ser envolvida em `do { } while (0)`. Quando ela precisa devolver um valor e executar várias instruções ao mesmo tempo, o melhor é transformá-la em uma função `static inline`
