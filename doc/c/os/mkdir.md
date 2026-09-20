**mkdir**

> `sys/stat.h`

O `mkdir` cria um novo diretório no caminho informado

```c
#include <sys/stat.h>

int mkdir(const char *pathname, mode_t mode);
```

- `pathname`: o caminho do novo diretório a ser criado
- `mode`: as permissões do diretório (por exemplo `0755`), sujeitas à `umask` do processo, que pode restringir ainda mais o resultado final

- Retorna `0` em caso de sucesso, ou `-1` em caso de erro, por exemplo se o diretório já existir ou se o diretório pai não existir
- Não cria diretórios intermediários automaticamente; se algum nível do caminho pai não existir, a chamada falha, sendo necessário criar cada nível manualmente

```c
mkdir("nova_pasta", 0755);
```
