**Dispositivo de áudio**

> `raylib.h` — módulo `raudio`

O dispositivo de áudio é a conexão do programa com a placa de som do sistema. O `InitAudioDevice` abre essa conexão e inicia a thread que mistura todos os sons tocando e os entrega ao sistema operacional. Sem ele, nenhum som pode ser carregado nem tocado

```c
void InitAudioDevice(void);
void CloseAudioDevice(void);
bool IsAudioDeviceReady(void);
void SetMasterVolume(float volume);
float GetMasterVolume(void);
```

```c
InitWindow(800, 450, "jogo");
InitAudioDevice();

if (!IsAudioDeviceReady()) {
  TraceLog(LOG_WARNING, "sem áudio: o jogo continua mudo");
}

/* carregar sons, game loop */

CloseAudioDevice();
CloseWindow();
```

---

**O que acontece por baixo**

```text
InitAudioDevice()
  │  abre o dispositivo de saída padrão do sistema (via miniaudio)
  ▼
  │  cria o mixer e a thread de áudio
  ▼
thread de áudio (a cada poucos milissegundos)
  │  pede amostras de cada Sound/Music/AudioStream tocando
  │  aplica volume, pitch e pan de cada um
  │  soma tudo (mixagem) e aplica o volume master
  ▼
placa de som
```

- O game loop e a thread de áudio rodam em paralelo: o som continua tocando enquanto o jogo desenha
- O mixer trabalha em uma taxa fixa (normalmente 44100 ou 48000 amostras por segundo), e os sons com outras taxas são convertidos

---

**Ordem**

- O `InitAudioDevice` é independente da janela: pode vir antes ou depois do `InitWindow`
- Sons e músicas só podem ser carregados **depois** do `InitAudioDevice`
- Libere todos os sons e músicas antes do `CloseAudioDevice`

> Se não houver placa de som (servidor, container, máquina virtual), o `InitAudioDevice` falha com um aviso, e as funções de som passam a não fazer nada. Verificar o `IsAudioDeviceReady` permite ao jogo continuar normalmente sem áudio
