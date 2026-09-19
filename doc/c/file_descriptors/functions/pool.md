**poll**

O `poll` verifica se o objeto I/O está pronto para leitura, escrita ou algum outro evento, sem bloquear o processo esperando

```c
__poll_t poll(struct file *file, struct poll_table_struct *wait);
```

- `file`: a estrutura interna do kernel que representa aquela abertura do objeto
- `wait`: a estrutura usada para registrar o processo em uma fila de espera, caso ele precise ser notificado quando o recurso ficar pronto

- Retorna uma máscara de bits indicando quais operações estão disponíveis no momento, por exemplo pronto para leitura ou pronto para escrita
- É a base por trás de chamadas como `poll` e `select` feitas em userspace, usadas para monitorar vários fds ao mesmo tempo sem precisar ficar chamando `read` repetidamente

```c
struct pollfd pfd = { .fd = fd, .events = POLLIN };
poll(&pfd, 1, -1); // chamada feita em userspace, espera o fd ficar pronto para leitura
```
