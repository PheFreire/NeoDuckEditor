**IsFileDropped**

> `raylib.h` — módulo `rcore`

O `IsFileDropped` verifica se o usuário soltou um ou mais arquivos sobre a janela

```c
bool IsFileDropped(void);
```

- Devolve `true` se há arquivos soltos esperando para serem lidos, e `false` caso contrário
- Continua `true` até o programa ler a lista com `LoadDroppedFiles` e liberá-la com `UnloadDroppedFiles`

```c
if (IsFileDropped()) {
  FilePathList arquivos = LoadDroppedFiles();
  for (unsigned int i = 0; i < arquivos.count; i++) {
    abrir(arquivos.paths[i]);
  }
  UnloadDroppedFiles(arquivos);
}
```

> Os arquivos chegam no `EndDrawing`, com os outros eventos da janela. O código que trata os arquivos soltos fica normalmente na fase de atualização do game loop (ver `../dropped-files.md`)
