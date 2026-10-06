**LoadImageFromMemory**

> `raylib.h` — módulo `rtextures`

O `LoadImageFromMemory` carrega uma imagem a partir de um arquivo que já está na memória, em vez de lê-lo do disco. Os bytes precisam ser os de um arquivo completo (um PNG inteiro, por exemplo), e não pixels crus

```c
Image LoadImageFromMemory(const char *fileType, const unsigned char *fileData, int dataSize);
```

- `fileType`: a extensão que diz qual o formato dos dados, **com o ponto**: `".png"`, `".qoi"`
- `fileData`: os bytes do arquivo
- `dataSize`: quantos bytes há em `fileData`

- Devolve a `Image` decodificada
- Os bytes de entrada não são modificados nem liberados: continuam sendo responsabilidade de quem chamou

```c
// imagem embutida no executável (gerada com: xxd -i logo.png > logo.h)
#include "logo.h"   // unsigned char logo_png[]; unsigned int logo_png_len;

Image logo = LoadImageFromMemory(".png", logo_png, logo_png_len);
Texture2D t = LoadTextureFromImage(logo);
UnloadImage(logo);
```

---

**Usos comuns**

- Distribuir o jogo em um único executável, sem pasta de assets
- Imagens dentro de um arquivo compactado próprio do jogo (um `.pak`), lidas com `LoadFileData` e depois decodificadas
- Imagens recebidas pela rede

```c
int tamanho = 0;
unsigned char *dados = LoadFileData("assets.pak", &tamanho);
// ... encontrar o PNG dentro do pacote: inicio e tamanho_png ...
Image img = LoadImageFromMemory(".png", dados + inicio, tamanho_png);
UnloadFileData(dados);   // a imagem já foi decodificada, os bytes podem ser liberados
```

> O tipo é informado pelo `fileType`, e não detectado pelo conteúdo. Passar `"png"` sem o ponto, ou o tipo errado, faz o carregamento falhar
