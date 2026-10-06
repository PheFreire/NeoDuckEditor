**SetSoundPitch**

> `raylib.h` — módulo `raudio`

O `SetSoundPitch` muda o tom de um som. O tom e a velocidade mudam juntos: um pitch maior toca mais agudo e mais rápido, um menor toca mais grave e mais lento

```c
void SetSoundPitch(Sound sound, float pitch);
```

- `sound`: o som
- `pitch`: `1.0` é o original, `2.0` uma oitava acima (dobro da velocidade), `0.5` uma oitava abaixo (metade da velocidade)

- Não devolve nada
- O valor fica guardado no som

```c
// variação aleatória para sons repetidos não soarem idênticos
SetSoundPitch(passo, 0.9f + GetRandomValue(0, 20) / 100.0f);   // entre 0.9 e 1.1
PlaySound(passo);

// motor que fica mais agudo com a velocidade
SetSoundPitch(motor, 0.8f + velocidade / velocidade_max);
```

> O pitch funciona como acelerar ou desacelerar uma gravação. Para mudar o tom sem mudar a duração, seria preciso um processamento de áudio específico, que o raylib não oferece
