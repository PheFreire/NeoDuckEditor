**UnloadDroppedFiles**

> `raylib.h` — módulo `rcore`

O `UnloadDroppedFiles` libera a lista de caminhos devolvida pelo `LoadDroppedFiles` e marca os arquivos soltos como já tratados

```c
void UnloadDroppedFiles(FilePathList files);
```

- `files`: a lista devolvida pelo `LoadDroppedFiles`

- Não devolve nada
- Depois da chamada, o `IsFileDropped` volta a `false` até o usuário soltar novos arquivos
- Os caminhos em `files.paths` deixam de ser válidos

```c
FilePathList lista = LoadDroppedFiles();
char ultimo[512] = "";
if (lista.count > 0) {
  snprintf(ultimo, sizeof(ultimo), "%s", lista.paths[0]);   // copia antes de liberar
}
UnloadDroppedFiles(lista);

DrawText(TextFormat("Último arquivo: %s", GetFileName(ultimo)), 10, 10, 20, GRAY);
```

> Guardar `lista.paths[0]` em uma variável e usá-lo depois do `UnloadDroppedFiles` é um uso de memória liberada (use-after-free). Copie o texto, como no exemplo, se ele for necessário depois
