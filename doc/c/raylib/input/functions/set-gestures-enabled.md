**SetGesturesEnabled**

> `raylib.h` — módulo `rgestures`

O `SetGesturesEnabled` define quais gestos o raylib deve reconhecer. Os gestos não habilitados são ignorados, o que evita que um movimento seja confundido com outro

```c
void SetGesturesEnabled(unsigned int flags);
```

- `flags`: os gestos habilitados, combinados com `|`, como `GESTURE_TAP | GESTURE_DRAG`

- Não devolve nada
- Por padrão, todos os gestos estão habilitados
- Substitui a configuração anterior por completo (não soma)

```c
// visualizador de imagens: tocar, arrastar e pinça
SetGesturesEnabled(GESTURE_TAP | GESTURE_DOUBLETAP | GESTURE_DRAG |
                   GESTURE_PINCH_IN | GESTURE_PINCH_OUT);
```

---

**Por que limitar os gestos**

- Um arraste rápido pode ser reconhecido como swipe, e um toque demorado como hold. Desabilitar o que não é usado deixa o reconhecimento mais previsível
- O `GESTURE_DOUBLETAP` faz o primeiro toque esperar um pouco para saber se virá um segundo. Se o jogo não usa toque duplo, desabilitá-lo deixa o `GESTURE_TAP` mais responsivo

> Os valores de gesto são bits (`1`, `2`, `4`, `8`...), por isso podem ser combinados com `|` em um único inteiro, a mesma ideia das flags de janela e do `termios` (ver `../gestures.md`)
