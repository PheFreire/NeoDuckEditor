**UnloadMusicStream**

> `raylib.h` — módulo `raudio`

O `UnloadMusicStream` para uma música, fecha o arquivo e libera o decodificador e os buffers

```c
void UnloadMusicStream(Music music);
```

- `music`: a música a liberar

- Não devolve nada
- Deve ser chamado antes do `CloseAudioDevice`

```c
// trocar a música ao mudar de fase
StopMusicStream(atual);
UnloadMusicStream(atual);
atual = LoadMusicStream(TextFormat("musica/fase%d.ogg", fase));
PlayMusicStream(atual);
```

> Cada `Music` carregada mantém um arquivo aberto e um decodificador ativo. Esquecer de liberar a antiga a cada troca de fase acumula arquivos abertos e memória até o fim do programa
