**CloseWindow**

> `raylib.h` — módulo `rcore`

O `CloseWindow` fecha a janela e destrói o contexto OpenGL criado pelo `InitWindow`. Também libera a fonte padrão e os recursos internos do raylib. É a última função do raylib chamada pelo programa

```c
void CloseWindow(void);
```

- Não recebe parâmetros e não devolve nada
- Libera só o que o próprio raylib criou internamente. Texturas, sons, fontes e modelos carregados pelo programa precisam ser liberados com o `Unload` correspondente **antes** dele
- Não fecha o dispositivo de áudio: se o programa usou `InitAudioDevice`, chame `CloseAudioDevice` também

```c
Texture2D t = LoadTexture("jogador.png");
Sound s = LoadSound("pulo.wav");

/* game loop */

UnloadSound(s);        // primeiro os recursos
UnloadTexture(t);
CloseAudioDevice();    // depois os subsistemas
CloseWindow();         // por último a janela
```

---

**Ordem de finalização**

```text
Unload...()          precisa do contexto OpenGL ainda vivo
  │
  ▼
CloseAudioDevice()   se o áudio foi iniciado
  │
  ▼
CloseWindow()        destrói o contexto: depois dele, nenhuma função de GPU funciona
```

- Chamar `UnloadTexture` depois do `CloseWindow` tenta apagar uma textura de um contexto que não existe mais. O resultado depende do driver, de um aviso no log até um crash
- Quando o processo termina, o sistema operacional devolve toda a memória, inclusive a da GPU. Mesmo assim, liberar os recursos em ordem é importante em programas que recriam a janela ou trocam de fase sem fechar

> O `CloseWindow` não encerra o programa: depois dele o `main` continua normalmente. O `WindowShouldClose` apenas informa que o usuário quer sair, e é o programa que sai do game loop e chama o `CloseWindow` (ver `window-should-close.md`)
