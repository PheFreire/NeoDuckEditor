**#error / #warning**

> diretiva do pré-processador, não precisa de nenhum header

O `#error` interrompe a compilação com uma mensagem sua quando o pré-processador chega até ele, e o `#warning` mostra uma mensagem de aviso mas deixa a compilação continuar, ambos normalmente usados dentro de um `#if` para checar configurações antes do código ser compilado

> Como o pré-processador apaga os trechos falsos de um `#if`, um `#error` só tem efeito quando está em um trecho que foi mantido. Dentro de um `#if` cuja condição é falsa, ele é apagado junto com o resto e nunca dispara

```c
#error mensagem
#warning mensagem
```

- `mensagem`: o texto exibido pelo compilador, que pode ou não estar entre aspas. Entre aspas é mais seguro, pois apóstrofos soltos podem confundir o pré-processador

- O `#error` faz parte do padrão C desde sempre e para a compilação imediatamente
- O `#warning` só entrou no padrão no C23, mas já era suportado pelo GCC e pelo Clang há muito tempo
- Com `-Werror`, um `#warning` também passa a interromper a compilação, como qualquer outro aviso

```sh
# saída do GCC (o Clang mostra o mesmo, sem repetir o "#error" / "#warning")
main.c:3:2: error: #error "sistema operacional não suportado"
main.c:7:2: warning: #warning "modo debug ativado" [-Wcpp]
```

---

**Plataforma não suportada**

```c
#if defined(__linux__)
#include <sys/epoll.h>
#elif defined(__APPLE__)
#include <sys/event.h>
#else
#error "sistema operacional não suportado"
#endif
```

---

**Configuração obrigatória**

```c
#ifndef TAMANHO_BUFFER
#error "defina TAMANHO_BUFFER, por exemplo com -DTAMANHO_BUFFER=1024"
#endif
```

---

**Valores inválidos**

```c
#define NIVEL_LOG 5

#if NIVEL_LOG < 0 || NIVEL_LOG > 3
#error "NIVEL_LOG precisa estar entre 0 e 3"
#endif
```

---

**Versão mínima do C**

```c
#if !defined(__STDC_VERSION__) || __STDC_VERSION__ < 201112L
#error "este projeto precisa de C11 ou mais recente (-std=c11)"
#endif
```

---

**Lembrete durante o desenvolvimento**

```c
#ifdef DEBUG
#warning "compilando em modo debug, não usar em produção"
#endif
```

> Diferente do `static_assert` (em `assert.md`), que roda na compilação e consegue checar coisas como `sizeof(int) == 4`, o `#error` roda no pré-processamento e só enxerga macros e números. Para validar configurações e plataforma use `#error`, e para validar tamanhos de tipos e structs use `static_assert`
