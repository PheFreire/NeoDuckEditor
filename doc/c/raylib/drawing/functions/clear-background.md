**ClearBackground**

> `raylib.h` — módulo `rcore`

O `ClearBackground` preenche toda a área de desenho com uma cor, apagando o que estava lá. É normalmente a primeira chamada depois do `BeginDrawing`

```c
void ClearBackground(Color color);
```

- `color`: a cor de fundo

- Não devolve nada
- Apaga o destino de desenho atual inteiro: a janela, ou a render texture se estiver dentro de um `BeginTextureMode`
- Não é afetado pela câmera nem pelo scissor mode: limpa o buffer todo

```c
BeginDrawing();
ClearBackground(RAYWHITE);   // fundo claro padrão do raylib
/* ... */
EndDrawing();

BeginTextureMode(alvo);
ClearBackground(BLANK);      // render texture transparente, para desenhar por cima de outra cena
/* ... */
EndTextureMode();
```

---

**Sem ClearBackground**

```text
frame 1: ● (círculo em x = 100)
frame 2: ●● (círculo em x = 110, o anterior continua lá)
frame 3: ●●● rastro
```

- O buffer de desenho não é apagado automaticamente entre os frames. Sem limpar, o que foi desenhado antes continua visível, deixando rastros de tudo que se move

> Limpar com uma cor transparente (`BLANK`) só faz sentido em render textures ou em janelas com `FLAG_WINDOW_TRANSPARENT`. Em uma janela normal, o alfa é ignorado e o fundo fica preto
