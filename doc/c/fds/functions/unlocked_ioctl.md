**unlocked_ioctl**

O `unlocked_ioctl` executa comandos customizados sobre o objeto I/O, usado para operações que não se encaixam em `read`/`write` e que costumam ser específicas de um driver

```c
long unlocked_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
```

- `file`: a estrutura interna do kernel que representa aquela abertura do objeto
- `cmd`: o número do comando a ser executado, definido pelo driver
- `arg`: um argumento genérico para o comando, podendo ser um valor direto ou um ponteiro para dados em userspace, dependendo do que o driver espera

- `unlocked` no nome indica que essa versão não segura automaticamente um lock global do kernel antes de chamar a função, diferente de uma versão antiga já removida
- Cada driver define seus próprios comandos e o significado de `arg` para cada um deles

```c
ioctl(fd, COMANDO, argumento); // chamada feita em userspace
```
