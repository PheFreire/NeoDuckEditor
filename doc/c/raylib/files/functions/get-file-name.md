**GetFileName**

> `raylib.h` — módulo `rcore`

O `GetFileName` devolve só o nome do arquivo de um caminho, sem as pastas

```c
const char *GetFileName(const char *filePath);
```

- `filePath`: o caminho completo

- Devolve um ponteiro para o trecho depois da última `/` (ou `\`): `"assets/img/heroi.png"` dá `"heroi.png"`
- Se não houver pasta no caminho, devolve o próprio caminho
- O ponteiro aponta para **dentro** da string passada: continua válido enquanto ela existir

```c
FilePathList soltos = LoadDroppedFiles();
for (unsigned int i = 0; i < soltos.count; i++) {
  DrawText(GetFileName(soltos.paths[i]), 20, 20 + i * 25, 20, DARKGRAY);   // mostra só o nome
}
UnloadDroppedFiles(soltos);
```

> Para o nome sem a extensão (`"heroi"`), use o `GetFileNameWithoutExt`, que devolve uma cópia em um buffer estático, sobrescrito na próxima chamada (ver `../paths.md`)
