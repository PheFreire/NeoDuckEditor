**CloseAudioDevice**

> `raylib.h` — módulo `raudio`

O `CloseAudioDevice` para o mixer, encerra a thread de áudio e fecha o dispositivo de áudio do sistema

```c
void CloseAudioDevice(void);
```

- Não recebe parâmetros e não devolve nada
- Deve ser chamado depois de liberar todos os sons, músicas e streams
- O `CloseWindow` não fecha o áudio: se o programa chamou `InitAudioDevice`, precisa chamar `CloseAudioDevice` também

```c
UnloadMusicStream(trilha);
UnloadSound(pulo);
CloseAudioDevice();   // depois dos recursos de áudio
CloseWindow();
```

> A ordem segue a mesma regra de todos os recursos do raylib: primeiro os `Unload` dos recursos, depois o fechamento do sistema que os criou (ver `../../concepts/resource-lifetime.md`)
