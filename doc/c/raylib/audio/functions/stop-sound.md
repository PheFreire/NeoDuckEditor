**StopSound**

> `raylib.h` — módulo `raudio`

O `StopSound` interrompe um som que está tocando e volta a posição de reprodução para o início

```c
void StopSound(Sound sound);
```

- `sound`: o som a parar

- Não devolve nada
- Depois de parado, o próximo `PlaySound` (ou `ResumeSound`) começa do início
- Em um som que não está tocando, não faz nada

```c
// som de motor que só toca enquanto acelera
if (IsKeyDown(KEY_UP)) {
  if (!IsSoundPlaying(motor)) PlaySound(motor);
} else {
  StopSound(motor);
}
```

> Para interromper e continuar depois do mesmo ponto, use `PauseSound` e `ResumeSound` (ver `pause-sound.md`)
