**open**

O `open` é chamado quando um processo pede a abertura de um recurso, sendo responsável por preparar a `struct file` que vai representar aquela abertura

```c
int open(struct inode *inode, struct file *file);
```

- `inode`: a estrutura que representa o recurso em si dentro do sistema de arquivos, existindo uma única vez por recurso, independente de quantas vezes ele é aberto
- `file`: a estrutura que representa esta abertura específica do recurso, preenchida durante o `open`

- Uma nova `struct file` é criada a cada `open`, permitindo múltiplas aberturas independentes do mesmo recurso, cada uma com sua própria posição de cursor, por exemplo
- Retorna `0` em caso de sucesso, ou um código de erro negativo caso a abertura falhe

```c
int fd = open("/dev/meu_dispositivo", O_RDWR); // chamada feita em userspace
```
