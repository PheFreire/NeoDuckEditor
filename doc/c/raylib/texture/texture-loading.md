**Carregando texturas**

> `raylib.h` — módulo `rtextures`

Uma textura é criada a partir de um arquivo, de uma `Image` já carregada, ou vazia (render texture, para desenhar dentro dela). Em todos os casos, os pixels são enviados para a GPU, e a textura só pode ser criada depois do `InitWindow`

| Função | Cria a textura a partir de |
|--------|----------------------------|
| `LoadTexture(arquivo)` | um arquivo de imagem |
| `LoadTextureFromImage(img)` | uma `Image` na RAM |
| `LoadRenderTexture(w, h)` | nada: uma textura vazia para desenhar dentro (ver `render-texture.md`) |
| `LoadTextureCubemap(img, layout)` | uma imagem com as 6 faces de um cubo (skybox) |

```c
InitWindow(800, 450, "jogo");

Texture2D fundo  = LoadTexture("assets/fundo.png");
Texture2D heroi  = LoadTexture("assets/heroi.png");

if (!IsTextureValid(heroi)) {
  TraceLog(LOG_ERROR, "heroi.png não carregou");
}
```

---

**O que o LoadTexture faz**

```text
LoadTexture("heroi.png")
  │  LoadImage: disco → RAM
  ▼
  │  LoadTextureFromImage: RAM → GPU (glGenTextures + glTexImage2D)
  ▼
  │  UnloadImage: libera a RAM
  ▼
Texture2D (só o id fica na struct)
```

---

**Quando o carregamento falha**

- O programa **não** para: o log mostra um aviso, e a textura devolvida tem `id == 0`
- Desenhar uma textura inválida não aparece nada (ou aparece um quadrado da cor do tint), o que pode passar despercebido
- As causas mais comuns são o caminho errado (relativo ao diretório de trabalho, e não ao executável) e chamar o `LoadTexture` antes do `InitWindow`

```c
// caminho relativo à pasta do executável, independente de onde o programa foi chamado
ChangeDirectory(GetApplicationDirectory());
Texture2D t = LoadTexture("assets/heroi.png");
```

- Ver `../files/paths.md` para a diferença entre diretório de trabalho e pasta do executável

---

**Uma textura para muitos sprites**

```text
spritesheet.png (uma única textura)
┌────┬────┬────┬────┐
│ f0 │ f1 │ f2 │ f3 │   animação de andar
├────┼────┼────┼────┤
│ f0 │ f1 │ f2 │ f3 │   animação de pular
└────┴────┴────┴────┘
```

- Juntar vários sprites em uma imagem (spritesheet, atlas) e desenhar só o pedaço necessário com `DrawTextureRec` ou `DrawTexturePro` é mais eficiente que carregar uma textura por sprite: a GPU troca menos de textura entre os desenhos (ver `texture-drawing.md`)

> Carregue as texturas uma vez, antes do game loop, e reutilize. Chamar `LoadTexture` dentro do loop carrega o arquivo de novo a cada frame e consome a memória de vídeo até o programa travar
