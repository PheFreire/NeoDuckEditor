**SetMasterVolume**

> `raylib.h` — módulo `raudio`

O `SetMasterVolume` define o volume geral de todo o áudio do programa, aplicado por cima do volume de cada som e música

```c
void SetMasterVolume(float volume);
```

- `volume`: de `0.0` (mudo) a `1.0` (máximo)

- Não devolve nada
- Afeta tudo que está tocando e tudo que tocar depois

```c
// botão de mudo
static bool mudo = false;
if (IsKeyPressed(KEY_M)) {
  mudo = !mudo;
  SetMasterVolume(mudo ? 0.0f : volume_salvo);
}
```

> O volume final de cada som é `volume do som × volume master`. Por isso o master é o lugar certo para a opção "volume geral" do jogo, enquanto os volumes individuais controlam "música" e "efeitos" (ver `../volume.md`)
