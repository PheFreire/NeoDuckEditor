**Macros para não passar o count**

> macros variádicas sobre uma função variádica

Uma função variádica precisa de uma regra para saber quando parar de ler os argumentos: um `count` ou um `NULL` no fim (ver `variadic-functions.md`). Os dois dependem de quem chama acertar, e errar compila sem nenhum aviso. Uma macro variádica pode fazer esse trabalho na hora da chamada, colocando o `NULL` ou calculando o `count` sozinha (ver `macros/variadic.md` em `doc/c`)

---

**Uma macro que coloca o NULL**

```c
void imprimir_verde_lista(const char *texto, ...);   // lê até encontrar NULL

#define IMPRIMIR_VERDE(...) imprimir_verde_lista(__VA_ARGS__, NULL)

IMPRIMIR_VERDE("Texto 1", "Texto 2", "Texto infinitos...");
// vira: imprimir_verde_lista("Texto 1", "Texto 2", "Texto infinitos...", NULL);
```

- `__VA_ARGS__` é substituído pelos argumentos da macro, e o `NULL` entra sempre no fim
- Sem a macro, a declaração pode ser marcada com `__attribute__((sentinel))` (GCC e Clang), e o compilador avisa `missing sentinel in function call` quando o `NULL` falta

---

**Uma macro que conta sozinha**

```c
void imprimir_verde_n(size_t count, ...);   // lê count textos

#define CONTAR_STRINGS(...) (sizeof((const char *[]){__VA_ARGS__}) / sizeof(const char *))
#define IMPRIMIR_VERDE_N(...) imprimir_verde_n(CONTAR_STRINGS(__VA_ARGS__), __VA_ARGS__)

IMPRIMIR_VERDE_N("Texto 1", "Texto 2", "Texto infinitos...");
// vira: imprimir_verde_n(3, "Texto 1", "Texto 2", "Texto infinitos...");
```

- `(const char *[]){...}` é um `compound literal` (C99): um array criado na hora, com um elemento para cada argumento
- O tamanho do array dividido pelo tamanho de um elemento dá a quantidade de argumentos. O `sizeof` é calculado na compilação, então o `3` sai pronto, sem custo em tempo de execução
- Só funciona se todos os argumentos forem do mesmo tipo, e de quebra o compilador passa a avisar quando um deles não é uma string

> As duas macros resolvem o maior problema das funções variádicas, que é a quantidade de argumentos não ser verificada. Quando todos os argumentos têm o mesmo tipo, elas deixam a chamada tão simples quanto `IMPRIMIR_VERDE("a", "b")` e tiram a chance de esquecer o `NULL` ou de errar o `count`
