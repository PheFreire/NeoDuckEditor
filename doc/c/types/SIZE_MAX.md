**SIZE_MAX**

> `stdint.h`

O `SIZE_MAX` é uma constante com o maior valor que um `size_t` consegue guardar, ou seja, o maior tamanho em bytes que um objeto ou uma alocação pode ter na plataforma

> O `size_t` é o tipo inteiro sem sinal usado em C para representar tamanhos e quantidades de bytes. É o que o `sizeof` devolve, o que o `malloc` recebe e o que o `strlen` devolve, e no `printf` é impresso com `%zu`

```c
#define SIZE_MAX /* maior valor de size_t */
```

- Em sistemas de 64 bits vale `18446744073709551615` (2⁶⁴ - 1), e em sistemas de 32 bits vale `4294967295` (2³² - 1)
- Como o `size_t` não tem sinal, `(size_t)-1` é exatamente igual a `SIZE_MAX`, e `SIZE_MAX + 1` dá a volta e vira `0`, sem nenhum aviso

O uso mais importante é evitar overflow ao calcular o tamanho de uma alocação. Uma multiplicação como `quantidade * sizeof(int)` que passa do `SIZE_MAX` dá a volta e vira um número pequeno, fazendo o `malloc` alocar muito menos memória do que o código pensa ter:

```c
size_t quantidade = /* valor vindo do usuário ou de um arquivo */;

// quantidade * sizeof(int) > SIZE_MAX, reescrito sem fazer a multiplicação
if (quantidade > SIZE_MAX / sizeof(int)) {
  // a conta estouraria, não tente alocar
  return NULL;
}

int *arr = malloc(quantidade * sizeof(int)); // seguro
```

> A verificação é feita com divisão (`SIZE_MAX / sizeof(int)`) porque testar `quantidade * sizeof(int) > SIZE_MAX` nunca funciona: o resultado da multiplicação já teria dado a volta antes da comparação. O `calloc` faz essa mesma verificação internamente, por isso devolve `NULL` em vez de alocar um tamanho errado

Também é usado como valor especial de "não encontrado" em funções que devolvem um índice do tipo `size_t`, já que nenhum índice válido chega a esse valor e não é possível devolver `-1` em um tipo sem sinal:

```c
size_t buscar(const int *arr, size_t total, int valor) {
  for (size_t i = 0; i < total; i++) {
    if (arr[i] == valor) {
      return i;
    }
  }
  return SIZE_MAX; // não encontrado
}

if (buscar(nums, 5, 42) == SIZE_MAX) {
  // 42 não está no array
}
```

> Por dar a volta em `SIZE_MAX` em vez de ficar negativo, um `size_t` nunca é menor que `0`, então um laço decrescente como `for (size_t i = n - 1; i >= 0; i--)` nunca termina: depois do `0`, `i` vira `SIZE_MAX`. A forma correta é `for (size_t i = n; i-- > 0;)`
