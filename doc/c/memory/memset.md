**memset**

> `string.h`

O `memset` preenche um bloco de memória com um valor de byte específico, copiando um valor convertido para `unsigned char` para uma quantidade de bytes. Muito usado para limpar buffers ou zerar arrays

```c
void *memset(void *ptr, int value, size_t num);
```

> Diferente do `memmove`, o `memset` não precisa de um segundo ponteiro, pois o mesmo valor é repetido em todos os bytes

```c
char buffer[10];
memset(buffer, 0, sizeof(buffer)); // zera os 10 bytes do buffer
```

