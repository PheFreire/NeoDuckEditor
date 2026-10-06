**SetSoundVolume**

> `raylib.h` — módulo `raudio`

O `SetSoundVolume` define o volume de um som específico

```c
void SetSoundVolume(Sound sound, float volume);
```

- `sound`: o som
- `volume`: de `0.0` (mudo) a `1.0` (volume original)

- Não devolve nada
- O valor fica guardado no som e vale para os próximos `PlaySound`
- O volume final é multiplicado pelo volume master

```c
// volume pela distância até o jogador
float d = Vector2Distance(jogador, explosao);
float volume = 1.0f - d / 800.0f;   // some a 800 pixels
if (volume < 0) volume = 0;
SetSoundVolume(som_explosao, volume);
PlaySound(som_explosao);
```

> Para controlar o volume de categorias inteiras (todos os efeitos, toda a música), mantenha uma variável por categoria e aplique ao configurar cada som (ver `../volume.md`)
