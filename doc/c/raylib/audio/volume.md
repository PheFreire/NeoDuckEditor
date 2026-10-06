**Volume, pitch e pan**

> `raylib.h` — módulo `raudio`

Cada som, música ou stream tem três ajustes próprios: volume (o quão alto), pitch (o tom e a velocidade) e pan (a posição entre o alto-falante esquerdo e o direito). Além deles, um volume master controla todo o áudio do programa

| Ajuste | Faixa | Padrão | Funções |
|--------|-------|--------|---------|
| volume master | `0.0` a `1.0` | `1.0` | `SetMasterVolume`, `GetMasterVolume` |
| volume | `0.0` (mudo) a `1.0` (máximo) | `1.0` | `SetSoundVolume`, `SetMusicVolume`, `SetAudioStreamVolume` |
| pitch | maior que `0`. `1.0` = original | `1.0` | `SetSoundPitch`, `SetMusicPitch`, `SetAudioStreamPitch` |
| pan | `0.0` a `1.0`, `0.5` = centro | `0.5` | `SetSoundPan`, `SetMusicPan`, `SetAudioStreamPan` |

```text
volume final = amostra × volume do som × volume master
```

---

**Volume**

```c
// configurações do jogo
float volume_geral = 0.8f, volume_musica = 0.5f, volume_efeitos = 1.0f;

SetMasterVolume(volume_geral);
SetMusicVolume(trilha, volume_musica);
SetSoundVolume(pulo, volume_efeitos);
```

- O volume é linear, mas o ouvido percebe volume de forma logarítmica: de `1.0` para `0.5` parece uma diferença menor do que se espera. Sliders de volume costumam usar o valor ao quadrado (`v * v`) para soar mais natural

---

**Pitch**

```c
SetSoundPitch(motor, 0.5f + velocidade_carro / velocidade_max);   // motor mais agudo com velocidade
SetSoundPitch(passo, 0.9f + GetRandomValue(0, 20) / 100.0f);      // variação natural
```

- O pitch muda o tom **e** a velocidade juntos: `2.0` toca uma oitava acima e com metade da duração, como acelerar uma fita

---

**Pan**

```c
// som posicional simples: pan conforme a posição na tela
float pan = Clamp(1.0f - inimigo.x / GetScreenWidth(), 0.0f, 1.0f);
SetSoundPan(rosnado, pan);
```

- No raylib 5.5, `0.5` é o centro. O sentido de `0.0` e `1.0` (qual é a esquerda) e a faixa já mudaram entre versões do raylib. Confira no header da versão usada e teste com fones antes de depender disso

> Volume, pitch e pan de um `Sound` são guardados no próprio som. Para tocar o mesmo efeito com ajustes diferentes ao mesmo tempo, use aliases (`LoadSoundAlias`), cada um com seus valores (ver `sound.md`)
