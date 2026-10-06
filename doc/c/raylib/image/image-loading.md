**Carregando imagens**

> `raylib.h` — módulo `rtextures`

O raylib carrega imagens de arquivos, de dados já em memória e até da própria tela ou de uma textura da GPU. O resultado é sempre uma `Image` na RAM, pronta para ser editada ou enviada para a GPU

| Função | Carrega de |
|--------|------------|
| `LoadImage(arquivo)` | um arquivo de imagem (PNG, BMP, JPG, GIF, QOI, DDS por padrão) |
| `LoadImageRaw(arquivo, w, h, formato, header)` | um arquivo de pixels crus, sem formato |
| `LoadImageFromMemory(".png", dados, tamanho)` | um arquivo que já está em memória (embutido no executável, baixado da rede) |
| `LoadImageAnim(arquivo, &frames)` | um GIF animado, com todos os frames empilhados |
| `LoadImageFromTexture(textura)` | uma textura da GPU, copiada de volta para a RAM |
| `LoadImageFromScreen()` | o conteúdo atual da tela (screenshot) |

```c
Image img = LoadImage("assets/heroi.png");
if (!IsImageValid(img)) {
  TraceLog(LOG_ERROR, "não foi possível carregar heroi.png");
}
```

---

**Formatos de arquivo**

- Os formatos suportados dependem de como o raylib foi compilado (flags `SUPPORT_FILEFORMAT_*` no `config.h`). Na configuração padrão do raylib 5.5, PNG, BMP, JPG, GIF, QOI e DDS estão ligados. TGA, PSD e HDR existem, mas precisam de uma compilação própria do raylib com as flags ativadas
- Na dúvida, use PNG: é suportado em qualquer compilação, sem perdas e com transparência
- O formato é detectado pela **extensão** do arquivo, e não pelo conteúdo

---

**Quando o carregamento falha**

- O raylib **não** derruba o programa: escreve um aviso no log e devolve uma imagem vazia (`data == NULL`, tamanho `0`)
- Use `IsImageValid(img)` para conferir
- O caminho é relativo ao **diretório de trabalho** do processo, que nem sempre é a pasta do executável. Ao rodar pelo editor ou por outro diretório, o arquivo não é encontrado (ver `../files/paths.md`)

---

**Fluxo típico**

```c
Image img = LoadImage("tileset.png");     // 1. carregar na RAM
ImageResizeNN(&img, img.width * 2, img.height * 2);   // 2. editar (opcional)
Texture2D tileset = LoadTextureFromImage(img);        // 3. enviar para a GPU
UnloadImage(img);                         // 4. liberar a RAM
```

- Se não houver nenhuma edição, `LoadTexture("tileset.png")` faz os passos 1, 3 e 4 de uma vez (ver `../texture/texture-loading.md`)

> Para distribuir um jogo em um único executável, os arquivos podem ser embutidos como arrays de bytes no código (com `ExportImageAsCode` ou ferramentas como `xxd -i`) e carregados com `LoadImageFromMemory`
