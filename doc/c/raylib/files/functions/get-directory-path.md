**GetDirectoryPath**

> `raylib.h` — módulo `rcore`

O `GetDirectoryPath` devolve a parte de pastas de um caminho de arquivo, sem o nome do arquivo

```c
const char *GetDirectoryPath(const char *filePath);
```

- `filePath`: o caminho do arquivo

- Devolve o caminho da pasta, sem a barra final
- O resultado fica em um **buffer estático** do raylib, sobrescrito na próxima chamada
- Caminhos relativos recebem `"./"` na frente

```text
"/home/user/jogo/assets/heroi.png"  →  "/home/user/jogo/assets"
"assets/img/heroi.png"              →  "./assets/img"
"heroi.png"                         →  "./"
```

```c
// carregar a textura que está na mesma pasta do modelo
const char *pasta = GetDirectoryPath(caminho_modelo);
char caminho_textura[512];
snprintf(caminho_textura, sizeof(caminho_textura), "%s/textura.png", pasta);   // usa antes da próxima chamada
Texture2D t = LoadTexture(caminho_textura);
```

---

**O buffer é compartilhado**

```c
printf("%s %s\n", GetDirectoryPath("a/x.png"), GetDirectoryPath("b/y.png"));
// imprime "./b ./b": os dois argumentos apontam para o mesmo buffer
```

> Use o resultado imediatamente ou copie para um array próprio. Duas chamadas na mesma expressão (como os dois argumentos de um `printf`) já sobrescrevem uma à outra (ver `../paths.md`)
