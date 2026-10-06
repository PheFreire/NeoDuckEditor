**Ciclo de desenho**

> `raylib.h` — módulo `rcore`

Cada frame é desenhado em um ciclo fixo: começar o desenho, limpar a tela, desenhar tudo e terminar o desenho, que mostra o resultado na janela. O raylib usa **double buffering**: o frame é montado em um buffer invisível e só aparece de uma vez, quando está completo

```c
while (!WindowShouldClose()) {
  BeginDrawing();               // começa o frame
  ClearBackground(RAYWHITE);    // apaga o frame anterior
  DrawCircle(400, 225, 50, RED);
  EndDrawing();                 // mostra o frame e prepara o próximo
}
```

---

**Double buffering**

```text
             front buffer                 back buffer
             (na tela)                    (sendo desenhado)
frame N:     [ imagem N-1 ]               BeginDrawing → Draw... → EndDrawing
                     ▲                            │
                     └──────── troca (swap) ──────┘
frame N+1:   [ imagem N ]                 BeginDrawing → ...
```

- Todos os `Draw...` escrevem no **back buffer**, que o usuário não vê
- O `EndDrawing` troca os buffers: o que foi desenhado aparece de uma vez, sem que o usuário veja o frame pela metade (o que causaria flicker)

---

**O que cada função faz**

| Função | Efeito |
|--------|--------|
| `BeginDrawing()` | prepara o back buffer e a matriz de desenho para o frame |
| `ClearBackground(cor)` | preenche todo o back buffer com uma cor |
| `Draw...()` | acumula formas, texturas e texto para desenhar |
| `EndDrawing()` | envia o que foi acumulado à GPU, troca os buffers, espera o tempo do `SetTargetFPS` e lê os eventos de input |

- O `EndDrawing` faz bem mais que "terminar o desenho": é nele que o tempo do frame é medido e que o input do próximo frame é lido (ver `../core/timing.md` e `../input/input.md`)

---

**Por que limpar a tela**

- O back buffer guarda o conteúdo de dois frames atrás (depois de cada troca, o buffer antigo volta a ser o de desenho). Sem o `ClearBackground`, as imagens se acumulam e criam rastros
- Se o fundo inteiro é coberto por uma imagem ou um mapa, o `ClearBackground` pode ser omitido, mas é barato e evita surpresas

---

**Blocos dentro do desenho**

```c
BeginDrawing();
ClearBackground(RAYWHITE);

BeginMode2D(camera);            // tudo aqui é afetado pela câmera
  DrawTextureV(mapa, (Vector2){ 0, 0 }, WHITE);
  DrawCircleV(jogador, 10, RED);
EndMode2D();

DrawText("vida: 3", 10, 10, 20, BLACK);   // interface fixa, fora da câmera
EndDrawing();
```

- Modos como `BeginMode2D`, `BeginMode3D`, `BeginShaderMode`, `BeginScissorMode` e `BeginBlendMode` são abertos e fechados **dentro** do bloco de desenho
- `BeginTextureMode` é a exceção: pode ser usado fora do `BeginDrawing`, pois desenha em uma textura e não na tela (ver `../texture/render-texture.md`)

> Todo `Begin...` precisa do seu `End...` correspondente, na ordem inversa da abertura, como chaves em C. Esquecer um `End` deixa o modo ativo nos frames seguintes e produz resultados difíceis de entender
