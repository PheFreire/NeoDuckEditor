**LoadDroppedFiles**

> `raylib.h` — módulo `rcore`

O `LoadDroppedFiles` devolve a lista de caminhos dos arquivos soltos sobre a janela

```c
FilePathList LoadDroppedFiles(void);
```

- Devolve um `FilePathList` com:
    - `count`: quantos arquivos foram soltos
    - `paths`: os caminhos absolutos, em UTF-8
- A lista é uma cópia que pertence ao programa até o `UnloadDroppedFiles`

```c
if (IsFileDropped()) {
  FilePathList lista = LoadDroppedFiles();

  for (unsigned int i = 0; i < lista.count; i++) {
    if (IsFileExtension(lista.paths[i], ".png")) {
      sprites[n_sprites++] = LoadTexture(lista.paths[i]);   // vários arquivos de uma vez
    }
  }

  UnloadDroppedFiles(lista);
}
```

> Cada chamada ao `LoadDroppedFiles` precisa do seu `UnloadDroppedFiles`. Sem ele, o `IsFileDropped` continua `true` e os caminhos ficam ocupando memória (ver `unload-dropped-files.md`)
