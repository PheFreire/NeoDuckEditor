**strlen**

> `string.h`

O `strlen` percorre a string a partir do início, contando um caractere de cada vez, até chegar no `\0` que marca o fim. O valor retornado é essa contagem, sem incluir o próprio terminador "`\0`"

```c
size_t strlen(const char *str);
```

```c
size_t tamanho = strlen(buffer); // 9
```

