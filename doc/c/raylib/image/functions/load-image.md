**LoadImage**

> `raylib.h` — módulo `rtextures`

O `LoadImage` lê um arquivo de imagem do disco e o carrega na memória RAM como uma `Image`, pronta para ser editada ou enviada para a GPU

```c
Image LoadImage(const char *fileName);
```

- `fileName`: o caminho do arquivo, relativo ao diretório de trabalho ou absoluto

- Devolve a `Image` com os pixels na RAM
- Se o arquivo não existir ou o formato não for suportado, escreve um aviso no log e devolve uma imagem vazia (`data == NULL`). Confira com `IsImageValid`
- O formato é detectado pela extensão do arquivo. Na configuração padrão, PNG, BMP, JPG, GIF, QOI e DDS são suportados
- Não precisa da janela: funciona antes do `InitWindow`, pois usa só a CPU

```c
Image icone = LoadImage("assets/icone.png");
if (IsImageValid(icone)) {
  SetWindowIcon(icone);   // ícone da janela
}
UnloadImage(icone);
```

---

**Fluxo com edição**

```c
Image img = LoadImage("heroi.png");      // disco → RAM
ImageResizeNN(&img, 64, 64);             // editar na CPU
Texture2D heroi = LoadTextureFromImage(img);   // RAM → GPU
UnloadImage(img);                        // libera a RAM
```

> Toda imagem carregada precisa de um `UnloadImage`, que libera os pixels alocados. Se a imagem só vai ser desenhada, sem nenhuma edição, use direto o `LoadTexture`, que faz o carregamento e o envio para a GPU de uma vez (ver `../../texture/functions/load-texture.md`)
