**Image vs Texture**

> a mesma imagem em duas memórias

No raylib, uma mesma imagem pode existir de duas formas: como `Image`, com os pixels na RAM, acessíveis e editáveis pelo programa, ou como `Texture2D`, com os pixels na memória da placa de vídeo, prontos para serem desenhados rapidamente. O tipo diz onde os dados estão, e isso define o que se pode fazer com eles

```text
arquivo.png
    │ LoadImage
    ▼
 Image  ─────────────── editar, ler pixels, salvar (CPU)
    │ LoadTextureFromImage
    ▼
Texture2D ───────────── desenhar na tela (GPU)
```

| Pergunta | `Image` | `Texture2D` |
|----------|---------|-------------|
| Posso desenhar na tela? | não | sim |
| Posso ler ou alterar um pixel? | sim, em `data` | não diretamente |
| Funciona antes do `InitWindow`? | sim | não |
| Custo de desenhar 1000 vezes | — | baixo |
| Liberar com | `UnloadImage` | `UnloadTexture` |

---

**Regras práticas**

- Só vai desenhar? `LoadTexture` direto, sem `Image`
- Precisa editar antes? `LoadImage` → `Image...` → `LoadTextureFromImage` → `UnloadImage`
- Precisa mudar pixels todo frame? Mantenha um buffer de `Color` na RAM e use `UpdateTexture`, ou faça o efeito com um shader
- Precisa salvar o que foi desenhado? Render texture → `LoadImageFromTexture` → `ExportImage` (lento, só ocasionalmente)

> A explicação detalhada, com as funções de cada lado, está em `../texture/image-vs-texture.md`. A diferença entre as duas memórias está em `cpu-vs-gpu.md`
