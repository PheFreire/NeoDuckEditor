**Arquivos arrastados**

> `raylib.h` — módulo `rcore`

O raylib detecta quando o usuário arrasta arquivos do sistema operacional e os solta sobre a janela. O programa recebe a lista de caminhos e pode carregar os arquivos, como em editores de mapas, visualizadores de imagens e ferramentas de conversão

```c
bool IsFileDropped(void);
FilePathList LoadDroppedFiles(void);
void UnloadDroppedFiles(FilePathList files);

typedef struct FilePathList {
  unsigned int capacity;   // tamanho do array alocado
  unsigned int count;      // quantos caminhos foram soltos
  char **paths;            // os caminhos
} FilePathList;
```

```c
Texture2D imagem = { 0 };

while (!WindowShouldClose()) {
  if (IsFileDropped()) {
    FilePathList soltos = LoadDroppedFiles();

    for (unsigned int i = 0; i < soltos.count; i++) {
      if (IsFileExtension(soltos.paths[i], ".png;.jpg;.bmp")) {
        if (imagem.id != 0) UnloadTexture(imagem);
        imagem = LoadTexture(soltos.paths[i]);   // carrega antes de liberar a lista
        break;
      }
    }

    UnloadDroppedFiles(soltos);   // os caminhos deixam de ser válidos aqui
  }

  BeginDrawing();
  ClearBackground(RAYWHITE);
  if (imagem.id != 0) DrawTexture(imagem, 0, 0, WHITE);
  else DrawText("Arraste uma imagem para a janela", 200, 200, 20, GRAY);
  EndDrawing();
}
```

---

**Comportamento**

- `IsFileDropped` fica `true` a partir do frame em que os arquivos foram soltos, até a lista ser carregada e liberada
- Os caminhos são **absolutos** e podem conter espaços e acentos (em UTF-8)
- Pastas também podem ser soltas: confira com `DirectoryExists` ou `IsPathFile`

> Os caminhos são copiados para a lista pelo raylib. Depois do `UnloadDroppedFiles`, eles não existem mais: carregue os arquivos ou copie os caminhos que precisar guardar antes de liberar a lista
