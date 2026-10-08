**Da imagem até a tela**

> o caminho completo de um arquivo .png até os pixels aparecerem na janela

Uma imagem passa por quatro lugares até aparecer na tela: o **disco** (o arquivo), a **RAM** (uma `Image`, que a CPU pode editar), a **VRAM** (uma `Texture2D`, que a GPU pode desenhar) e o **framebuffer** (a imagem do frame que a janela mostra). Cada passagem é feita por uma função diferente, em um momento diferente do programa. Esta nota liga as etapas em ordem, e cada uma aponta para a nota que a explica em detalhes

```text
  DISCO           RAM (CPU)         VRAM (GPU)           FRAMEBUFFER         TELA
┌───────────┐ 1 ┌─────────┐   3   ┌───────────┐  5 e 6  ┌─────────────┐ 7 ┌────────┐
│ heroi.png │──►│  Image  │──────►│ Texture2D │────────►│ back buffer │──►│ janela │
└───────────┘   └─────────┘       └───────────┘         └─────────────┘   └────────┘
                  2 editar          4 filtro e wrap

1  LoadImage                        decodifica o arquivo em pixels na RAM
2  Image...                         edita os pixels com a CPU (opcional)
3  LoadTextureFromImage             copia os pixels para a VRAM, depois UnloadImage
4  SetTextureFilter / Wrap          define como a GPU vai ler a textura
5  DrawTexture...                   coloca o pedido de desenho no batch
6  flush do batch                   a GPU pinta os pixels no back buffer
7  EndDrawing                       troca os buffers e o frame aparece
8  UnloadTexture                    libera a VRAM no fim do programa

etapas 1 a 4: uma vez, antes do game loop
etapas 5 a 7: todo frame, dentro do game loop
etapa 8:      uma vez, depois do game loop
```

---

**O programa inteiro, etapa por etapa**

```c
#include "raylib.h"

int main(void) {
  InitWindow(800, 450, "da imagem até a tela");   // cria o contexto OpenGL: a GPU passa a existir para o raylib
  SetTargetFPS(60);

  Image img = LoadImage("heroi.png");               // 1. disco → RAM
  ImageResizeNN(&img, img.width * 4, img.height * 4); // 2. editar na CPU (opcional)
  Texture2D heroi = LoadTextureFromImage(img);      // 3. RAM → VRAM
  UnloadImage(img);                                 //    a cópia na RAM não é mais necessária
  SetTextureFilter(heroi, TEXTURE_FILTER_POINT);    // 4. como a GPU vai ler os pixels

  Vector2 pos = { 100, 100 };

  while (!WindowShouldClose()) {
    pos.x += 100 * GetFrameTime();                  // lógica: só muda números na CPU

    BeginDrawing();
    ClearBackground(RAYWHITE);                      // apaga o back buffer
    DrawTextureV(heroi, pos, WHITE);                // 5. pede o desenho (vai para o batch)
    EndDrawing();                                   // 6. GPU desenha  7. o frame aparece
  }

  UnloadTexture(heroi);                             // 8. libera a VRAM
  CloseWindow();                                    //    destrói o contexto OpenGL
  return 0;
}
```

- As etapas 1 a 4 acontecem **uma vez**, antes do game loop. As etapas 5 a 7 se repetem **todo frame**
- Dentro do loop, a textura nunca é recriada. O que muda de um frame para o outro são só os parâmetros do desenho (`pos`)
- A ordem `InitWindow` → `LoadTexture...` → loop → `UnloadTexture` → `CloseWindow` é obrigatória, porque a textura só existe enquanto o contexto OpenGL existe

---

**1. Arquivo → Image**

```c
Image img = LoadImage("heroi.png");
```

- O `LoadImage` lê o arquivo e **decodifica** o PNG: descompacta os bytes do arquivo e transforma em um array de pixels em `img.data`
- Um PNG de 32x32 com transparência vira `32 * 32 * 4 = 4096` bytes na RAM (4 bytes por pixel: R, G, B, A). O arquivo no disco é menor porque é comprimido
- Não precisa da janela: funciona antes do `InitWindow`
- Se falhar, `img.data` é `NULL` e o tamanho é `0`. Confira com `IsImageValid`

> Detalhes em `../image/image-loading.md` e `../image/image-memory.md`

---

**2. Editar a Image (opcional)**

```c
ImageResizeNN(&img, 128, 128);
ImageFlipHorizontal(&img);
Image celula = ImageFromImage(folha, (Rectangle){ 0, 0, 32, 32 });   // recortar uma célula em uma imagem nova
```

- As funções `Image...` mexem nos pixels de `img.data` com a CPU, e por isso recebem um ponteiro
- É a única etapa em que o programa pode ler e alterar pixels livremente
- Se não há nada para editar, as etapas 1 a 3 podem ser feitas de uma vez com `LoadTexture` (ver etapa 3)

> Detalhes em `../image/image-manipulation.md` e `../image/image-drawing.md`

---

**3. Image → Texture2D**

```c
Texture2D heroi = LoadTextureFromImage(img);
UnloadImage(img);
```

```text
RAM                                     VRAM
img.data ──► [pixels] ── cópia ──────► [pixels]
                                           ▲
heroi = { id = 3, width, height, ... } ────┘  o id é só o "nome" da textura na GPU
```

- O `LoadTextureFromImage` pede ao OpenGL uma textura nova e copia os pixels da RAM para a VRAM
- A `Texture2D` devolvida **não contém pixels**: só o `id` que a GPU usa para encontrá-los, o tamanho e o formato
- A `Image` continua na RAM e não está mais ligada à textura. Editá-la depois não muda a textura. Por isso ela é liberada logo em seguida com `UnloadImage`
- Precisa da janela: antes do `InitWindow` não existe GPU para receber os pixels, e a textura volta com `id == 0`

```c
Texture2D heroi = LoadTexture("heroi.png");   // atalho: LoadImage + LoadTextureFromImage + UnloadImage
```

> Detalhes em `../texture/functions/load-texture-from-image.md`, `../texture/texture-loading.md` e `../texture/image-vs-texture.md`

---

**4. Configurar como a textura é lida**

```c
SetTextureFilter(heroi, TEXTURE_FILTER_POINT);       // pixelado (padrão) ou BILINEAR (suave)
SetTextureWrap(heroi, TEXTURE_WRAP_CLAMP);           // o que acontece fora das bordas
```

- Não muda os pixels da textura: muda **como a GPU vai ler** esses pixels na etapa 6, quando a textura for desenhada maior, menor ou fora das bordas
- É feito uma vez, logo depois de criar a textura. Vale para todos os desenhos dela

> Detalhes em `../texture/texture-filtering.md` e `../texture/texture-wrapping.md`

---

**5. Pedir o desenho**

```c
BeginDrawing();
ClearBackground(RAYWHITE);
DrawTexturePro(heroi, source, dest, origin, rotacao, WHITE);
EndDrawing();
```

```text
DrawTexturePro(heroi, source, dest, origin, rotacao, tint)
                  │      │      │       │       │       │
                  │      │      └───────┴───────┘       └─ cor de cada vértice
                  │      │      4 cantos na tela (posição, tamanho, giro)
                  │      └─ 4 coordenadas de textura (qual pedaço da textura)
                  └─ qual textura a GPU vai usar (o id)
```

- Uma função `DrawTexture...` **não desenha nada na hora**. Ela transforma o pedido em um retângulo de 4 vértices e o coloca no **batch**, um buffer na RAM que junta os desenhos do frame
- Cada vértice leva três informações: **onde** fica na tela (vem de `pos` ou `dest`), **qual ponto da textura** corresponde a ele (vem de `source`) e **a cor** (o `tint`)
- Todas as variações (`DrawTexture`, `DrawTextureV`, `DrawTextureEx`, `DrawTextureRec`) são casos particulares do `DrawTexturePro`, preenchendo `source`, `dest` e `origin` com valores padrão
- Se houver uma câmera ativa (`BeginMode2D`), as posições são transformadas por ela antes de chegar à tela (ver `world-space.md`)
- Só funciona entre `BeginDrawing` e `EndDrawing`

> Detalhes em `../texture/texture-drawing.md` e `../texture/functions/draw-texture-pro.md`

---

**6. A GPU desenha**

```text
batch (RAM) ── flush ──► GPU
                           │ vertex shader     posiciona os 4 vértices na tela
                           │ rasterização      descobre quais pixels da tela o retângulo cobre
                           │ fragment shader   para cada pixel: lê a textura (com o filtro da etapa 4)
                           │                   e multiplica pela cor do tint
                           ▼
                        back buffer        o pixel é misturado com o que já estava ali (transparência)
```

- O **flush** envia o batch para a GPU de uma vez. Acontece no `EndDrawing`, ou antes, quando o desenho troca de textura, de shader ou de modo, ou quando o buffer enche
- Para cada pixel coberto, a GPU lê a textura no ponto correspondente: é aqui que o filtro decide entre o pixel mais próximo (`POINT`) ou uma média dos vizinhos (`BILINEAR`)
- O resultado vai para o **back buffer**, uma imagem invisível do tamanho da janela. O que é desenhado depois fica por cima
- Trocar de textura entre desenhos força um flush a cada troca. Por isso uma sprite sheet com `DrawTextureRec` é mais rápida que uma textura por sprite

> Detalhes em `rendering-pipeline.md` e `../shaders/shader-pipeline.md`

---

**7. O frame aparece**

```text
EndDrawing()
  │  flush final do batch
  │  troca os buffers: o back buffer vira o que a janela mostra
  │  espera o tempo do SetTargetFPS
  ▼
próximo frame: ClearBackground apaga o back buffer e tudo é desenhado de novo
```

- Nada aparece na janela antes do `EndDrawing`. O frame inteiro é montado escondido e mostrado de uma vez (double buffering)
- A tela não guarda o desenho entre frames: todo frame desenha tudo de novo, a partir da mesma textura que já está na VRAM

> Detalhes em `../drawing/drawing-cycle.md` e `frame.md`

---

**8. Liberar**

```c
UnloadTexture(heroi);   // depois do loop, antes do CloseWindow
CloseWindow();
```

- `UnloadImage` libera a RAM (feito logo na etapa 3). `UnloadTexture` libera a VRAM
- O `UnloadTexture` precisa vir antes do `CloseWindow`, porque depois dele o contexto OpenGL não existe mais

> Detalhes em `resource-lifetime.md`

---

**Resumo**

| Etapa | Função | Memória | Quando |
|---|---|---|---|
| 1. carregar | `LoadImage` | disco → RAM | uma vez, antes do loop |
| 2. editar | `Image...` | RAM | uma vez, antes do loop |
| 3. enviar | `LoadTextureFromImage` + `UnloadImage` | RAM → VRAM | uma vez, depois do `InitWindow` |
| 4. configurar | `SetTextureFilter`, `SetTextureWrap` | VRAM | uma vez, depois de criar a textura |
| 5. pedir o desenho | `DrawTexture...` | batch na RAM | todo frame, entre `BeginDrawing` e `EndDrawing` |
| 6. desenhar | flush do batch | VRAM → back buffer | todo frame, no `EndDrawing` ou antes |
| 7. mostrar | `EndDrawing` | back buffer → tela | todo frame |
| 8. liberar | `UnloadTexture` | VRAM | uma vez, depois do loop |

---

**Qual etapa falhou**

| Sintoma | Etapa | Causa comum |
|---|---|---|
| log `Failed to open file` | 1 | caminho relativo ao diretório de trabalho (ver `../files/paths.md`) |
| textura com `id == 0` | 3 | `LoadTexture` antes do `InitWindow`, ou a etapa 1 falhou |
| a edição da `Image` não aparece | 3 | a `Image` foi editada **depois** do `LoadTextureFromImage` |
| pixel art borrada | 4 | filtro `BILINEAR` |
| linhas finas na borda dos sprites | 4 e 6 | filtro lendo o sprite vizinho na sprite sheet (ver `../texture/texture-wrapping.md`) |
| nada aparece | 5 | `DrawTexture` fora do `BeginDrawing` / `EndDrawing`, ou posição fora da tela |
| sprite com a cor errada | 5 | `tint` diferente de `WHITE` |
| sprite some atrás de outro | 6 | ordem de desenho: o último fica por cima |
| rastros na tela | 7 | faltou o `ClearBackground` |
| memória de vídeo crescendo | 3 e 8 | `LoadTexture` dentro do loop |

---

**Outros caminhos**

```text
pixels mudando todo frame:   buffer de Color na RAM ──UpdateTexture──► Texture2D existente
desenhar dentro de textura:  Draw... entre BeginTextureMode/EndTextureMode ──► RenderTexture2D ──► DrawTexture
ler de volta da GPU:         Texture2D ──LoadImageFromTexture──► Image (lento)
imagem gerada no código:     GenImage... ──► Image ──► etapa 2 em diante
```

- `UpdateTexture` pula as etapas 1 e 3: reenvia pixels para uma textura que já existe, sem criar outra (ver `../texture/functions/update-texture.md`)
- Uma render texture é uma textura em que a etapa 6 escreve no lugar do back buffer. Depois ela é desenhada como qualquer outra textura (ver `../texture/render-texture.md`)

> A regra que conecta tudo: a CPU **prepara** (carrega, edita, decide onde desenhar) e a GPU **executa** (guarda os pixels e pinta a tela). Os pixels atravessam da RAM para a VRAM uma vez, e a partir daí, todo frame, só viajam números pequenos: qual textura, qual pedaço, onde e com qual cor (ver `cpu-vs-gpu.md`)
