**rewind**

> `stdio.h`

O `rewind` volta o cursor do stream instantaneamente para o início do arquivo

> Um `stream` é uma abstração para uma fonte ou destino de dados que pode ser lido ou escrito sequencialmente, representada em C pelo tipo `FILE *`. Pode ser um arquivo aberto com `fopen`, ou um dos streams padrão que já vêm prontos, como `stdin`, `stdout` e `stderr`

```c
void rewind(FILE *stream);
```

- Equivale a chamar `fseek(file, 0, SEEK_SET)`, mas sem devolver nenhum valor e sem a necessidade de checar erro

```c
rewind(file); // cursor volta para o início do arquivo
```

