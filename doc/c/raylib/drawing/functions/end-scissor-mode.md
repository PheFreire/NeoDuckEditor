**EndScissorMode**

> `raylib.h` — módulo `rcore`

O `EndScissorMode` desliga o corte iniciado pelo `BeginScissorMode`, voltando a permitir o desenho na tela inteira

```c
void EndScissorMode(void);
```

- Não recebe parâmetros e não devolve nada
- Envia à GPU o que foi desenhado dentro da área antes de desligar o corte

```c
BeginScissorMode(painel.x, painel.y, painel.width, painel.height);
  desenhar_conteudo_rolavel();
EndScissorMode();

desenhar_barra_de_rolagem();   // fora do corte: aparece normalmente
```

> Esquecer o `EndScissorMode` mantém o corte ativo para o resto do frame, e tudo desenhado depois (inclusive a interface) fica invisível fora da área. Se partes da tela "sumirem" sem motivo, procure um `BeginScissorMode` sem o par
