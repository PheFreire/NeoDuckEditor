**SetWindowTitle**

> `raylib.h` — módulo `rcore`

O `SetWindowTitle` troca o texto da barra de título da janela durante a execução. O título inicial é o passado ao `InitWindow`

```c
void SetWindowTitle(const char *title);
```

- `title`: o novo título, em UTF-8, terminado em `\0`

- Não devolve nada
- O texto é copiado pelo sistema de janelas, então o buffer pode ser reutilizado ou liberado depois da chamada

```c
SetWindowTitle(TextFormat("Meu Jogo - Fase %d", fase));

// marcar alterações não salvas, como em um editor
SetWindowTitle(alterado ? "editor - mapa.txt *" : "editor - mapa.txt");
```

---

**Armadilha: chamar todo frame**

```c
while (!WindowShouldClose()) {
  SetWindowTitle(TextFormat("FPS: %d", GetFPS()));   // funciona, mas pede ao sistema para redesenhar a barra todo frame
  /* ... */
}
```

- Trocar o título envolve uma chamada ao sistema operacional, que é lenta comparada ao desenho. Atualize só quando o valor mudar, ou algumas vezes por segundo

> O `TextFormat` devolve um buffer estático interno do raylib, o que é seguro aqui porque o título é copiado na hora (ver `../../text/functions/text-format.md`)
