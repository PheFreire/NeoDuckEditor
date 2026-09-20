**closedir**

> `dirent.h`

O `closedir` fecha um stream de diretório previamente aberto, liberando os recursos associados a ele

```c
#include <dirent.h>

int closedir(DIR *dirp);
```

- `dirp`: o stream de diretório a ser fechado

- Retorna `0` em caso de sucesso, ou `-1` em caso de erro
- Assim como um `fd` aberto com `open` precisa ser pareado com um `close`, todo `DIR *` aberto com `opendir` precisa ser pareado com um `closedir`

```c
closedir(dir);
```

