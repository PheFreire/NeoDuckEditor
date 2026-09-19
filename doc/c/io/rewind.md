**rewind**

> `stdio.h`

> `stdio.h`

O `rewind` volta o cursor do stream instantaneamente para o início do arquivo

```c
void rewind(FILE *stream);
```

- Equivale a chamar `fseek(file, 0, SEEK_SET)`, mas sem devolver nenhum valor e sem a necessidade de checar erro

```c
rewind(file); // cursor volta para o início do arquivo
```

