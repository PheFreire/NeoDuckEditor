**system**

> `stdlib.h`

O `system` executa um comando no shell do sistema operacional, bloqueando o processo atual até o comando terminar

```c
#include <stdlib.h>

int system(const char *command);
```

- `command`: a string do comando a ser executado pelo shell (`/bin/sh` no Linux)

- Retorna o status de saída do comando (dependente da implementação, geralmente combinando o código de saída do shell), ou um valor indicando falha caso o shell não possa ser executado
- Se `command` for `NULL`, retorna um valor diferente de zero caso um shell esteja disponível no sistema, sem executar nada
- Deve ser usado com cautela quando o comando envolve entrada externa não confiável, pois monta uma string interpretada pelo shell, abrindo espaço para injeção de comandos

```c
system("ls -la");
```

