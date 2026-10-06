**TraceLog**

> `raylib.h` — módulo `rcore`

O `TraceLog` escreve uma mensagem de log com um nível de gravidade, usando o mesmo sistema de log do raylib. A mensagem é formatada como no `printf` e só aparece se o nível dela for igual ou mais grave que o nível mínimo definido com `SetTraceLogLevel`

```c
void TraceLog(int logLevel, const char *text, ...);
```

- `logLevel`: o nível da mensagem: `LOG_TRACE`, `LOG_DEBUG`, `LOG_INFO`, `LOG_WARNING`, `LOG_ERROR` ou `LOG_FATAL`
- `text`: o texto de formato, com os mesmos especificadores do `printf` (`%d`, `%f`, `%s`...)
- `...`: os valores para os especificadores

- Não devolve nada
- Adiciona o prefixo do nível (`INFO: `, `WARNING: `) e a quebra de linha automaticamente
- Com `LOG_FATAL`, depois de escrever a mensagem, o raylib encerra o programa com `exit(EXIT_FAILURE)`

```c
TraceLog(LOG_INFO, "fase %d carregada em %.2f s", fase, tempo);
TraceLog(LOG_WARNING, "save '%s' não encontrado, criando um novo", arquivo);
TraceLog(LOG_DEBUG, "jogador em (%.1f, %.1f)", pos.x, pos.y);

if (!FileExists("dados/mapa.txt")) {
  TraceLog(LOG_FATAL, "arquivo obrigatório não encontrado");   // encerra o programa
}
```

```text
INFO: fase 2 carregada em 0.34 s
WARNING: save 'slot1.dat' não encontrado, criando um novo
FATAL: arquivo obrigatório não encontrado
```

---

**Filtrando pelo nível**

```c
SetTraceLogLevel(LOG_DEBUG);     // durante o desenvolvimento: mostra até as mensagens de debug
SetTraceLogLevel(LOG_WARNING);   // versão final: só avisos e erros
```

- O nível padrão é `LOG_INFO`, então mensagens `LOG_DEBUG` não aparecem até que o nível seja reduzido
- O mesmo filtro vale para as mensagens internas do raylib e para as do programa

> Como o `LOG_FATAL` chama `exit`, as funções registradas com `atexit` rodam, mas os recursos não são liberados com os `Unload` correspondentes. Use-o só para erros sem recuperação. Ver `../logging.md` para redirecionar o log para um arquivo com `SetTraceLogCallback`
