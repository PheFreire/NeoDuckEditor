**Cores**

> `raylib.h` — tipo `Color`

Uma cor no raylib é uma struct de 4 bytes: vermelho, verde, azul e alfa (transparência), cada um de `0` a `255`. Toda função de desenho recebe uma `Color`, e o raylib define as cores mais comuns como macros prontas

```c
typedef struct Color {
  unsigned char r;   // vermelho, 0 a 255
  unsigned char g;   // verde, 0 a 255
  unsigned char b;   // azul, 0 a 255
  unsigned char a;   // alfa: 0 = transparente, 255 = opaco
} Color;
```

```c
Color laranja = { 255, 161, 0, 255 };
Color meio_transparente = { 255, 0, 0, 128 };
DrawCircle(400, 225, 50, (Color){ 30, 144, 255, 255 });   // compound literal do C99
```

---

**Cores prontas**

| Macro | RGBA | Macro | RGBA |
|-------|------|-------|------|
| `WHITE` | 255 255 255 255 | `BLACK` | 0 0 0 255 |
| `RAYWHITE` | 245 245 245 255 | `BLANK` | 0 0 0 0 (transparente) |
| `LIGHTGRAY` | 200 200 200 255 | `GRAY` | 130 130 130 255 |
| `DARKGRAY` | 80 80 80 255 | `MAGENTA` | 255 0 255 255 |
| `RED` | 230 41 55 255 | `MAROON` | 190 33 55 255 |
| `ORANGE` | 255 161 0 255 | `GOLD` | 255 203 0 255 |
| `YELLOW` | 253 249 0 255 | `PINK` | 255 109 194 255 |
| `GREEN` | 0 228 48 255 | `LIME` | 0 158 47 255 |
| `DARKGREEN` | 0 117 44 255 | `SKYBLUE` | 102 191 255 255 |
| `BLUE` | 0 121 241 255 | `DARKBLUE` | 0 82 172 255 |
| `PURPLE` | 200 122 255 255 | `VIOLET` | 135 60 190 255 |
| `DARKPURPLE` | 112 31 126 255 | `BEIGE` | 211 176 131 255 |
| `BROWN` | 127 106 79 255 | `DARKBROWN` | 76 63 47 255 |

---

**Funções de cor**

| Função | Devolve |
|--------|---------|
| `Fade(cor, alfa)` | a cor com transparência, `alfa` de `0.0` a `1.0` |
| `ColorAlpha(cor, alfa)` | o mesmo que `Fade` |
| `ColorFromHSV(h, s, v)` | cor a partir de matiz (`0` a `360`), saturação e valor (`0` a `1`) |
| `GetColor(0xRRGGBBAA)` | cor a partir de um hexadecimal |
| `ColorLerp(a, b, t)` | mistura de duas cores, `t` de `0` (só `a`) a `1` (só `b`) |
| `ColorToInt(cor)` | a cor como inteiro hexadecimal |

```c
DrawRectangle(0, 0, 800, 450, Fade(BLACK, 0.5f));          // escurece a tela pela metade
Color c = GetColor(0x1E90FFFF);                             // azul "dodger blue"
Color arco_iris = ColorFromHSV(fmodf(GetTime() * 90, 360), 1.0f, 1.0f);  // cor que gira com o tempo
Color vida = ColorLerp(RED, GREEN, hp / 100.0f);            // vermelho com pouca vida, verde com muita
```

---

**Tint: cor como filtro**

Em texturas, texto e modelos, a cor passada não pinta a forma: ela **multiplica** cada pixel (tint)

```text
pixel da textura × tint / 255 = pixel na tela
(200, 100, 50) × WHITE (255, 255, 255) = (200, 100, 50)   sem alteração
(200, 100, 50) × RED   (230, 41, 55)   = (180, 16, 10)    avermelhado
qualquer       × alfa 128              = meio transparente
```

- Por isso o `WHITE` é usado para desenhar uma textura sem alteração (ver `../texture/texture-drawing.md`)

> O alfa só tem efeito porque o raylib desenha com mistura (blending) ligada por padrão: a cor nova é combinada com o que já está na tela. A ordem importa: desenhe primeiro o que fica atrás, e depois o que é transparente na frente
