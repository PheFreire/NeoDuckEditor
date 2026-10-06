**InitAudioDevice**

> `raylib.h` — módulo `raudio`

O `InitAudioDevice` abre o dispositivo de áudio padrão do sistema e inicia o mixer do raylib, que roda em uma thread própria. Precisa ser chamado antes de carregar ou tocar qualquer som

```c
void InitAudioDevice(void);
```

- Não recebe parâmetros e não devolve nada
- Independe da janela: pode ser chamado antes ou depois do `InitWindow`
- Para saber se funcionou, use `IsAudioDeviceReady()`

```c
InitWindow(800, 450, "jogo");
InitAudioDevice();

Sound moeda = LoadSound("moeda.wav");   // só depois do InitAudioDevice
```

> Carregar um `Sound` antes do `InitAudioDevice` gera um aviso no log e devolve um som que não toca. Ver o funcionamento do mixer em `../audio-device.md`
