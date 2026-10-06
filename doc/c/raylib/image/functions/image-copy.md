**ImageCopy**

> `raylib.h` — módulo `rtextures`

O `ImageCopy` cria uma cópia independente de uma imagem, com um novo bloco de pixels na memória. É a forma correta de duplicar uma imagem antes de modificá-la, mantendo a original intacta

```c
Image ImageCopy(Image image);
```

- `image`: a imagem a copiar

- Devolve uma nova `Image` com os mesmos pixels, em um bloco de memória separado
- A cópia precisa do seu próprio `UnloadImage`

```c
Image original = LoadImage("heroi.png");

Image espelhada = ImageCopy(original);
ImageFlipHorizontal(&espelhada);          // só a cópia muda

Image sombra = ImageCopy(original);
ImageColorTint(&sombra, BLACK);           // silhueta para a sombra

UnloadImage(original);
UnloadImage(espelhada);
UnloadImage(sombra);
```

---

**ImageCopy vs atribuição**

```c
Image b = a;             // cópia rasa: b.data == a.data, os dois apontam para os mesmos pixels
Image c = ImageCopy(a);  // cópia real: c.data é um bloco novo
```

```text
Image b = a:                       ImageCopy(a):
a.data ──┐                         a.data ──► [pixels]
         ├──► [pixels]
b.data ──┘                         c.data ──► [pixels copiados]
```

- Com a atribuição, modificar `b` afeta `a`, e liberar os dois causa double free (ver `../image-memory.md`)

> A mesma ideia vale para qualquer struct com ponteiros em C: copiar a struct copia o ponteiro, e não o que ele aponta. Funções como o `ImageCopy` existem justamente para fazer a cópia profunda (deep copy)
