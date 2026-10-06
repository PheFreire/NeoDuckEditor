**IsWindowReady**

> `raylib.h` — módulo `rcore`

O `IsWindowReady` verifica se a janela e o contexto OpenGL foram criados com sucesso pelo `InitWindow`. Como o `InitWindow` não devolve nenhum valor, esta é a forma de detectar uma falha na inicialização

```c
bool IsWindowReady(void);
```

- Devolve `true` se o `InitWindow` funcionou, e `false` se ainda não foi chamado ou falhou

```c
InitWindow(800, 450, "jogo");
if (!IsWindowReady()) {
  TraceLog(LOG_ERROR, "não foi possível criar a janela");
  return 1;
}
```

---

**Quando o InitWindow falha**

- Sem servidor gráfico: rodando por SSH sem `DISPLAY` (Linux), ou em um container sem acesso à tela
- Driver gráfico sem suporte à versão do OpenGL que o raylib precisa (OpenGL 3.3 por padrão no desktop)
- Flags pedindo algo que a placa não oferece, como `FLAG_MSAA_4X_HINT` em hardware muito antigo

> O motivo da falha aparece no log do raylib, logo depois da tentativa de criar a janela (ver `../logging.md`). Verificar o `IsWindowReady` evita que o programa continue e quebre mais tarde, ao carregar a primeira textura
