**close**

O `close` é a chamada de sistema feita em userspace para fechar um fd, sendo o gatilho que faz o kernel executar a operação `release` da `file_operations` daquele objeto quando não sobra mais nenhuma referência a ele

```c
int close(int fd);
```

- `fd`: o descritor de arquivo a ser fechado

- Retorna `0` em caso de sucesso, ou `-1` em caso de erro, por exemplo se `fd` não for um descritor válido
- Depois de fechado, aquele número de `fd` fica livre e pode ser reaproveitado pela próxima chamada a `open` que precisar do menor descritor disponível
- Se o mesmo fd tiver sido duplicado (`dup`) e compartilhado por outro processo ou outra parte do programa, `close` apenas remove esta referência específica; o `release` só roda quando a última referência de fato é fechada

```c
int fd = open("/dev/meu_dispositivo", O_RDWR);
// ... usa o fd ...
close(fd); // dispara release() no kernel quando é a última referência
```

> Assim como o `fopen` precisa ser pareado com um `fclose`, todo `fd` aberto com `open` precisa ser pareado com um `close`, evitando deixar descritores presos e ocupando espaço na tabela de FDs do processo
