**BeginDrawing**

> `raylib.h` — módulo `rcore`

O `BeginDrawing` marca o início do desenho de um frame. Ele prepara o buffer de desenho e o estado interno do raylib para receber as chamadas `Draw...` daquele frame

```c
void BeginDrawing(void);
```

- Não recebe parâmetros e não devolve nada
- Deve ser chamado uma vez por frame, dentro do game loop, sempre seguido de um `EndDrawing`
- Também registra o momento em que o frame começou, usado no cálculo do `GetFrameTime`

```c
while (!WindowShouldClose()) {
  atualizar();

  BeginDrawing();
  ClearBackground(RAYWHITE);
  desenhar();
  EndDrawing();
}
```

---

**O que acontece por baixo**

- Marca o tempo atual como início do frame
- Reseta a matriz de transformação (`modelview`) para a identidade, desfazendo qualquer transformação esquecida do frame anterior
- Seleciona o framebuffer padrão (a janela) como destino do desenho

> Funções `Draw...` chamadas fora de um par `BeginDrawing`/`EndDrawing` (ou de um `BeginTextureMode`/`EndTextureMode`) não aparecem em lugar nenhum de forma confiável. Toda chamada de desenho para a tela deve estar dentro desse bloco (ver `../drawing-cycle.md`)
