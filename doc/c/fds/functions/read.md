**read**

O `read` é chamado quando o processo pede a leitura de dados de um objeto I/O, sendo responsável por copiar bytes do kernel para o buffer fornecido pelo processo

```c
ssize_t read(struct file *file, char __user *buf, size_t count, loff_t *offset);
```

- `file`: a estrutura interna do kernel que representa aquela abertura do objeto
- `buf`: o buffer em espaço de usuário (`__user`) para onde os dados lidos serão copiados
- `count`: quantos bytes o processo pediu para ler
- `offset`: ponteiro para a posição atual de leitura, atualizado pela própria função conforme os bytes são consumidos

- Retorna quantos bytes foram de fato lidos, podendo ser menor que `count`
- É essa função que roda no kernel por trás da chamada de sistema `read(fd, buffer, tamanho)` feita em userspace

```c
char buffer[100];
ssize_t lidos = read(fd, buffer, 100); // chamada feita em userspace
```

