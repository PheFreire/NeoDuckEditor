**sendfile**

O `sendfile` transfere dados diretamente entre dois fds já abertos, sem precisar copiar os bytes para um buffer em espaço de usuário no meio do caminho

```c
ssize_t sendfile(struct file *out_file, loff_t *offset, size_t count, read_actor_t actor, void *target);
```

- Evita o caminho tradicional de `read` (kernel para buffer em userspace) seguido de `write` (buffer em userspace para kernel), copiando os dados diretamente dentro do próprio kernel
- Muito usado para servir arquivos estáticos em servidores web, onde os dados só precisam sair de um arquivo em disco e ir para um socket de rede

```c
sendfile(fd_destino, fd_origem, NULL, tamanho); // chamada feita em userspace
```
