**freeaddrinfo**

> `netdb.h`

O `freeaddrinfo` libera a memória alocada internamente por uma chamada anterior a `getaddrinfo`, incluindo toda a lista encadeada de resultados

```c
#include <netdb.h>

void freeaddrinfo(struct addrinfo *res);
```

- `res`: o ponteiro para o início da lista retornada por `getaddrinfo`

- Não tem valor de retorno
- Assim como todo `malloc` precisa de um `free` correspondente, toda chamada a `getaddrinfo` que retornar sucesso precisa ser pareada com um `freeaddrinfo`; deixar de chamá-lo vaza memória a cada resolução de endereço feita pelo programa
- Deve ser chamado depois que o endereço já foi usado (por exemplo, depois do `bind` ou `connect`), já que a lista deixa de ser válida assim que é liberada

```c
freeaddrinfo(res);
```

