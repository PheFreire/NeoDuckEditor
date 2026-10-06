**UnloadSound**

> `raylib.h` — módulo `raudio`

O `UnloadSound` para um som (se estiver tocando) e libera a memória com os dados de áudio dele

```c
void UnloadSound(Sound sound);
```

- `sound`: o som a liberar

- Não devolve nada
- Deve ser chamado antes do `CloseAudioDevice`
- Aliases criados com `LoadSoundAlias` são liberados com `UnloadSoundAlias`, **antes** do som original

```c
Sound passo = LoadSound("passo.wav");
Sound passo2 = LoadSoundAlias(passo);

/* ... */

UnloadSoundAlias(passo2);   // primeiro os aliases, que usam os dados do original
UnloadSound(passo);
CloseAudioDevice();
```

> Liberar o som original antes dos aliases deixa os aliases apontando para dados liberados. O alias não tem cópia própria do áudio, só uma voz separada (ver `../sound.md`)
