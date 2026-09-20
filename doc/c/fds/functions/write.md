**write**

O `write` é chamado quando o processo pede a escrita de dados em um objeto I/O, sendo responsável por copiar bytes do buffer fornecido pelo processo para dentro do kernel/dispositivo

```c
ssize_t write(struct file *file, const char __user *buf, size_t count, loff_t *offset);
```

- `file`: a estrutura interna do kernel que representa aquela abertura do objeto
- `buf`: o buffer em espaço de usuário com os dados a serem escritos, `const` porque a função só lê dele
- `count`: quantos bytes o processo pediu para escrever
- `offset`: ponteiro para a posição atual de escrita, atualizado pela própria função

- Retorna quantos bytes foram de fato escritos, podendo ser menor que `count`
- É essa função que roda no kernel por trás da chamada de sistema `write(fd, buffer, tamanho)` feita em userspace

```c
const char *msg = "ola\n";
write(fd, msg, 4); // chamada feita em userspace
```
