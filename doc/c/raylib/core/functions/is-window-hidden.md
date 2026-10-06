**IsWindowHidden**

> `raylib.h` — módulo `rcore`

O `IsWindowHidden` verifica se a janela está escondida, ou seja, existe mas não aparece na tela nem na barra de tarefas. A janela fica escondida com a flag `FLAG_WINDOW_HIDDEN`

```c
bool IsWindowHidden(void);
```

- Devolve `true` se a janela está escondida, e `false` se está visível (mesmo que minimizada)
- Escondida é diferente de minimizada: a minimizada aparece na barra de tarefas e pode ser restaurada pelo usuário, a escondida só pelo programa

```c
SetConfigFlags(FLAG_WINDOW_HIDDEN);   // cria a janela já escondida
InitWindow(800, 450, "jogo");

carregar_tudo();                      // carrega sem mostrar uma janela vazia
ClearWindowState(FLAG_WINDOW_HIDDEN); // mostra só quando estiver pronto
```

---

**Usos comuns**

- Esconder a janela enquanto os recursos carregam, evitando uma janela preta ou piscando
- Programas que só usam o raylib para gerar imagens (renderizar em uma render texture e exportar com `ExportImage`), sem precisar mostrar nada
- Testes automatizados que precisam do contexto OpenGL, mas não de uma janela visível

> Com a janela escondida, o desenho continua funcionando, mas não aparece. O `SetWindowState(FLAG_WINDOW_HIDDEN)` esconde e o `ClearWindowState(FLAG_WINDOW_HIDDEN)` mostra de novo (ver `set-window-state.md`)
