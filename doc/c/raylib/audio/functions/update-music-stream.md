**UpdateMusicStream**

> `raylib.h` — módulo `raudio`

O `UpdateMusicStream` mantém uma música tocando: verifica se o buffer de áudio precisa de mais dados e, se precisar, decodifica o próximo pedaço do arquivo. Precisa ser chamado em **todo frame** enquanto a música toca

```c
void UpdateMusicStream(Music music);
```

- `music`: a música

- Não devolve nada
- Quando a música termina e `looping` é `true`, volta ao início automaticamente
- Em uma música parada ou pausada, não faz nada

```c
while (!WindowShouldClose()) {
  UpdateMusicStream(trilha);   // primeira coisa do frame
  atualizar();
  BeginDrawing();
  desenhar();
  EndDrawing();
}
```

---

**O que acontece sem ele**

```text
PlayMusicStream   → preenche os buffers iniciais (fração de segundo)
sem UpdateMusicStream:
  thread de áudio consome os buffers ──► acabam ──► silêncio ou o mesmo trecho repetido
```

- A música toca uma fração de segundo e para (ou fica repetindo um pedaço curto)
- O mesmo acontece se o game loop travar por muito tempo, por exemplo durante um carregamento pesado: a música engasga

> Em telas de carregamento, chame o `UpdateMusicStream` entre os passos do carregamento (por exemplo, depois de cada `LoadTexture`) para a música não falhar enquanto o jogo carrega
