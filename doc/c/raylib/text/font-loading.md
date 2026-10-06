**Carregando fontes**

> `raylib.h` — módulo `rtext`

O raylib carrega fontes vetoriais (TTF, OTF), fontes bitmap (FNT/BMFont) e imagens com caracteres desenhados (estilo XNA). Para fontes vetoriais, o carregamento rasteriza os caracteres em um tamanho escolhido e monta o atlas na GPU

| Função | Uso |
|--------|-----|
| `GetFontDefault()` | a fonte padrão embutida, sem arquivo |
| `LoadFont(arquivo)` | carrega com tamanho e caracteres padrão |
| `LoadFontEx(arquivo, tamanho, codepoints, n)` | escolhe o tamanho e quais caracteres incluir |
| `LoadFontFromImage(img, cor_chave, primeiro)` | fonte desenhada em uma imagem |
| `LoadFontFromMemory(".ttf", dados, tamanho, ...)` | arquivo de fonte já em memória |
| `UnloadFont(fonte)` | libera a textura e as tabelas |

```c
InitWindow(800, 450, "fontes");

Font fonte = LoadFontEx("assets/Inter.ttf", 32, NULL, 0);   // 32 px, caracteres ASCII
if (!IsFontValid(fonte)) {
  fonte = GetFontDefault();   // usa a padrão se o arquivo não carregar
}
```

---

**LoadFont vs LoadFontEx**

- `LoadFont(arquivo)`: para TTF/OTF, usa um tamanho padrão pequeno (32 pixels na configuração padrão) e só os caracteres ASCII. Simples, mas sem controle
- `LoadFontEx(arquivo, tamanho, codepoints, n)`: o tamanho em pixels e a lista de caracteres. Com `codepoints = NULL` e `n = 0`, carrega o conjunto padrão (ASCII)

---

**Incluindo acentos**

```c
// todos os caracteres usados em um texto, inclusive acentuados
const char *textos = "Olá, ação, coração, é, ç, ã, õ, ü";
int n = 0;
int *codepoints = LoadCodepoints(textos, &n);   // um codepoint por caractere do texto, com repetições

Font fonte = LoadFontEx("Inter.ttf", 32, codepoints, n);
UnloadCodepoints(codepoints);
```

- O `LoadCodepoints` converte o texto UTF-8 em uma lista de codepoints, que vira a lista de caracteres da fonte
- A lista mantém as repetições (`"aãa"` gera 3 codepoints). A fonte funciona assim, mas cada repetição ocupa espaço no atlas. Em textos grandes, remova os repetidos antes de carregar
- Um caractere que não está na fonte é desenhado como `?` (ver `unicode.md`)

> Cada combinação de arquivo e tamanho é uma fonte diferente, com o seu próprio atlas. Carregue as fontes uma vez, antes do game loop, e libere todas com `UnloadFont` antes do `CloseWindow`
