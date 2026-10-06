**Logging**

> `raylib.h` — módulo `rcore`

O raylib escreve mensagens de log no terminal sobre tudo que faz: a criação da janela, a versão do OpenGL, cada textura carregada, avisos e erros. O mesmo sistema pode ser usado pelo programa com `TraceLog`, e o nível mínimo das mensagens mostradas é configurável com `SetTraceLogLevel`

```text
INFO: Initializing raylib 5.5
INFO: DISPLAY: Device initialized successfully
INFO: GL: OpenGL device information:
INFO:     > Version:  4.1 Metal - 88
INFO: TEXTURE: [ID 3] Texture loaded successfully (64x64 | R8G8B8A8 | 1 mipmaps)
WARNING: FILEIO: [sprite.png] Failed to open file
```

---

**Níveis**

| Nível | Uso |
|-------|-----|
| `LOG_ALL` | mostra tudo |
| `LOG_TRACE` | rastreamento interno, muito detalhado |
| `LOG_DEBUG` | depuração |
| `LOG_INFO` | informação normal (padrão do raylib a partir daqui) |
| `LOG_WARNING` | falhas recuperáveis, como um arquivo que não abriu |
| `LOG_ERROR` | falhas não recuperáveis |
| `LOG_FATAL` | erro fatal: o raylib encerra o programa com `exit(EXIT_FAILURE)` |
| `LOG_NONE` | não mostra nada |

- Os níveis são ordenados: definir um nível mínimo mostra ele e todos os mais graves

```c
SetTraceLogLevel(LOG_WARNING);   // só avisos, erros e fatais
SetTraceLogLevel(LOG_NONE);      // silencia o raylib (bom para versões finais)
```

- Chame o `SetTraceLogLevel` **antes** do `InitWindow` para silenciar também as mensagens da inicialização

---

**TraceLog no próprio programa**

```c
TraceLog(LOG_INFO, "jogador entrou na fase %d", fase);
TraceLog(LOG_WARNING, "save corrompido, usando valores padrão");
TraceLog(LOG_DEBUG, "pos = (%.1f, %.1f)", pos.x, pos.y);   // só aparece com nível LOG_DEBUG ou menor
```

- Usa o mesmo formato do `printf` e adiciona o prefixo do nível e a quebra de linha
- Mantém o mesmo filtro de nível do raylib, então o mesmo `SetTraceLogLevel` controla as mensagens dos dois (ver `functions/trace-log.md`)

---

**Redirecionando o log**

```c
#include <stdarg.h>
#include <stdio.h>

static void meu_log(int nivel, const char *texto, va_list args) {
  FILE *f = fopen("jogo.log", "a");
  if (!f) return;
  fprintf(f, "[%d] ", nivel);
  vfprintf(f, texto, args);
  fputc('\n', f);
  fclose(f);
}

SetTraceLogCallback(meu_log);   // a partir daqui todo log vai para jogo.log
```

- O callback recebe o nível, o texto de formato e os argumentos como `va_list`, que são repassados com `vfprintf` (ver `../../macros/variadic.md`)

> As mensagens de `WARNING` do raylib são a forma mais rápida de descobrir por que algo não aparece na tela: uma textura que não carregou, por exemplo, não derruba o programa, apenas gera um aviso no log e devolve uma textura com `id` igual a `0`
