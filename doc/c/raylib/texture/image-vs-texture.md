**Image vs Texture**

> `raylib.h` — módulo `rtextures`

O raylib separa imagens em dois tipos, conforme a memória onde os pixels ficam. `Image` fica na RAM e é manipulada pela CPU. `Texture2D` fica na VRAM e é desenhada pela GPU. Cada tipo é bom no que o outro é ruim, e boa parte do trabalho com gráficos é decidir quando passar de um para o outro

```text
               CPU (RAM)                                GPU (VRAM)
          ┌─────────────────┐   LoadTextureFromImage  ┌─────────────────┐
arquivo ─►│      Image      │ ───────────────────────►│    Texture2D    │──► tela
          │  data → pixels  │ ◄─────────────────────── │  id → pixels    │
          └─────────────────┘   LoadImageFromTexture  └─────────────────┘
           ler, editar, salvar    (lento: GPU → CPU)    desenhar rápido
```

---

**Comparação**

| | `Image` | `Texture2D` |
|---|---|---|
| Onde ficam os pixels | RAM | VRAM (placa de vídeo) |
| Quem acessa | CPU, pelo programa | GPU |
| Ler e alterar pixels | sim, direto em `data` | não diretamente (só reenviando com `UpdateTexture`) |
| Desenhar na tela | não | sim, `DrawTexture...` |
| Precisa da janela | não, funciona antes do `InitWindow` | sim (contexto OpenGL) |
| Custo de desenhar 1000 vezes | — (não desenha) | baixo, os pixels já estão na GPU |
| Liberar com | `UnloadImage` | `UnloadTexture` |
| Funções | `Image...`, `GenImage...` | `DrawTexture...`, `SetTextureFilter` |

---

**Regras práticas**

- Só vai desenhar? `LoadTexture` direto, sem `Image`
- Precisa editar antes? `LoadImage` → `Image...` → `LoadTextureFromImage` → `UnloadImage`
- Precisa mudar pixels todo frame? Mantenha um buffer de `Color` na RAM e use `UpdateTexture`, ou faça o efeito com um shader
- Precisa salvar o que foi desenhado? Render texture → `LoadImageFromTexture` → `ExportImage` (lento, só ocasionalmente)

---

**Fluxos comuns**

Só desenhar:

```c
Texture2D t = LoadTexture("sprite.png");   // carrega direto na GPU
```

Editar antes de desenhar:

```c
Image img = LoadImage("sprite.png");
ImageColorTint(&img, RED);
Texture2D t = LoadTextureFromImage(img);
UnloadImage(img);                           // a RAM não é mais necessária
```

Atualizar pixels todo frame (emulador, simulação, vídeo):

```c
Color *pixels = malloc(w * h * sizeof(Color));   // buffer na RAM
/* preencher pixels */
UpdateTexture(t, pixels);                       // copia o buffer inteiro para a textura na GPU
```

Ler o que foi desenhado e salvar:

```c
Image captura = LoadImageFromTexture(render.texture);   // GPU → RAM: lento, evite todo frame
ExportImage(captura, "captura.png");
UnloadImage(captura);
```

> A transferência entre RAM e VRAM passa pelo barramento entre a CPU e a placa de vídeo, que é muito mais lento que acessar cada memória localmente. Por isso, o ideal é enviar uma vez e desenhar muitas vezes (ver `../concepts/cpu-vs-gpu.md`). O caminho completo, do arquivo até a tela, está em `../concepts/image-to-screen.md`
