**IsFileExtension**

> `raylib.h` — módulo `rcore`

O `IsFileExtension` verifica se um nome de arquivo termina com uma extensão, ou com uma de várias extensões separadas por `;`

```c
bool IsFileExtension(const char *fileName, const char *ext);
```

- `fileName`: o nome ou caminho do arquivo
- `ext`: a extensão **com o ponto** (`".png"`), ou várias separadas por `;` (`".png;.jpg;.bmp"`)

- Devolve `true` se a extensão do arquivo for uma das listadas
- A comparação ignora maiúsculas e minúsculas: `"FOTO.PNG"` corresponde a `".png"`

```c
FilePathList soltos = LoadDroppedFiles();
for (unsigned int i = 0; i < soltos.count; i++) {
  const char *p = soltos.paths[i];
  if (IsFileExtension(p, ".png;.jpg;.bmp")) carregar_imagem(p);
  else if (IsFileExtension(p, ".wav;.ogg;.mp3")) carregar_som(p);
  else TraceLog(LOG_WARNING, "formato não suportado: %s", GetFileName(p));
}
UnloadDroppedFiles(soltos);
```

> A verificação é só pelo nome: um arquivo renomeado de `.txt` para `.png` passa no teste e falha ao carregar. Para conferir o conteúdo, tente carregar e verifique o resultado (`IsImageValid`, `IsTextureValid`)
