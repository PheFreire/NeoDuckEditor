**IsSoundPlaying**

> `raylib.h` — módulo `raudio`

O `IsSoundPlaying` verifica se um som está tocando neste momento

```c
bool IsSoundPlaying(Sound sound);
```

- `sound`: o som

- Devolve `true` se o som está tocando, e `false` se terminou, foi parado, pausado ou nunca tocou

```c
// tocar um som em loop manualmente
if (!IsSoundPlaying(chuva)) {
  PlaySound(chuva);
}

// esperar a fala terminar para mostrar a próxima linha do diálogo
if (mostrando_dialogo && !IsSoundPlaying(fala_atual)) {
  proxima_linha();
}
```

> Para músicas e sons ambientes longos, prefira `Music`, que tem repetição embutida (`looping`) e não precisa ser reiniciada manualmente (ver `../music.md`)
