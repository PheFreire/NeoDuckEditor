**release**

O `release` é chamado quando a última referência a uma abertura é fechada, liberando os recursos associados a ela

```c
int release(struct inode *inode, struct file *file);
```

- Corresponde à chamada de sistema `close(fd)` feita em userspace, sendo o `close()` no comentário do código-fonte
- Só roda quando não sobra mais nenhuma referência àquela `struct file`, já que um mesmo fd pode ser duplicado (`dup`) e compartilhado por mais de um processo

```c
close(fd); // chamada feita em userspace, dispara release() no kernel
```
