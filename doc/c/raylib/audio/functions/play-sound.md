**PlaySound**

> `raylib.h` — módulo `raudio`

O `PlaySound` toca um som desde o início. A reprodução acontece na thread de áudio, e o game loop continua imediatamente

```c
void PlaySound(Sound sound);
```

- `sound`: o som a tocar

- Não devolve nada
- Se o som já estiver tocando, ele **recomeça** do início (não toca duas cópias)
- Não precisa de nenhuma chamada por frame: o som toca até o fim sozinho

```c
if (IsKeyPressed(KEY_SPACE) && no_chao) {
  pular();
  PlaySound(som_pulo);
}
```

---

**Sons sobrepostos**

```c
// tiro automático: cada disparo usa uma voz diferente para não cortar o anterior
static Sound vozes[6];   // criadas com LoadSoundAlias
static int v = 0;
PlaySound(vozes[v]);
v = (v + 1) % 6;
```

> Para efeitos muito repetidos (passos, tiros), variar levemente o pitch a cada `PlaySound` com `SetSoundPitch` evita que o som pareça mecânico (ver `../volume.md`)
