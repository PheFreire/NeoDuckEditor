**close**

> `unistd.h`

O `close`, aplicado a um socket, encerra e libera o descritor de arquivo associado à conexão, permitindo que o sistema recupere os recursos usados por ela

```c
#include <unistd.h>

int close(int fd);
```

- `fd`: o descritor do socket a ser fechado

- Retorna `0` em caso de sucesso, ou `-1` em caso de erro
- Sobre um socket TCP, dispara o processo de encerramento da conexão (o *handshake* de finalização), mas só libera de fato os recursos quando não existir mais nenhuma referência ao mesmo `fd`, caso ele tenha sido duplicado e compartilhado
- É a forma padrão de encerrar tanto o socket de uma conexão individual (retornado por `accept` ou criado com `connect`) quanto o socket em modo escuta usado pelo servidor

```c
close(client_fd);
close(server_fd);
```

