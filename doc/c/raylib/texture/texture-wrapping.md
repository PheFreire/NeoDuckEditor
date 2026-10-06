**Repetição de textura (wrap)**

> `raylib.h` — módulo `rtextures`

O modo de wrap define o que a GPU desenha quando a textura é lida fora dos seus limites. Com `REPEAT`, a textura se repete como um azulejo, o que permite cobrir áreas grandes com uma textura pequena. Com `CLAMP`, a borda da textura é esticada

```c
void SetTextureWrap(Texture2D texture, int wrap);
```

| Modo | Fora dos limites |
|------|------------------|
| `TEXTURE_WRAP_REPEAT` | a textura se repete (padrão) |
| `TEXTURE_WRAP_CLAMP` | repete o pixel da borda |
| `TEXTURE_WRAP_MIRROR_REPEAT` | se repete espelhando a cada vez |
| `TEXTURE_WRAP_MIRROR_CLAMP` | espelha uma vez e depois prende na borda |

```text
REPEAT              MIRROR_REPEAT         CLAMP
[AB][AB][AB]        [AB][BA][AB]          [AB]BBBBBB
```

---

**Fundo infinito com uma textura pequena**

```c
Texture2D grama = LoadTexture("grama_64.png");
SetTextureWrap(grama, TEXTURE_WRAP_REPEAT);

// o source maior que a textura faz ela se repetir
Rectangle source = { 0, 0, 800, 450 };   // 800/64 = 12,5 repetições na horizontal
Rectangle dest   = { 0, 0, 800, 450 };
DrawTexturePro(grama, source, dest, (Vector2){ 0, 0 }, 0, WHITE);
```

Fundo que rola (parallax):

```c
float rolagem = 0;
rolagem += 50 * GetFrameTime();
Rectangle source = { rolagem, 0, 800, 450 };   // deslocar o source move o padrão
DrawTexturePro(nuvens, source, (Rectangle){ 0, 0, 800, 450 }, (Vector2){ 0 }, 0, WHITE);
```

---

**Quando usar CLAMP**

- Ao desenhar um pedaço de uma spritesheet com filtro bilinear, a GPU pode misturar pixels da borda com os do sprite vizinho, criando linhas finas nas bordas. O `CLAMP` evita que a leitura saia da textura inteira, mas não do sprite. Para spritesheets, deixe um espaço (padding) entre os sprites ou use o filtro point

> O wrap só faz diferença quando o `source` (ou as coordenadas de textura de um modelo 3D) passa dos limites da textura. Com o `DrawTexture` simples, a textura é sempre desenhada inteira, uma vez, e o modo não tem efeito visível
