**IsAudioDeviceReady**

> `raylib.h` — módulo `raudio`

O `IsAudioDeviceReady` verifica se o `InitAudioDevice` conseguiu abrir o dispositivo de áudio

```c
bool IsAudioDeviceReady(void);
```

- Devolve `true` se o áudio está pronto, e `false` se ainda não foi iniciado ou falhou

```c
InitAudioDevice();
bool tem_audio = IsAudioDeviceReady();
if (!tem_audio) {
  TraceLog(LOG_WARNING, "áudio indisponível, o jogo vai rodar sem som");
}
```

> Sem dispositivo (máquina sem placa de som, servidor, alguns containers), as funções de áudio não derrubam o programa, mas também não tocam nada. Com essa verificação, o jogo pode, por exemplo, esconder as opções de volume
