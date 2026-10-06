**ShowCursor**

> `raylib.h` — módulo `rcore`

O `ShowCursor` torna o cursor do mouse visível de novo depois de um `HideCursor`

```c
void ShowCursor(void);
```

- Não recebe parâmetros e não devolve nada
- Só desfaz o `HideCursor`. Se o cursor foi travado com `DisableCursor`, use `EnableCursor`, que também destrava

```c
if (menu_aberto) {
  ShowCursor();   // mostra o ponteiro do sistema no menu
} else {
  HideCursor();   // esconde durante o jogo, que desenha a própria mira
}
```

> Chamar o `ShowCursor` todo frame é inofensivo, mas também desnecessário. Prefira chamar só quando o estado muda, como ao abrir ou fechar um menu (ver `../cursor.md`)
