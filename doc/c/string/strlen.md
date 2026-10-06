**strlen**

> `string.h`

O `strlen` percorre a string a partir do início, contando um caractere de cada vez, até chegar no `\0` que marca o fim, devolvendo essa contagem sem incluir o próprio terminador

> Uma `string` em C não é um tipo próprio, é apenas um array de `char` terminado pelo caractere `\0`, que marca onde o texto acaba. As funções da `string.h` recebem um ponteiro para o primeiro caractere e percorrem a memória até encontrar esse `\0`

```c
size_t strlen(const char *str);
```

- `str`: a string cujo tamanho será contado

- Devolve a quantidade de caracteres antes do `\0`, ou seja, uma string vazia (`""`) tem tamanho `0`
- Não é o mesmo que `sizeof`: `sizeof` devolve o tamanho total do array reservado em memória (incluindo o `\0` e qualquer espaço sobrando), enquanto `strlen` conta apenas os caracteres que realmente fazem parte do texto
- Precisa percorrer a string inteira a cada chamada, então chamá-lo repetidamente dentro de um laço sobre a mesma string pode deixar o código lento sem necessidade

```c
char buffer[20] = "patopatop";
size_t tamanho = strlen(buffer); // 9
size_t total = sizeof(buffer);   // 20
```

> Se a string não tiver um `\0` no final, o `strlen` continua lendo a memória além do fim do array até encontrar algum `\0` por acaso, resultando em um valor errado ou em um acesso inválido de memória
