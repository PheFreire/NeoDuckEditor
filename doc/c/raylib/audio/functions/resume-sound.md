**ResumeSound**

> `raylib.h` — módulo `raudio`

O `ResumeSound` continua a reprodução de um som pausado, a partir do ponto em que ele parou

```c
void ResumeSound(Sound sound);
```

- `sound`: o som a continuar

- Não devolve nada
- Só tem efeito em um som pausado com `PauseSound`. Um som parado com `StopSound` ou que nunca tocou precisa de `PlaySound`

```c
if (!IsWindowFocused()) {
  PauseSound(narracao);
} else if (!IsSoundPlaying(narracao) && narracao_pausada) {
  ResumeSound(narracao);
}
```

> Diferença entre os três: `PlaySound` sempre começa do início, `ResumeSound` continua de onde parou, e `StopSound` para e volta ao início
