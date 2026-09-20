**ftell**

> `stdio.h`

O `ftell` devolve a posição atual do cursor do stream, ou seja, o número exato do byte em que a próxima leitura ou escrita vai começar

> Um `stream` é uma abstração para uma fonte ou destino de dados que pode ser lido ou escrito sequencialmente, representada em C pelo tipo `FILE *`. Pode ser um arquivo aberto com `fopen`, ou um dos streams padrão que já vêm prontos, como `stdin`, `stdout` e `stderr`

```c
long ftell(FILE *stream);
```

- Muito usado em conjunto com `fseek` para descobrir o tamanho total de um arquivo: move-se o cursor para o final com `fseek(file, 0, SEEK_END)` e depois lê-se a posição dele com `ftell`

```c
fseek(file, 0, SEEK_END);
long tamanho = ftell(file); // tamanho total do arquivo em bytes
```

