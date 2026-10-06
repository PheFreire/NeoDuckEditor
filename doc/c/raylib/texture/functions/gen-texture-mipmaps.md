**GenTextureMipmaps**

> `raylib.h` — módulo `rtextures`

O `GenTextureMipmaps` gera os mipmaps de uma textura na GPU: versões cada vez menores da imagem (metade, um quarto, um oitavo...), usadas automaticamente quando a textura aparece pequena na tela

```c
void GenTextureMipmaps(Texture2D *texture);
```

- `texture`: ponteiro para a textura (o campo `mipmaps` é atualizado)

- Não devolve nada
- Depois da chamada, `texture->mipmaps` passa a indicar quantos níveis existem

```c
Texture2D chao = LoadTexture("chao_1024.png");
GenTextureMipmaps(&chao);
SetTextureFilter(chao, TEXTURE_FILTER_TRILINEAR);   // usa os mipmaps, com transição suave entre eles
```

---

**Os níveis**

```text
nível 0: 1024 x 1024   (original)
nível 1:  512 x 512
nível 2:  256 x 256
  ...
nível 10:   1 x 1

memória extra: cerca de 1/3 do tamanho original
```

- Uma textura grande desenhada pequena (um chão que se afasta da câmera) sem mipmaps "cintila", pois cada pixel da tela pega um pixel quase aleatório da textura
- Com mipmaps, a GPU usa o nível do tamanho certo, que já tem a média das cores

> Mipmaps fazem diferença principalmente em 3D, onde a mesma textura aparece em várias distâncias. Em jogos 2D com sprites desenhados no tamanho original, eles não são necessários
