**ftell**

> `stdio.h`

O `ftell` devolve a posição atual do cursor do stream, ou seja, o número exato do byte em que a próxima leitura ou escrita vai começar

```c
long ftell(FILE *stream);
```

- Muito usado em conjunto com `fseek` para descobrir o tamanho total de um arquivo: move-se o cursor para o final com `fseek(file, 0, SEEK_END)` e depois lê-se a posição dele com `ftell`

```c
fseek(file, 0, SEEK_END);
long tamanho = ftell(file); // tamanho total do arquivo em bytes
```

