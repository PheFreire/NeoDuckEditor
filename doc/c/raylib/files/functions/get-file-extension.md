**GetFileExtension**

> `raylib.h` — módulo `rcore`

O `GetFileExtension` devolve a extensão de um nome de arquivo, incluindo o ponto

```c
const char *GetFileExtension(const char *fileName);
```

- `fileName`: o nome ou caminho do arquivo

- Devolve um ponteiro para o último `.` do nome: `"heroi.png"` dá `".png"`, `"arq.tar.gz"` dá `".gz"`
- Sem extensão, devolve `NULL`
- O ponteiro aponta para **dentro** da string passada: não é uma cópia e não precisa ser liberado

```c
const char *ext = GetFileExtension(caminho);
if (ext != NULL && TextIsEqual(ext, ".txt")) {
  abrir_como_texto(caminho);
}
```

> Sempre verifique o `NULL` antes de usar o resultado: passar `NULL` para `strcmp` ou `printf("%s")` é comportamento indefinido. Para só testar a extensão, o `IsFileExtension` já trata esse caso e ignora maiúsculas (ver `is-file-extension.md`)
