**Gerando imagens**

> `raylib.h` — módulo `rtextures`

As funções `GenImage...` criam imagens sem precisar de arquivos: cor sólida, gradientes, xadrez, ruído e padrões celulares. São úteis para protótipos, texturas procedurais, fundos e testes

| Função | Gera |
|--------|------|
| `GenImageColor(w, h, cor)` | imagem de uma cor só |
| `GenImageGradientLinear(w, h, direção, ini, fim)` | gradiente linear em um ângulo |
| `GenImageGradientRadial(w, h, densidade, dentro, fora)` | gradiente circular a partir do centro |
| `GenImageGradientSquare(w, h, densidade, dentro, fora)` | gradiente quadrado a partir do centro |
| `GenImageChecked(w, h, nx, ny, cor1, cor2)` | xadrez |
| `GenImageWhiteNoise(w, h, fator)` | ruído branco (pixels aleatórios brancos e pretos) |
| `GenImagePerlinNoise(w, h, ox, oy, escala)` | ruído Perlin (suave, como nuvens ou terreno) |
| `GenImageCellular(w, h, tamanho)` | padrão celular (Voronoi) |
| `GenImageText(w, h, texto)` | imagem a partir dos bytes de um texto |

```c
Image xadrez = GenImageChecked(256, 256, 8, 8, LIGHTGRAY, GRAY);   // textura de "não encontrado"
Image ceu    = GenImageGradientLinear(800, 450, 0, SKYBLUE, DARKBLUE);  // 0 graus: vertical
Image nuvens = GenImagePerlinNoise(512, 512, 0, 0, 4.0f);

Texture2D t_ceu = LoadTextureFromImage(ceu);
UnloadImage(ceu);
```

---

**Ruído Perlin para terreno**

```c
Image ruido = GenImagePerlinNoise(128, 128, 50, 50, 3.0f);
Color *p = LoadImageColors(ruido);   // cópia dos pixels como Color, em qualquer formato

for (int y = 0; y < 128; y++) {
  for (int x = 0; x < 128; x++) {
    unsigned char altura = p[y * 128 + x].r;   // tons de cinza: 0 a 255
    mapa[y][x] = altura < 90 ? AGUA : altura < 160 ? GRAMA : MONTANHA;
  }
}

UnloadImageColors(p);
UnloadImage(ruido);
```

- Os deslocamentos (`offsetX`, `offsetY`) escolhem qual pedaço do ruído infinito é gerado. Valores diferentes geram mapas diferentes, e valores vizinhos geram pedaços que se encaixam

> Toda imagem gerada é alocada na RAM como qualquer imagem carregada, e precisa de um `UnloadImage`. Uma imagem gerada também é um bom ponto de partida para desenhar dentro dela com as funções `ImageDraw...` (ver `image-drawing.md`)
