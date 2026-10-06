**PauseSound**

> `raylib.h` — módulo `raudio`

O `PauseSound` pausa um som que está tocando, guardando a posição atual para continuar depois com `ResumeSound`

```c
void PauseSound(Sound sound);
```

- `sound`: o som a pausar

- Não devolve nada
- Enquanto pausado, `IsSoundPlaying` devolve `false`

```c
// menu de pausa: pausa os sons longos e continua de onde pararam
if (IsKeyPressed(KEY_P)) {
  pausado = !pausado;
  if (pausado) PauseSound(dialogo);
  else ResumeSound(dialogo);
}
```

> A pausa vale só para o som passado. Para pausar todo o áudio do jogo de uma vez, uma alternativa é zerar o volume master, mas isso não para a reprodução: os sons continuam avançando em silêncio
