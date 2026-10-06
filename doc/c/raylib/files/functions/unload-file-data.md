**UnloadFileData**

> `raylib.h` — módulo `rcore`

O `UnloadFileData` libera os bytes alocados pelo `LoadFileData`

```c
void UnloadFileData(unsigned char *data);
```

- `data`: o ponteiro devolvido pelo `LoadFileData`

- Não devolve nada
- Passar `NULL` é seguro e não faz nada

```c
int n = 0;
unsigned char *dados = LoadFileData("save.dat", &n);
processar(dados, n);
UnloadFileData(dados);   // mesmo que dados seja NULL
```

> Use o `UnloadFileData`, e não o `free` diretamente: o raylib pode ter sido compilado com um alocador próprio (`RL_MALLOC`/`RL_FREE`), e liberar com outro alocador causaria erro
