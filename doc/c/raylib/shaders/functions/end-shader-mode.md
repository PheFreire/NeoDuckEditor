**EndShaderMode**

> `raylib.h` — módulo `rcore`

O `EndShaderMode` desativa o shader próprio e volta ao shader padrão do raylib para os desenhos seguintes

```c
void EndShaderMode(void);
```

- Não recebe parâmetros e não devolve nada
- Envia à GPU o que foi desenhado com o shader próprio antes de voltar ao padrão

```c
BeginShaderMode(desfoque);
  DrawTexture(fundo, 0, 0, WHITE);
EndShaderMode();

DrawTexture(heroi, x, y, WHITE);   // shader padrão: nítido sobre o fundo desfocado
```

> Esquecer o `EndShaderMode` faz tudo que vem depois no frame, inclusive a interface, ser desenhado com o efeito
