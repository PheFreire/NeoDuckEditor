**GetMasterVolume**

> `raylib.h` — módulo `raudio`

O `GetMasterVolume` devolve o volume geral atual do áudio do programa

```c
float GetMasterVolume(void);
```

- Devolve o volume master, de `0.0` a `1.0`

```c
// slider de volume na tela de opções
float v = GetMasterVolume();
if (IsKeyPressed(KEY_RIGHT)) v += 0.1f;
if (IsKeyPressed(KEY_LEFT))  v -= 0.1f;
if (v < 0) v = 0;
if (v > 1) v = 1;
SetMasterVolume(v);

DrawRectangle(100, 200, 200, 20, LIGHTGRAY);
DrawRectangle(100, 200, (int)(200 * v), 20, BLUE);
```

> Para salvar a preferência do usuário entre execuções, guarde o valor devolvido em um arquivo de configuração e aplique com `SetMasterVolume` logo depois do `InitAudioDevice`
